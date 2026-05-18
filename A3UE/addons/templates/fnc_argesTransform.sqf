// GFL Arges — server: TDoll → Arges_F body swap.
//
// Identity bundle stored on Arges (GFL_ArgesIdentity array):
//   [0] unitType      — A3A respawn target class
//   [1] A3A_playerUID — A3A identity key
//   [2] moneyX        — economy balance at transform time
//   [3] ownerID       — machine ID for remoteExec routing
//   [4] prevOutfit    — TDoll uniform worn before GFL_ArgesFrame was equipped
//
// TDoll is NOT deleted. deleteVehicle triggers A3A's keepup loop.
// It is stashed underground (hidden, sim-disabled) and cleaned up on revert or death.

if (!isServer) exitWith {};
params ["_player", ["_prevOutfit", ""]];

if (isNull _player || !alive _player)                          exitWith {};
if (typeOf _player == "Arges_F")                               exitWith {};
if (_player getVariable ["GFL_ArgesState", "NONE"] != "NONE")  exitWith {};
if !(isClass (configFile >> "CfgVehicles" >> "Arges_F"))       exitWith {};

// Lock immediately — broadcast so the client PFH stops monitoring on the next tick
_player setVariable ["GFL_ArgesState", "ARGES", true];

private _pos   = getPosATL _player;
private _dir   = getDir _player;
private _grp   = group _player;
private _owner = owner _player;

private _identity = [
    _player getVariable ["unitType",      typeOf _player],
    _player getVariable ["A3A_playerUID", getPlayerUID _player],
    _player getVariable ["moneyX",        0],
    _owner,
    _prevOutfit
];

// Spawn Arges_F into the player's existing group (preserves radio net, HC display)
private _arges = _grp createUnit ["Arges_F", _pos, [], 0, "NONE"];
_arges setDir _dir;
_arges setPosATL _pos;
_arges setName (name _player);

// allowDamage false: take the engine out of the damage loop entirely. With this,
// HandleDamage never fires and engine hitpoints can't accumulate to 1.0 (no instakill).
// The HitPart EH (registered later, fires regardless of allowDamage) drains the
// GFL_ArgesHP pool and triggers death when HP reaches 0.
// The 1 s PFH below flips allowDamage to true while COR_SysEnabled is active so
// Corvus's wound chain (which requires HD) can run.
_arges allowDamage false;

// Aegis combat buffs — applied immediately on the server and maintained on the client.
// These run regardless of whether the player activates Corvus (Corvus's own SysInit PFH
// will overwrite them when active, which is fine — both set the same values).
_arges enableStamina false;
_arges setAnimSpeedCoef 1.4;
_arges setUnitRecoilCoefficient 0.1;
_arges setCustomAimCoef 0.05;

// TacGirls' config EventHandlers.init fires automatically on createUnit and runs
// hitboxinit.sqf — no explicit call needed. Aegis_Hitbox is an abstract class
// (scope=private, no model) so createVehicle inside that script will fail regardless;
// that is a TacGirls limitation outside our control.

_arges setVariable ["GFL_ArgesState",    "ARGES",   true];
_arges setVariable ["GFL_ArgesIdentity", _identity, true];
_arges setVariable ["GFL_OldBody",       _player,   true];
_arges setVariable ["GFL_PlayerOwner",   _owner,    true];

// A3A identity: all gates (flag, garage, map, store) and respawn read these.
// unitType MUST remain the lobby/TDoll class — A3A's PlayerKilled EH reads it to create
// the respawn unit. If it were "Arges_F" A3A would spawn a fresh Arges_F at the respawn
// point with authority still attached. Interaction objects check isPlayer + owner + side
// group, none of which involve unitType, so keeping TDoll class here is invisible to them.
_arges setVariable ["unitType",      _identity # 0,                          true];
_arges setVariable ["A3A_playerUID", _identity # 1,                          true];
_arges setVariable ["moneyX",        _identity # 2,                          true];
_arges setVariable ["owner",         _arges,                                  true];
_arges setVariable ["eligible",      _player getVariable ["eligible", false], true];

// Aegis combat profile — custom HP pool (replaces Arma's default hitpoints).
// GFL_ArgesKilling: re-entrancy guard — lets our own setDamage 1 call through unchanged.
// GFL_ArgesFainting: burst guard — prevents multiple HandleDamage callbacks in the same
//   physics tick (full-auto burst) all entering the faint path simultaneously.
_arges setVariable ["GFL_ArgesHP",              1500,  true];
_arges setVariable ["GFL_ArgesKilling",         false, true];
_arges setVariable ["GFL_ArgesFainting",        false, true];
_arges setVariable ["GFL_COR_OverrideApplied",  false, true];

// --- Loadout ---
private _dl = getUnitLoadout _player;
private _al = getUnitLoadout _arges;

_al set [0, _dl # 0]; // primary weapon
_al set [1, _dl # 1]; // secondary weapon
_al set [2, _dl # 2]; // handgun
_al set [8, _dl # 8]; // assigned items (NVG, map, radio, GPS)

// Uniform: keep Arges skeleton class, graft TDoll's pocket contents
private _au = _al # 3;
private _du = _dl # 3;
if (!(_au isEqualTo []) && !(_du isEqualTo [])) then {
    _al set [3, [_au # 0, _du # 1]];
};

// Vest + backpack: full container (class + items)
{ if !(_dl # _x isEqualTo []) then { _al set [_x, _dl # _x]; }; } forEach [4, 5];

_arges setUnitLoadout _al;

// Disable TacGirls' 10-shot kill trigger (AE_Health = 100, -10 per rifle shot → setDamage 1).
// We maintain AE_Health = 9999 here (server broadcast) and in the client PFH every 1 s
// so hitboxinit.sqf's async client-side reset to 100 can never accumulate to a kill.
// Our GFL_ArgesHP pool via HandleDamage is the sole death path.
_arges setVariable ["AE_Health", 9999, true];

// Fallback: if Arges_F class restrictions rejected a container, recover items via addItem
{
    _x params ["_slot", "_checkFn"];
    if (!(_slot isEqualTo []) && { call _checkFn isEqualTo [] }) then {
        { _arges addItem (if (_x isEqualType "") then { _x } else { _x # 0 }); } forEach (_slot # 1);
    };
} forEach [
    [_dl # 4, { vestItems     _arges }],
    [_dl # 5, { backpackItems _arges }]
];

// --- Aegis damage filter ---
// HandleDamage is registered via direct addEventHandler below. The CBA XEH approach
// (Extended_HandleDamage_EventHandlers) was tried twice with both Arges_F and CAManBase
// inner classes — neither fired in RPT, so we use direct registration which is proven
// to work (the original inline filter ran fine).
//
// _damageFilter is a thin wrapper that delegates to the global GFL_fnc_argesDamageFilter.
// That global function is the single source of truth for the filter logic.
//
// Chain ordering: addEventHandler appends to the end of the EH list, so registering
// after createUnit puts our EH AFTER ACE's XEH-registered EH. Engine fires EHs in
// registration order; the LAST EH's return value wins. We return 0 → engine applies 0.
private _damageFilter = { _this call GFL_fnc_argesDamageFilter };

// Server-side registration — covers the window between createUnit and selectPlayer.
// HandleDamage only fires on the locality owner. _arges is server-local until
// selectPlayer transfers it to the client, so the server EH catches any hits
// in that window (and on the server's hidden copy after selectPlayer).
_arges addEventHandler ["HandleDamage", _damageFilter];

// --- Authority ---
if (leader _grp == _player) then { _grp selectLeader _arges; };

if (!isNil "theBoss" && { _player == theBoss } && { !isNil "A3A_fnc_theBossTransfer" }) then {
    [_arges, true] call A3A_fnc_theBossTransfer;
    diag_log "[GFL Arges] HC command transferred to Arges";
};

// --- Switch ---
[_arges] remoteExec ["selectPlayer", _owner];

// Zeus: reassigned on client after selectPlayer settles (1.5 s headroom)
// No unassign needed — old unit becomes AI underground and cannot use Zeus UI
[{ { player assignCurator _x } forEach allCurators; }, [], 1.5] remoteExec ["CBA_fnc_waitAndExecute", _owner];

// Client-side EHs + revert action; 2 s guarantees player == _arges and locality has
// transferred from server to client before we register HandleDamage / Killed EHs.
[{
    params ["_arges", "_damageFilter"];

    // Default state on client: allowDamage false (non-Corvus, engine cannot damage).
    // The 1 s PFH below flips this to true if/when the player activates Corvus.
    // TacGirls' hitboxinit may flip this around — our PFH wins within 1 s.
    _arges allowDamage false;
    _arges enableStamina false;
    _arges setAnimSpeedCoef 1.4;
    _arges setUnitRecoilCoefficient 0.1;
    _arges setCustomAimCoef 0.05;

    // Slip-through monitor: runs every 0.25 s in BOTH Corvus and non-Corvus mode.
    // Last RPT showed our HD return is being overridden by something later in the
    // chain (dmgApplied matched _damage at entry exactly, way above 1.0 → instakill).
    // The HD-refresh PFH above tries to keep us last every 0.1 s, but if a hit lands
    // in a refresh-window race, damage accumulates beyond 1.0 before the next refresh.
    // This PFH catches that: if damage > 0 after a tick, reset to 0 + fullHeal.
    // Caveat: setDamage 0 can't revive a unit whose damage reached 1.0 in the same
    // physics tick (Killed EH fires synchronously). But for sub-lethal accumulation
    // this catches it before the next hit pushes past 1.0.
    [{
        params ["_args", "_handle"];
        private _arges = _args select 0;
        if (!alive _arges || _arges getVariable ["GFL_ArgesState", "NONE"] != "ARGES") exitWith {
            [_handle] call CBA_fnc_removePerFrameHandler;
        };
        // Skip when in killing-Arges flow (we WANT damage to apply for clean death)
        if (_arges getVariable ["GFL_ArgesKilling", false]) exitWith {};
        if (_arges getVariable ["GFL_ArgesFainting", false]) exitWith {};

        // Re-enforce allowDamage state every 0.25 s (in addition to the 1 s PFH).
        // Some external script (TacGirls hitboxinit, ACE Medical setUnconscious, etc.) may
        // flip allowDamage; this catches it within 250 ms instead of 1 s.
        private _corOn = _arges getVariable ["COR_SysEnabled", false];
        private _wantAllow = _corOn;  // true only when Corvus is active
        private _curAllow = isDamageAllowed _arges;
        if (_curAllow != _wantAllow) then {
            _arges allowDamage _wantAllow;
            diag_log format ["[GFL Diag] allowDamage flipped to %1 (was %2, COR=%3)", _wantAllow, _curAllow, _corOn];
        };

        private _slipped = damage _arges;
        private _filterCalls = _arges getVariable ["GFL_DiagFilterCalls", 0];
        _arges setVariable ["GFL_DiagFilterCalls", 0];
        if (_slipped > 0) then {
            _arges setDamage 0;
            if (!isNil "ace_medical_fnc_fullHeal") then { _arges call ace_medical_fnc_fullHeal; };
            private _mode = if (_corOn) then { "Corvus" } else { "non-Corvus" };
            diag_log format ["[GFL Arges] %1 slip-through suppressed: dmg was %2 (filterCalls=%3)", _mode, _slipped, _filterCalls];
        } else {
            if (_filterCalls > 0) then {
                diag_log format ["[GFL Diag] Tick: %1 filter calls, no slip-through", _filterCalls];
            };
        };
    }, 0.25, [_arges]] call CBA_fnc_addPerFrameHandler;

    // Every 1 s: maintain AE_Health sentinel + Aegis combat buffs + allowDamage.
    // AE_Health guards TacGirls' 10-shot kill trigger (hitboxinit.sqf async-resets it to 100;
    // we keep it at 9999 so the running tally never reaches the kill threshold of 0).
    // allowDamage true: TacGirls' hitboxinit async init can flip this to false; without it
    // HandleDamage never fires and the engine applies raw damage.
    [{
        params ["_args", "_handle"];
        private _arges = _args select 0;
        if (!alive _arges || _arges getVariable ["GFL_ArgesState", "NONE"] != "ARGES") exitWith {
            [_handle] call CBA_fnc_removePerFrameHandler;
        };

        // allowDamage toggle: drives the entire damage model.
        //   Corvus active   → allowDamage true:  HD fires → ACE wound chain runs →
        //                     Corvus's COR_fnc_damage processes hit (drains armor/coolant).
        //                     Death only via COR_Shutdown (heat/coolant=0).
        //   Corvus inactive → allowDamage false: HD cannot fire, engine cannot apply damage.
        //                     HitPart EH (still fires) drains GFL_ArgesHP.
        //                     Death only when HP pool reaches 0.
        // The killing flow flips allowDamage back to true momentarily so setDamage 1 sticks.
        if (_arges getVariable ["GFL_ArgesKilling", false]) then {
            _arges allowDamage true;
        } else {
            if (_arges getVariable ["COR_SysEnabled", false]) then {
                _arges allowDamage true;
            } else {
                _arges allowDamage false;
            };
        };

        _arges setVariable ["AE_Health", 9999, true];
        _arges enableStamina false;
        _arges setAnimSpeedCoef 1.4;
        _arges setUnitRecoilCoefficient 0.1;
        _arges setCustomAimCoef 0.05;
    }, 1, [_arges]] call CBA_fnc_addPerFrameHandler;

    // Every 0.25 s: handle Corvus-specific lifecycle.
    // Two jobs: (1) apply stat overrides once when player activates Corvus; (2) detect
    // Corvus heat-shutdown and redirect to TDoll before the player can hit respawn UI.
    [{
        params ["_args", "_handle"];
        private _arges = _args select 0;
        if (!alive _arges || _arges getVariable ["GFL_ArgesState", "NONE"] != "ARGES") exitWith {
            [_handle] call CBA_fnc_removePerFrameHandler;
        };

        // Job 1 — Corvus override: runs every tick while Corvus is active.
        //
        // Armor boost (+1200): applied once on first activation; COR_FrameArmor updated so
        // DoFluidLoss's bleed-rate math uses the boosted max as its reference.
        //
        // Coolant maintenance: run every tick because the "Coolant Capacity +" module writes
        // absolute values (6000 on Add, 5000 on Remove) which would silently overwrite our
        // base. We treat Arges's 8000 as the floor and add the module's +1000 bonus on top
        // when active — same additive logic as the module, applied continuously.
        //   No module:          COR_MaxCoolant = 8000
        //   Coolant Capacity +: COR_MaxCoolant = 9000  (8000 + 1000 module delta)
        if (_arges getVariable ["COR_SysEnabled", false]) then {
            // Armor: one-shot on first activation.
            // IMPORTANT: Do NOT boost COR_FrameArmor — the Corvus fluid-loss system scales
            // coolant drain proportionally to FrameArmor.  Boosting 500→1700 (×3.4) cuts the
            // natural ~55 s lifespan down to ~16 s.  Instead we only boost COR_ArmorValues
            // (per-hitbox incoming-damage reduction), which has no effect on drain rate.
            if (!(_arges getVariable ["GFL_COR_OverrideApplied", false])) then {
                _arges setVariable ["GFL_COR_OverrideApplied", true];
                private _base = _arges getVariable ["COR_FrameArmor", 200];
                private _arm  = _arges getVariable ["COR_ArmorValues", createHashMap];
                { _arm set [_x, (_arm getOrDefault [_x, _base]) + 1200]; } forEach (keys _arm);
                _arges setVariable ["COR_ArmorValues", _arm, true];
                // Fill coolant to Arges base on activation (Corvus default is 5000)
                private _initMax = if (_arges getVariable ["COR_CoolCap+", false]) then { 9000 } else { 8000 };
                _arges setVariable ["COR_MaxCoolant",    _initMax, true];
                _arges setVariable ["COR_CoolantVolume", _initMax, true];
                diag_log format ["[GFL Arges] Corvus override: frameArmor unchanged (%1), armorValues +1200, coolant %2", _base, _initMax];
            };
            // Coolant maintenance: every tick keep the CAP at Arges floor (so module
            // absolute-value writes don't shrink it), but let the VOLUME drain naturally.
            // Drain → fluid loss → COR_Shutdown via Corvus's normal mechanism, which we
            // catch via the COR_Shutdown redirect below (Job 2) and hand control back to TDoll.
            private _targetMax = if (_arges getVariable ["COR_CoolCap+", false]) then { 9000 } else { 8000 };
            _arges setVariable ["COR_MaxCoolant", _targetMax, true];
            // (removed: COR_CoolantVolume reset — coolant must be allowed to drain so
            //  Corvus can shut down naturally and the redirect path triggers death.)

            // Heat handling: let heat rise naturally so the user has feedback that the
            // system is overheating, but pre-empt fn_heating's setDamage 1 at 110°C by
            // triggering COR_Shutdown ourselves when heat passes 100°C. Job 2 below
            // catches the shutdown and redirects control to TDoll (clean death path).
            //
            // We still clamp staticHeating to 1 so module count doesn't cause runaway
            // heat — keeps the curve gentle enough that the user can react before death.
            _arges setVariable ["COR_staticHeating", 1, true];
            private _heat = _arges getVariable ["COR_Heat", 30];
            if (_heat >= 100 && !(_arges getVariable ["COR_Shutdown", false])) then {
                diag_log format ["[GFL Arges] Heat threshold reached (%1°C) — triggering COR_Shutdown", _heat];
                _arges setVariable ["COR_Shutdown", true, true];
            };
            // Diagnostic: log vitals every 0.25 s. Includes AE_Health, ACE medical state,
            // and lifeState so we can correlate "Killed" events with non-engine-damage paths
            // (TacGirls AE_Health setDamage 1, ACE setDead, unconscious-to-dead transitions).
            diag_log format ["[GFL Arges] Corvus vitals: coolant=%1/%2 heat=%3 shutdown=%4 dmg=%5 AE_H=%6 aceDead=%7 lifeState=%8 alive=%9",
                _arges getVariable ["COR_CoolantVolume", -1],
                _arges getVariable ["COR_MaxCoolant",    -1],
                _arges getVariable ["COR_Heat",          -1],
                _arges getVariable ["COR_Shutdown",      false],
                damage _arges,
                _arges getVariable ["AE_Health",         -1],
                _arges getVariable ["ace_medical_dead",  false],
                lifeState _arges,
                alive _arges
            ];
        };

        // Job 2 — shutdown redirect: fn_shutDown.sqf sets COR_Shutdown = true after its
        // 3-second drama (HUD warning, sparks, setUnconscious). Unit is already unconscious;
        // we redirect to TDoll immediately so the player cannot trigger A3A voluntary respawn.
        if (!(_arges getVariable ["COR_Shutdown", false]))    exitWith {};
        if (_arges getVariable ["GFL_ArgesFainting", false]) exitWith {};

        [_handle] call CBA_fnc_removePerFrameHandler;
        _arges setVariable ["GFL_ArgesFainting", true];
        _arges setVariable ["COR_SysEnabled",    false, true]; // stops fluid PFH + ACE hook

        private _identity = _arges getVariable ["GFL_ArgesIdentity", []];
        private _oldBody  = _arges getVariable ["GFL_OldBody",       objNull];

        if (isNull _oldBody || _identity isEqualTo []) exitWith {
            diag_log "[GFL Arges] COR_Shutdown redirect: missing identity/body";
        };

        private _prevOutfit = _identity # 4;
        private _grp        = group _arges;
        private _isLeader   = (leader _grp == _arges);
        private _isBoss     = (!isNil "theBoss" && { _arges == theBoss } && { !isNil "A3A_fnc_theBossTransfer" });

        private _dl = getUnitLoadout _oldBody;
        _dl set [3, if (_prevOutfit != "") then { [_prevOutfit, []] } else { [] }];

        _oldBody setVariable ["unitType",       _identity # 0,                                true];
        _oldBody setVariable ["A3A_playerUID",  _identity # 1,                                true];
        _oldBody setVariable ["moneyX",         _arges getVariable ["moneyX", _identity # 2], true];
        _oldBody setVariable ["owner",          _oldBody,                                      true];
        _oldBody setVariable ["eligible",       _arges getVariable ["eligible", false],        true];
        _oldBody setVariable ["GFL_ArgesState", "NONE",                                        true];

        _oldBody hideObjectGlobal false;
        _oldBody enableSimulationGlobal true;
        _oldBody setPosATL getPosATL _arges;
        _oldBody setDir    getDir    _arges;

        selectPlayer _oldBody;

        _arges setVariable ["GFL_OldBody",       objNull, true];
        _arges setVariable ["GFL_ArgesState",    "NONE",  true];
        _arges setVariable ["GFL_ArgesIdentity", [],      true];

        [_oldBody] join _grp;
        _oldBody setUnitLoadout _dl;
        if (_isLeader) then { _grp selectLeader _oldBody; };
        if (_isBoss)   then { [_oldBody, true] remoteExec ["A3A_fnc_theBossTransfer", 2]; };

        [{ (_this select 0) setDamage 1; }, [_oldBody], 0.5] call CBA_fnc_waitAndExecute;
        [{ deleteVehicle (_this select 0); }, [_arges],  3  ] call CBA_fnc_waitAndExecute;

        diag_log "[GFL Arges] COR_Shutdown redirect: selectPlayer done, TDoll kill 0.5 s, Arges delete 3 s";

    }, 0.25, [_arges]] call CBA_fnc_addPerFrameHandler;

    // Revert scroll action
    player addAction [
        "<t color='#ff8800'>[URNC] Revert to TDoll</t>",
        { [player] remoteExec ["GFL_fnc_argesRevert", 2]; diag_log "[GFL Arges] Revert action used"; }
    ];

    // Client-side HD registration — covers all combat once the player controls Arges.
    // Re-register here because locality has transferred from server to client via
    // selectPlayer, and the server-side EH no longer fires (HandleDamage is locality-bound).
    //
    // RPT proved we run FIRST in the chain (raw engine `_damage` values like 4.06 reach
    // our filter), meaning ACE re-registers AFTER us via its own XEH triggers (locality
    // transfer, respawn). ACE's return value wins and accumulates hitpoint damage past 1.0.
    //
    // Fix: track the index of OUR most-recently-added EH. Every 2 s, remove just that one
    // (not removeAllEventHandlers — that nukes ACE too and creates an EH-less window) and
    // re-add at a new higher index. Even if ACE re-registers in between, our EH is now
    // at the highest index → we run LAST → our return 0 is what the engine applies.
    private _idx = _arges addEventHandler ["HandleDamage", _damageFilter];
    _arges setVariable ["GFL_LastHDIdx", _idx];

    // 0.1 s interval — last RPT showed dmgApplied=4.36817 matching _damage at our HD
    // entry, meaning something else ran after our refresh and returned the raw value.
    // The 2 s interval was too slow; tighten to 10 Hz so any post-refresh re-registration
    // is overtaken within 100 ms.
    [{
        params ["_args", "_handle"];
        private _arges  = _args select 0;
        private _filter = _args select 1;
        if (!alive _arges || _arges getVariable ["GFL_ArgesState", "NONE"] != "ARGES") exitWith {
            [_handle] call CBA_fnc_removePerFrameHandler;
        };
        private _oldIdx = _arges getVariable ["GFL_LastHDIdx", -1];
        if (_oldIdx >= 0) then {
            _arges removeEventHandler ["HandleDamage", _oldIdx];
        };
        private _newIdx = _arges addEventHandler ["HandleDamage", _filter];
        _arges setVariable ["GFL_LastHDIdx", _newIdx];
    }, 0.1, [_arges, _damageFilter]] call CBA_fnc_addPerFrameHandler;

    // DIAGNOSTIC: Hit EH fires AFTER engine applies damage from a hit. Useful for
    // confirming what damage actually got applied, separate from the HandleDamage chain.
    // _damage here is the damage that was applied to the unit (post-chain).
    _arges addEventHandler ["Hit", {
        params ["_unit", "_source", "_damage", "_instigator"];
        diag_log format ["[GFL Diag] Hit EH: src=%1 inst=%2 dmgApplied=%3 unitDmgNow=%4 AE_H=%5 aceDead=%6 lifeState=%7 alive=%8 CORen=%9",
            _source, _instigator, _damage, damage _unit,
            _unit getVariable ["AE_Health", -1],
            _unit getVariable ["ace_medical_dead", false],
            lifeState _unit,
            alive _unit,
            _unit getVariable ["COR_SysEnabled", false]
        ];
    }];

    // HitPart-based HP pool drain for non-Corvus mode.
    //
    // Why HitPart instead of HandleDamage: chain ordering is unreliable — RPT shows
    // dmgApplied matching engine-raw _damage values (4.4+), meaning some other handler
    // wins the chain and our return 0 is overridden. With allowDamage false, the engine
    // can't apply damage at all and the HD chain doesn't fire. HitPart fires regardless
    // of allowDamage (it's a hit-detection event, not a damage-application one).
    //
    // Result: engine damage is impossible (allowDamage false), HP pool is the SOLE death
    // path, and the player gets Corvus-like tankiness without needing real Corvus active.
    //
    // Corvus active: skip — Corvus owns its own armor/coolant model via the wound chain.
    _arges addEventHandler ["HitPart", {
        params ["_hitData"];
        {
            _x params ["_target", "_shooter", "_proj", "_pos", "_vel", "_normal", "_ammoCfg", "_radius", "_partHash"];
            if (_target getVariable ["GFL_ArgesState", "NONE"] != "ARGES")  then { continue };
            if (_target getVariable ["GFL_ArgesKilling", false])             then { continue };
            if (_target getVariable ["GFL_ArgesFainting", false])            then { continue };
            if (_target getVariable ["COR_SysEnabled", false])               then { continue };
            if (_proj isEqualTo "")                                          then { continue };

            private _hit = getNumber (configFile >> "CfgAmmo" >> _proj >> "hit");
            if (_hit < 8) then { continue };

            private _cost = switch (true) do {
                case (_hit < 30):  { 2  };
                case (_hit < 100): { 5  };
                case (_hit < 300): { 7  };
                default            { 15 };
            };
            private _hp = (_target getVariable ["GFL_ArgesHP", 100]) - _cost;
            _target setVariable ["GFL_ArgesHP", _hp max 0, true];

            diag_log format ["[GFL Arges] HitPart drain: proj=%1 hit=%2 cost=%3 HP=%4", _proj, _hit, _cost, _hp max 0];

            if (_hp <= 0 && !(_target getVariable ["GFL_ArgesFainting", false])) then {
                _target setVariable ["GFL_ArgesFainting", true];

                private _identity = _target getVariable ["GFL_ArgesIdentity", []];
                private _oldBody  = _target getVariable ["GFL_OldBody",       objNull];
                private _grp      = group _target;
                private _isLeader = (leader _grp == _target);
                private _isBoss   = (!isNil "theBoss" && { _target == theBoss } && { !isNil "A3A_fnc_theBossTransfer" });

                if (isNull _oldBody || _identity isEqualTo []) then {
                    [{
                        params ["_u"];
                        _u setVariable ["GFL_ArgesKilling", true];
                        _u allowDamage true;
                        _u setDamage 1;
                    }, [_target], 0] call CBA_fnc_waitAndExecute;
                } else {
                    [{
                        params ["_unit", "_oldBody", "_grp", "_identity", "_isLeader", "_isBoss"];
                        if (!isNil "ace_medical_fnc_setUnconscious") then {
                            [_unit, true] call ace_medical_fnc_setUnconscious;
                        };
                        private _prevOutfit = _identity # 4;
                        private _dl = getUnitLoadout _oldBody;
                        _dl set [3, if (_prevOutfit != "") then { [_prevOutfit, []] } else { [] }];
                        _oldBody setVariable ["unitType",       _identity # 0,                               true];
                        _oldBody setVariable ["A3A_playerUID",  _identity # 1,                               true];
                        _oldBody setVariable ["moneyX",         _unit getVariable ["moneyX", _identity # 2], true];
                        _oldBody setVariable ["owner",          _oldBody,                                     true];
                        _oldBody setVariable ["eligible",       _unit getVariable ["eligible", false],        true];
                        _oldBody setVariable ["GFL_ArgesState", "NONE",                                       true];
                        _oldBody hideObjectGlobal    false;
                        _oldBody enableSimulationGlobal true;
                        _oldBody setPosATL getPosATL _unit;
                        _oldBody setDir    getDir    _unit;
                        selectPlayer _oldBody;
                        _unit setVariable ["GFL_OldBody",       objNull, true];
                        _unit setVariable ["GFL_ArgesState",    "NONE",  true];
                        _unit setVariable ["GFL_ArgesIdentity", [],      true];
                        [_oldBody] join _grp;
                        _oldBody setUnitLoadout _dl;
                        if (_isLeader) then { _grp selectLeader _oldBody; };
                        if (_isBoss)   then { [_oldBody, true] remoteExec ["A3A_fnc_theBossTransfer", 2]; };
                        [{ (_this select 0) setDamage 1; }, [_oldBody], 0.5] call CBA_fnc_waitAndExecute;
                        _unit setVariable ["GFL_ArgesKilling", true];
                        _unit allowDamage true;
                        [{ deleteVehicle (_this select 0); }, [_unit], 3] call CBA_fnc_waitAndExecute;
                        diag_log "[GFL Arges] HitPart HP=0: faint initiated — TDoll kill 0.5 s, Arges NPC delete 3 s";
                    }, [_target, _oldBody, _grp, _identity, _isLeader, _isBoss], 0] call CBA_fnc_waitAndExecute;
                };
            };
        } forEach _hitData;
    }];

    // Death redirect — fires synchronously on the client BEFORE A3A's fn_onPlayerRespawn
    // reads _oldUnit.owner. A3A checks: if (owner != self) → selectPlayer owner; deleteVehicle _newUnit.
    // By setting owner = TDoll here, A3A redirects the respawn to the TDoll and deletes
    // the unwanted Arges_F respawn body automatically.
    _arges addEventHandler ["Killed", {
        params ["_arges", "_killer", "_instigator", "_useEffects"];
        // DIAGNOSTIC: capture death state BEFORE redirect runs, so we can see what state the
        // unit was in at the moment of death — pinpoints the kill source.
        diag_log format ["[GFL Diag] Killed (client) STATE: killer=%1 instigator=%2 useEffects=%3 unitDmg=%4 AE_H=%5 aceDead=%6 lifeState=%7 COR_SD=%8 heat=%9 coolant=%10",
            _killer, _instigator, _useEffects, damage _arges,
            _arges getVariable ["AE_Health", -1],
            _arges getVariable ["ace_medical_dead", false],
            lifeState _arges,
            _arges getVariable ["COR_Shutdown", false],
            _arges getVariable ["COR_Heat", -1],
            _arges getVariable ["COR_CoolantVolume", -1]
        ];
        private _identity = _arges getVariable ["GFL_ArgesIdentity", []];
        private _oldBody  = _arges getVariable ["GFL_OldBody",       objNull];

        if (isNull _oldBody || _identity isEqualTo []) exitWith {
            diag_log "[GFL Arges] Killed (client): missing identity/body — respawn redirect skipped";
        };

        private _prevOutfit = _identity # 4;
        private _grp        = group _arges;

        // Strip ArgesFrame from TDoll's uniform slot so fnc_argesInit PFH does not
        // see the frame on respawn and immediately start another transform countdown.
        private _dl = getUnitLoadout _oldBody;
        _dl set [3, if (_prevOutfit != "") then { [_prevOutfit, []] } else { [] }];
        _oldBody setUnitLoadout _dl;

        // Restore A3A identity on TDoll (gates, flags, garage, store all read these)
        _oldBody setVariable ["unitType",       _identity # 0,                                true];
        _oldBody setVariable ["A3A_playerUID",  _identity # 1,                                true];
        _oldBody setVariable ["moneyX",         _arges getVariable ["moneyX", _identity # 2], true];
        _oldBody setVariable ["owner",          _oldBody,                                      true];
        _oldBody setVariable ["eligible",       _arges getVariable ["eligible", false],        true];
        _oldBody setVariable ["GFL_ArgesState", "NONE",                                        true];

        // Re-enable TDoll at the death position and put it back in the squad
        [_oldBody] join _grp;
        _oldBody setPosATL getPosATL _arges;
        _oldBody setDir    getDir    _arges;
        _oldBody hideObjectGlobal    false;
        _oldBody enableSimulationGlobal true;

        // Transfer control immediately. selectPlayer works even when TDoll is server-local —
        // the engine handles the locality grant. This is the primary respawn path: player is
        // back on TDoll before A3A's fn_onPlayerRespawn runs.
        selectPlayer _oldBody;

        // Arm A3A's redirect as a backup (owner != self → deleteVehicle _newArgesF_engine).
        _arges setVariable ["owner", _oldBody, true];

        // Kill TDoll 0.5 s later so A3A processes a proper TDoll-class death:
        //   fn_onPlayerRespawn fires with typeOf _oldBody = TDoll class
        //   → correct respawn body, money penalty, HC/squad logic all run normally.
        [{
            params ["_b", "_grp", "_isLeader"];
            if (_isLeader) then { _grp selectLeader _b; };
            _b setDamage 1;
        }, [_oldBody, _grp, leader _grp == _arges], 0.5] call CBA_fnc_waitAndExecute;

        diag_log "[GFL Arges] Killed (client): TDoll restored, selectPlayer done, TDoll kill in 0.5 s";
    }];

    diag_log "[GFL Arges] Revert action + damage filter + death redirect active";
}, [_arges, _damageFilter], 2] remoteExec ["CBA_fnc_waitAndExecute", _owner];

// Stash TDoll: 0.5 s gives selectPlayer time to reach the client before we move the body.
// Guard: if Arges died before this fires the Killed EH is already handling the TDoll.
[{
    params ["_player", "_arges"];
    if (!alive _arges) exitWith {};
    [_player] join createGroup (side _player);
    _player setPosATL [getPos _arges # 0, getPos _arges # 1, -500];
    _player hideObjectGlobal true;
    _player enableSimulationGlobal false;
}, [_player, _arges], 0.5] call CBA_fnc_waitAndExecute;

// Death: unitType was never set to "Arges_F", so A3A's PlayerKilled EH always reads the
// correct TDoll class — no race condition, no rogue Arges_F at the respawn point.
// NO double-death chain — that caused: TDoll re-enabling sim → A3A keepup selectPlayer →
// TDoll falling from Z=-500 with ArgesFrame equipped → PFH restart → extra onPlayerKilled.
_arges addEventHandler ["Killed", {
    params ["_arges", "_killer", "_instigator", "_useEffects"];
    // DIAGNOSTIC: capture death state on server side too. The client EH might miss
    // events if locality has not transferred (early death). _killer/_instigator pin
    // down whether the kill was from a unit (combat) or objNull (script setDamage).
    diag_log format ["[GFL Diag] Killed (server) STATE: killer=%1 instigator=%2 useEffects=%3 unitDmg=%4 AE_H=%5 aceDead=%6 lifeState=%7 COR_SD=%8 heat=%9 alive=%10",
        _killer, _instigator, _useEffects, damage _arges,
        _arges getVariable ["AE_Health", -1],
        _arges getVariable ["ace_medical_dead", false],
        lifeState _arges,
        _arges getVariable ["COR_Shutdown", false],
        _arges getVariable ["COR_Heat", -1],
        alive _arges
    ];
    private _identity = _arges getVariable ["GFL_ArgesIdentity", []];
    private _oldBody  = _arges getVariable ["GFL_OldBody",       objNull];
    private _grp      = group _arges;

    // 1. Clear state — unitType already holds the TDoll class (never set to "Arges_F"),
    //    so A3A's PlayerKilled EH will create the correct TDoll respawn unit without a race.
    _arges setVariable ["GFL_ArgesState", "NONE", true];

    // 2. Transfer squad leadership off the dead Arges immediately
    if (leader _grp == _arges) then {
        private _next = (units _grp - [_arges]) select { alive _x } select 0;
        if (!isNull _next) then { _grp selectLeader _next; };
    };

    // 3. Transfer HC command off Arges — pass to another alive player if one exists,
    //    otherwise A3A's own respawn handler will reassign it to the new TDoll.
    if (!isNil "theBoss" && { _arges == theBoss } && { !isNil "A3A_fnc_theBossTransfer" }) then {
        private _newBoss = (allPlayers - [_arges]) select { alive _x } select 0;
        if (!isNull _newBoss) then {
            [_newBoss, true] call A3A_fnc_theBossTransfer;
            diag_log format ["[GFL Arges] Killed: HC command passed to %1", name _newBoss];
        } else {
            diag_log "[GFL Arges] Killed: no other player for HC command — A3A will reassign on respawn";
        };
    };

    // 4. TDoll is NOT deleted here. The client Killed EH (registered in the 2 s block)
    //    fires synchronously on the owner machine before A3A's fn_onPlayerRespawn reads
    //    _oldUnit.owner. It re-enables the TDoll and sets owner = TDoll. A3A then fires:
    //      selectPlayer _oldBody; deleteVehicle _newArgesF
    //    giving the player their TDoll body and deleting the unwanted Arges_F respawn unit.

    // 5. Deferred: remove dead Arges from the player's group then delete the corpse.
    //    8 s gives the respawn screen time to appear; corpse gone before player returns.
    [{
        params ["_arges", "_grp"];
        [_arges] join createGroup (side _arges);
        deleteVehicle _arges;
        if (!isNull _grp && { count (units _grp) == 0 }) then { deleteGroup _grp; };
    }, [_arges, _grp], 8] call CBA_fnc_waitAndExecute;

    diag_log format ["[GFL Arges] Killed (server): unitType '%1', TDoll redirect via client EH, corpse queued 8 s", _identity # 0];
}];

diag_log format ["[GFL Arges] Transform complete: %1 -> Arges %2 (owner %3)", name _player, _arges, _owner];

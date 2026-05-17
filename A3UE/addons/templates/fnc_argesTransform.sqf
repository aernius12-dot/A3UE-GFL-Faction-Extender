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

// allowDamage true: required for HandleDamage to fire so our HP pool code runs.
// Our EH is registered after ACE's (post-transform vs ACE's mission-start XEH), so
// our return value (0) is authoritative — hitpoints cannot accumulate.
_arges allowDamage true;

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
// Replicates TacGirls' Aegis hitbox behaviour via HandleDamage (Aegis_Hitbox createVehicle
// fails for externally-created units — scope=0 abstract class, TacGirls limitation).
//
// Thresholds match hitboxinit.sqf (_ammo select 0 == CfgAmmo >> hit):
//   hit < 8   → immune (light pistol rounds)
//   hit 8–99  → -10 HP  (rifle/SMG — ~10 shots to kill)
//   hit ≥ 100 → -25 HP  (HMG, explosives — ~4 hits to kill)
//   HitHead / HitNeck → absorbed (headshot immunity)
//
// Two instances are registered:
//   • Server-local:  covers the window between createUnit and selectPlayer reaching the client
//   • Client-local:  covers all combat while the player controls Arges
// HandleDamage only fires on the machine that has locality, so there is no double-counting.

private _damageFilter = {
    params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint"];

    // Re-entrancy guard: when we call setDamage 1 ourselves, let it through so Arges actually dies
    if (_unit getVariable ["GFL_ArgesKilling", false])       exitWith { _damage };

    // Dead guard: in-flight bullets can trigger HandleDamage after the unit is killed.
    // Suppress silently — nothing to protect and fullHeal would error on a dead unit.
    if (!alive _unit)                                        exitWith { 0 };

    // Overall-damage slot (hitPoint == ""): suppress — we manage death via our HP pool
    if (_hitPoint isEqualTo "")                              exitWith { 0 };

    // Non-projectile call (environmental, engine internal): absorb silently
    if (_projectile isEqualTo "")                            exitWith { 0 };

    // Read ammo hit value — same number TacGirls reads from HitPart's _ammo select 0
    private _hit = getNumber (configFile >> "CfgAmmo" >> _projectile >> "hit");

    // Sub-rifle immunity: pistols, birdshot, anything below rifle threshold
    if (_hit < 8)                                            exitWith { 0 };

    // Corvus active: player manually activated the system via ACE self-action.
    // Corvus's ACE hook (COR_fnc_damage) owns armor drain, wound clearing, and death
    // (COR_Shutdown = true → setUnconscious). Our 0.25 s PFH monitors COR_Shutdown and
    // fires the redirect. We only suppress engine hitpoints here — Corvus handles the rest.
    if (_unit getVariable ["COR_SysEnabled", false])         exitWith { 0 };

    // No per-hitpoint (head/body) checks: Arges_F uses a custom TacGirls skeleton whose
    // visual mesh does not align with the default Arma fire geometry. HitHead could fire
    // from a chest shot and vice versa, making location-based filtering unreliable noise.
    // TacGirls' own Aegis_Hitbox uses the same flat approach — one HP pool, pure hit-value
    // filter, no hit-location logic. "Headshot immunity" means sniper rounds cost the same
    // 10 HP as a body shot rather than being an instant kill — not that head hits are absorbed.

    // Branch 2 (ACE present, no Corvus): clear ACE wounds inside this HandleDamage callback.
    // Our EH fires after ACE's (ACE registers at mission start via XEH config; we register
    // after transform). ACE creates wounds in its EH, then we call fullHeal here in the same
    // physics tick — before ACE's vitals PFH (scheduled context) can trigger cardiac arrest.
    // Branch 3 (Corvus active) already returned 0 above; this only runs on the no-Corvus path.
    if (!isNil "ace_medical_fnc_fullHeal") then { _unit call ace_medical_fnc_fullHeal; };

    // HP cost by hit tier:
    //   hit  8–29 → 2   rifle/SMG (5.56, 5.45, 7.62x39, 7.62x51, .338…)  750 hits to drain
    //   hit 30–99 → 5   .50 BMG, HMG, heavy AP                            300 hits to drain
    //   hit 100–299→ 7  light explosive (grenades, 40mm)                  ~214 hits to drain
    //   hit 300+  → 15  heavy explosive (RPG, ATGM, bombs, artillery)     100 hits to drain
    private _cost = switch (true) do {
        case (_hit < 30):  { 2  };
        case (_hit < 100): { 5  };
        case (_hit < 300): { 7  };
        default            { 15 };
    };
    private _hp   = (_unit getVariable ["GFL_ArgesHP", 100]) - _cost;
    _unit setVariable ["GFL_ArgesHP", _hp max 0, true];

    diag_log format ["[GFL Arges] Hit: proj=%1 hit=%2 cost=%3 HP=%4", _projectile, _hit, _cost, _hp max 0];

    if (_hp <= 0 && !(_unit getVariable ["GFL_ArgesFainting", false])) then {
        // Burst guard: set before allowDamage so that concurrent HandleDamage callbacks
        // from the same physics tick (full-auto burst) all see it and skip the faint path.
        _unit setVariable ["GFL_ArgesFainting", true];
        // Lock out further engine damage immediately (unscheduled context).
        _unit allowDamage false;

        private _identity = _unit getVariable ["GFL_ArgesIdentity", []];
        private _oldBody  = _unit getVariable ["GFL_OldBody",       objNull];
        private _grp      = group _unit;
        private _isLeader = (leader _grp == _unit);
        private _isBoss   = (!isNil "theBoss" && { _unit == theBoss } && { !isNil "A3A_fnc_theBossTransfer" });

        if (isNull _oldBody || _identity isEqualTo []) then {
            // No stashed body — re-enable damage and kill normally
            [{
                params ["_u"];
                _u setVariable ["GFL_ArgesKilling", true];
                _u allowDamage true;
                _u setDamage 1;
            }, [_unit], 0] call CBA_fnc_waitAndExecute;
        } else {
            [{
                params ["_unit", "_oldBody", "_grp", "_identity", "_isLeader", "_isBoss"];

                // --- Faint: hold Arges alive so no PlayerKilled fires for it ---
                // ACE: setUnconscious stops ACE's own injury model from pushing towards setDead.
                // Vanilla: allowDamage false already set — unit frozen at near-death, not dead.
                if (!isNil "ace_medical_fnc_setUnconscious") then {
                    [_unit, true] call ace_medical_fnc_setUnconscious;
                };

                // --- Prepare TDoll identity and loadout ---
                private _prevOutfit = _identity # 4;
                private _dl = getUnitLoadout _oldBody;
                // Strip ArgesFrame from uniform slot — PFH must not see it on respawn
                _dl set [3, if (_prevOutfit != "") then { [_prevOutfit, []] } else { [] }];

                // Restore A3A identity (global broadcast — works from any machine)
                _oldBody setVariable ["unitType",       _identity # 0,                               true];
                _oldBody setVariable ["A3A_playerUID",  _identity # 1,                               true];
                _oldBody setVariable ["moneyX",         _unit getVariable ["moneyX", _identity # 2], true];
                _oldBody setVariable ["owner",          _oldBody,                                     true];
                _oldBody setVariable ["eligible",       _unit getVariable ["eligible", false],        true];
                _oldBody setVariable ["GFL_ArgesState", "NONE",                                       true];

                // Re-enable TDoll at death position (global commands — cross-machine safe)
                _oldBody hideObjectGlobal    false;
                _oldBody enableSimulationGlobal true;
                _oldBody setPosATL getPosATL _unit;
                _oldBody setDir    getDir    _unit;

                // --- Hand control to TDoll ---
                // selectPlayer transfers TDoll locality to this client; all subsequent TDoll
                // ops (join, setUnitLoadout, setDamage) must run here, not on the server.
                selectPlayer _oldBody;

                // Clear Arges refs — Killed EH fallback and server EH both exit early on null
                _unit setVariable ["GFL_OldBody",       objNull, true];
                _unit setVariable ["GFL_ArgesState",    "NONE",  true];
                _unit setVariable ["GFL_ArgesIdentity", [],      true];

                // TDoll is now client-local: group, loadout, authority
                [_oldBody] join _grp;
                _oldBody setUnitLoadout _dl;
                if (_isLeader) then { _grp selectLeader _oldBody; };
                if (_isBoss)   then { [_oldBody, true] remoteExec ["A3A_fnc_theBossTransfer", 2]; };

                // Kill TDoll after 0.5 s → PlayerKilled fires → A3A fn_onPlayerRespawn runs
                // with typeOf _oldBody = TDoll class → correct respawn + full A3A treatment
                [{ (_this select 0) setDamage 1; }, [_oldBody], 0.5] call CBA_fnc_waitAndExecute;

                // Silently remove Arges NPC after 3 s — deleteVehicle does not fire Killed EH
                [{ deleteVehicle (_this select 0); }, [_unit], 3] call CBA_fnc_waitAndExecute;

                diag_log "[GFL Arges] HP=0: faint initiated — TDoll kill 0.5 s, Arges NPC delete 3 s";

            }, [_unit, _oldBody, _grp, _identity, _isLeader, _isBoss], 0] call CBA_fnc_waitAndExecute;
        };
    };

    0 // engine applies zero damage — we own the health
};

// Remove all HandleDamage EHs (ACE's, TacGirls', etc.) before adding ours.
// ACE's EH calls setDead directly inside its EH for hits with normalised damage ≥ 1.0,
// which fires before our EH runs and cannot be cancelled by fullHeal after the fact.
// With ACE's EH gone, only our filter processes damage — HP pool + fullHeal + return 0.
_arges removeAllEventHandlers "HandleDamage";
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

    // allowDamage true: HandleDamage must fire for our HP pool to run. TacGirls'
    // hitboxinit.sqf (async init EH) can flip this back to false — PFH beats it each second.
    _arges allowDamage true;
    _arges enableStamina false;
    _arges setAnimSpeedCoef 1.4;
    _arges setUnitRecoilCoefficient 0.1;
    _arges setCustomAimCoef 0.05;

    // Per-frame: maintain allowDamage true + HandleDamage EH management.
    //
    // allowDamage true: TacGirls' hitboxinit (async init EH) can flip this to false at any
    //   time; without it HandleDamage never fires and the engine applies raw damage.
    //
    // Non-Corvus mode (COR_SysEnabled = false):
    //   removeAll + re-add every frame. Closes the ACE EH re-registration race to one frame
    //   (~16 ms). ACE re-registers its HandleDamage EH after selectPlayer; if it lands before
    //   our next tick and a heavy round hits while ACE's EH is last, ACE returns >= 1.0 →
    //   engine kill. Stripping every frame ensures only our EH is ever last. Our filter drains
    //   GFL_ArgesHP pool and returns 0.
    //
    // Corvus mode (COR_SysEnabled = true):
    //   Hand off entirely. Corvus registers its own HandleDamage EH via SysInit, and its own
    //   PFH also re-registers it periodically to stay last. If we compete by also re-adding
    //   ours every frame, it becomes a race — whichever EH is last at shot-time wins, and
    //   Corvus's EH returns non-zero damage which accumulates on the unit.
    //   Fix: remove our EH on the first Corvus-mode frame, then do nothing. Corvus handles
    //   damage natively, exactly as it does on regular TDolls.
    [{
        params ["_args", "_handle"];
        private _arges = _args select 0;
        private _filter = _args select 1;
        if (!alive _arges || _arges getVariable ["GFL_ArgesState", "NONE"] != "ARGES") exitWith {
            [_handle] call CBA_fnc_removePerFrameHandler;
        };
        _arges allowDamage true;
        if (_arges getVariable ["COR_SysEnabled", false]) then {
            // Corvus mode: remove our EH if still registered, then stand aside.
            private _ourId = _arges getVariable ["GFL_ArgesHdEhId", -1];
            if (_ourId >= 0) then {
                _arges removeEventHandler ["HandleDamage", _ourId];
                _arges setVariable ["GFL_ArgesHdEhId", -1];
            };
            // No addEventHandler — Corvus owns the damage pipeline from here.
        } else {
            // Non-Corvus: strip all (ACE, TacGirls, any lingering Corvus EH), add only ours.
            _arges removeAllEventHandlers "HandleDamage";
            _arges addEventHandler ["HandleDamage", _filter];
            _arges setVariable ["GFL_ArgesHdEhId", -1];
        };
    }, 0, [_arges, _damageFilter]] call CBA_fnc_addPerFrameHandler;

    // Every 1 s: maintain AE_Health sentinel + Aegis combat buffs.
    // AE_Health guards TacGirls' 10-shot kill trigger (hitboxinit.sqf async-resets it to 100;
    // we keep it at 9999 so the running tally never reaches the kill threshold of 0).
    [{
        params ["_args", "_handle"];
        private _arges = _args select 0;
        if (!alive _arges || _arges getVariable ["GFL_ArgesState", "NONE"] != "ARGES") exitWith {
            [_handle] call CBA_fnc_removePerFrameHandler;
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
            // Coolant maintenance: every tick.
            // (1) Keep the cap at Arges floor so module absolute-value writes don't shrink it.
            // (2) Arges IS the Corvus frame — she has no finite coolant tank.  Drain is blocked
            //     so Corvus lasts until incoming damage forces COR_Shutdown, not a time limit.
            private _targetMax = if (_arges getVariable ["COR_CoolCap+", false]) then { 9000 } else { 8000 };
            _arges setVariable ["COR_MaxCoolant",    _targetMax, true];
            _arges setVariable ["COR_CoolantVolume", _targetMax, true];

            // Heat maintenance: fn_heating.sqf runs every 0.5 s.  When COR_Heat >= 110 it
            // calls `_unit setDamage 1` directly — bypassing HandleDamage entirely.  This is
            // what was killing Arges after ~16-44 s (timing varies with module count and FPS).
            // Root cause: each active Corvus module raises COR_staticHeating; once it exceeds
            // the cooling coefficient (1.5 at 100% coolant) heat accumulates to the kill point.
            // Fix: Arges IS the Corvus frame — she dissipates heat intrinsically.  Reset heat
            // and static heating every tick so the kill threshold is never reached.
            _arges setVariable ["COR_Heat",          30, true];
            _arges setVariable ["COR_staticHeating",  1, true];
            // Diagnostic: log vitals every 0.25 s to confirm stability
            diag_log format ["[GFL Arges] Corvus vitals: coolant=%1/%2 heat=%3 shutdown=%4 dmg=%5",
                _arges getVariable ["COR_CoolantVolume", -1],
                _arges getVariable ["COR_MaxCoolant",    -1],
                _arges getVariable ["COR_Heat",          -1],
                _arges getVariable ["COR_Shutdown",      false],
                damage _arges
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

    // Remove all HandleDamage EHs that ACE/TacGirls registered on the client copy of Arges,
    // then re-add only ours. ACE's EH fires before ours and calls setDead directly inside
    // its EH for hits with normalised damage ≥ 1.0 — we can never cancel that after the fact.
    _arges removeAllEventHandlers "HandleDamage";
    _arges addEventHandler ["HandleDamage", _damageFilter];

    // Death redirect — fires synchronously on the client BEFORE A3A's fn_onPlayerRespawn
    // reads _oldUnit.owner. A3A checks: if (owner != self) → selectPlayer owner; deleteVehicle _newUnit.
    // By setting owner = TDoll here, A3A redirects the respawn to the TDoll and deletes
    // the unwanted Arges_F respawn body automatically.
    _arges addEventHandler ["Killed", {
        params ["_arges"];
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
    params ["_arges"];
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

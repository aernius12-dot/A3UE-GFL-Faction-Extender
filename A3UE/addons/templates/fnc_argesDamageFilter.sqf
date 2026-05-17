// GFL Arges damage filter — invoked via XEH Extended_HandleDamage_EventHandlers
// on Arges_F class with priority lower than ACE Medical (priority=1), so this
// runs LAST in the chain and its return value is the one the engine applies.
//
// XEH ensures this is registered on whichever machine has locality of the unit,
// across createUnit, selectPlayer, and JIP.  No manual addEventHandler needed.
//
// Pass-through for non-transformed Arges_F (e.g. shouldn't exist normally, but
// safe-guards against config edge cases).

params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint"];

// Only operate on actively transformed Arges. If something else creates a raw
// Arges_F unit, return engine damage unchanged.
if (_unit getVariable ["GFL_ArgesState", "NONE"] != "ARGES") exitWith { _damage };

// DIAGNOSTIC: count filter invocations and log Corvus-mode entries.
// _damage at entry now tells us chain position relative to ACE:
//   ≤ 0.9   → we ran AFTER ACE (correct, ACE's cap)
//   ≫ 1     → we ran BEFORE ACE (would be bad, indicates priority mis-set)
if (_unit getVariable ["COR_SysEnabled", false]) then {
    private _n = (_unit getVariable ["GFL_DiagFilterCalls", 0]) + 1;
    _unit setVariable ["GFL_DiagFilterCalls", _n];
    diag_log format ["[GFL Diag] HD enter #%1: proj=%2 hp='%3' _damage=%4 curUnitDmg=%5 hitIdx=%6",
        _n, _projectile, _hitPoint, _damage, damage _unit, _hitIndex];
};

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

// Branch 2 (ACE present, no Corvus): clear ACE wounds inside this HandleDamage callback.
// Our EH runs after ACE's via XEH priority. ACE created wounds in its EH; we call fullHeal
// here in the same physics tick — before ACE's vitals PFH (scheduled) can trigger cardiac arrest.
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
            if (!isNil "ace_medical_fnc_setUnconscious") then {
                [_unit, true] call ace_medical_fnc_setUnconscious;
            };

            // --- Prepare TDoll identity and loadout ---
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
            [{ deleteVehicle (_this select 0); }, [_unit], 3] call CBA_fnc_waitAndExecute;

            diag_log "[GFL Arges] HP=0: faint initiated — TDoll kill 0.5 s, Arges NPC delete 3 s";

        }, [_unit, _oldBody, _grp, _identity, _isLeader, _isBoss], 0] call CBA_fnc_waitAndExecute;
    };
};

0 // engine applies zero damage — we own the health

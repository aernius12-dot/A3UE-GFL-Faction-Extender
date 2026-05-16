// GFL Arges — client: outfit PFH that guards and triggers the body swap.
//
// Equipping GFL_ArgesFrame starts a 10 s grace period.
// Removing it before countdown fires cancels cleanly — no transform.
// Revert is via a scroll-wheel addAction added to the Arges unit after transform.
//
// GFL_PrevUniform (player-local): tracks the last non-ArgesFrame outfit so the
// server can restore it on revert without a round-trip read.

if (!hasInterface) exitWith {};

[{
    params ["_args", "_pfhId"];
    if (isNull player || !alive player) exitWith { _args set [0, false]; };

    // In Arges form: idle here; revert is via the addAction on the Arges unit
    if (player getVariable ["GFL_ArgesState", "NONE"] == "ARGES") exitWith {
        _args set [0, false];
    };

    private _unif    = uniform player;
    private _pending = _args select 0;

    // Keep GFL_PrevUniform current — server reads this as the restore-target outfit
    if (_unif != "" && _unif != "GFL_ArgesFrame") then {
        player setVariable ["GFL_PrevUniform", _unif];
    };

    if (_unif == "GFL_ArgesFrame" && !_pending) then {
        _args set [0, true];
        diag_log format ["[GFL Arges] ArgesFrame equipped by %1 — transform in 10 s", name player];

        [{
            params ["_args"];
            if !(_args select 0)                                            exitWith {};
            if (isNull player || !alive player)                             exitWith { _args set [0, false]; };
            if (uniform player != "GFL_ArgesFrame")                        exitWith { _args set [0, false]; };
            if (player getVariable ["GFL_ArgesState", "NONE"] != "NONE")   exitWith { _args set [0, false]; };
            diag_log format ["[GFL Arges] Transform triggered for %1", name player];
            [player, player getVariable ["GFL_PrevUniform", ""]] remoteExec ["GFL_fnc_argesTransform", 2];
        }, [_args], 10] call CBA_fnc_waitAndExecute;
    };

    if (_unif != "GFL_ArgesFrame" && _pending) then {
        _args set [0, false];
        diag_log format ["[GFL Arges] ArgesFrame removed — transform cancelled for %1", name player];
    };

}, 0.5, [false]] call CBA_fnc_addPerFrameHandler;

// Branch 2 (ACE present, Corvus not active): mirror COR_fnc_damage line 5 exactly.
// ACE_Medical_Injuries fires synchronously inside ACE's HandleDamage chain — before
// ACE's vitals PFH can trigger cardiac arrest. fullHeal clears all ACE wound state
// the same way Corvus does. Exits immediately when Corvus is active (Branch 3) so
// COR_fnc_damage can own ACE state as designed.
if (isClass (configFile >> "CfgPatches" >> "ace_medical")) then {
    ["Arges_F", "ACE_Medical_Injuries", {
        params ["_unit"];
        if (_unit getVariable ["GFL_ArgesState", "NONE"] != "ARGES") exitWith {};
        if (_unit getVariable ["COR_SysEnabled", false]) exitWith {};
        _unit call ace_medical_fnc_fullHeal;
    }] call CBA_fnc_addClassEventHandler;
    diag_log "[GFL Arges] ACE_Medical_Injuries hook registered for Arges_F (Branch 2)";
};

diag_log "[GFL Arges] fnc_argesInit active";

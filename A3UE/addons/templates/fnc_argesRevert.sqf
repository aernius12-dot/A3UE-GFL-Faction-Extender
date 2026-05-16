// GFL Arges — server: Arges_F → TDoll revert.
//
// Reads GFL_ArgesIdentity from the Arges unit (written by fnc_argesTransform):
//   [0] unitType, [1] A3A_playerUID, [2] moneyX, [3] ownerID, [4] prevOutfit
//
// Inventory rule: weapons + assigned items come from Arges (field acquisitions kept).
// Containers (vest/backpack) keep TDoll's own classes but receive Arges's contents.
// Uniform is restored to prevOutfit so the client PFH does not re-trigger the transform.

if (!isServer) exitWith {};
params ["_arges"];

if (isNull _arges || !alive _arges)                           exitWith {};
if (typeOf _arges != "Arges_F")                               exitWith {};
if (_arges getVariable ["GFL_ArgesState", ""] != "ARGES")     exitWith {};

private _identity = _arges getVariable ["GFL_ArgesIdentity", []];
private _oldBody  = _arges getVariable ["GFL_OldBody",       objNull];
private _owner    = _arges getVariable ["GFL_PlayerOwner",   0];

if (_identity isEqualTo [] || isNull _oldBody) exitWith {
    diag_log "[GFL Arges] Revert aborted: identity bundle or stashed body missing";
};

// Block any duplicate revert call while this one is in flight
_arges setVariable ["GFL_ArgesState", "REVERTING", true];

private _pos = getPosATL _arges;
private _dir = getDir _arges;
private _grp = group _arges;

// --- Loadout transfer back ---
private _al = getUnitLoadout _arges;
private _dl = getUnitLoadout _oldBody;

_dl set [0, _al # 0]; // primary weapon
_dl set [1, _al # 1]; // secondary weapon
_dl set [2, _al # 2]; // handgun
_dl set [8, _al # 8]; // assigned items

// Containers: keep TDoll's original class, fill with whatever Arges carried
{
    private _aSlot = _al # _x;
    private _dSlot = _dl # _x;
    if (!(_dSlot isEqualTo []) && !(_aSlot isEqualTo [])) then {
        _dl set [_x, [_dSlot # 0, _aSlot # 1]];
    };
} forEach [4, 5];

// Restore pre-ArgesFrame outfit; blank if none recorded — either way prevents re-trigger
private _prevOutfit = _identity # 4;
_dl set [3, if (_prevOutfit != "") then { [_prevOutfit, []] } else { [] }];

_oldBody setUnitLoadout _dl;

// --- Restore TDoll to world ---
[_oldBody] join _grp;
_oldBody setPosATL _pos;
_oldBody setDir _dir;
_oldBody hideObjectGlobal false;
_oldBody enableSimulationGlobal true;

// A3A identity fully restored; moneyX uses current Arges value (field economy changes kept)
_oldBody setVariable ["unitType",       _identity # 0,                                true];
_oldBody setVariable ["A3A_playerUID",  _identity # 1,                                true];
_oldBody setVariable ["moneyX",         _arges getVariable ["moneyX", _identity # 2],  true];
_oldBody setVariable ["owner",          _oldBody,                                      true];
_oldBody setVariable ["eligible",       _arges getVariable ["eligible", false],        true];
_oldBody setVariable ["GFL_ArgesState", "NONE",                                        true];

// --- Authority ---
if (leader _grp == _arges) then { _grp selectLeader _oldBody; };

if (!isNil "theBoss" && { _arges == theBoss } && { !isNil "A3A_fnc_theBossTransfer" }) then {
    [_oldBody, true] call A3A_fnc_theBossTransfer;
    diag_log "[GFL Arges] HC command returned to TDoll";
};

// --- Switch ---
[_oldBody] remoteExec ["selectPlayer", _owner];

// Zeus: reassigned on client after selectPlayer settles
[{ { player assignCurator _x } forEach allCurators; }, [], 1.5] remoteExec ["CBA_fnc_waitAndExecute", _owner];

// Dispose Arges: brief stash then delete so A3A keepup loop doesn't react to sudden removal
[{
    params ["_arges"];
    private _dp = createGroup (side _arges);
    [_arges] join _dp;
    _arges hideObjectGlobal true;
    _arges enableSimulationGlobal false;
    _arges setVariable ["GFL_ArgesState", "NONE", true];
    [{
        params ["_a", "_g"];
        deleteVehicle _a;
        deleteGroup _g;
    }, [_arges, _dp], 1] call CBA_fnc_waitAndExecute;
}, [_arges], 0.3] call CBA_fnc_waitAndExecute;

diag_log format ["[GFL Arges] Revert complete -> TDoll %1", _oldBody];

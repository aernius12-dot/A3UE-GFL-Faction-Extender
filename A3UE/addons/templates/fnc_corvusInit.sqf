// GFL CORVUS AI Initializer
// Activates CORVUS T-Doll mechanics on GnK rebel AI units wearing FCC backpacks.
//
// Design note: CORVUS's own COR_fnc_SysInit uses a single global var (COR_SysInit_EH)
// for its per-frame handler, so calling it on multiple units causes each call to remove
// the previous unit's handler. We therefore do our own per-unit setup instead:
//   - Set all COR_* unit variables that COR_fnc_damage (ACE wound handler) expects.
//   - Add a per-unit CBA per-frame handler (runs every 0.5s) to maintain combat buffs
//     and adjust for limb-damage penalties, matching CORVUS's own logic.
//
// The ACE wound handler COR_fnc_damage is registered globally via ACE_Medical_Injuries
// in CORVUS's config and fires automatically for any unit with COR_SysEnabled = true.

if (!isServer) exitWith {};
if !(isClass (configFile >> "cfgVehicles" >> "TDoll_B_Pack")) exitWith {};

diag_log "[GFL Corvus] fnc_corvusInit running on server";

private _fccPacks = ["TDoll_B_Pack", "TDoll_V_Pack", "TDoll_Sup_Pack", "TDoll_Sent_Pack", "TDoll_Bul_Pack"];

// Hostile-AI armor scaling. Rebel-side units (Petros / GnK / recruited squadmates) get
// the full frameArmor from the backpack config; west/east AI (ELMO, Sangvis, Mangi,
// Varjagers, Paradeus) get reduced values so they're not bullet sponges.
GFL_CorvusHostileArmor = createHashMapFromArray [
    ["TDoll_Bul_Pack",  130],
    ["TDoll_Sent_Pack",  90],
    ["TDoll_Sup_Pack",   60],
    ["TDoll_V_Pack",     60],
    ["TDoll_B_Pack",     40]
];

// Guarantee the caliber gate is active on the server regardless of CBA settings propagation.
// COR_fnc_damage reads COR_AArmor from missionNamespace; if the CBA callback never ran on
// the server the variable is nil (falsy) and the 4-shot mechanic silently does nothing.
if (isNil "COR_AArmor") then { missionNamespace setVariable ["COR_AArmor", true]; };

// ACE_Medical_Injuries is a CBA/XEH extended event, not a native Arma mission event.
// addMissionEventHandler rejects it with "Unknown enum value" in ACE 3.15+.
// COR_FluidLoss_EH cleanup is instead added per-unit as a Hit EH inside the init function.

// Shared per-unit init — called from both EntityCreated EH and the fallback scanner.
GFL_fnc_corvusInitUnit = {
    params ["_unit", "_fccPacks"];
    if (!local _unit) exitWith {};
    // Aegis-family units (Arges_F, Aegis_F, Aegis_SWAP_F, Steropes_F) are TacGirls
    // heavy-combat frames. Their canonical weapon is baked into the body model and
    // assigned by TacGirls config — Corvus PFH init must not run on them.
    // Using inline isKindOf chain (no forEach/exitWith scope trap) to catch all
    // subclasses. Arges_F specifically is also player-controlled; activating
    // COR_SysEnabled without COR_fnc_SysInit's tight allowDamage PFH would conflict
    // with the player faint mechanism, so all Aegis family is skipped here.
    if (_unit isKindOf "Arges_F" || _unit isKindOf "Aegis_F" ||
        _unit isKindOf "Aegis_SWAP_F" || _unit isKindOf "Steropes_F") exitWith {};
    if (!(backpack _unit in _fccPacks)) exitWith {};
    if (_unit getVariable ["GFL_COR_InitDone", false]) exitWith {};

    // Per-side buff toggle: GFL_CorvusBuff_Hostile for west/east units, GFL_CorvusBuff_GnK
    // for any other side (resistance / civilian) that ends up here with an FCC pack equipped.
    private _isHostile = (side group _unit) in [west, east];
    private _buffOn = if (_isHostile) then {
        missionNamespace getVariable ["GFL_CorvusBuff_Hostile", true]
    } else {
        missionNamespace getVariable ["GFL_CorvusBuff_GnK", true]
    };
    if (!_buffOn) exitWith {};

    _unit setVariable ["GFL_COR_InitDone", true, true];

    // Per-unit cleanup: CORVUS's COR_fnc_damage sets the global COR_FluidLoss_EH on
    // every injury. If two GFL AI units are injured in rapid succession the second hit
    // overwrites the reference, leaking the first unit's PFH. We remove the EH 0.1 s
    // after each Hit — long enough for ACE/CORVUS's XEH chain to finish writing it,
    // short enough that almost no fluid-loss ticks slip through before removal.
    _unit addEventHandler ["Hit", {
        [{
            if (!isNil "COR_FluidLoss_EH") then {
                [COR_FluidLoss_EH] call CBA_fnc_removePerFrameHandler;
                COR_FluidLoss_EH = nil;
            };
        }, [], 0.1] call CBA_fnc_waitAndExecute;
    }];

    private _pbp   = backpack _unit;
    private _baseArmor = getNumber (configFile >> "cfgVehicles" >> _pbp >> "frameArmor");
    private _frame = getText  (configFile >> "cfgVehicles" >> _pbp >> "frameType");
    // Apply hostile-AI nerf — rebels get full _baseArmor, hostile sides use the GFL_CorvusHostileArmor table.
    private _armor = if (_isHostile) then {
        GFL_CorvusHostileArmor getOrDefault [_pbp, _baseArmor]
    } else {
        _baseArmor
    };

    // Core CORVUS state — read by COR_fnc_damage and repair actions
    _unit setVariable ["COR_SysEnabled",          true,  true];
    _unit setVariable ["COR_Shutdown",             false, true];
    _unit setVariable ["COR_FrameArmor",           _armor, true];
    _unit setVariable ["COR_Frame",                _frame, true];
    _unit setVariable ["COR_CoolantVolume",        5000,  true];
    _unit setVariable ["COR_MaxCoolant",           5000,  true];
    _unit setVariable ["COR_Heat",                 30];
    _unit setVariable ["COR_StaticTemp",           30];
    _unit setVariable ["COR_staticHeating",        1];
    _unit setVariable ["COR_HeatingEffectsActive", false];
    _unit setVariable ["COR_DamTick",              0];
    _unit setVariable ["COR_ArmorValues", createHashMapFromArray [
        ["Head",     _armor], ["Body",     _armor],
        ["LeftArm",  _armor], ["RightArm", _armor],
        ["LeftLeg",  _armor], ["RightLeg", _armor]
    ], true];
    _unit setVariable ["COR_TQdLimbs", createHashMapFromArray [
        ["Head", false], ["Body", false],
        ["LeftArm", false], ["RightArm", false],
        ["LeftLeg", false], ["RightLeg", false]
    ]];

    // Apply combat buffs immediately
    _unit enableStamina false;
    _unit setAnimSpeedCoef 1.4;
    _unit setUnitRecoilCoefficient 0.1;
    _unit setCustomAimCoef 0.05;

    diag_log format ["[GFL Corvus] unit=%1 pack=%2 frame=%3 armor=%4 hostile=%5", _unit, _pbp, _frame, _armor, _isHostile];

    // Per-unit maintenance handler — mirrors CORVUS's own EH logic for AI
    [{
        params ["_args", "_idPFH"];
        private _unit = _args select 0;

        // Clean up when unit dies or leaves locality
        if (!alive _unit || !local _unit) exitWith {
            [_idPFH] call CBA_fnc_removePerFrameHandler;
            _unit setVariable ["GFL_COR_PFH", nil];
        };

        private _arm    = _unit getVariable "COR_ArmorValues";
        if (isNil "_arm") exitWith { [_idPFH] call CBA_fnc_removePerFrameHandler; };
        private _fa     = _unit getVariable ["COR_FrameArmor",  200];
        private _75p    = _fa * 0.75;
        private _50p    = _fa * 0.5;

        // Defaults
        private _spd  = 1.4;
        private _rec  = 0.1;
        private _stab = 0.05;

        // Arm damage → accuracy/recoil penalties
        if ((_arm getOrDefault ["LeftArm",  _fa]) < _75p ||
            (_arm getOrDefault ["RightArm", _fa]) < _75p) then {
            _rec = 0.5; _stab = 0.5;
        };
        if ((_arm getOrDefault ["LeftArm",  _fa]) < _50p ||
            (_arm getOrDefault ["RightArm", _fa]) < _50p) then {
            _rec = 1; _stab = 1;
        };

        // Leg damage → speed penalties
        if ((_arm getOrDefault ["LeftLeg",  _fa]) < _75p ||
            (_arm getOrDefault ["RightLeg", _fa]) < _75p) then {
            _spd = 1.2;
        };
        if ((_arm getOrDefault ["LeftLeg",  _fa]) < _50p ||
            (_arm getOrDefault ["RightLeg", _fa]) < _50p) then {
            _spd = 1;
        };

        _unit enableStamina false;
        _unit setAnimSpeedCoef _spd;
        _unit setUnitRecoilCoefficient _rec;
        _unit setCustomAimCoef _stab;

    }, 0.5, [_unit]] call CBA_fnc_addPerFrameHandler;
};

// Immediate init on spawn — fires the moment Antistasi creates a new AI unit.
// EntityCreated fires before the loadout is applied, so we defer 1 s to let
// Antistasi's setUnitLoadout finish before checking the backpack slot.
// GFL_fnc_corvusInitUnit is a global so it survives beyond this script's scope.
addMissionEventHandler ["EntityCreated", {
    params ["_unit"];
    if (!(_unit isKindOf "Man") || isPlayer _unit) exitWith {};
    private _packs = ["TDoll_B_Pack", "TDoll_V_Pack", "TDoll_Sup_Pack", "TDoll_Sent_Pack", "TDoll_Bul_Pack"];
    [{
        params ["_unit", "_packs"];
        if (!alive _unit) exitWith {};
        [_unit, _packs] call GFL_fnc_corvusInitUnit;
    }, [_unit, _packs], 1] call CBA_fnc_waitAndExecute;
}];

// Fallback scanner: catches units that existed before this script ran (mission start / JIP)
// and any unit the EntityCreated path missed (e.g. after a locality transfer).
[{
    params ["_fccPacks"];
    {
        private _unit = _x;
        if (!local _unit) then { continue };
        if (!(backpack _unit in _fccPacks)) then { continue };
        [_unit, _fccPacks] call GFL_fnc_corvusInitUnit;
    } forEach allUnits;
}, 10, [_fccPacks]] call CBA_fnc_addPerFrameHandler;

// Petros identity override (head + name) — server-side 3 s poll.
// Idempotent via per-unit signature variable so we only call setIdentity when the
// applied combo changes. Variable resets automatically on respawn since the new
// petros object starts with no variables set.
if (isServer) then {
    diag_log "[GFL PetrosIdentity] Registering perFrame poll handler (3 s interval)";

    // [firstName, lastName] pairs, indexed by GFL_petrosNameSetting
    GFL_petrosNameOptions = [
        ["Petros", ":)"],
        ["John", "Frontline"],
        ["Commander", ""],
        ["Shikikan", ""]
    ];

    [{
        if (isNull petros || !alive petros) exitWith {};

        private _headSetting = missionNamespace getVariable ["GFL_petrosHeadSetting", 0];
        private _nameSetting = missionNamespace getVariable ["GFL_petrosNameSetting", 0];
        private _signature = format ["h%1_n%2", _headSetting, _nameSetting];

        if ((petros getVariable ["GFL_appliedIdentity", ""]) isEqualTo _signature) exitWith {};

        // Head: default "GreekHead_A3_01" (what initPetros applies), or commandermaleface
        private _desiredFace = if (_headSetting isEqualTo 1) then { "commandermaleface" } else { "GreekHead_A3_01" };

        // Name: clamp index into options
        private _idx = (_nameSetting max 0) min ((count GFL_petrosNameOptions) - 1);
        (GFL_petrosNameOptions select _idx) params ["_firstName", "_lastName"];

        // Use Antistasi's identity setter (same pattern as fn_initPetros) so the
        // face + name pair are applied together and MP-synced consistently.
        private _identity = createHashMapFromArray [
            ["face", _desiredFace],
            ["speaker", "Male01GRE"],
            ["pitch", 1.1],
            ["firstName", _firstName],
            ["lastName", _lastName]
        ];
        [petros, _identity] call A3A_fnc_setIdentity;

        // Update group label so the HUD / map shows the chosen name too
        group petros setGroupIdGlobal [_firstName, "GroupColor4"];

        petros setVariable ["GFL_appliedIdentity", _signature, true];

        diag_log format ["[GFL PetrosIdentity] Applied face=%1 firstName=%2 lastName=%3 (h=%4 n=%5)", _desiredFace, _firstName, _lastName, _headSetting, _nameSetting];
    }, 3] call CBA_fnc_addPerFrameHandler;
};

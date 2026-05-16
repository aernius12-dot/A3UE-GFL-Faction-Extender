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
    // Arges_F is a player-controlled unit. Player activates Corvus manually via ACE self-action.
    // Auto-init here would set COR_SysEnabled without COR_fnc_SysInit's tight allowDamage PFH,
    // which would conflict with our faint mechanism. Skip and let the player choose.
    if (typeOf _unit == "Arges_F") exitWith {};
    if (!(backpack _unit in _fccPacks)) exitWith {};
    if (_unit getVariable ["GFL_COR_InitDone", false]) exitWith {};

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
    private _armor = getNumber (configFile >> "cfgVehicles" >> _pbp >> "frameArmor");
    private _frame = getText  (configFile >> "cfgVehicles" >> _pbp >> "frameType");

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

    diag_log format ["[GFL Corvus] unit=%1 pack=%2 frame=%3 armor=%4", _unit, _pbp, _frame, _armor];

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

// Face-uniform matcher: fires once per unit on spawn rather than polling allUnits.
// EntityCreated fires when createUnit is called; identity (face) arrives one frame
// later via remoteExec, so we defer 0.5 s to let setIdentityLocal land.
// Disable per-mission via server debug console: GFL_FaceUniformEnabled = false
GFL_FaceUniformMap = createHashMapFromArray [
    // tacgirls_elmo (27)
    ["alvaface",            "alva_uniform"],         ["balthildeface",       "balthilde_uniform"],
    ["bastiface",           "basti_uniform"],         ["centaureissiface",    "centaureissi_uniform"],
    ["cheetaface",          "cheeta_uniform"],        ["cheyanneface",        "cheyanne_uniform"],
    ["commanderfemaleface", "commanderfemale_uniform"],["commandermaleface",  "commandermale_uniform"],
    ["grozaface",           "groza_uniform"],         ["harpsyface",          "harpsy_uniform"],
    ["helenface",           "helen_uniform"],         ["jiangyuface",         "jiangyu_uniform"],
    ["klukaiface",          "klukai_uniform"],        ["lainiealtface",       "lainiealt_uniform"],
    ["Levaface",            "Leva_uniform"],          ["lindface",            "lind_uniform"],
    ["littaraface",         "littara_uniform"],       ["liushihface",         "liushih_uniform"],
    ["lottaface",           "lotta_uniform"],         ["makiattoface",        "makiatto_uniform"],
    ["mechtyface",          "mechty_uniform"],        ["mitylface",           "mityl_uniform"],
    ["mosinface",           "mosin_uniform"],         ["nagantface",          "nagant_uniform"],
    ["papashaface",         "papasha_uniform"],       ["qiongjiuface",        "qiongjiu_uniform"],
    ["robellaface",         "robella_uniform"],
    // tacgirls_elmo_beta (15)
    ["sakuraface",          "sakura_uniform"],        ["sextansmaidface",     "sextansmaid_uniform"],
    ["sharkryface",         "sharkry_uniform"],       ["simulacrum_oface",    "simulacrum_o_uniform"],
    ["soppoface",           "soppo_uniform"],         ["springfieldface",     "springfield_uniform"],
    ["suomiface",           "suomi_uniform"],         ["tololoface",          "tololo_uniform"],
    ["ullridface",          "ullrid_uniform"],        ["ump9face",            "ump9_uniform"],
    ["vectorface",          "vector_uniform"],        ["vectoraltface",       "vectoralt_uniform"],
    ["voymastinaface",      "voymastina_uniform"],    ["yooheeface",          "yoohee_uniform"],
    ["zhaohuiface",         "zhaohui_uniform"],
    // tacgirls_elmo_century (14 faces → 12 uniforms; aglteama/b share base)
    ["aglteamface",         "aglteam_uniform"],       ["aglteamaface",        "aglteam_uniform"],
    ["aglteambface",        "aglteam_uniform"],       ["andorisface",         "andoris_uniform"],
    ["colphneface",         "colphne_uniform"],       ["dushevnayaface",      "dushevnaya_uniform"],
    ["fayeface",            "faye_uniform"],          ["kseniaface",          "ksenia_uniform"],
    ["nemesisface",         "nemesis_uniform"],       ["nikketaface",         "nikketa_uniform"],
    ["periface",            "peri_uniform"],          ["perityaface",         "peritya_uniform"],
    ["phaetusaface",        "phaetusa_uniform"],      ["sabrinaface",         "sabrina_uniform"],
    // Sangvis Ferri (4)
    ["sangvisguardface",    "sangvisguard_uniform"],  ["sangvisjaegerface",   "sangvisjaeger_uniform"],
    ["sangvisripperface",   "sangvisripper_uniform"], ["sangvisvespidface",   "sangvisvespid_uniform"]
];

addMissionEventHandler ["EntityCreated", {
    params ["_unit"];
    if (!(_unit isKindOf "Man")) exitWith {};
    if (!(missionNamespace getVariable ["GFL_FaceUniformEnabled", true])) exitWith {};
    [{
        params ["_unit"];
        if (isPlayer _unit || !alive _unit) exitWith {};
        if (_unit getVariable ["GFL_FaceUniformDone", false]) exitWith {};
        _unit setVariable ["GFL_FaceUniformDone", true];
        private _face = face _unit;
        private _currentUniform = uniform _unit;
        private _targetUniform = GFL_FaceUniformMap getOrDefault [_face, ""];
        if (_targetUniform isEqualTo "") exitWith {};
        diag_log format ["[GFL FaceUniform] unit=%1 face=%2 current=%3 target=%4", _unit, _face, _currentUniform, _targetUniform];
        if (_currentUniform isEqualTo _targetUniform) exitWith {
            diag_log format ["[GFL FaceUniform] MATCH (no swap needed) unit=%1 face=%2 uniform=%3", _unit, _face, _currentUniform];
        };
        private _loadout = getUnitLoadout _unit;
        private _oldSlot = _loadout # 3;
        private _items = if (count _oldSlot > 1) then { _oldSlot # 1 } else { [] };
        _loadout set [3, [_targetUniform, _items]];
        _unit setUnitLoadout _loadout;
        diag_log format ["[GFL FaceUniform] SWAPPED unit=%1 face=%2 old=%3 new=%4", _unit, _face, _currentUniform, _targetUniform];
    }, [_unit], 0.5] call CBA_fnc_waitAndExecute;
}];

#include "script_component.hpp"

if (!isServer) exitWith {};
if (missionNamespace getVariable ["GFL_DollInitLoaded", false]) exitWith {};
missionNamespace setVariable ["GFL_DollInitLoaded", true];

diag_log "[GFL DollInit] registering face/uniform and ELMO weapon resolver";

GFL_FaceUniformMap = createHashMapFromArray [
    ["alvaface", "alva_uniform"], ["balthildeface", "balthilde_uniform"],
    ["bastiface", "basti_uniform"], ["centaureissiface", "centaureissi_uniform"],
    ["cheetaface", "cheeta_uniform"], ["cheyanneface", "cheyanne_uniform"],
    ["commanderfemaleface", "commanderfemale_uniform"], ["commandermaleface", "commandermale_uniform"],
    ["grozaface", "groza_uniform"], ["harpsyface", "harpsy_uniform"],
    ["helenface", "helen_uniform"], ["jiangyuface", "jiangyu_uniform"],
    ["klukaiface", "klukai_uniform"], ["lainiealtface", "lainiealt_uniform"],
    ["levaface", "Leva_uniform"], ["lindface", "lind_uniform"],
    ["littaraface", "littara_uniform"], ["liushihface", "liushih_uniform"],
    ["lottaface", "lotta_uniform"], ["makiattoface", "makiatto_uniform"],
    ["mechtyface", "mechty_uniform"], ["mitylface", "mityl_uniform"],
    ["mosinface", "mosin_uniform"], ["nagantface", "nagant_uniform"],
    ["papashaface", "papasha_uniform"], ["qiongjiuface", "qiongjiu_uniform"],
    ["robellaface", "robella_uniform"],
    ["sakuraface", "sakura_uniform"], ["sextansmaidface", "sextansmaid_uniform"],
    ["sharkryface", "sharkry_uniform"], ["simulacrum_oface", "simulacrum_o_uniform"],
    ["soppoface", "soppo_uniform"], ["springfieldface", "springfield_uniform"],
    ["suomiface", "suomi_uniform"], ["tololoface", "tololo_uniform"],
    ["ullridface", "ullrid_uniform"], ["ump9face", "ump9_uniform"],
    ["vectorface", "vector_uniform"], ["vectoraltface", "vectoralt_uniform"],
    ["voymastinaface", "voymastina_uniform"], ["yooheeface", "yoohee_uniform"],
    ["zhaohuiface", "zhaohui_uniform"],
    ["aglteamface", "aglteam_uniform"], ["aglteamaface", "aglteam_uniform"],
    ["aglteambface", "aglteam_uniform"], ["andorisface", "andoris_uniform"],
    ["colphneface", "colphne_uniform"], ["dushevnayaface", "dushevnaya_uniform"],
    ["fayeface", "faye_uniform"], ["kseniaface", "ksenia_uniform"],
    ["nemesisface", "nemesis_uniform"], ["nikketaface", "nikketa_uniform"],
    ["periface", "peri_uniform"], ["perityaface", "peritya_uniform"],
    ["phaetusaface", "phaetusa_uniform"], ["sabrinaface", "sabrina_uniform"],
    ["blasterface", "blaster_uniform"], ["mechanistface", "mechanist_uniform"],
    ["spotterface", "spotter_uniform"], ["strikecaptainface", "strikecaptain_uniform"],
    ["feladeface", "felade_uniform"], ["felamedisinface", "felamedisin_uniform"],
    ["urokrakeface", "urokrake_uniform"],
    ["custos036face", "custos036_uniform"], ["niterface", "niter_uniform"],
    ["sextansaltface", "sextansalt_uniform"], ["unitas015face", "unitas015_uniform"],
    ["unitas039face", "unitas039_uniform"],
    ["sangvisguardface", "sangvisguard_uniform"], ["sangvisjaegerface", "sangvisjaeger_uniform"],
    ["sangvisripperface", "sangvisripper_uniform"], ["sangvisvespidface", "sangvisvespid_uniform"]
];

GFL_ElmoSupportedFamilies = ["AR", "SMG", "MG", "RF", "HG"];

private _packForRole = {
    params ["_role"];
    switch (_role) do {
        case "Bulwark": { "TDoll_Bul_Pack" };
        case "Sentinel": { "TDoll_Sent_Pack" };
        case "Support": { "TDoll_Sup_Pack" };
        case "Vanguard": { "TDoll_V_Pack" };
        default { "TDoll_B_Pack" };
    };
};

private _profileRows = [
    ["alvaface", "AlvaFace", "alva_uniform", "Support", "AR", ["an-94", "an94"]],
    ["balthildeface", "BalthildeFace", "balthilde_uniform", "Support", "MG", ["lahti", "m/26", "m26"]],
    ["bastiface", "BastiFace", "basti_uniform", "Support", "HG", ["mark 23", "mk23", "socom"]],
    ["centaureissiface", "CentaureissiFace", "centaureissi_uniform", "Support", "AR", ["g36"]],
    ["cheetaface", "CheetaFace", "cheeta_uniform", "Support", "SMG", ["mp7"]],
    ["cheyanneface", "CheyanneFace", "cheyanne_uniform", "Sentinel", "RF", ["m200", "cheytac"]],
    ["grozaface", "GrozaFace", "groza_uniform", "Bulwark", "AR", ["ots-14", "ots14", "groza"]],
    ["harpsyface", "HarpsyFace", "harpsy_uniform", "Vanguard", "SMG", ["steyr smg", "tmp"]],
    ["helenface", "HelenFace", "helen_uniform", "Bulwark", "SG", ["dp-12", "dp12"]],
    ["jiangyuface", "JiangyuFace", "jiangyu_uniform", "Support", "AR", ["type 97", "type97", "qbz-97", "qbz97"]],
    ["klukaiface", "KlukaiFace", "klukai_uniform", "Sentinel", "AR", ["hk416", "416"]],
    ["lainiealtface", "LainieAltFace", "lainiealt_uniform", "Sentinel", "SMG", ["ump40", "ump-40"]],
    ["levaface", "LevaFace", "Leva_uniform", "Sentinel", "SMG", ["ump45", "ump-45"]],
    ["lindface", "LindFace", "lind_uniform", "Sentinel", "SG", ["aa-12", "aa12"]],
    ["littaraface", "LittaraFace", "littara_uniform", "Sentinel", "MG", ["galil arm", "galil"]],
    ["liushihface", "LiushihFace", "liushih_uniform", "Sentinel", "RF", ["liu", "general liu"]],
    ["lottaface", "LottaFace", "lotta_uniform", "Sentinel", "SG", ["m1 super 90", "super 90", "m1014"]],
    ["makiattoface", "MakiattoFace", "makiatto_uniform", "Sentinel", "RF", ["wa2000", "wa-2000"]],
    ["mechtyface", "MechtyFace", "mechty_uniform", "Support", "AR", ["g11"]],
    ["mitylface", "MitylFace", "mityl_uniform", "Sentinel", "SMG", ["p90"]],
    ["mosinface", "MosinFace", "mosin_uniform", "Sentinel", "RF", ["mosin"]],
    ["nagantface", "NagantFace", "nagant_uniform", "Support", "HG", ["nagant"]],
    ["papashaface", "PapashaFace", "papasha_uniform", "Sentinel", "SMG", ["ppsh", "ppsh-41", "pps-41"]],
    ["qiongjiuface", "QiongjiuFace", "qiongjiu_uniform", "Sentinel", "AR", ["qbz-191", "qbz191"]],
    ["robellaface", "RobellaFace", "robella_uniform", "Sentinel", "SMG", ["r0635", "635"]],
    ["sakuraface", "SakuraFace", "sakura_uniform", "Vanguard", "SMG", ["type 100", "type100"]],
    ["sextansmaidface", "SextansMaidFace", "sextansmaid_uniform", "Support", "BLD", ["night snake"]],
    ["sharkryface", "SharkryFace", "sharkry_uniform", "Sentinel", "AR", ["robinson xcr", "xcr"]],
    ["simulacrum_oface", "Simulacrum_OFace", "simulacrum_o_uniform", "Sentinel", "SMG", ["ump40", "ump-40"]],
    ["soppoface", "SoppoFace", "soppo_uniform", "Sentinel", "AR", ["sopmod", "m4", "m4a1"]],
    ["springfieldface", "SpringfieldFace", "springfield_uniform", "Support", "RF", ["springfield", "m1903"]],
    ["suomiface", "SuomiFace", "suomi_uniform", "Support", "SMG", ["suomi", "kp/-31", "kp31"]],
    ["tololoface", "TololoFace", "tololo_uniform", "Sentinel", "AR", ["ak-alfa", "akalfa", "ak alfa"]],
    ["ullridface", "UllridFace", "ullrid_uniform", "Vanguard", "BLD", ["pluma edge"]],
    ["ump9face", "UMP9Face", "ump9_uniform", "Support", "SMG", ["ump9", "ump-9"]],
    ["vectorface", "VectorFace", "vector_uniform", "Support", "SMG", ["vector", "kriss"]],
    ["vectoraltface", "VectorAltFace", "vectoralt_uniform", "Support", "SMG", ["vector", "kriss"]],
    ["voymastinaface", "VoymastinaFace", "voymastina_uniform", "Sentinel", "AR", ["ak-15", "ak15"]],
    ["yooheeface", "YooheeFace", "yoohee_uniform", "Support", "AR", ["k2"]],
    ["zhaohuiface", "ZhaohuiFace", "zhaohui_uniform", "Vanguard", "SMG", ["cs/ls06", "csls06", "ls06"]],
    ["andorisface", "AndorisFace", "andoris_uniform", "Bulwark", "AR", ["g36k", "g36"]],
    ["colphneface", "ColphneFace", "colphne_uniform", "Support", "HG", ["taurus curve", "curve"]],
    ["dushevnayaface", "DushevnayaFace", "dushevnaya_uniform", "Support", "RF", ["ksvk", "degtyarev"]],
    ["fayeface", "FayeFace", "faye_uniform", "Vanguard", "HG", ["cz75", "cz 75"]],
    ["kseniaface", "KseniaFace", "ksenia_uniform", "Support", "HG", ["stechkin", "aps"]],
    ["nemesisface", "NemesisFace", "nemesis_uniform", "Sentinel", "RF", ["san 511", "san511", "om 50", "om50"]],
    ["nikketaface", "NikketaFace", "nikketa_uniform", "Sentinel", "RF", ["vsk-94", "vsk94"]],
    ["periface", "PeriFace", "peri_uniform", "Bulwark", "SMG", ["mp5"]],
    ["perityaface", "PerityaFace", "peritya_uniform", "Sentinel", "MG", ["pkp", "pecheneg"]],
    ["phaetusaface", "PhaetusaFace", "phaetusa_uniform", "Sentinel", "BLD", ["graythorn"]],
    ["sabrinaface", "SabrinaFace", "sabrina_uniform", "Bulwark", "SG", ["spas-12", "spas12"]]
];

GFL_ElmoProfileMap = createHashMap;
GFL_ElmoProfilesByFamily = createHashMapFromArray [["AR", []], ["SMG", []], ["MG", []], ["RF", []], ["HG", []]];
GFL_ElmoFaceKeys = [];
GFL_ElmoUniforms = [];

{
    _x params ["_key", "_face", "_uniform", "_role", "_family", "_hints"];
    private _profile = [_key, _face, _uniform, _role, _family, _hints, [_role] call _packForRole];
    GFL_ElmoProfileMap set [_key, _profile];
    GFL_ElmoFaceKeys pushBack _key;
    GFL_ElmoUniforms pushBack _uniform;
    if (_family in GFL_ElmoSupportedFamilies) then {
        (GFL_ElmoProfilesByFamily get _family) pushBack _profile;
    };
} forEach _profileRows;

GFL_fnc_weaponSourcePriority = {
    params ["_class"];
    private _lower = toLower _class;
    if (_lower find "rhs" == 0) exitWith { 3 };
    if (_lower find "cup_" == 0) exitWith { 1 };
    2
};

GFL_fnc_getEffectiveWeaponFamily = {
    params ["_family"];
    if (_family isEqualTo "HG") exitWith { "SMG" };
    _family
};

GFL_fnc_buildWeaponCatalog = {
    if !(isNil "GFL_WeaponCatalog") exitWith { GFL_WeaponCatalog };

    private _catalog = createHashMapFromArray [["AR", []], ["SMG", []], ["MG", []], ["RF", []], ["SG", []], ["HG", []]];
    {
        private _cfg = _x;
        if (getNumber (_cfg >> "scope") < 2) then { continue };

        private _class = configName _cfg;
        private _itemType = [_class] call BIS_fnc_itemType;
        _itemType params [["_category", ""], ["_subType", ""]];
        if !(_category isEqualTo "Weapon") then { continue };

        private _family = switch (toLower _subType) do {
            case "assaultrifle": { "AR" };
            case "submachinegun": { "SMG" };
            case "machinegun": { "MG" };
            case "sniperrifle": { "RF" };
            case "shotgun": { "SG" };
            case "handgun": { "HG" };
            case "pistol": { "HG" };
            default {
                if (_class isKindOf ["Rifle_Long_Base_F", configFile >> "CfgWeapons"]) then {
                    "RF"
                } else {
                    if (_class isKindOf ["Rifle_Base_F", configFile >> "CfgWeapons"]) then { "AR" } else { "" };
                };
            };
        };
        if (_family isEqualTo "") then { continue };

        private _displayName = getText (_cfg >> "displayName");
        if (_displayName isEqualTo "") then { continue };

        private _magazines = getArray (_cfg >> "magazines");
        private _hasUGL = false;
        private _ubMags = [];
        {
            if (_hasUGL) exitWith {};
            if (_x isEqualTo "this") then { continue };
            private _candidateMags = getArray (_cfg >> _x >> "magazines");
            if (_candidateMags isEqualTo []) then { continue };
            _hasUGL = true;
            _ubMags = _candidateMags;
        } forEach getArray (_cfg >> "muzzles");

        private _entry = createHashMapFromArray [
            ["class", _class],
            ["displayName", _displayName],
            ["searchText", toLower (_class + " " + _displayName)],
            ["family", _family],
            ["magazines", _magazines],
            ["ubMagazines", _ubMags],
            ["hasUGL", _hasUGL],
            ["sourcePriority", [_class] call GFL_fnc_weaponSourcePriority]
        ];
        (_catalog get _family) pushBack _entry;
    } forEach ("true" configClasses (configFile >> "CfgWeapons"));

    GFL_WeaponCatalog = _catalog;
    diag_log "[GFL DollInit] weapon catalog built";
    _catalog
};

GFL_fnc_applyFaceUniform = {
    params ["_unit", "_uniform", ["_face", ""]];
    if (!local _unit) exitWith {};

    if (_face != "" && {face _unit != _face}) then {
        _unit setFace _face;
    };

    if (uniform _unit isEqualTo _uniform) exitWith {
        _unit setVariable ["GFL_FaceUniformDone", true];
    };

    private _loadout = getUnitLoadout _unit;
    private _uniformSlot = _loadout param [3, []];
    private _uniformItems = if (_uniformSlot isEqualType [] && {count _uniformSlot > 1}) then { _uniformSlot # 1 } else { [] };
    _loadout set [3, [_uniform, _uniformItems]];
    _unit setUnitLoadout _loadout;
    _unit setVariable ["GFL_FaceUniformDone", true];
};

GFL_fnc_applyFaceUniformFromCurrentFace = {
    params ["_unit"];
    private _targetUniform = GFL_FaceUniformMap getOrDefault [toLower (face _unit), ""];
    if (_targetUniform isEqualTo "") exitWith { false };
    [_unit, _targetUniform] call GFL_fnc_applyFaceUniform;
    true
};

GFL_fnc_isFaceUniformResolved = {
    params ["_unit"];
    private _targetUniform = GFL_FaceUniformMap getOrDefault [toLower (face _unit), ""];
    if (_targetUniform isEqualTo "") exitWith { true };
    uniform _unit isEqualTo _targetUniform
};

GFL_fnc_getUnitRoleFamily = {
    params ["_unit"];
    if (_unit getUnitTrait "Medic") exitWith { "HG" };

    private _primary = primaryWeapon _unit;
    if (_primary isEqualTo "") exitWith { "" };

    private _itemType = [_primary] call BIS_fnc_itemType;
    _itemType params [["_category", ""], ["_subType", ""]];
    private _subTypeLower = toLower _subType;

    if (_subTypeLower isEqualTo "machinegun") exitWith { "MG" };
    if (_subTypeLower isEqualTo "submachinegun") exitWith { "SMG" };
    if (_subTypeLower isEqualTo "sniperrifle") exitWith { "RF" };
    if (_subTypeLower isEqualTo "shotgun") exitWith { "SG" };
    if (_subTypeLower in ["handgun", "pistol"]) exitWith { "HG" };
    if ((binocular _unit) isEqualTo "Rangefinder") exitWith { "RF" };
    "AR"
};

GFL_fnc_unitRequiresUGL = {
    params ["_unit"];
    private _primarySlot = (getUnitLoadout _unit) param [0, []];
    if !(_primarySlot isEqualType []) exitWith { false };
    count (_primarySlot param [5, []]) > 0
};

GFL_fnc_scoreWeaponCandidate = {
    params ["_entry", "_hints"];
    private _searchText = _entry get "searchText";
    private _score = 0;
    {
        private _hint = toLower _x;
        if (_hint != "" && {_searchText find _hint >= 0}) then {
            _score = _score + 1000;
        };
    } forEach _hints;
    _score + ((_entry get "sourcePriority") * 100)
};

GFL_fnc_selectWeaponForProfile = {
    params ["_profile", "_requireUGL"];
    _profile params ["", "", "", "", "_family", "_hints"];

    private _entries = +((call GFL_fnc_buildWeaponCatalog) getOrDefault [[_family] call GFL_fnc_getEffectiveWeaponFamily, []]);
    if (_requireUGL) then {
        _entries = _entries select { _x get "hasUGL" };
    };
    if (_entries isEqualTo []) exitWith { createHashMapFromArray [["score", -1]] };

    private _bestScore = -1;
    private _bestEntries = [];
    {
        private _score = [_x, _hints] call GFL_fnc_scoreWeaponCandidate;
        if (_score > _bestScore) then {
            _bestScore = _score;
            _bestEntries = [_x];
        } else {
            if (_score isEqualTo _bestScore) then {
                _bestEntries pushBack _x;
            };
        };
    } forEach _entries;

    if (_bestEntries isEqualTo []) exitWith { createHashMapFromArray [["score", -1]] };
    private _picked = selectRandom _bestEntries;
    _picked set ["score", _bestScore];
    _picked
};

GFL_fnc_selectElmoProfile = {
    params ["_unit", "_family", "_requireUGL"];

    private _lockedKey = _unit getVariable ["GFL_ElmoProfileKey", ""];
    if (_lockedKey != "") then {
        private _lockedProfile = GFL_ElmoProfileMap getOrDefault [_lockedKey, []];
        if !(_lockedProfile isEqualTo []) then {
            _lockedProfile params ["", "", "", "", "_lockedFamily"];
            if (_lockedFamily isEqualTo _family) then {
                private _lockedWeapon = [_lockedProfile, _requireUGL] call GFL_fnc_selectWeaponForProfile;
                if ((_lockedWeapon getOrDefault ["score", -1]) >= 0) exitWith {
                    [_lockedProfile, _lockedWeapon]
                };
            };
        };
    };

    private _candidates = +(GFL_ElmoProfilesByFamily getOrDefault [_family, []]);
    if (_candidates isEqualTo []) exitWith { [] };

    private _currentProfile = GFL_ElmoProfileMap getOrDefault [toLower (face _unit), []];
    private _bestScore = -1;
    private _bestPairs = [];
    {
        private _weaponEntry = [_x, _requireUGL] call GFL_fnc_selectWeaponForProfile;
        private _score = _weaponEntry getOrDefault ["score", -1];
        if (!(_currentProfile isEqualTo []) && {_x isEqualTo _currentProfile}) then {
            _score = _score + 50;
        };

        if (_score > _bestScore) then {
            _bestScore = _score;
            _bestPairs = [[_x, _weaponEntry]];
        } else {
            if (_score isEqualTo _bestScore) then {
                _bestPairs pushBack [_x, _weaponEntry];
            };
        };
    } forEach _candidates;

    if (_bestPairs isEqualTo []) exitWith { [] };
    selectRandom _bestPairs
};

GFL_fnc_swapPrimaryWeapon = {
    params ["_unit", "_weaponEntry"];

    private _newClass = _weaponEntry getOrDefault ["class", ""];
    if (_newClass isEqualTo "") exitWith {};

    private _oldLoadout = getUnitLoadout _unit;
    private _primarySlot = _oldLoadout param [0, []];
    private _oldPrimary = primaryWeapon _unit;
    private _oldPrimaryMags = _primarySlot param [4, []];
    private _oldUbMags = _primarySlot param [5, []];
    private _magInfo = magazinesAmmoFull _unit;
    private _primaryMagCount = { (_x # 0) in _oldPrimaryMags } count _magInfo;
    private _ubMagCount = { (_x # 0) in _oldUbMags } count _magInfo;

    {
        _unit removeMagazines _x;
    } forEach ((_oldPrimaryMags + _oldUbMags) arrayIntersect (_oldPrimaryMags + _oldUbMags));

    if (_oldPrimary != "") then {
        _unit removeWeaponGlobal _oldPrimary;
    };

    _unit addWeaponGlobal _newClass;
    {
        if (_x != "") then {
            _unit addPrimaryWeaponItem _x;
        };
    } forEach [
        _primarySlot param [1, ""],
        _primarySlot param [2, ""],
        _primarySlot param [3, ""],
        _primarySlot param [6, ""]
    ];

    private _newMags = _weaponEntry getOrDefault ["magazines", []];
    if !(_newMags isEqualTo []) then {
        private _defaultPrimaryMag = _newMags # 0;
        _unit addPrimaryWeaponItem _defaultPrimaryMag;
        private _defaultPrimaryCount = switch (_weaponEntry getOrDefault ["family", "AR"]) do {
            case "MG": { 4 };
            case "RF": { 6 };
            default { 6 };
        };
        for "_i" from 1 to ((_primaryMagCount max _defaultPrimaryCount) - 1) do {
            _unit addMagazine _defaultPrimaryMag;
        };
    };

    private _newUbMags = _weaponEntry getOrDefault ["ubMagazines", []];
    if !(_newUbMags isEqualTo []) then {
        private _defaultUbMag = _newUbMags # 0;
        for "_i" from 1 to (_ubMagCount max 10) do {
            _unit addMagazine _defaultUbMag;
        };
    };
};

GFL_fnc_assignFccBackpack = {
    params ["_unit", "_fccPack"];
    if (_fccPack isEqualTo "") exitWith {};
    if !(isClass (configFile >> "CfgVehicles" >> _fccPack)) exitWith {};

    private _loadout = getUnitLoadout _unit;
    private _backpackSlot = _loadout param [5, []];
    private _backpackItems = if (_backpackSlot isEqualType [] && {count _backpackSlot > 1}) then { _backpackSlot # 1 } else { [] };
    _loadout set [5, [_fccPack, _backpackItems]];
    _unit setUnitLoadout _loadout;
};

GFL_fnc_isElmoResolved = {
    params ["_unit", "_face", "_uniform", "_weaponClass", "_fccPack"];
    if (toLower (face _unit) != toLower _face) exitWith { false };
    if !(uniform _unit isEqualTo _uniform) exitWith { false };
    if (_weaponClass != "" && {primaryWeapon _unit != _weaponClass}) exitWith { false };
    if (_fccPack != "" && {isClass (configFile >> "CfgVehicles" >> "TDoll_B_Pack")} && {backpack _unit != _fccPack}) exitWith { false };
    true
};

GFL_fnc_isElmoUnit = {
    params ["_unit"];
    // ELMO can be used as either Occupant or Invader, so allow both military AI sides.
    // Keeping this off resistance/civilian prevents the ELMO weapon resolver from
    // touching GnK rebels, which intentionally share the same TacGirls identities.
    if !((side group _unit) in [west, east]) exitWith { false };
    (toLower (face _unit) in GFL_ElmoFaceKeys) || (uniform _unit in GFL_ElmoUniforms)
};

GFL_fnc_tryResolveElmoUnit = {
    params ["_unit"];
    if !([_unit] call GFL_fnc_isElmoUnit) exitWith { false };

    private _family = [_unit] call GFL_fnc_getUnitRoleFamily;
    if !(_family in GFL_ElmoSupportedFamilies) exitWith {
        [_unit] call GFL_fnc_applyFaceUniformFromCurrentFace;
        true
    };

    private _selection = [_unit, _family, [_unit] call GFL_fnc_unitRequiresUGL] call GFL_fnc_selectElmoProfile;
    if (_selection isEqualTo []) exitWith {
        [_unit] call GFL_fnc_applyFaceUniformFromCurrentFace;
        true
    };

    _selection params ["_profile", "_weaponEntry"];
    _profile params ["_profileKey", "_face", "_uniform", "_role", "", "", "_fccPack"];
    private _weaponClass = _weaponEntry getOrDefault ["class", ""];

    _unit setVariable ["GFL_ElmoProfileKey", _profileKey];

    [_unit, _uniform, _face] call GFL_fnc_applyFaceUniform;
    [_unit, _weaponEntry] call GFL_fnc_swapPrimaryWeapon;

    if (isClass (configFile >> "CfgVehicles" >> "TDoll_B_Pack")) then {
        [_unit, _fccPack] call GFL_fnc_assignFccBackpack;
    };

    // Re-apply after weapon/backpack edits so late loadout churn has to fight a stable target.
    [_unit, _uniform, _face] call GFL_fnc_applyFaceUniform;

    diag_log format ["[GFL DollInit] ELMO resolved unit=%1 face=%2 role=%3 family=%4 weapon=%5", _unit, _face, _role, _family, _weaponEntry getOrDefault ["class", ""]];
    [_unit, _face, _uniform, _weaponClass, _fccPack] call GFL_fnc_isElmoResolved
};

GFL_fnc_processDollUnit = {
    params ["_unit"];
    if (!alive _unit || isPlayer _unit || !local _unit) exitWith {};
    if (_unit getVariable ["GFL_DollInitDone", false]) then {
        if ([_unit] call GFL_fnc_isElmoUnit) then {
            private _lockedKey = _unit getVariable ["GFL_ElmoProfileKey", ""];
            if (_lockedKey != "") then {
                private _lockedProfile = GFL_ElmoProfileMap getOrDefault [_lockedKey, []];
                if !(_lockedProfile isEqualTo []) then {
                    _lockedProfile params ["", "_face", "_uniform", "", "", "", "_fccPack"];
                    if ([_unit, _face, _uniform, primaryWeapon _unit, _fccPack] call GFL_fnc_isElmoResolved) exitWith {};
                };
            };
        } else {
            if ([_unit] call GFL_fnc_isFaceUniformResolved) exitWith {};
        };
        _unit setVariable ["GFL_DollInitDone", false];
    };

    if ([_unit] call GFL_fnc_isElmoUnit) exitWith {
        if ([_unit] call GFL_fnc_tryResolveElmoUnit) then {
            _unit setVariable ["GFL_DollInitDone", true];
        };
    };

    if ([_unit] call GFL_fnc_applyFaceUniformFromCurrentFace) then {
        _unit setVariable ["GFL_DollInitDone", true];
    } else {
        _unit setVariable ["GFL_DollInitDone", false];
    };
};

call GFL_fnc_buildWeaponCatalog;

addMissionEventHandler ["EntityCreated", {
    params ["_unit"];
    if (!(_unit isKindOf "Man") || isPlayer _unit) exitWith {};
    [{ params ["_unit"]; [_unit] call GFL_fnc_processDollUnit; }, [_unit], 1] call CBA_fnc_waitAndExecute;
}];

[{
    {
        [_x] call GFL_fnc_processDollUnit;
    } forEach allUnits;
}, [], 2] call CBA_fnc_waitAndExecute;

[{
    {
        [_x] call GFL_fnc_processDollUnit;
    } forEach allUnits;
}, 15, []] call CBA_fnc_addPerFrameHandler;

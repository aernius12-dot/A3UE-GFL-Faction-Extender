// Griffin & Kryuger PMC (Rebel / Player Faction)

///////////////////////////
//   Rebel Information   //
///////////////////////////

// &amp; is the XML entity for & — faction name is inserted verbatim into parseText
// contexts (status bar, popups, save notifications) throughout A3A core; raw & would
// break the structured-text parser and corrupt the HUD display.
["name", "Griffin &amp; Kryuger PMC"] call _fnc_saveToTemplate;

["flag", "Flag_FIA_F"] call _fnc_saveToTemplate;
["flagTexture", "\x\A3UE\addons\templates\data\gnk_logo_co.paa"] call _fnc_saveToTemplate;
["flagMarkerType", "flag_FIA"] call _fnc_saveToTemplate;

//////////////////////////
//       Vehicles       //
//////////////////////////
// GnK PMC uses independent vehicles + EG Mecha for heavy support.
// Civilian vehicles are kept vanilla for immersion.

private _vehiclesBasic = ["I_Quadbike_01_F", "I_MRAP_03_F"];
private _vehiclesLightUnarmed = ["I_MRAP_03_F"];
private _vehiclesLightArmed = ["I_MRAP_03_gmg_F", "I_MRAP_03_hmg_F"];
private _vehiclesAt = ["I_MRAP_03_gmg_F"];
private _VehTruck = ["I_Truck_02_transport_F", "I_Truck_02_covered_F"];
private _vehicleAA = ["I_APC_Wheeled_03_cannon_F"];
private _vehiclesBoat = ["I_Boat_Armed_01_minigun_F", "I_C_Boat_Transport_02_F"];
private _vehiclesMedical = [];
private _vehiclesSupply = ["I_Truck_02_box_F"];
private _vehiclePlane = [];
private _vehicleCivPlane = ["C_Plane_Civil_01_F"];
private _vehiclesCivCar = ["C_Offroad_01_F", "C_Hatchback_01_F", "C_SUV_01_F"];
private _CivTruck = ["C_Truck_02_transport_F", "C_Truck_02_covered_F"];
private _civHelicopters = ["C_Heli_Light_01_civil_F"];
private _CivBoat = ["C_Boat_Civil_01_F", "C_Rubberboat"];

if (isClass (configFile >> "cfgVehicles" >> "EG_Mecha_FourFoot")) then {
    _vehiclesLightArmed pushBack "EG_Mecha_FourFoot";
};

// Sci-Fi vehicles pack: replace default squad transport with the Bearcat IFV
// (TKE_Ext_Bearcat_Autocannon — 30mm autocannon, 3 crew + 8 passengers)
if (isClass (configFile >> "cfgVehicles" >> "TKE_Ext_Bearcat_Autocannon")) then {
    _VehTruck = ["TKE_Ext_Bearcat_Autocannon"];
};

["vehiclesCivPlane", _vehicleCivPlane] call _fnc_saveToTemplate;
["vehiclesCivSupply", _vehiclesSupply] call _fnc_saveToTemplate;
["vehiclesMedical", _vehiclesMedical] call _fnc_saveToTemplate;
["vehiclesBoat", _vehiclesBoat] call _fnc_saveToTemplate;
["vehiclesBasic", _vehiclesBasic] call _fnc_saveToTemplate;
["vehiclesPlane", _vehiclePlane] call _fnc_saveToTemplate;
["vehiclesCivTruck", _CivTruck] call _fnc_saveToTemplate;
["vehiclesTruck", _VehTruck] call _fnc_saveToTemplate;
["vehiclesCivBoat", _CivBoat] call _fnc_saveToTemplate;
["vehiclesAA", _vehicleAA] call _fnc_saveToTemplate;
["vehiclesCivCar", _vehiclesCivCar] call _fnc_saveToTemplate;
["vehiclesCivHeli", _civHelicopters] call _fnc_saveToTemplate;
["vehiclesLightUnarmed", _vehiclesLightUnarmed] call _fnc_saveToTemplate;
["vehiclesLightArmed", _vehiclesLightArmed] call _fnc_saveToTemplate;
["vehiclesAT", _vehiclesAt] call _fnc_saveToTemplate;

["staticMGs", ["I_HMG_01_F", "I_HMG_01_high_F"]] call _fnc_saveToTemplate;
["staticAT", ["I_static_AT_F"]] call _fnc_saveToTemplate;
["staticAA", ["I_static_AA_F"]] call _fnc_saveToTemplate;
["staticMortars", ["I_Mortar_01_F"]] call _fnc_saveToTemplate;
["staticMortarMagHE", "3Rnd_82mm_Mo_shells"] call _fnc_saveToTemplate;
["staticMortarMagSmoke", "3Rnd_82mm_Mo_Smoke_white"] call _fnc_saveToTemplate;

["minesAT", ["ATMine_Range_Mag", "SLAMDirectionalMine_Wire_Mag"]] call _fnc_saveToTemplate;
["minesAPERS", ["ClaymoreDirectionalMine_Remote_Mag", "APERSMine_Range_Mag",
    "APERSBoundingMine_Range_Mag", "APERSTripMine_Wire_Mag"]] call _fnc_saveToTemplate;

["breachingExplosivesAPC", [["DemoCharge_Remote_Mag", 1]]] call _fnc_saveToTemplate;
["breachingExplosivesTank", [["SatchelCharge_Remote_Mag", 1], ["DemoCharge_Remote_Mag", 2]]] call _fnc_saveToTemplate;
["lootCrate", "Box_FIA_Support_F"] call _fnc_saveToTemplate;
["rallyPoint", "Flag_FIA_F"] call _fnc_saveToTemplate;

["variants", []] call _fnc_saveToTemplate;

///////////////////////////
//  Rebel Starting Gear  //
///////////////////////////
// PMC starting kit — better than a standard guerrilla band.

private _initialRebelEquipment = [
    "hgun_P07_F",
    "arifle_MXC_F",
    "SMG_01_F",
    "hgun_PDW2000_F",
    "klukaiGun",
    "vectorGun",
    "jiangyuGun",
    "jiangyuOptic",
    "belkaGun",
    "belkaOptic",
    "30Rnd_65x39_caseless_mag", "30Rnd_65x39_caseless_mag", "30Rnd_65x39_caseless_mag",
    "30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag",
    "30Rnd_45ACP_Mag_SMG_01", "30Rnd_45ACP_Mag_SMG_01", "30Rnd_45ACP_Mag_SMG_01",
    "10Rnd_338_Mag", "10Rnd_338_Mag", "10Rnd_338_Mag",
    "20Rnd_762x51_Mag", "20Rnd_762x51_Mag", "20Rnd_762x51_Mag",
    "16Rnd_9x21_Mag", "16Rnd_9x21_Mag",
    "30Rnd_9x21_Mag", "30Rnd_9x21_Mag",
    "HandGrenade", "HandGrenade", "SmokeShell", "SmokeShell",
    ["IEDUrbanSmall_Remote_Mag", 5], ["IEDLandSmall_Remote_Mag", 5],
    ["IEDUrbanBig_Remote_Mag", 2], ["IEDLandBig_Remote_Mag", 2],
    "V_PlateCarrier1_rgr",
    "V_PlateCarrier2_rgr",
    "V_BandollierB_rgr",
    "V_BandollierB_oli",
    "V_Rangemaster_belt",
    "bc036_invisible_carrier",
    "bc036_invisible_carrier_special",
    "bc036_invisible_tacvest",
    "bc036_invisible_chestrig",
    "bc036_invisible_light_combat",
    "bc036_invisible_enhanced_combat",
    "bc036_invisible_special_purpose",
    "bc036_invisible_assassin",
    "bc036_invisible_combat",
    "bc036_invisible_defender",
    "bc036_invisible_protector",
    "bc036_invisible_stealth_combat",
    "bc036_invisible_crew",
    "bc036_invisible_deckcrew",
    "bc036_invisible_heli_crew",
    "bc036_invisible_heli_pilot",
    "bc036_invisible_pilot",
    // FCC backpacks are added conditionally below (requires CORVUS mod)
    "Binocular",
    "acc_flashlight",
    ["launch_RPG32_F", 1], ["RPG32_F", 3], ["RPG32_HE_F", 2],
    "Chemlight_blue", "Chemlight_green", "Chemlight_red", "Chemlight_yellow"
];

if (isClass (configFile >> "cfgVehicles" >> "TDoll_B_Pack")) then {
    _initialRebelEquipment append [
        "TDoll_B_Pack", "TDoll_V_Pack", "TDoll_Sup_Pack", "TDoll_Sent_Pack", "TDoll_Bul_Pack"
    ];
};

if (A3A_hasTFAR) then { _initialRebelEquipment append ["tf_microdagr", "tf_anprc154"]; };
if (A3A_hasTFAR && startWithLongRangeRadio) then { _initialRebelEquipment append ["tf_anprc155", "tf_anprc155_coyote"]; };
if (A3A_hasTFARBeta) then { _initialRebelEquipment append ["TFAR_microdagr", "TFAR_anprc154"]; };
if (A3A_hasTFARBeta && startWithLongRangeRadio) then { _initialRebelEquipment append ["TFAR_anprc155", "TFAR_anprc155_coyote"]; };

["initialRebelEquipment", _initialRebelEquipment] call _fnc_saveToTemplate;

/////////////////////
//    Appearance   //
/////////////////////
// TacGirls uniforms ARE the T-Doll character models. bc036 Invisible Gear hides vests/helmets visually.

private _rebUniforms = [
    // tacgirls_elmo (27)
    "alva_uniform", "balthilde_uniform", "basti_uniform", "centaureissi_uniform",
    "cheeta_uniform", "cheyanne_uniform",
    "groza_uniform", "harpsy_uniform", "helen_uniform", "jiangyu_uniform",
    "klukai_uniform", "lainiealt_uniform", "Leva_uniform", "lind_uniform",
    "littara_uniform", "liushih_uniform", "lotta_uniform", "makiatto_uniform",
    "mechty_uniform", "mityl_uniform", "mosin_uniform", "nagant_uniform",
    "papasha_uniform", "qiongjiu_uniform", "robella_uniform",
    // tacgirls_elmo_beta (18)
    "sakura_uniform", "sextansmaid_uniform", "sharkry_uniform",
    "simulacrum_o_uniform",
    "soppo_uniform", "springfield_uniform", "suomi_uniform", "tololo_uniform",
    "ullrid_uniform", "ump9_uniform", "vector_uniform", "vectoralt_uniform",
    "voymastina_uniform", "yoohee_uniform", "zhaohui_uniform",
    // tacgirls_elmo_century (12 — aglteama/aglteamb share aglteam_uniform)
    "aglteam_uniform", "andoris_uniform", "colphne_uniform", "dushevnaya_uniform",
    "faye_uniform", "ksenia_uniform", "nemesis_uniform", "nikketa_uniform",
    "peri_uniform", "peritya_uniform", "phaetusa_uniform", "sabrina_uniform"
];

private _headgear = [];

["uniforms", _rebUniforms] call _fnc_saveToTemplate;
["headgear", _headgear] call _fnc_saveToTemplate;

/////////////////////
///  Identities   ///
/////////////////////

private _faces = [
    // tacgirls_elmo (27)
    "alvaface", "balthildeface", "bastiface", "centaureissiface",
    "cheetaface", "cheyanneface",
    "grozaface", "harpsyface", "helenface", "jiangyuface",
    "klukaiface", "lainiealtface", "Levaface", "lindface",
    "littaraface", "liushihface", "lottaface", "makiattoface",
    "mechtyface", "mitylface", "mosinface", "nagantface",
    "papashaface", "qiongjiuface", "robellaface",
    // tacgirls_elmo_beta (18)
    "sakuraface", "sextansmaidface", "sharkryface",
    "simulacrum_oface",
    "soppoface", "springfieldface", "suomiface", "tololoface",
    "ullridface", "ump9face", "vectorface", "vectoraltface",
    "voymastinaface", "yooheeface", "zhaohuiface",
    // tacgirls_elmo_century (14)
    "aglteamface", "aglteamaface", "aglteambface",
    "andorisface", "colphneface", "dushevnayaface", "fayeface",
    "kseniaface", "nemesisface", "nikketaface", "periface",
    "perityaface", "phaetusaface", "sabrinaface"
];

["voices", ["FemaleCV2CHI"]] call _fnc_saveToTemplate;
["faces", _faces] call _fnc_saveToTemplate;

//////////////////////////
//       Loadouts       //
//////////////////////////

private _loadoutData = call _fnc_createLoadoutData;
private _vests = ["bc036_invisible_carrier", "bc036_invisible_tacvest", "bc036_invisible_chestrig", "bc036_invisible_combat", "bc036_invisible_defender", "bc036_invisible_protector"];

_loadoutData set ["maps", ["ItemMap"]];
_loadoutData set ["watches", ["ItemWatch"]];
_loadoutData set ["compasses", ["ItemCompass"]];
_loadoutData set ["binoculars", ["Binocular"]];

// Uniforms reuse rebel uniform list above
_loadoutData set ["uniforms", _rebUniforms];
_loadoutData set ["vests", _vests];
_loadoutData set ["petrosUniforms", ["commandermale_uniform"]];
_loadoutData set ["petrosVests", ["bc036_invisible_carrier_special", "bc036_invisible_special_purpose"]];
_loadoutData set ["slUniforms", ["qiongjiu_uniform", "littara_uniform", "jiangyu_uniform"]];

// FCC backpacks — all five frame types available to every GnK soldier
if (isClass (configFile >> "cfgVehicles" >> "TDoll_B_Pack")) then {
    _loadoutData set ["backpacks", ["TDoll_B_Pack","TDoll_V_Pack","TDoll_Sup_Pack","TDoll_Sent_Pack","TDoll_Bul_Pack"]];
};

_loadoutData set ["headgear", []];
_loadoutData set ["helmets", ["bc036_invisible_light_combat", "bc036_invisible_special_purpose"]];
_loadoutData set ["slHat",   ["bc036_invisible_special_purpose", "bc036_invisible_enhanced_combat"]];
_loadoutData set ["sniHats", ["bc036_invisible_assassin", "bc036_invisible_stealth_combat"]];
_loadoutData set ["glasses", []];
_loadoutData set ["goggles", []];
_loadoutData set ["facemask", []];
_loadoutData set ["balaclavas", []];
_loadoutData set ["argoFacemask", []];
_loadoutData set ["facewearWS", []];
_loadoutData set ["facewearContact", []];
_loadoutData set ["facewearLawsOfWar", []];
_loadoutData set ["facewearGM", []];
_loadoutData set ["facewearCLSA", []];
_loadoutData set ["facewearSOG", []];
_loadoutData set ["facewearSPE", []];

_loadoutData set ["items_medical_basic", ["BASIC"] call A3A_fnc_itemset_medicalSupplies];
_loadoutData set ["items_medical_standard", ["STANDARD"] call A3A_fnc_itemset_medicalSupplies];
_loadoutData set ["items_medical_medic", ["MEDIC"] call A3A_fnc_itemset_medicalSupplies];
_loadoutData set ["items_miscEssentials", [] call A3A_fnc_itemset_miscEssentials];

///////////////////////////////////
//  Rebel Squad Leader Template  //
///////////////////////////////////

private _squadLeaderTemplate = {
    [["slUniforms", "uniforms"] call _fnc_fallback] call _fnc_setUniform;
    ["vests"] call _fnc_setVest;
    ["backpacks"] call _fnc_setBackpack;
    [[]] call _fnc_setFacewear;
    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["binoculars"] call _fnc_addBinoculars;
};

private _petrosTemplate = {
    [["petrosUniforms", "slUniforms"] call _fnc_fallback] call _fnc_setUniform;
    [["petrosVests", "vests"] call _fnc_fallback] call _fnc_setVest;
    ["backpacks"] call _fnc_setBackpack;
    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["binoculars"] call _fnc_addBinoculars;
};

private _riflemanTemplate = {
    ["uniforms"] call _fnc_setUniform;
    ["vests"] call _fnc_setVest;
    ["backpacks"] call _fnc_setBackpack;
    [[]] call _fnc_setFacewear;
    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
};

//////////////////////////
//    Rebel Unit Types  //
//////////////////////////

private _prefix = "militia";
private _unitTypes = [
    ["Petros",            _petrosTemplate],
    ["SquadLeader",       _squadLeaderTemplate],
    ["Rifleman",          _riflemanTemplate],
    ["staticCrew",        _riflemanTemplate],
    ["Medic",             _riflemanTemplate, [["medic", true]]],
    ["Engineer",          _riflemanTemplate, [["engineer", true]]],
    ["ExplosivesExpert",  _riflemanTemplate, [["explosiveSpecialist", true]]],
    ["Grenadier",         _riflemanTemplate],
    ["LAT",               _riflemanTemplate],
    ["AT",                _riflemanTemplate],
    ["AA",                _riflemanTemplate],
    ["MachineGunner",     _riflemanTemplate],
    ["Marksman",          _riflemanTemplate],
    ["Sniper",            _riflemanTemplate],
    ["Unarmed",           _riflemanTemplate]
];

[_prefix, _unitTypes, _loadoutData] call _fnc_generateAndSaveUnitsToTemplate;

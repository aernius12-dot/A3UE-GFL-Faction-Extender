// GFL - Paradeus Remnants (Rival Rebels)

["name", "GFL - Paradeus Remnants"] call _fnc_saveToTemplate;
["nameLeader", "Paradeus Commander"] call _fnc_saveToTemplate;

/////////////////////
//   Identities    //
/////////////////////

private _faces = [
    "custos036face", "niterface", "sextansaltface",
    "unitas015face", "unitas039face"
];

["voices", ["Male10ENG", "FemaleCV2CHI", "Male08ENG", "Male03ENG"]] call _fnc_saveToTemplate;
["faces", _faces] call _fnc_saveToTemplate;

//////////////////////////
//       Vehicles       //
//////////////////////////
// Rivals use lighter OPFOR vehicles — no heavy armor or aircraft.

["ammobox", "Box_CSAT_Support_F"] call _fnc_saveToTemplate;
["surrenderCrate", "Box_CSAT_Wps_F"] call _fnc_saveToTemplate;

private _lightArmedVehicles = ["O_MRAP_02_hmg_F", "O_MRAP_02_gmg_F"];
private _lightUnarmedVehicles = ["O_MRAP_02_F", "O_Quadbike_01_F"];
private _apc = [];
private _tanks = [];
private _helis = ["O_Heli_Light_02_unarmed_F"];
private _uav = ["O_UAV_01_F"];
private _trucks = ["O_Truck_02_transport_F"];

["staticLowWeapons", ["O_HMG_01_F"]] call _fnc_saveToTemplate;
["staticAT", ["O_static_AT_F"]] call _fnc_saveToTemplate;
["staticMortars", ["O_Mortar_01_F"]] call _fnc_saveToTemplate;
["mortarMagazineHE", "3Rnd_82mm_Mo_shells"] call _fnc_saveToTemplate;
["handGrenadeAmmo", ["GrenadeHand"]] call _fnc_saveToTemplate;
["mortarAmmo", ["Sh_82mm_AMOS"]] call _fnc_saveToTemplate;

["minefieldAT", ["ATMine"]] call _fnc_saveToTemplate;
["minefieldAPERS", ["APERSMine", "APERSBoundingMine"]] call _fnc_saveToTemplate;

["vehiclesRivalsLightArmed", _lightArmedVehicles] call _fnc_saveToTemplate;
["vehiclesRivalsTrucks", _trucks] call _fnc_saveToTemplate;
["vehiclesRivalsCars", _lightUnarmedVehicles] call _fnc_saveToTemplate;
["vehiclesRivalsAPCs", _apc] call _fnc_saveToTemplate;
["vehiclesRivalsTanks", _tanks] call _fnc_saveToTemplate;
["vehiclesRivalsHelis", _helis] call _fnc_saveToTemplate;
["vehiclesRivalsUavs", _uav] call _fnc_saveToTemplate;

["animations", []] call _fnc_saveToTemplate;
["variants", []] call _fnc_saveToTemplate;

//////////////////////////
//       Loadouts       //
//////////////////////////

private _loadoutData = call _fnc_createLoadoutData;

// GL ammo mix
private _glammo = ["1Rnd_HE_Grenade_shell", "1Rnd_HE_Grenade_shell",
    "1Rnd_HE_Grenade_shell", "UGL_FlareWhite_F", "1Rnd_Smoke_Grenade_shell"];

// ----- Uniforms / Appearance -----
private _uniforms = [
    "custos036_uniform", "niter_uniform", "sextansalt_uniform",
    "unitas015_uniform", "unitas039_uniform"
];

// ----- Weapons -----
// Rivals carry standard Paradeus small arms — no heavy launchers.
private _rifles = [
    ["arifle_CTAR_ghex_F", "", "", "",
        ["30Rnd_580x42_Mag_F", "30Rnd_580x42_Mag_F", "30Rnd_580x42_Mag_Tracer_F"], [], ""],
    ["arifle_MX_F", "", "", "",
        ["30Rnd_65x39_caseless_mag", "30Rnd_65x39_caseless_mag", "30Rnd_65x39_caseless_mag_Tracer"], [], ""]
];
private _tunedRifles = [
    ["arifle_CTAR_ghex_F", "", "acc_flashlight", "optic_MRCO",
        ["30Rnd_580x42_Mag_F", "30Rnd_580x42_Mag_F", "30Rnd_580x42_Mag_Tracer_F"], [], ""],
    ["arifle_MX_F", "", "acc_flashlight", "optic_MRCO",
        ["30Rnd_65x39_caseless_mag", "30Rnd_65x39_caseless_mag", "30Rnd_65x39_caseless_mag_Tracer"], [], ""]
];
private _enforcerRifles = [
    ["arifle_CTARS_ghex_F", "", "", "",
        ["30Rnd_580x42_Mag_F", "30Rnd_580x42_Mag_F", "30Rnd_580x42_Mag_Tracer_F"], [], ""]
];
private _carbines = [
    ["arifle_CTARS_ghex_F", "", "", "",
        ["30Rnd_580x42_Mag_F", "30Rnd_580x42_Mag_F", "30Rnd_580x42_Mag_Tracer_F"], [], ""]
];
private _gls = [
    ["arifle_CTAR_GL_ghex_F", "", "", "",
        ["30Rnd_580x42_Mag_F", "30Rnd_580x42_Mag_F"], _glammo, ""],
    ["arifle_MX_GL_F", "", "", "",
        ["30Rnd_65x39_caseless_mag", "30Rnd_65x39_caseless_mag"], _glammo, ""]
];
private _mgs = [
    ["LMG_Zafir_F", "", "", "",
        ["150Rnd_762x54_Box", "150Rnd_762x54_Box", "150Rnd_762x54_Box_Tracer"], [], ""]
];
private _marksmanRifles = [
    ["srifle_DMR_05_ghex_F", "", "", "optic_MRCO",
        ["10Rnd_93x64_DMR_05_Mag", "10Rnd_93x64_DMR_05_Mag"], [], ""]
];
private _rpgs = [
    ["launch_RPG32_F", "", "", "", ["RPG32_F", "RPG32_F", "RPG32_HE_F"], [], ""],
    ["launch_O_Titan_short_F", "", "", "", ["Titan_AT", "Titan_AT"], [], ""]
];
private _pistols = ["hgun_ACPC2_F"];

_loadoutData set ["lightHELaunchers", [
    ["launch_RPG32_F", "", "", "", ["RPG32_HE_F", "RPG32_HE_F"], [], ""]
]];
_loadoutData set ["AALaunchers", [
    ["launch_O_Titan_F", "", "acc_pointer_IR", "", ["Titan_AA"], [], ""]
]];

_loadoutData set ["ATMines", ["ATMine_Range_Mag"]];
_loadoutData set ["APMines", ["APERSMine_Range_Mag", "APERSBoundingMine_Range_Mag"]];
_loadoutData set ["lightExplosives", ["IEDLandSmall_Remote_Mag"]];
_loadoutData set ["heavyExplosives", ["IEDLandBig_Remote_Mag"]];

_loadoutData set ["antiInfantryGrenades", ["HandGrenade", "MiniGrenade"]];
_loadoutData set ["smokeGrenades", ["SmokeShell"]];
_loadoutData set ["signalsmokeGrenades", ["SmokeShellYellow", "SmokeShellRed",
    "SmokeShellPurple", "SmokeShellOrange", "SmokeShellGreen", "SmokeShellBlue"]];

_loadoutData set ["rifles", _rifles];
_loadoutData set ["tunedRifles", _tunedRifles];
_loadoutData set ["enforcerRifles", _enforcerRifles];
_loadoutData set ["carbines", _carbines];
_loadoutData set ["grenadeLaunchers", _gls];
_loadoutData set ["machineGuns", _mgs];
_loadoutData set ["marksmanRifles", _marksmanRifles];
_loadoutData set ["lightATLaunchers", _rpgs];
_loadoutData set ["sidearms", _pistols];

_loadoutData set ["facewear", []];
_loadoutData set ["fullmask", []];
_loadoutData set ["headgear", ["H_HelmetB", "H_HelmetB_light"]];

_loadoutData set ["uniforms", _uniforms];
_loadoutData set ["vests", ["V_PlateCarrier1_blk", "V_TacVestIR_blk",
    "V_Chestrig_oli", "V_BandollierB_cbr"]];
_loadoutData set ["heavyVests", ["V_PlateCarrierSpec_blk", "V_PlateCarrierIAGL_oli",
    "V_TacVest_blk_POLICE"]];
_loadoutData set ["backpacks", ["B_AssaultPack_cbr", "B_AssaultPack_blk",
    "B_TacticalPack_oli", "B_FieldPack_cbr"]];
_loadoutData set ["maps", ["ItemMap"]];
_loadoutData set ["watches", ["ItemWatch"]];
_loadoutData set ["compasses", ["ItemCompass"]];
_loadoutData set ["radios", ["ItemRadio"]];
_loadoutData set ["gpses", ["ItemGPS"]];
_loadoutData set ["NVGs", ["NVGoggles_OPFOR"]];
_loadoutData set ["binoculars", ["Binocular"]];
_loadoutData set ["Rangefinder", ["Rangefinder"]];

_loadoutData set ["items_medical_basic", ["BASIC"] call A3A_fnc_itemset_medicalSupplies];
_loadoutData set ["items_medical_standard", ["STANDARD"] call A3A_fnc_itemset_medicalSupplies];
_loadoutData set ["items_medical_medic", ["MEDIC"] call A3A_fnc_itemset_medicalSupplies];
_loadoutData set ["items_miscEssentials", [] call A3A_fnc_itemset_miscEssentials];
_loadoutData set ["items_squadleader_extras", ["Laserbatteries", "Laserbatteries"]];
_loadoutData set ["items_rifleman_extras", []];
_loadoutData set ["items_medic_extras", []];
_loadoutData set ["items_grenadier_extras", []];
_loadoutData set ["items_explosivesExpert_extras", ["ToolKit", "MineDetector"]];
_loadoutData set ["items_engineer_extras", ["ToolKit", "MineDetector"]];
_loadoutData set ["items_lat_extras", []];
_loadoutData set ["items_at_extras", []];
_loadoutData set ["items_aa_extras", []];
_loadoutData set ["items_machineGunner_extras", []];
_loadoutData set ["items_marksman_extras", []];
_loadoutData set ["items_sniper_extras", []];
_loadoutData set ["items_police_extras", []];
_loadoutData set ["items_crew_extras", []];
_loadoutData set ["items_unarmed_extras", []];

private _crewLoadoutData = _loadoutData call _fnc_copyLoadoutData;
_crewLoadoutData set ["vests", _loadoutData get "vests"];
_crewLoadoutData set ["crewHelmets", ["H_Tank_black_F"]];

private _pilotLoadoutData = _loadoutData call _fnc_copyLoadoutData;
_pilotLoadoutData set ["uniforms", ["U_Marshal", "U_C_WorkerCoveralls"]];
_pilotLoadoutData set ["vests", _loadoutData get "vests"];
_pilotLoadoutData set ["helmets", ["H_PilotHelmetHeli_O", "H_CrewHelmetHeli_O"]];

/////////////////////////////
//    Unit Definitions     //
/////////////////////////////

private _cellLeaderTemplate = {
    if (random 100 > 60) then {
        ["headgear"] call _fnc_setHelmet;
        [selectRandomWeighted [[], 1.5, "fullmask", 1]] call _fnc_setFacewear;
    } else {
        ["headgear"] call _fnc_setHelmet;
        [selectRandomWeighted [[], 1.5, "facewear", 1]] call _fnc_setFacewear;
    };
    [selectRandom ["vests", "heavyVests"]] call _fnc_setVest;
    [["offuniforms", "uniforms"] call _fnc_fallback] call _fnc_setUniform;
    [selectRandom ["grenadeLaunchers", "rifles"]] call _fnc_setPrimary;
    ["primary", 6] call _fnc_addMagazines;
    ["primary", 5] call _fnc_addAdditionalMuzzleMagazines;
    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 2] call _fnc_addMagazines;
    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_squadleader_extras"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["antiInfantryGrenades", 2] call _fnc_addItem;
    ["smokeGrenades", 2] call _fnc_addItem;
    ["signalsmokeGrenades", 1] call _fnc_addItem;
    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
    ["gpses"] call _fnc_addGPS;
    ["binoculars"] call _fnc_addBinoculars;
    ["NVGs"] call _fnc_addNVGs;
};

private _mercenaryTemplate = {
    ["headgear"] call _fnc_setHelmet;
    [selectRandomWeighted [[], 1.5, "facewear", 1, "fullmask", 1]] call _fnc_setFacewear;
    ["heavyVests"] call _fnc_setVest;
    [["heavyUniforms", "uniforms"] call _fnc_fallback] call _fnc_setUniform;
    [selectRandom ["grenadeLaunchers", "rifles", "tunedRifles"]] call _fnc_setPrimary;
    ["primary", 6] call _fnc_addMagazines;
    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 2] call _fnc_addMagazines;
    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_squadleader_extras"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["antiInfantryGrenades", 2] call _fnc_addItem;
    ["smokeGrenades", 2] call _fnc_addItem;
    ["signalsmokeGrenades", 1] call _fnc_addItem;
    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
    ["gpses"] call _fnc_addGPS;
    ["binoculars"] call _fnc_addBinoculars;
    ["NVGs"] call _fnc_addNVGs;
};

private _enforcerTemplate = {
    ["headgear"] call _fnc_setHelmet;
    [selectRandomWeighted [[], 1.5, "facewear", 1]] call _fnc_setFacewear;
    ["vests"] call _fnc_setVest;
    ["uniforms"] call _fnc_setUniform;
    [["enforcerRifles", "rifles"] call _fnc_fallback] call _fnc_setPrimary;
    ["primary", 4] call _fnc_addMagazines;
    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 2] call _fnc_addMagazines;
    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_squadleader_extras"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["antiInfantryGrenades", 2] call _fnc_addItem;
    ["smokeGrenades", 2] call _fnc_addItem;
    ["signalsmokeGrenades", 1] call _fnc_addItem;
    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
    ["NVGs"] call _fnc_addNVGs;
};

private _partisanTemplate = {
    ["headgear"] call _fnc_setHelmet;
    [selectRandomWeighted [[], 1.5, "facewear", 1]] call _fnc_setFacewear;
    ["vests"] call _fnc_setVest;
    ["uniforms"] call _fnc_setUniform;
    if (random 1 < 0.15) then {
        ["backpacks"] call _fnc_setBackpack;
        ["lightHELaunchers"] call _fnc_setLauncher;
        ["launcher", 3] call _fnc_addMagazines;
    } else {
        ["sidearms"] call _fnc_setHandgun;
        ["handgun", 2] call _fnc_addMagazines;
    };
    [selectRandom ["rifles", "carbines"]] call _fnc_setPrimary;
    ["primary", 6] call _fnc_addMagazines;
    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_rifleman_extras"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["antiInfantryGrenades", 2] call _fnc_addItem;
    ["smokeGrenades", 2] call _fnc_addItem;
    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
    ["NVGs"] call _fnc_addNVGs;
};

private _medicTemplate = {
    ["headgear"] call _fnc_setHelmet;
    [selectRandomWeighted [[], 1.5, "facewear", 1]] call _fnc_setFacewear;
    ["vests"] call _fnc_setVest;
    ["uniforms"] call _fnc_setUniform;
    ["backpacks"] call _fnc_setBackpack;
    ["carbines"] call _fnc_setPrimary;
    ["primary", 6] call _fnc_addMagazines;
    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 2] call _fnc_addMagazines;
    ["items_medical_medic"] call _fnc_addItemSet;
    ["items_medic_extras"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["antiInfantryGrenades", 1] call _fnc_addItem;
    ["smokeGrenades", 2] call _fnc_addItem;
    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
    ["NVGs"] call _fnc_addNVGs;
};

private _saboteurTemplate = {
    ["headgear"] call _fnc_setHelmet;
    [selectRandomWeighted [[], 1.5, "fullmask", 1]] call _fnc_setFacewear;
    [selectRandom ["vests", "heavyVests"]] call _fnc_setVest;
    ["uniforms"] call _fnc_setUniform;
    ["backpacks"] call _fnc_setBackpack;
    ["grenadeLaunchers"] call _fnc_setPrimary;
    ["primary", 6] call _fnc_addMagazines;
    ["primary", 10] call _fnc_addAdditionalMuzzleMagazines;
    if (random 1 < 0.15) then {
        ["lightHELaunchers"] call _fnc_setLauncher;
        ["launcher", 2] call _fnc_addMagazines;
    } else {
        ["sidearms"] call _fnc_setHandgun;
        ["handgun", 2] call _fnc_addMagazines;
    };
    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_grenadier_extras"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["antiInfantryGrenades", 4] call _fnc_addItem;
    ["smokeGrenades", 2] call _fnc_addItem;
    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
    ["NVGs"] call _fnc_addNVGs;
};

private _explosivesExpertTemplate = {
    ["headgear"] call _fnc_setHelmet;
    ["heavyVests"] call _fnc_setVest;
    ["uniforms"] call _fnc_setUniform;
    ["backpacks"] call _fnc_setBackpack;
    [selectRandom ["rifles", "carbines"]] call _fnc_setPrimary;
    ["primary", 6] call _fnc_addMagazines;
    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 2] call _fnc_addMagazines;
    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_explosivesExpert_extras"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["lightExplosives", 2] call _fnc_addItem;
    if (random 1 > 0.5) then {["heavyExplosives", 1] call _fnc_addItem;};
    if (random 1 > 0.5) then {["ATMines", 1] call _fnc_addItem;};
    if (random 1 > 0.5) then {["APMines", 1] call _fnc_addItem;};
    ["antiInfantryGrenades", 1] call _fnc_addItem;
    ["smokeGrenades", 1] call _fnc_addItem;
    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
    ["NVGs"] call _fnc_addNVGs;
};

private _atTemplate = {
    ["headgear"] call _fnc_setHelmet;
    ["vests"] call _fnc_setVest;
    ["uniforms"] call _fnc_setUniform;
    ["backpacks"] call _fnc_setBackpack;
    [selectRandom ["rifles", "carbines"]] call _fnc_setPrimary;
    ["primary", 6] call _fnc_addMagazines;
    ["lightATLaunchers"] call _fnc_setLauncher;
    ["launcher", 3] call _fnc_addMagazines;
    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 2] call _fnc_addMagazines;
    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_at_extras"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["antiInfantryGrenades", 1] call _fnc_addItem;
    ["smokeGrenades", 1] call _fnc_addItem;
    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
    ["NVGs"] call _fnc_addNVGs;
};

private _aaTemplate = {
    ["headgear"] call _fnc_setHelmet;
    ["vests"] call _fnc_setVest;
    ["uniforms"] call _fnc_setUniform;
    ["backpacks"] call _fnc_setBackpack;
    [selectRandom ["rifles", "carbines"]] call _fnc_setPrimary;
    ["primary", 6] call _fnc_addMagazines;
    ["AALaunchers"] call _fnc_setLauncher;
    ["launcher", 3] call _fnc_addMagazines;
    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 2] call _fnc_addMagazines;
    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_aa_extras"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["antiInfantryGrenades", 1] call _fnc_addItem;
    ["smokeGrenades", 2] call _fnc_addItem;
    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
    ["NVGs"] call _fnc_addNVGs;
};

private _oppressorTemplate = {
    ["headgear"] call _fnc_setHelmet;
    ["vests"] call _fnc_setVest;
    ["uniforms"] call _fnc_setUniform;
    ["backpacks"] call _fnc_setBackpack;
    ["machineGuns"] call _fnc_setPrimary;
    ["primary", 6] call _fnc_addMagazines;
    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 2] call _fnc_addMagazines;
    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_machineGunner_extras"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["antiInfantryGrenades", 1] call _fnc_addItem;
    ["smokeGrenades", 2] call _fnc_addItem;
    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
    ["NVGs"] call _fnc_addNVGs;
};

private _sharpshooterTemplate = {
    ["headgear"] call _fnc_setHelmet;
    ["vests"] call _fnc_setVest;
    ["uniforms"] call _fnc_setUniform;
    ["marksmanRifles"] call _fnc_setPrimary;
    ["primary", 6] call _fnc_addMagazines;
    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 2] call _fnc_addMagazines;
    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_marksman_extras"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["antiInfantryGrenades", 1] call _fnc_addItem;
    ["smokeGrenades", 2] call _fnc_addItem;
    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
    ["Rangefinder"] call _fnc_addBinoculars;
    ["NVGs"] call _fnc_addNVGs;
};

private _crewTemplate = {
    ["crewHelmets"] call _fnc_setHelmet;
    [selectRandomWeighted [[], 1.5, "fullmask", 1.25, "facewear", 1]] call _fnc_setFacewear;
    ["vests"] call _fnc_setVest;
    ["uniforms"] call _fnc_setUniform;
    ["carbines"] call _fnc_setPrimary;
    ["primary", 3] call _fnc_addMagazines;
    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 2] call _fnc_addMagazines;
    ["items_medical_basic"] call _fnc_addItemSet;
    ["items_crew_extras"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["smokeGrenades", 2] call _fnc_addItem;
    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
    ["gpses"] call _fnc_addGPS;
    ["NVGs"] call _fnc_addNVGs;
};

private _unarmedTemplate = {
    ["vests"] call _fnc_setVest;
    [selectRandomWeighted [[], 1.5, "facewear", 1, "fullmask", 1]] call _fnc_setFacewear;
    ["uniforms"] call _fnc_setUniform;
    ["items_medical_basic"] call _fnc_addItemSet;
    ["items_unarmed_extras"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
};

private _commanderTemplate = {
    [selectRandomWeighted ["headgear", 0.7, "headgear", 0.3]] call _fnc_setHelmet;
    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 2] call _fnc_addMagazines;
    ["vests"] call _fnc_setVest;
    ["uniforms"] call _fnc_setUniform;
    ["items_medical_basic"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
};

///////////////////////
//  Rivals Units     //
///////////////////////
private _prefix = "militia";
private _unitTypes = [
    ["CellLeader",       _cellLeaderTemplate,       [], [_prefix, true]],
    ["Mercenary",        _mercenaryTemplate,         [], [_prefix, true]],
    ["Enforcer",         _enforcerTemplate,          [], [_prefix, true]],
    ["Partisan",         _partisanTemplate,          [], [_prefix, true]],
    ["Saboteur",         _saboteurTemplate,          [], [_prefix, true]],
    ["Medic",            _medicTemplate,             [["medic", true]], [_prefix, true]],
    ["ExplosivesExpert", _explosivesExpertTemplate,  [["explosiveSpecialist", true]], [_prefix, true]],
    ["SpecialistAT",     _atTemplate,                [], [_prefix, true]],
    ["SpecialistAA",     _aaTemplate,                [], [_prefix, true]],
    ["Oppressor",        _oppressorTemplate,         [], [_prefix, true]],
    ["Sharpshooter",     _sharpshooterTemplate,      [], [_prefix, true]]
];
[_prefix, _unitTypes, _loadoutData] call _fnc_generateAndSaveUnitsToTemplate;

["other", [["Crew",      _crewTemplate,     [], [_prefix, true]]], _crewLoadoutData] call _fnc_generateAndSaveUnitsToTemplate;
["other", [["Pilot",     _crewTemplate,     [], [_prefix, true]]], _pilotLoadoutData] call _fnc_generateAndSaveUnitsToTemplate;
["other", [["Commander", _commanderTemplate, [], [_prefix, true]]], _loadoutData] call _fnc_generateAndSaveUnitsToTemplate;
["other", [["Unarmed",   _unarmedTemplate,  [], [_prefix, true]]], _loadoutData] call _fnc_generateAndSaveUnitsToTemplate;

// GFL - Elmo Force (Occupant / BLUFOR)

["name", "GFL - Elmo Force"] call _fnc_saveToTemplate;
["spawnMarkerName", format [localize "STR_supportcorridor", "Elmo Force"]] call _fnc_saveToTemplate;
["flag", "Flag_NATO_F"] call _fnc_saveToTemplate;
["flagTexture", "\A3\Data_F\Flags\flag_nato_co.paa"] call _fnc_saveToTemplate;
["flagMarkerType", "flag_NATO"] call _fnc_saveToTemplate;

["ammobox", "Box_NATO_AmmoOrd_F"] call _fnc_saveToTemplate;
["surrenderCrate", "Box_NATO_Wps_F"] call _fnc_saveToTemplate;
["equipmentBox", "Box_NATO_Equip_F"] call _fnc_saveToTemplate;
["smallBunker", ""] call _fnc_saveToTemplate;
["sandbag", ""] call _fnc_saveToTemplate;
["sandbagRound", ""] call _fnc_saveToTemplate;

//////////////////////////
//       Vehicles       //
//////////////////////////
// Vehicle flow per user spec: Sci-Fi Vehicles Pack (TKE_Ext_*) preferred, fall back to
// vanilla CSAT (arid where available), optionally RHS Russian for the troop transport
// helicopter. Each block tests for the class so a missing mod degrades gracefully.

// --- Vanilla CSAT fallbacks (used when sci-fi mod not loaded) ---
private _vehiclesBasic         = ["O_Quadbike_01_F", "O_MRAP_02_F"];
private _vehiclesLightUnarmed  = ["O_MRAP_02_F"];
// Roadblock vehicle: CSAT Marshall (wheeled APC) as fallback per user spec ("whatever CSAT
// APC available"). Bearcat IFV is prepended when Sci-Fi Vehicles Pack is loaded.
private _vehiclesLightArmed    = ["O_APC_Wheeled_02_rcws_v2_F", "O_MRAP_02_hmg_F"];
private _vehiclesTrucks        = ["O_Truck_02_transport_F", "O_Truck_02_covered_F"];
private _vehiclesCargoTrucks   = ["O_Truck_02_box_F"];
private _vehiclesLightAPCs     = ["O_APC_Wheeled_02_rcws_v2_F"];
private _vehiclesAPCs          = ["O_APC_Tracked_02_cannon_F"];
private _vehiclesIFVs          = ["O_APC_Tracked_02_cannon_F"];
private _vehiclesTanks         = ["O_T_MBT_02_cannon_F"];   // CSAT Varsuk arid (user-requested buyable)
private _vehiclesLightTanks    = ["O_AFV_Wheeled_02_cannon_F"];
private _vehiclesAA            = ["O_APC_Tracked_02_AA_F"];
private _vehiclesHelisLight    = ["O_Heli_Light_02_unarmed_F"];
private _vehiclesHelisTransport = ["O_Heli_Transport_04_covered_F"];   // CSAT Taru covered as fallback
private _vehiclesHelisLightAttack = ["O_Heli_Light_02_F"];
private _vehiclesHelisAttack   = ["O_Heli_Attack_02_F"];                // CSAT Kajman
private _vehiclesPlanesCAS     = ["O_Plane_CAS_02_F"];
private _vehiclesPlanesAA      = ["O_Plane_Fighter_02_F"];
private _vehiclesPlanesTransport = [];
private _vehiclesMilitiaLightArmed = ["O_APC_Wheeled_02_rcws_v2_F", "O_MRAP_02_hmg_F"];
private _vehiclesMilitiaTrucks = ["O_Truck_02_transport_F"];
private _vehiclesMilitiaCars   = ["O_MRAP_02_F"];
private _vehiclesPolice        = ["O_MRAP_02_F"];
private _vehiclesAirPatrol     = ["O_Heli_Light_02_unarmed_F"];

// --- Heavy / "Chinook role" troop transport: RHS Mi-8 if RHSAFRF loaded, else CSAT Taru ---
if (isClass (configFile >> "cfgVehicles" >> "RHS_Mi8MT_vdv")) then {
    _vehiclesHelisTransport = ["RHS_Mi8MT_vdv"];
};

// --- Sci-Fi Vehicles Pack overrides (TKE_Ext_*) ---
// Bearcat IFV: roadblocks, light armed, light APC, militia roadblocks
if (isClass (configFile >> "cfgVehicles" >> "TKE_Ext_Bearcat_Autocannon")) then {
    _vehiclesLightArmed        = ["TKE_Ext_Bearcat_Autocannon"] + _vehiclesLightArmed;
    _vehiclesLightAPCs         = ["TKE_Ext_Bearcat_Autocannon"] + _vehiclesLightAPCs;
    _vehiclesMilitiaLightArmed = ["TKE_Ext_Bearcat_Autocannon"];
};
// Dragonfly: light helicopter, light attack, air patrol — and a separate "Huron heavy
// transport" slot per user spec (B_Heli_Transport_03_F is vanilla NATO Huron, distinct
// from the Chinook-role _vehiclesHelisTransport above).
if (isClass (configFile >> "cfgVehicles" >> "TKE_Ext_Dragonfly_A")) then {
    _vehiclesHelisLight        = ["TKE_Ext_Dragonfly_A"];
    _vehiclesHelisLightAttack  = ["TKE_Ext_Dragonfly_A"];
    _vehiclesAirPatrol         = ["TKE_Ext_Dragonfly_A"];
};
// Huron as the dedicated "heavy/utility transport" alongside the Chinook-role slot above.
if (isClass (configFile >> "cfgVehicles" >> "B_Heli_Transport_03_F")) then {
    _vehiclesHelisAttack = ["B_Heli_Transport_03_F"] + _vehiclesHelisAttack;
};

["vehiclesBasic", _vehiclesBasic] call _fnc_saveToTemplate;
["vehiclesLightUnarmed", _vehiclesLightUnarmed] call _fnc_saveToTemplate;
["vehiclesLightArmed", _vehiclesLightArmed] call _fnc_saveToTemplate;
["vehiclesTrucks", _vehiclesTrucks] call _fnc_saveToTemplate;
["vehiclesCargoTrucks", _vehiclesCargoTrucks] call _fnc_saveToTemplate;
["vehiclesAmmoTrucks", ["O_Truck_02_Ammo_F"]] call _fnc_saveToTemplate;
["vehiclesRepairTrucks", ["O_Truck_02_box_F"]] call _fnc_saveToTemplate;
["vehiclesFuelTrucks", ["O_Truck_02_fuel_F"]] call _fnc_saveToTemplate;
["vehiclesMedical", ["O_Truck_02_medical_F"]] call _fnc_saveToTemplate;
["vehiclesLightAPCs", _vehiclesLightAPCs] call _fnc_saveToTemplate;
["vehiclesAPCs", _vehiclesAPCs] call _fnc_saveToTemplate;
["vehiclesIFVs", _vehiclesIFVs] call _fnc_saveToTemplate;
["vehiclesTanks", _vehiclesTanks] call _fnc_saveToTemplate;
["vehiclesLightTanks", _vehiclesLightTanks] call _fnc_saveToTemplate;
["vehiclesAA", _vehiclesAA] call _fnc_saveToTemplate;
["vehiclesTransportBoats", []] call _fnc_saveToTemplate;
["vehiclesGunBoats", []] call _fnc_saveToTemplate;
["vehiclesHelisLight", _vehiclesHelisLight] call _fnc_saveToTemplate;
["vehiclesHelisTransport", _vehiclesHelisTransport] call _fnc_saveToTemplate;
["vehiclesHelisLightAttack", _vehiclesHelisLightAttack] call _fnc_saveToTemplate;
["vehiclesHelisAttack", _vehiclesHelisAttack] call _fnc_saveToTemplate;
["vehiclesPlanesCAS", _vehiclesPlanesCAS] call _fnc_saveToTemplate;
["vehiclesPlanesAA", _vehiclesPlanesAA] call _fnc_saveToTemplate;
["vehiclesPlanesTransport", _vehiclesPlanesTransport] call _fnc_saveToTemplate;
["vehiclesArtillery", []] call _fnc_saveToTemplate;
["magazines", createHashMapFromArray []] call _fnc_saveToTemplate;
["uavsAttack", []] call _fnc_saveToTemplate;
["uavsPortable", []] call _fnc_saveToTemplate;
["vehiclesMilitiaLightArmed", _vehiclesMilitiaLightArmed] call _fnc_saveToTemplate;
["vehiclesMilitiaTrucks", _vehiclesMilitiaTrucks] call _fnc_saveToTemplate;
["vehiclesMilitiaCars", _vehiclesMilitiaCars] call _fnc_saveToTemplate;
["vehiclesMilitiaAPCs", []] call _fnc_saveToTemplate;
["vehiclesPolice", _vehiclesPolice] call _fnc_saveToTemplate;
["vehiclesAirPatrol", _vehiclesAirPatrol] call _fnc_saveToTemplate;

// ----- Static emplacements -----
// MG emplacement at airport/military base/outpost/factory/resource sites uses the raised
// TacGirls Heavy MG when available, plus the Sci-Fi gatling for HMG variety. Falls back
// to vanilla CSAT static HMG.
private _staticMGs = ["O_HMG_01_high_F", "O_HMG_01_F"];
if (isClass (configFile >> "cfgVehicles" >> "GFL_Heavy_Machine_Gun_Raised")) then {
    _staticMGs = ["GFL_Heavy_Machine_Gun_Raised"] + _staticMGs;
};
if (isClass (configFile >> "cfgVehicles" >> "PHEN_TurretPack_B_Turret_01_GAU_FGrey_INDEP")) then {
    _staticMGs pushBack "PHEN_TurretPack_B_Turret_01_GAU_FGrey_INDEP";
};

// AT: Sci-Fi Turret Pack cannon preferred, vanilla CSAT static AT fallback.
private _staticAT = ["O_static_AT_F"];
if (isClass (configFile >> "cfgVehicles" >> "PHEN_TurretPack_B_Turret_06_cannon_FGrey_INDEP")) then {
    _staticAT = ["PHEN_TurretPack_B_Turret_06_cannon_FGrey_INDEP"] + _staticAT;
};

// AA: Sci-Fi Turret Pack HE autocannon preferred, vanilla CSAT static AA fallback.
private _staticAA = ["O_static_AA_F"];
if (isClass (configFile >> "cfgVehicles" >> "PHEN_TurretPack_B_Turret_03_FGrey_INDEP")) then {
    _staticAA = ["PHEN_TurretPack_B_Turret_03_FGrey_INDEP"] + _staticAA;
};

// Buyable static howitzer: RHS D-30 (VDV) if RHSAFRF loaded, otherwise none.
private _staticHowitzers = [];
if (isClass (configFile >> "cfgVehicles" >> "rhs_D30_vdv")) then {
    _staticHowitzers = ["rhs_D30_vdv"];
};

["staticMGs", _staticMGs] call _fnc_saveToTemplate;
["staticAT", _staticAT] call _fnc_saveToTemplate;
["staticAA", _staticAA] call _fnc_saveToTemplate;
["staticMortars", ["O_Mortar_01_F"]] call _fnc_saveToTemplate;
["staticHowitzers", _staticHowitzers] call _fnc_saveToTemplate;
["vehicleRadar", ""] call _fnc_saveToTemplate;
["vehicleSam", ""] call _fnc_saveToTemplate;
["howitzerMagazineHE", "rhs_mag_3OF56_30"] call _fnc_saveToTemplate;
["mortarMagazineHE", "3Rnd_82mm_Mo_shells"] call _fnc_saveToTemplate;
["mortarMagazineSmoke", "3Rnd_82mm_Mo_Smoke_white"] call _fnc_saveToTemplate;
["mortarMagazineFlare", ""] call _fnc_saveToTemplate;

["minefieldAT", ["ATMine"]] call _fnc_saveToTemplate;
["minefieldAPERS", ["APERSMine", "APERSBoundingMine"]] call _fnc_saveToTemplate;

["animations", []] call _fnc_saveToTemplate;
["variants", []] call _fnc_saveToTemplate;

/////////////////////
//   Identities    //
/////////////////////

["faces", [
    // tacgirls_elmo (25 — commandermaleface / commanderfemaleface deliberately excluded
    // so ELMO units never spawn with the Petros-style commander identity)
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
]] call _fnc_saveToTemplate;

["voices", ["FemaleCV2CHI"]] call _fnc_saveToTemplate;

//////////////////////////
//       Loadouts       //
//////////////////////////

private _loadoutData = call _fnc_createLoadoutData;

// ----- Uniforms / Appearance -----
// TacGirls uniforms ARE the T-Doll character models — equipping one swaps the full body mesh.
// ELMO uses bc036 Invisible Gear only for vests/headgear so the dolls keep their full model silhouettes.
private _uniforms = [
    // tacgirls_elmo (25 — commandermale_uniform / commanderfemale_uniform deliberately
    // excluded so ELMO units never visually appear as the rebel commander silhouette)
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

private _vests = [
    "bc036_invisible_carrier",
    "bc036_invisible_tacvest",
    "bc036_invisible_chestrig",
    "bc036_invisible_combat",
    "bc036_invisible_defender",
    "bc036_invisible_protector"
];
private _hvests = [
    "bc036_invisible_carrier_special",
    "bc036_invisible_enhanced_combat",
    "bc036_invisible_special_purpose"
];
private _helmets = ["bc036_invisible_light_combat", "bc036_invisible_special_purpose"];
private _slHat   = ["bc036_invisible_special_purpose", "bc036_invisible_enhanced_combat"];
private _sniHats = ["bc036_invisible_assassin", "bc036_invisible_stealth_combat"];
private _backpacks = ["B_AssaultPack_rgr", "B_FieldPack_ocamo", "B_Carryall_ocamo"];
private _atBackpacks = ["B_Carryall_ocamo"];
private _longRangeRadios = ["B_RadioBag_01_mtp_F"];

// ----- Weapons -----

private _rifles = [
    ["arifle_MX_F", "", "acc_flashlight", "optic_MRCO",
        ["30Rnd_65x39_caseless_mag", "30Rnd_65x39_caseless_mag", "30Rnd_65x39_caseless_mag_Tracer"], [], ""]
];
private _slRifles = [
    ["arifle_MX_F", "", "acc_flashlight", "optic_MRCO",
        ["30Rnd_65x39_caseless_mag", "30Rnd_65x39_caseless_mag", "30Rnd_65x39_caseless_mag_Tracer"], [], ""]
];
private _carbines = [
    ["arifle_MXC_F", "", "acc_flashlight", "optic_Holosight",
        ["30Rnd_65x39_caseless_mag", "30Rnd_65x39_caseless_mag", "30Rnd_65x39_caseless_mag_Tracer"], [], ""]
];
private _smgs = [
    ["SMG_02_F", "", "acc_flashlight", "optic_Holosight_smg",
        ["30Rnd_9x21_Mag", "30Rnd_9x21_Mag", "30Rnd_9x21_Mag"], [], ""]
];
private _mgs = [
    ["LMG_Mk200_F", "", "", "optic_Hamr",
        ["200Rnd_65x39_cased_Box", "200Rnd_65x39_cased_Box_Tracer"], [], ""]
];
private _marksmanRifles = [
    ["arifle_MXM_F", "", "", "optic_SOS_zoomonly",
        ["20Rnd_762x51_Mag", "20Rnd_762x51_Mag"], [], ""]
];
private _sniperRifles = [
    ["srifle_GM6_F", "", "", "optic_SOS",
        ["5Rnd_127x108_Mag", "5Rnd_127x108_Mag"], [], ""]
];
private _grenadeLaunchers = [
    ["arifle_MX_GL_F", "", "", "optic_Holosight",
        ["30Rnd_65x39_caseless_mag", "30Rnd_65x39_caseless_mag"],
        ["1Rnd_HE_Grenade_shell", "1Rnd_HE_Grenade_shell", "1Rnd_HE_Grenade_shell", "UGL_FlareWhite_F"], ""]
];
private _lightATLaunchers = [
    ["launch_NLAW_F", "", "", "", ["NLAW_F", "NLAW_F"], [], ""]
];
private _atLaunchers = [
    ["launch_Titan_F", "", "acc_pointer_IR", "", ["Titan_AT", "Titan_AT"], [], ""]
];
private _missileATLaunchers = [
    ["launch_Titan_F", "", "acc_pointer_IR", "", ["Titan_AT", "Titan_AT", "Titan_AT"], [], ""]
];
private _aaLaunchers = [
    ["launch_Titan_short_F", "", "acc_pointer_IR", "", ["Titan_AA", "Titan_AA"], [], ""]
];
private _sidearms = [
    ["hgun_P07_F", "", "acc_flashlight_pistol", "", ["16Rnd_9x21_Mag", "16Rnd_9x21_Mag"], [], ""]
];

_loadoutData set ["uniforms", _uniforms];
_loadoutData set ["vests", _vests];
_loadoutData set ["Hvests", _hvests];
_loadoutData set ["helmets", _helmets];
_loadoutData set ["slHat", _slHat];
_loadoutData set ["sniHats", _sniHats];
_loadoutData set ["backpacks", _backpacks];
_loadoutData set ["atBackpacks", _atBackpacks];
_loadoutData set ["longRangeRadios", _longRangeRadios];
_loadoutData set ["slRifles", _slRifles];
_loadoutData set ["rifles", _rifles];
_loadoutData set ["carbines", _carbines];
_loadoutData set ["SMGs", _smgs];
_loadoutData set ["machineGuns", _mgs];
_loadoutData set ["marksmanRifles", _marksmanRifles];
_loadoutData set ["sniperRifles", _sniperRifles];
_loadoutData set ["grenadeLaunchers", _grenadeLaunchers];
_loadoutData set ["lightATLaunchers", _lightATLaunchers];
_loadoutData set ["ATLaunchers", _atLaunchers];
_loadoutData set ["missileATLaunchers", _missileATLaunchers];
_loadoutData set ["AALaunchers", _aaLaunchers];
_loadoutData set ["sidearms", _sidearms];
_loadoutData set ["NVGs", ["NVGoggles", "NVGoggles_INDEP"]];
_loadoutData set ["binoculars", ["Binocular"]];
_loadoutData set ["rangefinders", ["Rangefinder"]];
_loadoutData set ["antiInfantryGrenades", ["HandGrenade", "MiniGrenade"]];
_loadoutData set ["smokeGrenades", ["SmokeShell"]];
_loadoutData set ["signalsmokeGrenades", ["SmokeShellYellow", "SmokeShellRed"]];
_loadoutData set ["ATMines", ["ATMine_Range_Mag"]];
_loadoutData set ["APMines", ["APERSMine_Range_Mag", "APERSBoundingMine_Range_Mag"]];
_loadoutData set ["lightExplosives", ["DemoCharge_Remote_Mag"]];
_loadoutData set ["heavyExplosives", ["SatchelCharge_Remote_Mag"]];
_loadoutData set ["facewear", []];
_loadoutData set ["goggles", []];
_loadoutData set ["glasses", []];
_loadoutData set ["officerUniforms", _uniforms];
_loadoutData set ["officerVests", _hvests];
_loadoutData set ["officerHats", _slHat];
_loadoutData set ["traitorUniforms", _uniforms];
_loadoutData set ["traitorVests", _vests];
_loadoutData set ["traitorHats", _helmets];
_loadoutData set ["cloakUniforms", _uniforms];
_loadoutData set ["cloakVests", _vests];
_loadoutData set ["cloakRifles", _rifles];
_loadoutData set ["cloakCarbines", _carbines];
_loadoutData set ["cloakSidearms", _sidearms];
_loadoutData set ["cloakGlasses", []];
_loadoutData set ["items_medical_basic", ["BASIC"] call A3A_fnc_itemset_medicalSupplies];
_loadoutData set ["items_medical_standard", ["STANDARD"] call A3A_fnc_itemset_medicalSupplies];
_loadoutData set ["items_medical_medic", ["MEDIC"] call A3A_fnc_itemset_medicalSupplies];
_loadoutData set ["items_miscEssentials", [] call A3A_fnc_itemset_miscEssentials];
_loadoutData set ["items_squadLeader_extras", ["Laserbatteries", "Laserbatteries"]];
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

// ----- Per-role loadout overrides -----

private _sfLoadoutData = _loadoutData call _fnc_copyLoadoutData;
_sfLoadoutData set ["vests", _hvests];
_sfLoadoutData set ["Hvests", _hvests];

private _militaryLoadoutData = _loadoutData call _fnc_copyLoadoutData;

private _policeLoadoutData = _loadoutData call _fnc_copyLoadoutData;
_policeLoadoutData set ["SMGs", _smgs];
_policeLoadoutData set ["rifles", _smgs];
_policeLoadoutData set ["carbines", _smgs];

private _militiaLoadoutData = _loadoutData call _fnc_copyLoadoutData;

private _eliteLoadoutData = _loadoutData call _fnc_copyLoadoutData;
_eliteLoadoutData set ["vests", _hvests];
_eliteLoadoutData set ["Hvests", _hvests];

private _crewLoadoutData = _militaryLoadoutData call _fnc_copyLoadoutData;
_crewLoadoutData set ["helmets", ["bc036_invisible_crew", "bc036_invisible_deckcrew", "bc036_invisible_heli_crew", "bc036_invisible_heli_pilot", "bc036_invisible_pilot"]];

private _pilotLoadoutData = _crewLoadoutData call _fnc_copyLoadoutData;

/////////////////////////////////
//    Unit Type Definitions    //
/////////////////////////////////

private _squadLeaderTemplate = {
    [selectRandomWeighted ["helmets", 2, "slHat", 1]] call _fnc_setHelmet;
    [selectRandomWeighted [[], 1.5, "glasses", 0.75, "goggles", 0.5]] call _fnc_setFacewear;
    [["Hvests", "vests"] call _fnc_fallback] call _fnc_setVest;
    [["slUniforms", "uniforms"] call _fnc_fallback] call _fnc_setUniform;
    ["backpacks"] call _fnc_setBackpack;
    [["slRifles", "rifles"] call _fnc_fallback] call _fnc_setPrimary;
    ["primary", 6] call _fnc_addMagazines;
    ["primary", 4] call _fnc_addAdditionalMuzzleMagazines;
    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 2] call _fnc_addMagazines;
    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_squadLeader_extras"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["antiInfantryGrenades", 2] call _fnc_addItem;
    ["signalsmokeGrenades", 2] call _fnc_addItem;
    ["smokeGrenades", 2] call _fnc_addItem;
    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
    ["gpses"] call _fnc_addGPS;
    ["binoculars"] call _fnc_addBinoculars;
    ["NVGs"] call _fnc_addNVGs;
};

private _riflemanTemplate = {
    ["helmets"] call _fnc_setHelmet;
    [selectRandomWeighted [[], 1.5, "glasses", 0.75, "goggles", 0.5]] call _fnc_setFacewear;
    ["vests"] call _fnc_setVest;
    ["uniforms"] call _fnc_setUniform;
    [selectRandom ["rifles", "carbines"]] call _fnc_setPrimary;
    ["primary", 6] call _fnc_addMagazines;
    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 2] call _fnc_addMagazines;
    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_rifleman_extras"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["antiInfantryGrenades", 2] call _fnc_addItem;
    ["smokeGrenades", 1] call _fnc_addItem;
    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
    ["NVGs"] call _fnc_addNVGs;
};

private _radiomanTemplate = {
    ["helmets"] call _fnc_setHelmet;
    ["vests"] call _fnc_setVest;
    ["uniforms"] call _fnc_setUniform;
    ["longRangeRadios"] call _fnc_setBackpack;
    [selectRandom ["rifles", "carbines"]] call _fnc_setPrimary;
    ["primary", 6] call _fnc_addMagazines;
    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 2] call _fnc_addMagazines;
    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["antiInfantryGrenades", 1] call _fnc_addItem;
    ["smokeGrenades", 2] call _fnc_addItem;
    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
    ["NVGs"] call _fnc_addNVGs;
};

private _medicTemplate = {
    ["helmets"] call _fnc_setHelmet;
    [["Hvests", "vests"] call _fnc_fallback] call _fnc_setVest;
    ["uniforms"] call _fnc_setUniform;
    ["backpacks"] call _fnc_setBackpack;
    [selectRandomWeighted ["carbines", 0.5, "SMGs", 0.5]] call _fnc_setPrimary;
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

private _grenadierTemplate = {
    ["helmets"] call _fnc_setHelmet;
    [["glVests", "vests"] call _fnc_fallback] call _fnc_setVest;
    ["uniforms"] call _fnc_setUniform;
    ["backpacks"] call _fnc_setBackpack;
    ["grenadeLaunchers"] call _fnc_setPrimary;
    ["primary", 6] call _fnc_addMagazines;
    ["primary", 10] call _fnc_addAdditionalMuzzleMagazines;
    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 2] call _fnc_addMagazines;
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

private _eeTemplate = {
    ["helmets"] call _fnc_setHelmet;
    [["Hvests", "vests"] call _fnc_fallback] call _fnc_setVest;
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

private _latTemplate = {
    ["helmets"] call _fnc_setHelmet;
    ["vests"] call _fnc_setVest;
    ["uniforms"] call _fnc_setUniform;
    [["atBackpacks", "backpacks"] call _fnc_fallback] call _fnc_setBackpack;
    [selectRandomWeighted ["rifles", 0.3, "carbines", 0.7]] call _fnc_setPrimary;
    ["primary", 6] call _fnc_addMagazines;
    [["lightATLaunchers", "ATLaunchers"] call _fnc_fallback] call _fnc_setLauncher;
    ["launcher", 3] call _fnc_addMagazines;
    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 2] call _fnc_addMagazines;
    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_lat_extras"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["antiInfantryGrenades", 1] call _fnc_addItem;
    ["smokeGrenades", 1] call _fnc_addItem;
    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
    ["NVGs"] call _fnc_addNVGs;
};

private _atTemplate = {
    ["helmets"] call _fnc_setHelmet;
    ["vests"] call _fnc_setVest;
    ["uniforms"] call _fnc_setUniform;
    [["atBackpacks", "backpacks"] call _fnc_fallback] call _fnc_setBackpack;
    [selectRandom ["rifles", "carbines"]] call _fnc_setPrimary;
    ["primary", 6] call _fnc_addMagazines;
    [selectRandom ["ATLaunchers", "missileATLaunchers"]] call _fnc_setLauncher;
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
    ["helmets"] call _fnc_setHelmet;
    ["vests"] call _fnc_setVest;
    ["uniforms"] call _fnc_setUniform;
    [["atBackpacks", "backpacks"] call _fnc_fallback] call _fnc_setBackpack;
    [selectRandom ["rifles", "carbines"]] call _fnc_setPrimary;
    ["primary", 6] call _fnc_addMagazines;
    ["AALaunchers"] call _fnc_setLauncher;
    ["launcher", 3] call _fnc_addMagazines;
    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 2] call _fnc_addMagazines;
    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_aa_extras"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["smokeGrenades", 2] call _fnc_addItem;
    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
    ["NVGs"] call _fnc_addNVGs;
};

private _mgTemplate = {
    ["helmets"] call _fnc_setHelmet;
    ["vests"] call _fnc_setVest;
    ["uniforms"] call _fnc_setUniform;
    ["backpacks"] call _fnc_setBackpack;
    ["machineGuns"] call _fnc_setPrimary;
    ["primary", 4] call _fnc_addMagazines;
    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 2] call _fnc_addMagazines;
    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_machineGunner_extras"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["smokeGrenades", 2] call _fnc_addItem;
    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
    ["NVGs"] call _fnc_addNVGs;
};

private _marksmanTemplate = {
    [selectRandomWeighted ["helmets", 2, "sniHats", 1]] call _fnc_setHelmet;
    ["vests"] call _fnc_setVest;
    ["uniforms"] call _fnc_setUniform;
    ["marksmanRifles"] call _fnc_setPrimary;
    ["primary", 6] call _fnc_addMagazines;
    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 2] call _fnc_addMagazines;
    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_marksman_extras"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["smokeGrenades", 2] call _fnc_addItem;
    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
    ["rangefinders"] call _fnc_addBinoculars;
    ["NVGs"] call _fnc_addNVGs;
};

private _sniperTemplate = {
    ["sniHats"] call _fnc_setHelmet;
    [["sniVests", "vests"] call _fnc_fallback] call _fnc_setVest;
    ["uniforms"] call _fnc_setUniform;
    [["sniperRifles", "marksmanRifles"] call _fnc_fallback] call _fnc_setPrimary;
    ["primary", 7] call _fnc_addMagazines;
    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 2] call _fnc_addMagazines;
    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_sniper_extras"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["smokeGrenades", 2] call _fnc_addItem;
    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
    ["rangefinders"] call _fnc_addBinoculars;
    ["NVGs"] call _fnc_addNVGs;
};

private _policeTemplate = {
    ["helmets"] call _fnc_setHelmet;
    ["vests"] call _fnc_setVest;
    ["uniforms"] call _fnc_setUniform;
    ["SMGs"] call _fnc_setPrimary;
    ["primary", 3] call _fnc_addMagazines;
    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 2] call _fnc_addMagazines;
    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_police_extras"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["smokeGrenades", 1] call _fnc_addItem;
    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
};

private _crewTemplate = {
    ["helmets"] call _fnc_setHelmet;
    ["vests"] call _fnc_setVest;
    ["uniforms"] call _fnc_setUniform;
    [selectRandomWeighted ["carbines", 0.5, "SMGs", 0.5]] call _fnc_setPrimary;
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
    ["uniforms"] call _fnc_setUniform;
    ["items_medical_basic"] call _fnc_addItemSet;
    ["items_unarmed_extras"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
};

private _officerTemplate = {
    ["officerHats"] call _fnc_setHelmet;
    ["officerVests"] call _fnc_setVest;
    ["officerUniforms"] call _fnc_setUniform;
    [["SMGs", "carbines"] call _fnc_fallback] call _fnc_setPrimary;
    ["primary", 3] call _fnc_addMagazines;
    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 2] call _fnc_addMagazines;
    ["items_medical_basic"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
};

private _traitorTemplate = {
    ["traitorHats"] call _fnc_setHelmet;
    ["traitorVests"] call _fnc_setVest;
    ["traitorUniforms"] call _fnc_setUniform;
    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 2] call _fnc_addMagazines;
    ["items_medical_basic"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
};

////////////////////////////////////////////////////////////////////////////////////////
//  Unit Generation — do not modify below unless you know what you're doing.
////////////////////////////////////////////////////////////////////////////////////////

private _prefix = "SF";
private _unitTypes = [
    ["SquadLeader", _squadLeaderTemplate, [], [_prefix]],
    ["Rifleman", _riflemanTemplate, [], [_prefix]],
    ["Radioman", _radiomanTemplate, [], [_prefix]],
    ["Medic", _medicTemplate, [["medic", true]], [_prefix]],
    ["Engineer", _riflemanTemplate, [["engineer", true]], [_prefix]],
    ["ExplosivesExpert", _eeTemplate, [["explosiveSpecialist", true]], [_prefix]],
    ["Grenadier", _grenadierTemplate, [], [_prefix]],
    ["LAT", _latTemplate, [], [_prefix]],
    ["AT", _atTemplate, [], [_prefix]],
    ["AA", _aaTemplate, [], [_prefix]],
    ["MachineGunner", _mgTemplate, [], [_prefix]],
    ["Marksman", _marksmanTemplate, [], [_prefix]],
    ["Sniper", _sniperTemplate, [], [_prefix]]
];
[_prefix, _unitTypes, _sfLoadoutData] call _fnc_generateAndSaveUnitsToTemplate;

private _prefix = "military";
private _unitTypes = [
    ["SquadLeader", _squadLeaderTemplate, [], [_prefix]],
    ["Rifleman", _riflemanTemplate, [], [_prefix]],
    ["Radioman", _radiomanTemplate, [], [_prefix]],
    ["Medic", _medicTemplate, [["medic", true]], [_prefix]],
    ["Engineer", _riflemanTemplate, [["engineer", true]], [_prefix]],
    ["ExplosivesExpert", _eeTemplate, [["explosiveSpecialist", true]], [_prefix]],
    ["Grenadier", _grenadierTemplate, [], [_prefix]],
    ["LAT", _latTemplate, [], [_prefix]],
    ["AT", _atTemplate, [], [_prefix]],
    ["AA", _aaTemplate, [], [_prefix]],
    ["MachineGunner", _mgTemplate, [], [_prefix]],
    ["Marksman", _marksmanTemplate, [], [_prefix]],
    ["Sniper", _sniperTemplate, [], [_prefix]]
];
[_prefix, _unitTypes, _militaryLoadoutData] call _fnc_generateAndSaveUnitsToTemplate;

private _prefix = "police";
private _unitTypes = [
    ["SquadLeader", _policeTemplate, [], [_prefix]],
    ["Standard", _policeTemplate, [], [_prefix]]
];
[_prefix, _unitTypes, _policeLoadoutData] call _fnc_generateAndSaveUnitsToTemplate;

private _prefix = "militia";
private _unitTypes = [
    ["SquadLeader", _squadLeaderTemplate, [], [_prefix]],
    ["Rifleman", _riflemanTemplate, [], [_prefix]],
    ["Radioman", _radiomanTemplate, [], [_prefix]],
    ["Medic", _medicTemplate, [["medic", true]], [_prefix]],
    ["Engineer", _riflemanTemplate, [["engineer", true]], [_prefix]],
    ["ExplosivesExpert", _eeTemplate, [["explosiveSpecialist", true]], [_prefix]],
    ["Grenadier", _grenadierTemplate, [], [_prefix]],
    ["LAT", _latTemplate, [], [_prefix]],
    ["AT", _atTemplate, [], [_prefix]],
    ["AA", _aaTemplate, [], [_prefix]],
    ["MachineGunner", _mgTemplate, [], [_prefix]],
    ["Sniper", _sniperTemplate, [], [_prefix]]
];
[_prefix, _unitTypes, _militiaLoadoutData] call _fnc_generateAndSaveUnitsToTemplate;

private _prefix = "elite";
private _unitTypes = [
    ["SquadLeader", _squadLeaderTemplate, [], [_prefix]],
    ["Rifleman", _riflemanTemplate, [], [_prefix]],
    ["Radioman", _radiomanTemplate, [], [_prefix]],
    ["Medic", _medicTemplate, [["medic", true]], [_prefix]],
    ["Engineer", _riflemanTemplate, [["engineer", true]], [_prefix]],
    ["ExplosivesExpert", _eeTemplate, [["explosiveSpecialist", true]], [_prefix]],
    ["Grenadier", _grenadierTemplate, [], [_prefix]],
    ["LAT", _latTemplate, [], [_prefix]],
    ["AT", _atTemplate, [], [_prefix]],
    ["AA", _aaTemplate, [], [_prefix]],
    ["MachineGunner", _mgTemplate, [], [_prefix]],
    ["Marksman", _marksmanTemplate, [], [_prefix]],
    ["Sniper", _sniperTemplate, [], [_prefix]]
];
[_prefix, _unitTypes, _eliteLoadoutData] call _fnc_generateAndSaveUnitsToTemplate;

["other", [["Crew", _crewTemplate, [], ["other"]]], _crewLoadoutData] call _fnc_generateAndSaveUnitsToTemplate;
["other", [["Pilot", _crewTemplate, [], ["other"]]], _pilotLoadoutData] call _fnc_generateAndSaveUnitsToTemplate;
["other", [["Official", _officerTemplate, [], ["other"]]], _militaryLoadoutData] call _fnc_generateAndSaveUnitsToTemplate;
["other", [["Traitor", _traitorTemplate, [], ["other"]]], _militiaLoadoutData] call _fnc_generateAndSaveUnitsToTemplate;
["other", [["Unarmed", _unarmedTemplate, [], ["other"]]], _militaryLoadoutData] call _fnc_generateAndSaveUnitsToTemplate;

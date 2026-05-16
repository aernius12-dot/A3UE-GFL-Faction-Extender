private _hasApex = "expansion" in A3A_enabledDLC;
private _hasContact = "enoch" in A3A_enabledDLC;
private _hasLawsOfWar = "orange" in A3A_enabledDLC;
private _hasWs = "ws" in A3A_enabledDLC;

//////////////////////////////
//   Civilian Information   //
//////////////////////////////

private _civCarsWithWeights = [
    "C_Quadbike_01_F", 0.3,
    "C_Hatchback_01_F", 7.0,
    "C_Hatchback_01_sport_F", 0.3,
    "C_Offroad_01_F", 1.0,
    "C_SUV_01_F", 1.0
];
private _civBoat = [
    "C_Boat_Civil_01_rescue_F", 0.1,
    "C_Boat_Civil_01_police_F", 0.1,
    "C_Boat_Civil_01_F", 1.0,
    "C_Rubberboat", 1.0
];
private _civIndustrial = [
    "C_Van_01_transport_F", 1.0,
    "C_Van_01_box_F", 0.8,
    "C_Truck_02_transport_F", 0.5,
    "C_Truck_02_covered_F", 0.5
];
private _civRepair = [
    "C_Offroad_01_repair_F", 0.3,
    "C_Truck_02_box_F", 0.1
];
private _civMedical = [];
private _civFuel = [
    "C_Van_01_fuel_F", 0.2,
    "C_Truck_02_fuel_F", 0.1
];
private _civPlanes = [];
private _civHelicopter = ["C_Heli_Light_01_civil_F", "a3a_C_Heli_Transport_02_F", "a3a_C_Heli_Light_02_blue_F"];

if (_hasApex) then {
    _civCarsWithWeights append ["C_Offroad_02_unarmed_F", 1.0];
};
if (_hasContact) then {
    _civCarsWithWeights append ["C_Offroad_01_comms_F", 0.1, "C_Offroad_01_covered_F", 0.1];
};
if (_hasLawsOfWar) then {
    _civMedical append ["C_Van_02_medevac_F", 0.1];
};
if (_hasWs) then {
    _civCarsWithWeights append ["C_Offroad_lxWS", 1.0];
};

["vehiclesCivCar", _civCarsWithWeights] call _fnc_saveToTemplate;
["vehiclesCivHeli", _civHelicopter] call _fnc_saveToTemplate;
["vehiclesCivIndustrial", _civIndustrial] call _fnc_saveToTemplate;
["vehiclesCivBoat", _civBoat] call _fnc_saveToTemplate;
["vehiclesCivRepair", _civRepair] call _fnc_saveToTemplate;
["vehiclesCivMedical", _civMedical] call _fnc_saveToTemplate;
["vehiclesCivFuel", _civFuel] call _fnc_saveToTemplate;
["vehiclesCivPlanes", _civPlanes] call _fnc_saveToTemplate;
["variants", []] call _fnc_saveToTemplate;
["animations", []] call _fnc_saveToTemplate;

//////////////////////////
//       Loadouts       //
//////////////////////////

private _civUniforms = ["U_C_Man_casual_1_F"];
private _faces = [
    "GreekHead_A3_02", "GreekHead_A3_03", "GreekHead_A3_04",
    "GreekHead_A3_05", "GreekHead_A3_06", "GreekHead_A3_07",
    "AsianHead_A3_01", "AsianHead_A3_02", "AsianHead_A3_03",
    "AfricanHead_01", "AfricanHead_02", "AfricanHead_03",
    "WhiteHead_01", "WhiteHead_02", "WhiteHead_03", "WhiteHead_04"
];

["uniforms", _civUniforms] call _fnc_saveToTemplate;
["headgear", []] call _fnc_saveToTemplate;
["faces", _faces] call _fnc_saveToTemplate;

private _loadoutData = call _fnc_createLoadoutData;

_loadoutData set ["uniforms", _civUniforms];
_loadoutData set ["pressUniforms", _civUniforms];
_loadoutData set ["workerUniforms", _civUniforms];
_loadoutData set ["pressVests", []];
_loadoutData set ["helmets", []];
_loadoutData set ["pressHelmets", []];
_loadoutData set ["workerHelmets", []];
_loadoutData set ["maps", ["ItemMap"]];
_loadoutData set ["watches", ["ItemWatch"]];
_loadoutData set ["compasses", ["ItemCompass"]];

private _manTemplate = {
    ["uniforms"] call _fnc_setUniform;
    ["items_medical_standard"] call _fnc_addItemSet;
    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
};
private _workerTemplate = {
    ["workerUniforms"] call _fnc_setUniform;
    ["items_medical_standard"] call _fnc_addItemSet;
    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
};
private _pressTemplate = {
    ["pressUniforms"] call _fnc_setUniform;
    ["items_medical_standard"] call _fnc_addItemSet;
    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
};

private _prefix = "militia";
private _unitTypes = [
    ["Press", _pressTemplate],
    ["Worker", _workerTemplate],
    ["Man", _manTemplate]
];

[_prefix, _unitTypes, _loadoutData] call _fnc_generateAndSaveUnitsToTemplate;

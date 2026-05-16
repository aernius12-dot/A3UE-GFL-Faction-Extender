/*
    EG Mecha trader stock for the GFL extender.
    The condition also checks that the vehicle class exists so the entry stays hidden
    when the EG Mecha mod is not loaded.
*/

class gfl_vehicles_egmecha : vehicles_base
{
    ITEM(EG_Mecha_FourFoot, 5000, ARMEDCAR, "isClass (configFile >> 'CfgVehicles' >> 'EG_Mecha_FourFoot') && ([""resources_3""] call A3U_fnc_hasRequirements) && ([""factories_3""] call A3U_fnc_hasRequirements)");
};

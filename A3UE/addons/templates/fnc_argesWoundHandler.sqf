// ACE wound handler for Arges_F — mirrors COR_fnc_damage's approach exactly.
// Registered via ACE_Medical_Injuries.damageTypes.woundHandlers in config.cpp.
// Runs after ace_medical_damage_fnc_woundsHandlerBase; fullHeal clears wounds it
// created, then _allDamages resize 0 prevents ACE from applying any of them.
// Skips when Corvus is active — COR_fnc_damage owns ACE state in that case.
params ["_unit", "_allDamages", "_typeOfDamage", "_ammo"];
if (typeOf _unit != "Arges_F")                               exitWith { _this };
if (!alive _unit)                                            exitWith { _this };
if (_unit getVariable ["GFL_ArgesState", "NONE"] != "ARGES") exitWith { _this };
if (_unit getVariable ["COR_SysEnabled", false])             exitWith { _this };

_unit call ace_medical_fnc_fullHeal;
_allDamages resize 0;
_this

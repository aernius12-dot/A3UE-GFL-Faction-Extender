// Replaces ACE's base wound handler key in ACE_Medical_Injuries config.
// For active non-Corvus Arges_F: clears wounds and blocks creation via resize 0.
// For all other units: delegates to the real ace_medical_damage_fnc_woundsHandlerBase.
// This avoids config key iteration order being non-deterministic — we ARE the base handler.
params ["_unit", "_allDamages", "_typeOfDamage", "_ammo"];

if (typeOf _unit == "Arges_F"
        && alive _unit
        && {_unit getVariable ["GFL_ArgesState", "NONE"] == "ARGES"}
        && {!(_unit getVariable ["COR_SysEnabled", false])}) then {
    _unit call ace_medical_fnc_fullHeal;
    _allDamages resize 0;
    _this
} else {
    [_unit, _allDamages, _typeOfDamage, _ammo] call ace_medical_damage_fnc_woundsHandlerBase
};

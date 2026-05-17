// Replaces ACE's base wound handler key in ACE_Medical_Injuries config.
// For ALL active Arges_F (both non-Corvus and Corvus modes): clears ACE wounds + blocks
//   creation via resize 0.  Corvus's own HandleDamage EH handles damage tracking internally
//   (COR_CoolantVolume drain, COR_Shutdown); ACE wounds must not accumulate in either path
//   or ACE cardiac-arrest will kill the unit independent of our HP pool / Corvus system.
// For all other units: delegates to the real ace_medical_damage_fnc_woundsHandlerBase.
params ["_unit", "_allDamages", "_typeOfDamage", "_ammo"];

if (typeOf _unit == "Arges_F"
        && alive _unit
        && {_unit getVariable ["GFL_ArgesState", "NONE"] == "ARGES"}) then {
    _unit call ace_medical_fnc_fullHeal;
    _allDamages resize 0;
    _this
} else {
    [_unit, _allDamages, _typeOfDamage, _ammo] call ace_medical_damage_fnc_woundsHandlerBase
};

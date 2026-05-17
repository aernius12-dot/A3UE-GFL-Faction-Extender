// Replaces ACE's base wound handler key in ACE_Medical_Injuries config.
// For active non-Corvus Arges_F: clears wounds + blocks creation via resize 0.
//   Our HandleDamage filter returns 0 so no engine damage passes through; fullHeal
//   ensures the ACE wound state stays clean between hits.
// For Corvus-active Arges_F: delegates to the real base handler.
//   Corvus's own HandleDamage EH owns the damage pipeline in Corvus mode (we remove
//   our EH and stand aside). ACE wound processing via the base handler is part of
//   Corvus's normal flow, same as on any TDoll.
// For all other units: delegates to the real ace_medical_damage_fnc_woundsHandlerBase.
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

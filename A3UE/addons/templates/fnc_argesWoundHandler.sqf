// Wound handler — registered as an ADDITIVE entry under ACE_Medical_Injuries
// (NOT replacing ace_medical_damage_woundsHandlerBase). This means ACE's normal
// wound pipeline and Corvus's COR_Damage handler still run unchanged for everyone;
// we only do extra work for actively-transformed, non-Corvus Arges.
//
// For everything else (non-Arges, dead Arges, Corvus-active Arges, raw Arges_F):
//   exit early returning _this unchanged — ACE/Corvus own those flows entirely.
//
// For non-Corvus transformed Arges: fullHeal + resize 0 so ACE creates no wounds.
//   This is the wound-side complement to the HandleDamage filter / HitPart drain
//   that handles structural damage in fnc_argesDamageFilter.sqf.
params ["_unit", "_allDamages", "_typeOfDamage", "_ammo"];

if (typeOf _unit != "Arges_F")                                   exitWith { _this };
if (!alive _unit)                                                exitWith { _this };
if (_unit getVariable ["GFL_ArgesState", "NONE"] != "ARGES")     exitWith { _this };
if (_unit getVariable ["COR_SysEnabled", false])                 exitWith { _this };

// Non-Corvus transformed Arges only — clear ACE state + suppress wound creation.
_unit call ace_medical_fnc_fullHeal;
_allDamages resize 0;
_this

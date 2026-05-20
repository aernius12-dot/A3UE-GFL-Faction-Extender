#include "script_component.hpp"
Info("settingsInit started — registering GFL Antistasi addon settings");

// Following CORVUS pattern: 7 params, category at position 4.
// For LIST type, the [values, labels, defaultIndex] array sits in the default-value slot.
[
    "GFL_petrosHeadSetting",                                                 // name
    "LIST",                                                                   // type
    ["Petros Head", "Select the head model used by Petros."],                 // [title, tooltip]
    "GFL Antistasi",                                                          // category
    [[0, 1], ["Default (Petros)", "Commander Male"], 0],                      // [values, labels, defaultIndex]
    1,                                                                        // isGlobal (1 = server-forced)
    {
        params ["_value"];
        diag_log format ["[GFL Settings] GFL_petrosHeadSetting changed to %1", _value];
    }
] call CBA_fnc_addSetting;

// Petros display name (chat / group label)
[
    "GFL_petrosNameSetting",
    "LIST",
    ["Petros Name", "Display name shown for Petros in chat, group label, and HUD."],
    "GFL Antistasi",
    [[0, 1, 2, 3], ["Petros", "John Frontline", "Commander", "Shikikan"], 0],
    1,
    {
        params ["_value"];
        diag_log format ["[GFL Settings] GFL_petrosNameSetting changed to %1", _value];
    }
] call CBA_fnc_addSetting;

// ---------------- Doll resolver toggles (per side, per concern) ----------------
//
// Three independent concerns, each split between GnK rebel side and hostile-AI side:
//
//   Face / Outfit / Weapon matcher
//     -> Reads the unit's face, picks the canonical doll profile, then applies the
//        matching face + uniform body model + canonical weapon family.
//
//   Corvus loadout (FCC backpack)
//     -> Independent of the matcher. Looks up the unit's current face in the doll
//        profile map, and assigns the FCC backpack that matches the doll's canonical
//        role (Sentinel -> Sent_Pack, Bulwark -> Bul_Pack, Support -> Sup_Pack, ...).
//
//   Corvus buff (armor + PFH)
//     -> The actual COR_SysEnabled init that gives the unit armor/coolant/stamina/
//        recoil-coefficient buffs. Reads the FCC backpack the unit is wearing.
//
// All six default to true (preserving current behavior). Toggling them off
// individually lets you e.g. "match face + outfit + weapon on hostile, but no FCC
// backpack, and no buff" — or any other combination.

[
    "GFL_MatchFaceOutfit_GnK",
    "CHECKBOX",
    ["GnK Rebel: Match Face / Outfit / Weapon", "Run the doll resolver on GnK rebel units (face -> uniform body model + canonical weapon family). When off, GnK rebels keep whatever random face/uniform Antistasi assigned."],
    "GFL Antistasi",
    [true],
    1,
    {
        params ["_value"];
        diag_log format ["[GFL Settings] GFL_MatchFaceOutfit_GnK changed to %1", _value];
    }
] call CBA_fnc_addSetting;

[
    "GFL_MatchFaceOutfit_Hostile",
    "CHECKBOX",
    ["Hostile Force: Match Face / Outfit / Weapon", "Run the doll resolver on hostile AI (ELMO, Paradeus, Sangvis, ...). When off, hostile units keep whatever random kit Antistasi assigned."],
    "GFL Antistasi",
    [true],
    1,
    {
        params ["_value"];
        diag_log format ["[GFL Settings] GFL_MatchFaceOutfit_Hostile changed to %1", _value];
    }
] call CBA_fnc_addSetting;

[
    "GFL_CorvusLoadout_GnK",
    "CHECKBOX",
    ["GnK Rebel: Corvus Loadout (FCC Backpack)", "Assign each GnK rebel the FCC backpack that matches their doll's canonical role (Sentinel/Bulwark/Support/Vanguard/Base)."],
    "GFL Antistasi",
    [true],
    1,
    {
        params ["_value"];
        diag_log format ["[GFL Settings] GFL_CorvusLoadout_GnK changed to %1", _value];
    }
] call CBA_fnc_addSetting;

[
    "GFL_CorvusLoadout_Hostile",
    "CHECKBOX",
    ["Hostile Force: Corvus Loadout (FCC Backpack)", "Assign each hostile AI doll the FCC backpack matching their canonical role. Without the backpack the Corvus buff init won't fire on them either."],
    "GFL Antistasi",
    [true],
    1,
    {
        params ["_value"];
        diag_log format ["[GFL Settings] GFL_CorvusLoadout_Hostile changed to %1", _value];
    }
] call CBA_fnc_addSetting;

[
    "GFL_CorvusBuff_GnK",
    "CHECKBOX",
    ["GnK Rebel: Corvus Buff", "Apply the Corvus armor / coolant / movement buff to GnK rebel units. Reads the FCC backpack on the unit, so this only fires if the GnK has an FCC pack equipped."],
    "GFL Antistasi",
    [true],
    1,
    {
        params ["_value"];
        diag_log format ["[GFL Settings] GFL_CorvusBuff_GnK changed to %1", _value];
    }
] call CBA_fnc_addSetting;

[
    "GFL_CorvusBuff_Hostile",
    "CHECKBOX",
    ["Hostile Force: Corvus Buff", "Apply the Corvus armor / coolant / movement buff to hostile AI dolls. Hostile armor is scaled down per GFL_CorvusHostileArmor (130/90/60/40)."],
    "GFL Antistasi",
    [true],
    1,
    {
        params ["_value"];
        diag_log format ["[GFL Settings] GFL_CorvusBuff_Hostile changed to %1", _value];
    }
] call CBA_fnc_addSetting;

// Whether equipping GFL_ArgesFrame triggers the Arges_F body swap on the player after 10 s.
// When off, the outfit can be worn cosmetically without transforming.
[
    "GFL_ArgesTransformEnabled",
    "CHECKBOX",
    ["Arges Transformation", "Enable the 10 s body swap to Arges_F when GFL_ArgesFrame is equipped."],
    "GFL Antistasi",
    [true],
    1,
    {
        params ["_value"];
        diag_log format ["[GFL Settings] GFL_ArgesTransformEnabled changed to %1", _value];
    }
] call CBA_fnc_addSetting;

// Whether GFL_ArgesFrame is pre-unlocked in the Antistasi arsenal at mission start.
// When off, the outfit must be unlocked through normal Antistasi progression.
[
    "GFL_ArgesArsenalPreUnlock",
    "CHECKBOX",
    ["Arges Frame Pre-Unlocked", "Add GFL_ArgesFrame to the Antistasi arsenal at mission start."],
    "GFL Antistasi",
    [false],
    1,
    {
        params ["_value"];
        diag_log format ["[GFL Settings] GFL_ArgesArsenalPreUnlock changed to %1", _value];
    }
] call CBA_fnc_addSetting;

// Server-side: wait until Antistasi's arsenal has finished initialising, then conditionally
// unlock GFL_ArgesFrame. waitUntilAndExecute polls the predicate once per frame.
if (isServer) then {
    [
        { missionNamespace getVariable ["serverInitDone", false] },
        {
            if (missionNamespace getVariable ["GFL_ArgesArsenalPreUnlock", false]) then {
                diag_log "[GFL Settings] Pre-unlocking GFL_ArgesFrame in arsenal";
                ["GFL_ArgesFrame", true] call A3A_fnc_unlockEquipment;
            };
        }
    ] call CBA_fnc_waitUntilAndExecute;
};

Info("settingsInit finished");

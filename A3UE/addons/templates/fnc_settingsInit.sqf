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

// Whether the Corvus init script applies armor/buffs to hostile AI units (ELMO etc.).
// When off, hostile ELMO units still get FCC backpacks but no COR_SysEnabled / buff PFH —
// so they fight as plain Antistasi infantry. Rebel units (GnK / Petros) are unaffected.
[
    "GFL_CorvusBuffHostileAI",
    "CHECKBOX",
    ["Corvus AI Buff (Hostile)", "Apply Corvus armor/buffs to hostile AI (ELMO etc.). Rebels always get the full buff."],
    "GFL Antistasi",
    [true],
    1,
    {
        params ["_value"];
        diag_log format ["[GFL Settings] GFL_CorvusBuffHostileAI changed to %1", _value];
    }
] call CBA_fnc_addSetting;

// Whether the ELMO doll resolver matches face/outfit/weapon on hostile AI units.
// When off, hostile ELMO units keep whatever random face + random weapon Antistasi assigned.
[
    "GFL_DollMatchHostileAI",
    "CHECKBOX",
    ["Match Face/Outfit/Weapon (Hostile)", "Run the class-first doll resolver on hostile AI (ELMO etc.). Disable to keep Antistasi's random kit."],
    "GFL Antistasi",
    [true],
    1,
    {
        params ["_value"];
        diag_log format ["[GFL Settings] GFL_DollMatchHostileAI changed to %1", _value];
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

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

Info("settingsInit finished");

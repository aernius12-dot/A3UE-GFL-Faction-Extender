#include "script_component.hpp"
Info("settingsInit started — registering GFL Antistasi addon settings");

[
    "GFL_petrosHeadSetting",                                                // setting name
    "LIST",                                                                  // type
    ["Petros Head", "Select the head model used by Petros."],                // [title, tooltip]
    [[0, 1], ["Default (Petros)", "Commander Male"]],                        // [values, labels]
    "GFL Antistasi",                                                         // category
    0,                                                                       // default value
    1,                                                                       // isGlobal (1 = server-forced)
    {
        params ["_value"];
        diag_log format ["[GFL Settings] GFL_petrosHeadSetting changed to %1", _value];
    }
] call CBA_fnc_addSetting;

Info("settingsInit finished");

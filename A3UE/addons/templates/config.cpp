#include "script_component.hpp"

class CfgPatches 
{
    class ADDON 
    {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {
            QDOUBLES(PREFIX,core), "A3A_core", "A3A_ultimate",
            "TacGirls", "GFL_Mangi", "GFL_Paradeus", "SF_Sangvis_Ferri",
            "cba_main",
            "ace_common"
        };
        author = AUTHOR;
        authors[] = { AUTHORS };
        authorUrl = "";
        VERSION_CONFIG;
    };
};

class A3A 
{
    #include "Templates.hpp"
};

// GFL_ArgesFrame: equippable outfit that triggers the Arges_F URNC body swap.
// Inherits appearance from arges_uniform (URNC heavy combat frame from TacGirls).
class CfgWeapons {
    class arges_uniform;
    class GFL_ArgesFrame: arges_uniform {
        scope = 2;
        scopeArsenal = 2;
        displayName = "Arges Frame [URNC]";
        description = "URNC autonomous heavy combat frame. Equipping initiates full skeleton transfer to Arges-class unit.";
    };
};

class cfgFunctions {
    class GFL {
        class GFL_Templates {
            PATHTO_FNC(settingsInit);
            PATHTO_FNC(dollInit);
            PATHTO_FNC(corvusInit);
            PATHTO_FNC(argesInit);
            PATHTO_FNC(argesTransform);
            PATHTO_FNC(argesRevert);
            PATHTO_FNC(argesWoundHandler);
            PATHTO_FNC(argesDamageFilter);
        };
    };
};

// (Extended_HandleDamage_EventHandlers tried with Arges_F and CAManBase inner classes —
//  neither fired in RPT. CBA's XEH HandleDamage framework appears not to apply to this
//  unit chain. HandleDamage is now registered via direct addEventHandler in
//  fnc_argesTransform.sqf — guaranteed to fire on whichever machine has unit locality.)

// Prevent ACE cardiac arrest on Arges_F units (Branch 2: ACE present, Corvus inactive).
// Override the base wound handler key so ours runs in its place — avoids non-deterministic
// config key iteration order. For Arges: fullHeal + resize 0. For all others: delegate to
// the real ace_medical_damage_fnc_woundsHandlerBase function.
class ACE_Medical_Injuries {
    class damageTypes {
        class woundHandlers {
            ace_medical_damage_woundsHandlerBase = "GFL_fnc_argesWoundHandler";
        };
    };
};

class Extended_PreInit_EventHandlers {
    class GFL_SettingsInit {
        init = "call compile preprocessFileLineNumbers '\x\A3UE\addons\templates\fnc_settingsInit.sqf';";
    };
};

// Activate CORVUS on GnK AI units at mission start (server-side only).
// Arges monitor runs on all clients with interface (hasInterface guard inside).
class Extended_PostInit_EventHandlers {
    class GFL_DollActivation {
        init = "call GFL_fnc_dollInit;";
    };
    class GFL_CORVUSActivation {
        init = "call GFL_fnc_corvusInit;";
    };
    class GFL_ArgesActivation {
        init = "call GFL_fnc_argesInit;";
    };
};

#include "CfgGroups.hpp"

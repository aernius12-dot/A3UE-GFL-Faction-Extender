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
            "CORVUS",
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
            PATHTO_FNC(corvusInit);
            PATHTO_FNC(argesInit);
            PATHTO_FNC(argesTransform);
            PATHTO_FNC(argesRevert);
        };
    };
};

// Activate CORVUS on GnK AI units at mission start (server-side only).
// Arges monitor runs on all clients with interface (hasInterface guard inside).
class Extended_PostInit_EventHandlers {
    class GFL_CORVUSActivation {
        init = "call GFL_fnc_corvusInit;";
    };
    class GFL_ArgesActivation {
        init = "call GFL_fnc_argesInit;";
    };
};

#include "CfgGroups.hpp"

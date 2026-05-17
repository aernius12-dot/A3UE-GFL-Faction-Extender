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
            PATHTO_FNC(corvusInit);
            PATHTO_FNC(argesInit);
            PATHTO_FNC(argesTransform);
            PATHTO_FNC(argesRevert);
            PATHTO_FNC(argesWoundHandler);
        };
    };
};

// Arges_F hitpoint armor override: sets every hitpoint's armour value to 1000.
// ACE normalises HandleDamage _damage as (raw_projectile_energy / hitpoint_armour).
// With default armour (~2-10), a .50 cal hit normalises to ~1.5-2.0 — instantly lethal.
// At 1000 the same round normalises to ~0.015, well below the engine's 1.0 kill threshold.
// Our HandleDamage filter still returns 0 for all non-killing hits; this is belt-and-
// suspenders for the brief window when ACE's EH is re-registered and runs last.
class CfgVehicles {
    class Arges_F {
        class HitPoints {
            class HitFace    { armor = 1000; };
            class HitNeck    { armor = 1000; };
            class HitHead    { armor = 1000; };
            class HitPelvis  { armor = 1000; };
            class HitAbdomen { armor = 1000; };
            class HitDiaphragm { armor = 1000; };
            class HitChest   { armor = 1000; };
            class HitBody    { armor = 1000; };
            class HitArms    { armor = 1000; };
            class HitHands   { armor = 1000; };
            class HitLegs    { armor = 1000; };
            class HitLeftArm  { armor = 1000; };
            class HitRightArm { armor = 1000; };
            class HitLeftLeg  { armor = 1000; };
            class HitRightLeg { armor = 1000; };
        };
    };
};

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

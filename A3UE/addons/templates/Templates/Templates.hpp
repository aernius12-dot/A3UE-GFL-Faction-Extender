class Templates
{
    class Vanilla_Base;

    class GFL_Base : Vanilla_Base
    {
        requiredAddons[] = {"TacGirls", "GFL_Mangi", "GFL_Paradeus", "SF_Sangvis_Ferri"};
        basepath = QPATHTOFOLDER(Templates\GFL);
        priority = 10;
    };

    class GFL_Elmo_Occ : GFL_Base
    {
        side = "Occ";
        flagTexture = "\A3\Data_F\Flags\flag_nato_co.paa";
        name = "GFL - Elmo Force";
        file = "GFL_AI_Elmo";
        climate[] = {"arid", "temperate"};
    };

    class GFL_Sangvis_Occ : GFL_Base
    {
        side = "Occ";
        flagTexture = "\A3\Data_F\Flags\Flag_CSAT_CO.paa";
        name = "GFL - Sangvis Ferri";
        file = "GFL_AI_Sangvis";
        climate[] = {"arid", "temperate"};
    };

    class GFL_Mangi_Occ : GFL_Base
    {
        side = "Occ";
        flagTexture = "\A3\Data_F\Flags\flag_aaf_co.paa";
        name = "GFL - Mangi Mercenaries";
        file = "GFL_AI_Mangi";
        climate[] = {"arid", "temperate"};
    };

    class GFL_Varjagers_Occ : GFL_Base
    {
        side = "Occ";
        flagTexture = "\A3\Data_F\Flags\Flag_CSAT_CO.paa";
        name = "GFL - Varjagers";
        file = "GFL_AI_Varjagers";
        climate[] = {"arid", "temperate"};
    };

    class GFL_Paradeus_Inv : GFL_Base
    {
        side = "Inv";
        flagTexture = "\A3\Data_F\Flags\Flag_CSAT_CO.paa";
        name = "GFL - Paradeus";
        file = "GFL_AI_Paradeus";
        climate[] = {"arid", "temperate"};
    };

    class GFL_Varjagers_Inv : GFL_Base
    {
        side = "Inv";
        flagTexture = "\A3\Data_F\Flags\Flag_CSAT_CO.paa";
        name = "GFL - Varjagers (Invader)";
        file = "GFL_AI_Varjagers";
        climate[] = {"arid", "temperate"};
    };

    class GFL_GnK_Reb : GFL_Base
    {
        side = "Reb";
        flagTexture = "\A3\Data_F\Flags\flag_fia_co.paa";
        name = "Griffin & Kryuger PMC";
        file = "GFL_Reb_GnK";
        climate[] = {"arid", "temperate"};
    };

    class GFL_Civ : GFL_Base
    {
        side = "Civ";
        flagTexture = "\A3\Data_F\Flags\Flag_Altis_CO.paa";
        name = "GFL Civilians";
        file = "GFL_Civ";
        climate[] = {"arid", "temperate"};
    };

    class GFL_Paradeus_Riv : GFL_Base
    {
        side = "Riv";
        flagTexture = "\A3\Data_F\Flags\Flag_CSAT_CO.paa";
        name = "GFL - Paradeus Remnants";
        file = "GFL_Riv_Paradeus";
    };

    class GFL_Sangvis_Riv : GFL_Base
    {
        side = "Riv";
        flagTexture = "\A3\Data_F\Flags\Flag_CSAT_CO.paa";
        name = "GFL - Sangvis Ferri Remnants";
        file = "GFL_AI_Sangvis";
    };
};

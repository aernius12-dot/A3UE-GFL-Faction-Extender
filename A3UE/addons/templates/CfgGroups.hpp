// CfgGroups — GFL Faction Zeus Group Presets

// Standard squad formation positions (wedge, 8-man)
#define POS_SL      {0,0,0}
#define POS_FIRETEAM_A1 {-4,4,0}
#define POS_FIRETEAM_A2 {4,4,0}
#define POS_FIRETEAM_B1 {-8,8,0}
#define POS_FIRETEAM_B2 {8,8,0}
#define POS_FIRETEAM_C1 {-4,12,0}
#define POS_FIRETEAM_C2 {4,12,0}
#define POS_REAR        {0,14,0}

// Fireteam formation positions (diamond, 4-man)
#define POS_FT_LEAD {0,0,0}
#define POS_FT_L    {-4,4,0}
#define POS_FT_R    {4,4,0}
#define POS_FT_REAR {0,8,0}

class CfgGroups {

    // ──────────────────────────────────────────────────────────
    //  WEST (BLUFOR) — Elmo Force
    // ──────────────────────────────────────────────────────────
    class West {
        name = "BLUFOR";
        class GFL_Elmo_Groups {
            name = "GFL - Elmo Force";
            class Infantry {
                name = "Infantry";

                class GFL_Elmo_Squad {
                    name = "T-Doll Squad (8)";
                    side = 1;
                    class Unit0 { vehicle = "Commanderfemale_F"; rank = "SERGEANT"; position[] = POS_SL;          special = "NONE"; };
                    class Unit1 { vehicle = "Klukai_F";          rank = "CORPORAL"; position[] = POS_FIRETEAM_A1; special = "NONE"; };
                    class Unit2 { vehicle = "Groza_F";           rank = "PRIVATE";  position[] = POS_FIRETEAM_A2; special = "NONE"; };
                    class Unit3 { vehicle = "Harpsy_F";          rank = "PRIVATE";  position[] = POS_FIRETEAM_B1; special = "NONE"; };
                    class Unit4 { vehicle = "Lotta_F";           rank = "PRIVATE";  position[] = POS_FIRETEAM_B2; special = "NONE"; };
                    class Unit5 { vehicle = "Helen_F";           rank = "CORPORAL"; position[] = POS_FIRETEAM_C1; special = "NONE"; };
                    class Unit6 { vehicle = "Mosin_F";           rank = "PRIVATE";  position[] = POS_FIRETEAM_C2; special = "NONE"; };
                    class Unit7 { vehicle = "Qiongjiu_F";        rank = "PRIVATE";  position[] = POS_REAR;        special = "NONE"; };
                };

                class GFL_Elmo_Fireteam {
                    name = "T-Doll Fireteam (4)";
                    side = 1;
                    class Unit0 { vehicle = "Commanderfemale_F"; rank = "SERGEANT"; position[] = POS_FT_LEAD; special = "NONE"; };
                    class Unit1 { vehicle = "Klukai_F";          rank = "PRIVATE";  position[] = POS_FT_L;    special = "NONE"; };
                    class Unit2 { vehicle = "Harpsy_F";          rank = "PRIVATE";  position[] = POS_FT_R;    special = "NONE"; };
                    class Unit3 { vehicle = "Helen_F";           rank = "PRIVATE";  position[] = POS_FT_REAR; special = "NONE"; };
                };

                class GFL_Elmo_Sniper {
                    name = "T-Doll Sniper Team (2)";
                    side = 1;
                    class Unit0 { vehicle = "Lind_F";    rank = "SERGEANT"; position[] = {0,0,0}; special = "NONE"; };
                    class Unit1 { vehicle = "Jiangyu_F"; rank = "CORPORAL"; position[] = {2,4,0}; special = "NONE"; };
                };
            };
        };
    };

    // ──────────────────────────────────────────────────────────
    //  EAST (OPFOR) — Paradeus / Sangvis Ferri / Varjagers
    // ──────────────────────────────────────────────────────────
    class East {
        name = "OPFOR";

        class GFL_Paradeus_Groups {
            name = "GFL - Paradeus";
            class Infantry {
                name = "Infantry";

                class GFL_Paradeus_NytoSquad {
                    name = "Nyto Squad (8)";
                    side = 0;
                    class Unit0 { vehicle = "Custos036_F";  rank = "SERGEANT"; position[] = POS_SL;          special = "NONE"; };
                    class Unit1 { vehicle = "Niter_F";      rank = "CORPORAL"; position[] = POS_FIRETEAM_A1; special = "NONE"; };
                    class Unit2 { vehicle = "Sextansalt_F"; rank = "PRIVATE";  position[] = POS_FIRETEAM_A2; special = "NONE"; };
                    class Unit3 { vehicle = "Unitas015_F";  rank = "PRIVATE";  position[] = POS_FIRETEAM_B1; special = "NONE"; };
                    class Unit4 { vehicle = "Unitas039_F";  rank = "PRIVATE";  position[] = POS_FIRETEAM_B2; special = "NONE"; };
                    class Unit5 { vehicle = "Niter_F";      rank = "CORPORAL"; position[] = POS_FIRETEAM_C1; special = "NONE"; };
                    class Unit6 { vehicle = "Custos036_F";  rank = "PRIVATE";  position[] = POS_FIRETEAM_C2; special = "NONE"; };
                    class Unit7 { vehicle = "Sextansalt_F"; rank = "PRIVATE";  position[] = POS_REAR;        special = "NONE"; };
                };

                class GFL_Paradeus_Fireteam {
                    name = "Nyto Fireteam (4)";
                    side = 0;
                    class Unit0 { vehicle = "Custos036_F";  rank = "SERGEANT"; position[] = POS_FT_LEAD; special = "NONE"; };
                    class Unit1 { vehicle = "Niter_F";      rank = "PRIVATE";  position[] = POS_FT_L;    special = "NONE"; };
                    class Unit2 { vehicle = "Unitas039_F";  rank = "PRIVATE";  position[] = POS_FT_R;    special = "NONE"; };
                    class Unit3 { vehicle = "Sextansalt_F"; rank = "PRIVATE";  position[] = POS_FT_REAR; special = "NONE"; };
                };
            };
        };

        class GFL_Sangvis_Groups {
            name = "GFL - Sangvis Ferri";
            class Infantry {
                name = "Infantry";

                class GFL_Sangvis_Squad {
                    name = "SF Hunter Squad (8)";
                    side = 0;
                    class Unit0 { vehicle = "SangvisVespid_F";  rank = "SERGEANT"; position[] = POS_SL;          special = "NONE"; };
                    class Unit1 { vehicle = "SangvisGuard_F";   rank = "CORPORAL"; position[] = POS_FIRETEAM_A1; special = "NONE"; };
                    class Unit2 { vehicle = "SangvisJaeger_F";  rank = "PRIVATE";  position[] = POS_FIRETEAM_A2; special = "NONE"; };
                    class Unit3 { vehicle = "SangvisRipper_F";  rank = "PRIVATE";  position[] = POS_FIRETEAM_B1; special = "NONE"; };
                    class Unit4 { vehicle = "SangvisGuard_F";   rank = "PRIVATE";  position[] = POS_FIRETEAM_B2; special = "NONE"; };
                    class Unit5 { vehicle = "SangvisJaeger_F";  rank = "CORPORAL"; position[] = POS_FIRETEAM_C1; special = "NONE"; };
                    class Unit6 { vehicle = "SangvisRipper_F";  rank = "PRIVATE";  position[] = POS_FIRETEAM_C2; special = "NONE"; };
                    class Unit7 { vehicle = "SangvisVespid_F";  rank = "PRIVATE";  position[] = POS_REAR;        special = "NONE"; };
                };

                class GFL_Sangvis_Fireteam {
                    name = "SF Scout Team (4)";
                    side = 0;
                    class Unit0 { vehicle = "SangvisVespid_F"; rank = "SERGEANT"; position[] = POS_FT_LEAD; special = "NONE"; };
                    class Unit1 { vehicle = "SangvisGuard_F";  rank = "PRIVATE";  position[] = POS_FT_L;    special = "NONE"; };
                    class Unit2 { vehicle = "SangvisJaeger_F"; rank = "PRIVATE";  position[] = POS_FT_R;    special = "NONE"; };
                    class Unit3 { vehicle = "SangvisRipper_F"; rank = "PRIVATE";  position[] = POS_FT_REAR; special = "NONE"; };
                };
            };
        };

        class GFL_Varjagers_Groups {
            name = "GFL - Varjagers";
            class Infantry {
                name = "Infantry";

                class GFL_Varjagers_Squad {
                    name = "Varjager Assault Squad (8)";
                    side = 0;
                    class Unit0 { vehicle = "Urokrake_F";    rank = "SERGEANT"; position[] = POS_SL;          special = "NONE"; };
                    class Unit1 { vehicle = "Felade_F";      rank = "CORPORAL"; position[] = POS_FIRETEAM_A1; special = "NONE"; };
                    class Unit2 { vehicle = "Felamedisin_F"; rank = "PRIVATE";  position[] = POS_FIRETEAM_A2; special = "NONE"; };
                    class Unit3 { vehicle = "Felade_F";      rank = "PRIVATE";  position[] = POS_FIRETEAM_B1; special = "NONE"; };
                    class Unit4 { vehicle = "Urokrake_F";    rank = "PRIVATE";  position[] = POS_FIRETEAM_B2; special = "NONE"; };
                    class Unit5 { vehicle = "Felamedisin_F"; rank = "CORPORAL"; position[] = POS_FIRETEAM_C1; special = "NONE"; };
                    class Unit6 { vehicle = "Felade_F";      rank = "PRIVATE";  position[] = POS_FIRETEAM_C2; special = "NONE"; };
                    class Unit7 { vehicle = "Urokrake_F";    rank = "PRIVATE";  position[] = POS_REAR;        special = "NONE"; };
                };

                class GFL_Varjagers_Fireteam {
                    name = "Varjager Strike Team (4)";
                    side = 0;
                    class Unit0 { vehicle = "Urokrake_F";    rank = "SERGEANT"; position[] = POS_FT_LEAD; special = "NONE"; };
                    class Unit1 { vehicle = "Felade_F";      rank = "PRIVATE";  position[] = POS_FT_L;    special = "NONE"; };
                    class Unit2 { vehicle = "Felamedisin_F"; rank = "PRIVATE";  position[] = POS_FT_R;    special = "NONE"; };
                    class Unit3 { vehicle = "Felade_F";      rank = "PRIVATE";  position[] = POS_FT_REAR; special = "NONE"; };
                };
            };
        };
    };

    // ──────────────────────────────────────────────────────────
    //  INDEPENDENT (GUER) — Mangi Mercenaries & GnK PMC
    // ──────────────────────────────────────────────────────────
    class Independent {
        name = "Independent";

        class GFL_Mangi_Groups {
            name = "GFL - Mangi Mercenaries";
            class Infantry {
                name = "Infantry";

                class GFL_Mangi_Squad {
                    name = "Mangi Contractor Squad (8)";
                    side = 2;
                    class Unit0 { vehicle = "StrikeCaptain_F"; rank = "SERGEANT"; position[] = POS_SL;          special = "NONE"; };
                    class Unit1 { vehicle = "Blaster_F";       rank = "CORPORAL"; position[] = POS_FIRETEAM_A1; special = "NONE"; };
                    class Unit2 { vehicle = "Spotter_F";       rank = "PRIVATE";  position[] = POS_FIRETEAM_A2; special = "NONE"; };
                    class Unit3 { vehicle = "Blaster_F";       rank = "PRIVATE";  position[] = POS_FIRETEAM_B1; special = "NONE"; };
                    class Unit4 { vehicle = "Mechanist_F";     rank = "PRIVATE";  position[] = POS_FIRETEAM_B2; special = "NONE"; };
                    class Unit5 { vehicle = "Mechanist_F";     rank = "CORPORAL"; position[] = POS_FIRETEAM_C1; special = "NONE"; };
                    class Unit6 { vehicle = "Spotter_F";       rank = "PRIVATE";  position[] = POS_FIRETEAM_C2; special = "NONE"; };
                    class Unit7 { vehicle = "Blaster_F";       rank = "PRIVATE";  position[] = POS_REAR;        special = "NONE"; };
                };

                class GFL_Mangi_Fireteam {
                    name = "Mangi Patrol (4)";
                    side = 2;
                    class Unit0 { vehicle = "StrikeCaptain_F"; rank = "SERGEANT"; position[] = POS_FT_LEAD; special = "NONE"; };
                    class Unit1 { vehicle = "Blaster_F";       rank = "PRIVATE";  position[] = POS_FT_L;    special = "NONE"; };
                    class Unit2 { vehicle = "Spotter_F";       rank = "PRIVATE";  position[] = POS_FT_R;    special = "NONE"; };
                    class Unit3 { vehicle = "Mechanist_F";     rank = "PRIVATE";  position[] = POS_FT_REAR; special = "NONE"; };
                };
            };
        };

        class GFL_GnK_Groups {
            name = "GFL - Griffin & Kryuger PMC";
            class Infantry {
                name = "Infantry";

                class GFL_GnK_PMCSquad {
                    name = "G&K PMC Squad (8)";
                    side = 2;
                    class Unit0 { vehicle = "Commanderfemale_F"; rank = "SERGEANT"; position[] = POS_SL;          special = "NONE"; };
                    class Unit1 { vehicle = "Qiongjiu_F";        rank = "CORPORAL"; position[] = POS_FIRETEAM_A1; special = "NONE"; };
                    class Unit2 { vehicle = "Lainiealt_F";       rank = "PRIVATE";  position[] = POS_FIRETEAM_A2; special = "NONE"; };
                    class Unit3 { vehicle = "Cheyanne_F";        rank = "PRIVATE";  position[] = POS_FIRETEAM_B1; special = "NONE"; };
                    class Unit4 { vehicle = "Papasha_F";         rank = "PRIVATE";  position[] = POS_FIRETEAM_B2; special = "NONE"; };
                    class Unit5 { vehicle = "Littara_F";         rank = "CORPORAL"; position[] = POS_FIRETEAM_C1; special = "NONE"; };
                    class Unit6 { vehicle = "Nagant_F";          rank = "PRIVATE";  position[] = POS_FIRETEAM_C2; special = "NONE"; };
                    class Unit7 { vehicle = "Alva_F";            rank = "PRIVATE";  position[] = POS_REAR;        special = "NONE"; };
                };

                class GFL_GnK_Fireteam {
                    name = "G&K Fireteam (4)";
                    side = 2;
                    class Unit0 { vehicle = "Commanderfemale_F"; rank = "SERGEANT"; position[] = POS_FT_LEAD; special = "NONE"; };
                    class Unit1 { vehicle = "Qiongjiu_F";        rank = "PRIVATE";  position[] = POS_FT_L;    special = "NONE"; };
                    class Unit2 { vehicle = "Cheyanne_F";        rank = "PRIVATE";  position[] = POS_FT_R;    special = "NONE"; };
                    class Unit3 { vehicle = "Littara_F";         rank = "PRIVATE";  position[] = POS_FT_REAR; special = "NONE"; };
                };
            };
        };
    };

}; // end CfgGroups

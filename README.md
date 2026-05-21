# GFL Antistasi Ultimate Faction

A faction pack for Arma 3 that brings the *Girls' Frontline* universe into [Antistasi Ultimate](https://steamcommunity.com/sharedfiles/filedetails/?id=3020755032)'s or [Antistasi the Mod](https://steamcommunity.com/sharedfiles/filedetails/?id=2867537125)'s insurgent warfare sandbox. It defines a full set of playable and AI faction templates — Griffin & Kryuger PMC (rebel/player side), five distinct OPFOR factions, civilians, and two rival remnant factions — using assets from the TacGirls mod and optional vehicle expansion packs.

This mod gives GFL-themed factions (occupant, invader, rebel, rival) into Antistasi's template system, by using GFL2 assets ported to Arma 3 by [Utage's TacGirl - GFL Mod](https://steamcommunity.com/sharedfiles/filedetails/?id=3722505664&tscn=1779110953).

---

### Disclaimer
- Github is a prerelease, expect bugs. especially in multiplayer use.
- I am a lazy bum, so probably won't mantain for long. feel free to fork or fix this after Steam workshop release.

## Requirements

### Required

| Mod | Steam Workshop |
|-----|---------------|
| Community Base Addons (CBA_A3) | [450814997](https://steamcommunity.com/workshop/filedetails/?id=450814997) |
| Antistasi Ultimate | [3020755032](https://steamcommunity.com/sharedfiles/filedetails/?id=3020755032) |
| BC036's Invisible Gears | [1817281735](https://steamcommunity.com/workshop/filedetails/?id=1817281735)
| Utage's TacGirls | [3722505664](https://steamcommunity.com/sharedfiles/filedetails/?id=3722505664) |

### Optional

| Mod | Steam Workshop | Effect |
|-----|---------------|--------|
| Ace3 | [463939057](https://steamcommunity.com/workshop/filedetails/?id=463939057) | Pre-req for Corvus, small support for Arges mode damage handler |
| NeuralCloud- C.O.R.V.U.S Systems [GFL / GFL2] | [3672434840](https://steamcommunity.com/sharedfiles/filedetails/?id=3672434840) | Enables Corvus System "feel" for AI units |
| EG Mecha / KCCO Mech Hydra | [3718158909](https://steamcommunity.com/sharedfiles/filedetails/?id=3718158909) | Enables four-legged mech units for GnK |
| Sci-Fi Vehicles Pack | [3539476763](https://steamcommunity.com/sharedfiles/filedetails/?id=3539476763) | Enables Bearcat IFV family for GnK and Elmo Faction |
| Sci-FI Turrets Pack  | [3712115907](https://steamcommunity.com/sharedfiles/filedetails/?id=3712115907) | Enables Sci-Fi turret pack  |


---

## Features

### 10 Faction Templates

| Template class | Role | Side | Note |
|------------------|---------|---------|-----------------|
| `GFL_GnK_Reb` | Griffin & Kryuger PMC | Rebel (player) | Pretty okay-ish content wise |
| `GFL_Sangvis_Occ` | Sangvis Ferri | Occupant | Content as is from TacGirls |
| `GFL_Sangvis_Riv` | Sangvis Ferri Remnants | Rival | Content as is from TacGirls |
| `GFL_Paradeus_Inv` | Paradeus | Invader | Content as is from TacGirls |
| `GFL_Paradeus_Riv` | Paradeus Remnants | Rival | Content as is from TacGirls |
| `GFL_Elmo_Occ` | Elmo Force | Occupant |  Pretty okay-ish content wise |
| `GFL_Mangi_Occ` | Mangi Mercenaries | Occupant | Content as is from TacGirls |
| `GFL_Varjagers_Occ` | Varjagers | Occupant | Content as is from TacGirls |
| `GFL_Varjagers_Inv` | Varjagers | Invader | Content as is from TacGirls |
| `GFL_Civ` | GFL Civilians | Civilian | #just test

### Named T-Doll Units

The girls which were added by Utage's TacGirls will be spawned by antistasi, and have a script to match each girls head with their outfit (no leva with helen body or other vanilla random outfit). For Opposing Elmo Faction, also have matcher for each T-Doll and their weapons, it might be accurate might be not (no weapon matcher in Rebel faction so antistasi unlock progression not broken). Right if Corvus system is active will also assign each dolls (both GnK and Elmo) with their matching FCC class.

### Transform to Special unit

TacGirls adds several special units, added support scripts to transform player to Arges_F (UNRC robot). The Stats are not exactly the same as TacGirls Arges and have to do a bit workaround for the feel. Able to revert to normal unit through a scroll selector, with saved prior inventory and outfit. all authority (Squad Lead, HC Commander) is transferred to Arges body or vice versa when reverting, but zeus auth is not transferred to arges (if you revert, zeus auth is on your original body. just use create zeus tbh).

### Optional Support

Support NeuralCloud- C.O.R.V.U.S Systems, If AI unit wear FCC there is a server script that will give them similar buff (its actually a workaround) to activated corvus system on player. Elmo faction also have such buff but a nerfed x0.3 (you don't want to be swarmed by such walking tanks) Arges Transformation is also buffed.

### Optional Vehicle Expansions

some objects of Sci-Fi Vehicles pack and Sci-Fi Turret pack are automatically added to GnK's vehicle/static pool when the corresponding mods are detected at load time.

### Addon setting

some feature able to be toggled on and off, because it might be heavy for server/client (e.g. the face-outfit matcher or transform into arges if you don't want it). oh right you can change petros to shikikan be it in his face or his name. No Gentianne.

### Planned Content
- Signing file for multiplayer
- flags for other faction (I am a bit lazy)
- Logos or icons for stuff that needed it (I am lazy)
- removing vanilla/template stuff from the repo (forgot to do it)

---

### Installation

A) Github release\
Download the release and extract, place it whereverer you like. Open Arma3 launcher add local mod, add the directory you save the folder.\
B) Steam Workshop Release (when it exist).\
click subscribe and activate it on your launcher.

## Building

Requires PowerShell and the Arma 3 Tools (Addon Builder / DSSignFile) to be installed.

```powershell
# Build the addon PBO
.\build.ps1

# Build and install to your Arma 3 mod folder
.\Install.ps1
```

---

## Shoutout for

- Mica Team/SUNBORN for GFL2 Assets.
- CBA devs for [CBA_A3](https://steamcommunity.com/workshop/filedetails/?id=450814997).
- Barbolani for Original Antistasi mission.
- Official Antistasi Community and all contributors for [Antistasi Community Edition](https://steamcommunity.com/sharedfiles/filedetails/?id=2867537125).
- Socrates for [Antistasi Plus](https://steamcommunity.com/sharedfiles/filedetails/?id=2912941775).
- The Antistasi Ultimate Dev Team and all contributors for [Antistasi Ultimate](https://steamcommunity.com/sharedfiles/filedetails/?id=3020755032).
- Silence112 for [A3UE template](https://github.com/Westalgie/A3UExtender)
- Utage for [TacGirls - GFL Mod](https://steamcommunity.com/sharedfiles/filedetails/?id=3722505664).
- Luca for [Sci-Fi Vehicles Pack](https://steamcommunity.com/sharedfiles/filedetails/?id=3539476763).
- Phaenosi for [Sci-Fi Turret Pack](https://steamcommunity.com/sharedfiles/filedetails/?id=3712115907).
- 呵呵荣乐 for [Girls' Frontline-KCCO Hydra](https://steamcommunity.com/sharedfiles/filedetails/?id=3718158909).
- Cannon and Cara for [NeuralCloud- C.O.R.V.U.S Systems GFL / GFL2](https://steamcommunity.com/sharedfiles/filedetails/?id=3672434840).
- Aernius (this mod author)

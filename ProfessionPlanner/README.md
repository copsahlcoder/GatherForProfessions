# ProfessionPlanner

A WoW Forever (Classic-based, Interface 16001) addon that helps you level
professions across all characters on your account.

Status: **step a** – character, profession, bag and bank scanning.

## Installation

Copy (or link) the `ProfessionPlanner` folder into your game's AddOns folder:

```
<WoW Forever install>\Interface\AddOns\ProfessionPlanner\ProfessionPlanner.toc
```

The `.toc` file must be directly inside `AddOns\ProfessionPlanner\`, not one
folder deeper.

Tip for development: instead of copying after every change, create a
directory junction once (PowerShell, adjust the AddOns path):

```powershell
cmd /c mklink /J `
  "<WoW Forever install>\Interface\AddOns\ProfessionPlanner" `
  "<your clone of this repository>\ProfessionPlanner"
```

The junction must point to the `ProfessionPlanner` folder (where the `.toc`
is), not to the repository root. To remove it, use `cmd /c rmdir <path>`;
this deletes only the link, not your files.

Then `/reload` in game picks up your edits.

## Commands

| Command | What it does |
| --- | --- |
| `/gfp` | Open/close the main window (step d) |
| `/gfp scan` | Rescan this character and print a summary |
| `/gfp plan <profession>` | Print the shopping list (step c) |
| `/gfp reset <name>` or `<name-realm>` | Delete saved data for a character |
| `/gfp help` | Show help |

## Saved data

Everything is stored account-wide in `ProfessionPlannerDB`
(`WTF\Account\<ACCOUNT>\SavedVariables\ProfessionPlanner.lua`):

```lua
ProfessionPlannerDB = {
  version = 1,
  settings = { tooltip = true },
  ui = {},
  accountBank = { items = { [itemID] = count }, time = <time()> },  -- shared Warband bank
  chars = {
    ["Name-Realm"] = {
      name, realm, race, raceFile, class, classFile, level, faction, lastUpdate,
      professions = { [skillLineID] = { name, rank, maxRank, primary } },
      bags = { [itemID] = count }, bagsTime = <time()>,
      bank = { [itemID] = count }, bankTime = <time()>,  -- bank is only readable while open
    },
  },
}
```

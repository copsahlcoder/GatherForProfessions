# ProfessionPlanner

A WoW Forever (Classic-based, Interface 16001) addon that helps you level
professions across all characters on your account.

Status: **step c** – scanning (a), profession data (b) and the calculator
with `/gfp plan` (c).

> WoW Forever is in **beta**. Leveling data comes from
> <https://www.wow-professions.com/forever> and stops at 225, because the
> Artisan routes are not published yet. Professions with data: Mining,
> Blacksmithing, Tailoring and Leatherworking. Mining has no Forever guide yet and
> uses Classic rules. Anything uncertain is marked `-- TODO: verify`.

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
| `/gfp plan <profession> [target]` | Print route, trainers, what to make and the shopping list. Target defaults to the next milestone (75/150/225/300) |
| `/gfp reset <name>` or `<name-realm>` | Delete saved data for a character |
| `/gfp verify` | Check every item/spell ID in `Data/` against the game |
| `/gfp lookup spell\|item <from> [to]` | Show the names of a range of IDs (max 50), to find the right ID |
| `/gfp help` | Show help |

## Adding or fixing data

All static data lives in `Data/` as plain Lua tables with no logic. IDs are what
count. Names are there for readability, and `/gfp verify` checks them.

### A profession (`Data/<Profession>.lua`)

```lua
local _, ns = ...

ns.Data.Professions[164] = {            -- skill line ID
    id = 164, name = "Blacksmithing", beta = true, source = "<guide URL>",
    tools = { { item = 5956, name = "Blacksmith Hammer" } },
    trainers = {
        { rank = "Journeyman", maxSkill = 150, minSkill = 50, minLevel = 10,
          cost = nil,                   -- copper, nil = unknown
          horde = { "Snarl (Orgrimmar)" }, alliance = { "Therum Deepforge (Stormwind)" } },
    },
    recipes = {
        [2660] = {                      -- spellID
            name = "Rough Sharpening Stone",   -- spell name as shown in game
            item = 2862, count = 1,            -- what it makes
            reagents = { { 2835, 1 } },        -- { itemID, amount }
            learn = "trainer",                 -- trainer / vendor / drop / quest
            -- optional: minSkill, skill = { orange, yellow, green, gray }, note
        },
    },
    route = {
        { from = 1, to = 25, recipe = 2660, crafts = 30 },
        { from = 75, to = 80, recipe = 2666, crafts = 5,
          alternatives = { { recipe = 7818, crafts = 5 } } },
        { from = 1, to = 65, gather = { 2770 }, note = "..." },     -- gathering step
        { from = 225, to = 300, missing = true, note = "..." },    -- no data yet
    },
}
```

Then add the file to `ProfessionPlanner.toc` (after `Data\Sources.lua`), and
add the profession's English name and ID to `Scanner.PROFESSIONS` if missing.

### A material (`Data/Sources.lua`)

Every reagent needs an entry. The `type` decides the other fields
(see the comment at the top of the file):
`node`, `smelt`, `craft`, `mobdrop`, `vendor` or `other`.

After changing data: `/reload`, then `/gfp verify`.

## How the calculator works

`Core/Calculator.lua` is plain Lua with no WoW calls.

1. It takes the route steps between your skill and the target. A step you
   are halfway through is scaled down.
2. It walks the steps in order. Each reagent is taken from what earlier steps
   made, then from your stock (all characters and the account bank), and the
   rest is crafted from its own reagents (Bronze Bar → Copper Bar + Tin Bar → ore).
3. Whatever can't be made is the shopping list, with sources and vendor cost.

## Tests

Install LuaJIT once (`winget install DEVCOM.LuaJIT`), then from the repo root:

```
luajit ProfessionPlanner/tests/run.lua
```

- `tests/calculator_spec.lua` tests the calculator with small mock data.
- `tests/data_spec.lua` checks the real data files: every reagent has a
  source, routes have no gaps, and Blacksmithing 1-150 matches the guide.

Run the tests after every data change. The specs use busted style
(`describe`/`it`/`assert.are.equal`), so real busted can run them later.

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

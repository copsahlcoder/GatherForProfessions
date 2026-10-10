-- All text shown to the player lives here, so it can be translated later.
local addonName, ns = ...

local L = {}
ns.L = L

-- General
L.PREFIX = "|cff33ff99ProfessionPlanner|r:"
L.ERROR_PREFIX = "|cffff3333Error:|r"
L.ERROR_IN = "something went wrong in %s: %s"
L.LOADED = "Loaded. Type /gfp help for commands."
L.DB_MIGRATED = "Saved data upgraded from version %d to %d."

-- Help
L.HELP_HEADER = "Commands:"
L.HELP_TOGGLE = "  /gfp - open/close the main window"
L.HELP_SCAN = "  /gfp scan - rescan this character and print a summary"
L.HELP_PLAN = "  /gfp plan <profession> - print the shopping list for a profession"
L.HELP_RESET = "  /gfp reset <name> or <name-realm> - delete saved data for a character"
L.HELP_HELP = "  /gfp help - show this help"
L.UNKNOWN_COMMAND = "Unknown command '%s'. Type /gfp help."

-- Not built yet
L.NOT_READY_UI = "The main window is not built yet (coming in step d)."

-- Plan
L.PLAN_USAGE = "Usage: /gfp plan <profession> [target skill]. Known professions: %s"
L.PLAN_UNKNOWN = "No data for '%s'. Known professions: %s"
L.PLAN_DONE = "%s is already at %d, nothing to plan (target %d)."
L.PLAN_MAXED = "%s is already at the maximum."
L.PLAN_HEADER = "|cffffd100%s %d -> %d|r"
L.PLAN_BETA = "Data (WoW Forever beta): %s"
L.PLAN_TRAINERS = "Trainers:"
L.PLAN_TRAINER = "  %s%s: %s"
L.PLAN_TRAINER_SKILL = "skill %d"
L.PLAN_TRAINER_LEVEL = "level %d"
L.PLAN_TOOL_MISSING = "You need a %s in your bags."
L.PLAN_STEPS = "Route:"
L.PLAN_STEP_CRAFT = "  %d-%d: %s x%d%s"
L.PLAN_STEP_ALT = " (or %s x%d)"
L.PLAN_STEP_LEARN = " [%s]"
L.PLAN_STEP_GATHER = "  %d-%d: gather %s. %s"
L.PLAN_STEP_MISSING = "  %d-%d: |cffff8000no route yet.|r %s"
L.PLAN_CRAFTING = "Make first:"
L.PLAN_CRAFT_LINE = "  %dx %s (%s, %s)%s"
L.PLAN_CRAFT_SKILL = "%s %d"
L.PLAN_CRAFT_SKILL_LOW = " |cffff3333- you have %s %d|r"
L.PLAN_STOCK = "Already have:"
L.PLAN_STOCK_LINE = "  %dx %s: %s"
L.PLAN_SHOPPING = "Still need:"
L.PLAN_SHOPPING_LINE = "  %dx %s - %s"
L.PLAN_SHOPPING_NONE = "  Nothing, you have everything."
L.PLAN_COST = "Estimated vendor cost: %s"
L.PLAN_MISSING_ROUTE = "|cffff8000Part of this range has no route data yet, so the list is incomplete.|r"

-- Where things are (used in plan output)
L.WHO_YOU = "you"
L.HOLDER = "%s %s %d"
L.HOLDER_ACCOUNT = "account bank %d"
L.SOURCE_NODE = "mine %s (Mining %d): %s"
L.SOURCE_MOBDROP = "%s: %s"
L.SOURCE_VENDOR = "vendor, %s each: %s"
L.SOURCE_UNKNOWN = "unknown source"
L.ZONE = "%s (%d-%d)"

-- Scan summary
L.SCAN_CHAR = "%s (%s %s, level %d, %s)"
L.SCAN_PROFS_HEADER = "Professions:"
L.SCAN_PROF_LINE = "  %s: %d/%d%s"
L.SCAN_SECONDARY = " (secondary)"
L.SCAN_NO_PROFS = "  (no professions found)"
L.SCAN_BAGS = "Bags: %d different items, %d in total."
L.SCAN_BANK = "Bank: %d different items, %d in total (last seen %s)."
L.SCAN_BANK_NEVER = "Bank: not seen yet. Open your bank once to save its contents."
L.SCAN_ACCOUNT_BANK = "Account bank: %d different items, %d in total (last seen %s)."
L.SCAN_CHARS_SAVED = "Characters saved on this account: %d"
L.NO_PROFESSION_API = "Can't read professions: this client has neither GetProfessions nor GetSkillLineInfo."
L.SCAN_UNAVAILABLE_EVENTS = "Events not available in this client: %s"
L.SKILL_HEADER_COLLAPSED = "A header in your Skills tab is collapsed, so some professions may be missing. Expand all headers and type /gfp scan."

-- Verify
L.HELP_VERIFY = "  /gfp verify - check item and spell IDs in the data files against the game"
L.VERIFY_START = "Checking %d items and %d spells, results in %d seconds..."
L.VERIFY_OK = "All data looks correct."
L.VERIFY_DONE = "Found %d problem(s). If items show as 'not found', run /gfp verify once more."
L.VERIFY_ITEM_MISSING = "Item %d (%s): not found in the game."
L.VERIFY_ITEM_WRONG = "Item %d: data says '%s', game says '%s'."
L.VERIFY_SPELL_MISSING = "Spell %d (%s): not found in the game."
L.VERIFY_SPELL_WRONG = "Spell %d: data says '%s', game says '%s'."
L.VERIFY_NO_SOURCE = "Item %d (used by %s) has no entry in Data/Sources.lua."
L.VERIFY_NO_RECIPE = "%s route %d-%d uses recipe %d, which is not in its recipes table."

-- Lookup
L.HELP_LOOKUP = "  /gfp lookup spell|item <from> [to] - show names for a range of IDs"
L.LOOKUP_USAGE = "Usage: /gfp lookup spell 2735 2750 or /gfp lookup item 2840 (max %d IDs)"
L.LOOKUP_WAIT = "Loading items, results in %d seconds..."
L.LOOKUP_LINE = "%s %d: %s"

-- Reset
L.RESET_USAGE = "Usage: /gfp reset <name> or /gfp reset <name-realm>"
L.RESET_DONE = "Deleted saved data for %s."
L.RESET_NOT_FOUND = "No saved character called '%s'. Saved characters: %s"
L.RESET_AMBIGUOUS = "Several characters match '%s': %s. Use name-realm."

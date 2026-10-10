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
L.NOT_READY_PLAN = "The planner is not built yet (coming in step c)."

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

-- Reset
L.RESET_USAGE = "Usage: /gfp reset <name> or /gfp reset <name-realm>"
L.RESET_DONE = "Deleted saved data for %s."
L.RESET_NOT_FOUND = "No saved character called '%s'. Saved characters: %s"
L.RESET_AMBIGUOUS = "Several characters match '%s': %s. Use name-realm."

-- Minimal test runner with a busted-compatible subset:
-- describe / it / before_each, assert.are.equal, assert.are.same,
-- assert.is_true, assert.is_false, assert.is_nil, assert.is_not_nil, assert.has_error.
--
-- Run from anywhere:  luajit ProfessionPlanner/tests/run.lua
-- The spec files also work with real busted later (busted ProfessionPlanner/tests).

-- Folder of this script, so paths work no matter where we run from.
local testDir = (arg and arg[0] or ""):match("^(.*)[/\\]") or "."
ROOT = testDir .. "/.."

---------------------------------------------------------------------------
-- Assertions
---------------------------------------------------------------------------

local function Show(value)
    if type(value) == "string" then return string.format("%q", value) end
    return tostring(value)
end

local function DeepEqual(a, b)
    if type(a) ~= "table" or type(b) ~= "table" then
        return a == b
    end
    for k, v in pairs(a) do
        if not DeepEqual(v, b[k]) then return false end
    end
    for k in pairs(b) do
        if a[k] == nil then return false end
    end
    return true
end

local function Fail(msg)
    error(msg, 3)
end

local plainAssert = assert
assert = setmetatable({
    are = {
        equal = function(expected, actual)
            if expected ~= actual then Fail("expected " .. Show(expected) .. ", got " .. Show(actual)) end
        end,
        same = function(expected, actual)
            if not DeepEqual(expected, actual) then Fail("tables are not the same") end
        end,
    },
    is_true = function(v) if v ~= true then Fail("expected true, got " .. Show(v)) end end,
    is_false = function(v) if v ~= false then Fail("expected false, got " .. Show(v)) end end,
    is_nil = function(v) if v ~= nil then Fail("expected nil, got " .. Show(v)) end end,
    is_not_nil = function(v) if v == nil then Fail("expected a value, got nil") end end,
    has_error = function(fn)
        if pcall(fn) then Fail("expected an error") end
    end,
}, {
    -- Plain assert(x, msg) still works.
    __call = function(_, ...) return plainAssert(...) end,
})

---------------------------------------------------------------------------
-- describe / it
---------------------------------------------------------------------------

local passed, failed = 0, 0
local names = {}
local beforeEach = {}

function describe(name, fn)
    table.insert(names, name)
    table.insert(beforeEach, false)
    fn()
    table.remove(beforeEach)
    table.remove(names)
end

function before_each(fn)
    beforeEach[#beforeEach] = fn
end

function it(name, fn)
    for _, setup in ipairs(beforeEach) do
        if setup then setup() end
    end
    local ok, err = pcall(fn)
    local fullName = table.concat(names, " > ") .. " > " .. name
    if ok then
        passed = passed + 1
        print("  ok    " .. fullName)
    else
        failed = failed + 1
        print("  FAIL  " .. fullName .. "\n        " .. tostring(err))
    end
end

---------------------------------------------------------------------------
-- Helpers for spec files
---------------------------------------------------------------------------

-- Loads an addon file the way WoW does: with (addonName, ns) as `...`.
function LoadAddonFile(path, ns)
    local chunk, err = loadfile(ROOT .. "/" .. path)
    if not chunk then error(err) end
    chunk("ProfessionPlanner", ns)
    return ns
end

---------------------------------------------------------------------------
-- Run all spec files
---------------------------------------------------------------------------

local SPECS = {
    "calculator_spec.lua",
    "data_spec.lua",
}

for _, spec in ipairs(SPECS) do
    print(spec)
    local chunk, err = loadfile(testDir .. "/" .. spec)
    if not chunk then
        failed = failed + 1
        print("  FAIL  could not load: " .. tostring(err))
    else
        local ok, runErr = pcall(chunk)
        if not ok then
            failed = failed + 1
            print("  FAIL  error in spec file: " .. tostring(runErr))
        end
    end
end

print(string.format("\n%d passed, %d failed", passed, failed))
os.exit(failed == 0 and 0 or 1)

-- Exercises Guard.Check, which decides whether a purchase should be confirmed
-- first. It takes plain tables and calls no game API.
--
-- Run with: py -3 tests/run.py

local failures, checks = 0, 0

local function check(label, actual, expected)
    checks = checks + 1
    if actual == expected then
        print(string.format("  ok    %s", label))
    else
        failures = failures + 1
        print(string.format("  FAIL  %s  -> got %s, want %s", label, tostring(actual), tostring(expected)))
    end
end

--------------------------------------------------------------------------------

local MCH = MonsterCofferHelper
local Guard = MCH.Guard

-- A pool of sets 101..10x, three shoulders each, `missingPerSet` still missing.
local function Pool(missingPerSet)
    local pool = { sets = {}, setCount = 0, total = 0, owned = 0, missing = 0, incompleteSets = 0 }
    for i, missing in ipairs(missingPerSet) do
        pool.sets[i] = { setId = 100 + i, name = "Set " .. i, total = 3, owned = 3 - missing, missing = missing }
        pool.setCount = pool.setCount + 1
        pool.total    = pool.total + 3
        pool.owned    = pool.owned + 3 - missing
        if missing > 0 then pool.incompleteSets = pool.incompleteSets + 1 end
    end
    pool.missing = pool.total - pool.owned
    return pool
end

-- A shelf: the mystery coffer is entry 1; entry 2 holds sets 101+102, entry 3
-- holds 103+104.
local SCAN = {
    vendorId = 3,
    mysteryIndex = 1,
    curatedIndexToSetIds = { [2] = { 101, 102 }, [3] = { 103, 104 } },
}

local function Result(missingPerSet)
    return MCH.Advisor.Evaluate(Pool(missingPerSet), 1, 8)
end

print("\nearly in the collection: mystery is the best buy")
do
    -- 10 of 12 missing: mystery costs 1.2 keys per new shoulder against 8.
    local result = Result({ 3, 3, 3, 1 })
    check("mystery goes through", Guard.Check(SCAN, result, 1), nil)
    check("a curated coffer asks first", Guard.Check(SCAN, result, 2), Guard.REASON_CURATED_WORSE)
end

print("\nnear the end: curated is the best buy")
do
    -- 1 of 12 missing: mystery costs 12 keys per new shoulder against 8.
    local result = Result({ 0, 0, 0, 1 })
    check("mystery asks first", Guard.Check(SCAN, result, 1), Guard.REASON_MYSTERY_WORSE)
    check("the coffer with the missing set goes through", Guard.Check(SCAN, result, 3), nil)
    check("a coffer whose sets are complete is a duplicate", Guard.Check(SCAN, result, 2), Guard.REASON_DUPLICATE)
end

print("\na duplicate is flagged even while curated would be the worse buy")
do
    local result = Result({ 0, 0, 3, 3 })
    check("complete coffer", Guard.Check(SCAN, result, 2), Guard.REASON_DUPLICATE)
end

print("\neverything collected")
do
    local result = Result({ 0, 0, 0, 0 })
    check("mystery is a duplicate", Guard.Check(SCAN, result, 1), Guard.REASON_DUPLICATE)
    check("curated is a duplicate", Guard.Check(SCAN, result, 2), Guard.REASON_DUPLICATE)
end

print("\nentries this addon does not know about are never held")
do
    local result = Result({ 3, 3, 3, 3 })
    check("a style page or anything else", Guard.Check(SCAN, result, 7), nil)
    check("no scan", Guard.Check(nil, result, 1), nil)
    check("no result", Guard.Check(SCAN, nil, 1), nil)
end

print("\nboth costs equal: either is fine")
do
    -- 3 of 24 missing: mystery costs exactly 8 keys per new shoulder.
    local result = Result({ 3, 0, 0, 0, 0, 0, 0, 0 })
    check("verdict is either", result.verdict, MCH.VERDICT_EITHER)
    check("mystery goes through", Guard.Check(SCAN, result, 1), nil)
    check("curated goes through", Guard.Check(SCAN, result, 2), nil)
end

print("\nbuying several mystery coffers at once")
do
    -- 10 of 12 missing, switching to curated at 1 missing: on average
    -- 12 x (H(10) - H(1)) = 23.1 Mystery Coffers get there.
    local result = Result({ 3, 3, 3, 1 })
    check("23 go through", Guard.Check(SCAN, result, 1, 23), nil)
    local reason, stop = Guard.Check(SCAN, result, 1, 24)
    check("24 ask first", reason, Guard.REASON_BULK_MYSTERY)
    check("saying to stop at 23", stop, 23)
    check("a single one goes through", Guard.Check(SCAN, result, 1, 1), nil)
    check("no quantity counts as one", Guard.Check(SCAN, result, 1), nil)
end

print("\nat the switch point, only one mystery coffer is worth it")
do
    local result = Result({ 3, 0, 0, 0, 0, 0, 0, 0 })
    check("one goes through", Guard.Check(SCAN, result, 1, 1), nil)
    local reason, stop = Guard.Check(SCAN, result, 1, 2)
    check("two ask first", reason, Guard.REASON_BULK_MYSTERY)
    check("saying to stop at 1", stop, 1)
end

print("\nbuying several of one curated coffer")
do
    -- Entry 3 holds sets 103 and 104, with one shoulder missing between them.
    local result = Result({ 0, 0, 0, 1 })
    check("one goes through", Guard.Check(SCAN, result, 3, 1), nil)
    local reason, stop = Guard.Check(SCAN, result, 3, 2)
    check("two ask first", reason, Guard.REASON_BULK_CURATED)
    check("saying only 1 is missing", stop, 1)
    check("a duplicate coffer is still reported as one", Guard.Check(SCAN, result, 2, 5), Guard.REASON_DUPLICATE)
    check("mystery when curated is cheaper is still reported as such",
        Guard.Check(SCAN, result, 1, 5), Guard.REASON_MYSTERY_WORSE)
end

print("\na curated coffer that is the worse buy, bought past what it has missing")
do
    -- 10 of 12 missing, so mystery is the best buy. Entry 3 holds sets 103 and
    -- 104, with 4 shoulders missing between them.
    local result = Result({ 3, 3, 3, 1 })
    local reason, stop = Guard.Check(SCAN, result, 3, 5)
    check("the worse buy is still the reason", reason, Guard.REASON_CURATED_WORSE)
    check("with what it has missing, for the duplicates", stop, 4)
    local _, none = Guard.Check(SCAN, result, 3, 4)
    check("no duplicates, nothing more to say", none, nil)
end

print("\na purchase made while another dialog is still on screen")
do
    -- The buy-multiple dialog calls BuyStoreItem before it closes. The game
    -- drops a dialog shown over another unless it can queue, so this stands in
    -- for that rule and checks the warning still reaches the player.
    local registered, hook, onScreen, queued, dropped = nil, nil, true, {}, 0
    local FAKE = {
        ZO_Dialogs_RegisterCustomDialog = function(_, info) registered = info end,
        ZO_PreHook = function(_, fn) hook = fn end,
        ZO_Dialogs_ShowPlatformDialog = function(name, data)
            if onScreen and not registered.canQueue then
                dropped = dropped + 1
            else
                queued[#queued + 1] = { name = name, data = data }
            end
        end,
        EVENT_MANAGER = { RegisterForEvent = function() end },
        GAMEPAD_DIALOGS = { BASIC = "basic" },
        GetString = function(id) return tostring(id) end,
        zo_strformat = function(format) return tostring(format) end,
    }
    local saved = {}
    for name, value in pairs(FAKE) do
        saved[name] = rawget(_G, name)
        _G[name] = value
    end
    local savedDb, savedCurrent, savedForVendor = MCH.db, MCH.Store.current, MCH.Advisor.ForVendor

    local ok, err = pcall(function()
        local result = Result({ 0, 0, 3, 3 })  -- entry 2's sets are complete
        MCH.db = { confirmPurchases = true }
        MCH.Store.current = SCAN
        MCH.Advisor.ForVendor = function() return result end

        Guard.Initialize()
        check("the warning dialog can queue", registered and registered.canQueue, true)
        check("buying 5 duplicates is held", hook(2, 5), true)
        check("and the warning is not dropped", dropped, 0)
        check("it waits to be shown", #queued, 1)
        check("with the quantity to buy if confirmed", queued[1] and queued[1].data.quantity, 5)
    end)

    for name in pairs(FAKE) do _G[name] = saved[name] end
    MCH.db, MCH.Store.current, MCH.Advisor.ForVendor = savedDb, savedCurrent, savedForVendor
    if not ok then error(err, 0) end
end

print(string.format("\n%d check(s), %d failure(s)\n", checks, failures))
if failures > 0 then error("guard tests failed", 0) end

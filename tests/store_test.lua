-- Exercises Store.DerivePrices, which reads the coffer prices off a vendor's
-- shelf. It takes plain entry tables and calls no game API, so it runs here.
--
-- Run with: py -3 tests/run.py

local failures, checks = 0, 0

local function check(label, condition, detail)
    checks = checks + 1
    if condition then
        print(string.format("  ok    %s", label))
    else
        failures = failures + 1
        print(string.format("  FAIL  %s%s", label, detail and ("  -> " .. detail) or ""))
    end
end

local function checkNum(label, actual, expected)
    check(label, actual == expected,
        string.format("got %s, want %s", tostring(actual), tostring(expected)))
end

-- Shorthand for a store entry: cost in keys, and the set it was matched to.
local function entry(index, cost, setId)
    return { index = index, name = "entry " .. index, cost = cost, setId = setId }
end

-- A quartermaster's shelf: one mystery coffer plus `count` curated ones.
-- `matched` decides whether the name matcher recognised the curated coffers.
local function Shelf(mysteryCost, curatedCost, count, matched)
    local entries = { entry(1, mysteryCost, nil) }
    for i = 1, count do
        entries[#entries + 1] = entry(i + 1, curatedCost, matched and (100 + i) or nil)
    end
    return entries
end

--------------------------------------------------------------------------------

local Store = MonsterCofferHelper.Store

print("\nan ordinary shelf")
do
    local mystery, curated, mysteryIndex = Store.DerivePrices(Shelf(1, 8, 12, true))
    checkNum("mystery coffer costs 1 key", mystery, 1)
    checkNum("curated coffers cost 8 keys", curated, 8)
    checkNum("the mystery coffer is entry 1", mysteryIndex, 1)
end

print("\nregression: a pricier unrelated item must not become the curated price")
do
    -- What Urgarlag's shelf did. A 50-key item was the only entry the name
    -- matcher tied to a set, so the old cheapest-match rule reported curated
    -- coffers at 50 keys. The price now comes from the price that repeats.
    local entries = Shelf(1, 8, 12, false)
    entries[#entries + 1] = entry(99, 50, 500)

    local mystery, curated = Store.DerivePrices(entries)
    checkNum("curated price is the one that repeats", curated, 8)
    checkNum("mystery coffer still costs 1 key", mystery, 1)
end

print("\nregression: several pricier items still cannot outvote the coffers")
do
    local entries = Shelf(1, 8, 12, true)
    for i = 1, 4 do entries[#entries + 1] = entry(90 + i, 50, nil) end

    local _, curated = Store.DerivePrices(entries)
    checkNum("curated price is unmoved", curated, 8)
end

print("\ntoo few name matches falls back to the whole shelf")
do
    -- Only two coffers recognised, below the trust threshold, plus a 50-key
    -- item that was. Voting across every key-priced entry still lands on 8.
    local entries = Shelf(1, 8, 12, false)
    entries[2].setId = 101
    entries[3].setId = 102
    entries[#entries + 1] = entry(99, 50, 500)

    local _, curated = Store.DerivePrices(entries)
    checkNum("curated price is still 8", curated, 8)
end

print("\nenough name matches are trusted over the rest of the shelf")
do
    -- Coffers recognised at 8, and a crowd of unrelated 3-key items that would
    -- otherwise win the vote outright.
    local entries = Shelf(1, 8, 5, true)
    for i = 1, 20 do entries[#entries + 1] = entry(200 + i, 3, nil) end

    local _, curated = Store.DerivePrices(entries)
    checkNum("matched coffers decide the price", curated, 8)
end

print("\nno mystery coffer on the shelf")
do
    local entries = {}
    for i = 1, 6 do entries[i] = entry(i, 8, 100 + i) end

    local mystery, curated, mysteryIndex = Store.DerivePrices(entries)
    checkNum("no mystery price is invented", mystery, nil)
    checkNum("curated price is still read", curated, 8)
    checkNum("no mystery entry index", mysteryIndex, nil)
end

print("\na set-named entry is never mistaken for the mystery coffer")
do
    -- A cheap curated coffer must not be picked as the mystery coffer just for
    -- being under the curated price.
    local entries = Shelf(2, 8, 12, true)
    entries[2].cost = 1

    local mystery, _, mysteryIndex = Store.DerivePrices(entries)
    checkNum("the unmatched entry wins", mystery, 2)
    checkNum("and it is entry 1", mysteryIndex, 1)
end

print("\nempty shelf")
do
    local mystery, curated = Store.DerivePrices({})
    checkNum("no mystery price", mystery, nil)
    checkNum("no curated price", curated, nil)
end

--------------------------------------------------------------------------------

print(string.format("\n%d check(s), %d failure(s)\n", checks, failures))
if failures > 0 then error("store tests failed", 0) end

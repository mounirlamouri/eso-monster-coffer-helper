-- Exercises Store.Scan end to end against a fake store: the game functions it
-- calls are replaced for the duration of this file, so a shelf can be described
-- in plain Lua and scanned exactly as the game's would be.
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

local function count(t)
    local n = 0
    for _ in pairs(t or {}) do n = n + 1 end
    return n
end

--------------------------------------------------------------------------------
-- The fake game
--------------------------------------------------------------------------------

local KEYS, GOLD = 6, 1

-- LibSets' view: vendor 1 stocks sets 101..112, vendor 3 stocks 301..334.
local setInfo = {}
for setId = 101, 112 do setInfo[setId] = { undauntedChestId = 1 } end
for setId = 301, 334 do setInfo[setId] = { undauntedChestId = 3 } end
local VENDOR_NAMES = { "Glirion the Redbeard", "Maj al-Ragath", "Urgarlag Chief-bane" }

-- What the store currently shows, and who is behind the counter.
-- Each item: { name, keys = n or gold = n, sets = { setId, ... }, collectible = true }
local shelf, npcName = {}, ""

local FAKE = {
    CURT_UNDAUNTED_KEYS   = KEYS,
    SI_TOOLTIP_ITEM_NAME  = "item",
    SI_UNIT_NAME          = "unit",
    zo_strformat          = function(_, text) return text end,
    zo_strlower           = string.lower,
    GetUnitName           = function() return npcName end,
    GetNumStoreItems      = function() return #shelf end,
    GetStoreItemLink      = function(index) return "link:" .. index end,

    GetStoreEntryInfo = function(index)
        local item = shelf[index]
        local currency = item.keys and KEYS or GOLD
        local quantity = item.keys or item.gold
        -- icon, name, stack, price, sellPrice, meetsRequirementsToBuy,
        -- meetsRequirementsToUse, displayQuality, questNameColor,
        -- currencyType1, currencyQuantity1, currencyType2, currencyQuantity2
        return "icon", item.name, 1, item.gold or 0, 0, true, true, 1, false,
            currency, quantity, 0, 0
    end,

    GetItemLinkNumContainerSetIds = function(link)
        local item = shelf[tonumber(link:match("%d+"))]
        return item.sets and #item.sets or 0
    end,

    GetItemLinkContainerSetInfo = function(link, setIndex)
        local item = shelf[tonumber(link:match("%d+"))]
        return true, "set", 0, 0, 5, item.sets[setIndex], 0
    end,

    GetItemLinkContainerCollectibleId = function(link)
        local item = shelf[tonumber(link:match("%d+"))]
        return item.collectible and 9000 + tonumber(link:match("%d+")) or 0
    end,

    LibSets = {
        setInfo = setInfo,
        GetUndauntedChestName = function(vendorId) return VENDOR_NAMES[vendorId] end,
    },
}

local saved = {}
for name, value in pairs(FAKE) do
    saved[name] = rawget(_G, name)
    _G[name] = value
end

local function Restore()
    for name in pairs(FAKE) do _G[name] = saved[name] end
end

--------------------------------------------------------------------------------
-- Shelves
--------------------------------------------------------------------------------

-- Urgarlag as seen in game: one Mystery Coffer, 17 curated coffers of two
-- sets each, two style pages, and something sold for gold.
local function Urgarlag(mysterySets)
    local items = { { name = "Mystery Coffer", keys = 1, sets = mysterySets } }
    for i = 0, 16 do
        items[#items + 1] = { name = "Coffer " .. i, keys = 8, sets = { 301 + 2 * i, 302 + 2 * i } }
    end
    -- Named after a set, as the ones that used to be mistaken for a coffer were.
    items[#items + 1] = { name = "Style Page: Set 301", keys = 8, collectible = true }
    items[#items + 1] = { name = "Style Page: Set 305", keys = 8, collectible = true }
    items[#items + 1] = { name = "Repair Kit", gold = 300 }
    return items
end

local Store = MonsterCofferHelper.Store

local ok, err = pcall(function()

    print("\nUrgarlag's shelf")
    do
        shelf, npcName = Urgarlag(nil), "Urgarlag Chief-bane"
        local scan = Store.Scan()
        check("is recognised", scan ~= nil, true)
        check("as vendor 3", scan.vendorId, 3)
        check("mystery coffer is entry 1", scan.mysteryIndex, 1)
        check("mystery costs 1 key", scan.mysteryCost, 1)
        check("curated costs 8 keys", scan.curatedCost, 8)
        check("all 17 curated coffers are found", count(scan.curatedIndexToSetIds), 17)
        check("covering 34 sets", #scan.setIds, 34)
        check("a coffer lists both its sets", #scan.curatedIndexToSetIds[2], 2)
        check("style pages are not coffers", scan.curatedIndexToSetIds[19], nil)
        check("style pages and gold items are not entries", #scan.entries, 18)
    end

    print("\na mystery coffer whose link lists every set it can roll")
    do
        local all = {}
        for setId = 301, 334 do all[#all + 1] = setId end
        shelf, npcName = Urgarlag(all), "Urgarlag Chief-bane"
        local scan = Store.Scan()
        check("is still the mystery coffer", scan.mysteryIndex, 1)
        check("and is not counted as a curated coffer", scan.curatedIndexToSetIds[1], nil)
        check("the curated coffers still cover 34 sets", #scan.setIds, 34)
    end

    print("\ncoffers whose links list no sets fall back to the NPC's name")
    do
        shelf = { { name = "Mystery Coffer", keys = 1 } }
        for i = 1, 5 do shelf[#shelf + 1] = { name = "Coffer " .. i, keys = 8 } end
        npcName = "Glirion the Redbeard"
        local scan = Store.Scan()
        check("is recognised", scan ~= nil, true)
        check("as vendor 1", scan and scan.vendorId, 1)
        check("with no sets learned", scan and #scan.setIds, 0)
    end

    print("\nother stores")
    do
        shelf, npcName = { { name = "Repair Kit", gold = 300 } }, "Merchant"
        check("a store selling for gold only is ignored", Store.Scan(), nil)

        shelf = { { name = "Something", keys = 3 }, { name = "Something else", keys = 5 } }
        check("key-priced items from an unknown NPC are ignored", Store.Scan(), nil)

        shelf = {}
        check("an empty store is ignored", Store.Scan(), nil)
    end
end)

Restore()
if not ok then error(err, 0) end

print(string.format("\n%d check(s), %d failure(s)\n", checks, failures))
if failures > 0 then error("store scan tests failed", 0) end

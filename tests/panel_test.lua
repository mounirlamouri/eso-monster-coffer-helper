-- Renders the panel and chat text with the English strings, so a line that
-- breaks, or a count that reads "1 keys", shows up outside the game.
--
-- The game's formatting is stood in for by a small zo_strformat that handles
-- what these strings use: <<n>> and the plural choice <<n[one/many]>>. The
-- vendors' pools, prices and the key count are stood in for too.
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

-- Colour codes off, so the checks read the text a player reads.
local function Plain(text)
    return (text:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", ""))
end

local function Has(label, text, wanted)
    check(label, Plain(text):find(wanted, 1, true) ~= nil,
        string.format("%q not in:\n%s", wanted, Plain(text)))
end

local function Lacks(label, text, unwanted)
    check(label, Plain(text):find(unwanted, 1, true) == nil,
        string.format("%q found in:\n%s", unwanted, Plain(text)))
end

--------------------------------------------------------------------------------
-- The stand-in game
--------------------------------------------------------------------------------

local MCH = MonsterCofferHelper
local strings = {}
local printed = {}

local FAKE = {
    ZO_CreateStringId = function(name, text)
        _G[name] = name
        strings[name] = text
    end,
    GetString = function(id) return strings[id] end,
    zo_strformat = function(format, ...)
        local args = { ... }
        local text = strings[format] or format
        text = text:gsub("<<(%d+)%[([^%]]*)%]>>", function(index, choice)
            local n = tonumber(args[tonumber(index)])
            local forms = {}
            for form in (choice .. "/"):gmatch("([^/]*)/") do forms[#forms + 1] = form end
            local form
            if #forms == 3 then
                form = (n == 0 and forms[1]) or (n == 1 and forms[2]) or forms[3]
            else
                form = (n == 1) and forms[1] or forms[2]
            end
            return (form:gsub("%$d", tostring(n)))
        end)
        return (text:gsub("<<(%d+)>>", function(index) return tostring(args[tonumber(index)]) end))
    end,
    d = function(text) printed[#printed + 1] = text end,
}

local saved = {}
for name, value in pairs(FAKE) do
    saved[name] = rawget(_G, name)
    _G[name] = value
end

local savedModel = {
    GetPool = MCH.Model.GetPool, GetPrices = MCH.Model.GetPrices,
    GetKeyCount = MCH.Model.GetKeyCount, GetVendorName = MCH.Model.GetVendorName,
}
local savedDb = MCH.db

local englishFile = ADDON_ROOT .. "/Localization/en.lua"
local localization = assert(loadfile(englishFile))
localization()

-- A pool shaped like Model.BuildPool's: `missingPerSet` shoulders missing per
-- set, three in each.
local function Pool(missingPerSet)
    local pool = { sets = {}, setCount = 0, total = 0, owned = 0, missing = 0, incompleteSets = 0 }
    for i, missing in ipairs(missingPerSet) do
        pool.sets[i] = { setId = i, name = "Set " .. i, total = 3, owned = 3 - missing, missing = missing }
        pool.setCount = pool.setCount + 1
        pool.total = pool.total + 3
        pool.owned = pool.owned + 3 - missing
        if missing > 0 then pool.incompleteSets = pool.incompleteSets + 1 end
    end
    pool.missing = pool.total - pool.owned
    return pool
end

local pools, keys, learned = {}, 0, true

MCH.db = { maxSetsListed = 6 }
MCH.Model.GetPool = function(vendorId) return pools[vendorId] end
MCH.Model.GetPrices = function() return 1, 8, learned end
MCH.Model.GetKeyCount = function() return keys end
MCH.Model.GetVendorName = function(vendorId) return "Vendor " .. vendorId end

local function Shelves(byVendor, heldKeys)
    pools, keys = byVendor, heldKeys or 0
    MCH.Advisor.Invalidate()
end

local Format = MCH.Format
local Advisor = MCH.Advisor

local ok, err = pcall(function()

    print("\nthe panel")
    do
        Shelves({ Pool({ 3, 3, 3, 3 }), Pool({ 0, 0, 0, 1 }), Pool({ 0, 0, 0, 0 }) }, 1)
        local body = Format.PanelBody(Advisor.ForVendor(1))
        Has("names the vendor's shoulders", body, "0 / 12 shoulders across 4 sets (12 missing)")
        Has("a mystery coffer at 1 key, 1 key per new shoulder", body, "1 key, 100.0% new -> 1 key per new shoulder")
        Has("curated", body, "8 keys, 100.0% new -> 8 keys per new shoulder")
        Has("one key held", body, "You hold 1 Undaunted Key")

        local late = Format.PanelBody(Advisor.ForVendor(2))
        Has("a vendor with one shoulder missing", late, "11 / 12 shoulders across 4 sets (1 missing)")

        Lacks("prices read from the store go unmentioned", body, "prices")
        learned = false
        Shelves({ Pool({ 3, 3, 3, 3 }) })
        Has("assumed prices are flagged", Format.PanelBody(Advisor.ForVendor(1)),
            "assumed prices - visit the vendor to confirm")
        learned = true
    end

    print("\nthe total across every vendor")
    do
        Shelves({ Pool({ 3, 3, 3, 3 }), Pool({ 0, 0, 0, 1 }), Pool({ 0, 0, 0, 0 }) })
        local sum = Advisor.ForAllVendors()
        local keysText = Format.Num(sum.optimal)
        Has("shows on a vendor with shoulders left elsewhere",
            Format.PanelBody(Advisor.ForVendor(1)), "All vendors  ~" .. keysText .. " keys for the 13 missing shoulders")
        Has("shows on a finished vendor", Format.PanelBody(Advisor.ForVendor(3)), "All vendors  ~")

        local function SetApartAtTheEnd(body)
            return Plain(body):find("\n\nAll vendors  ~[^\n]*$") ~= nil
        end
        check("comes last, after a blank line", SetApartAtTheEnd(Format.PanelBody(Advisor.ForVendor(1))),
            Plain(Format.PanelBody(Advisor.ForVendor(1))))
        check("on a finished vendor too", SetApartAtTheEnd(Format.PanelBody(Advisor.ForVendor(3))),
            Plain(Format.PanelBody(Advisor.ForVendor(3))))

        Shelves({ Pool({ 3, 3, 3, 3 }), Pool({ 0, 0, 0, 0 }), Pool({ 0, 0, 0, 0 }) })
        Lacks("is left out when every missing shoulder is at this vendor",
            Format.PanelBody(Advisor.ForVendor(1)), "All vendors")

        Shelves({ Pool({ 0, 0, 0, 0 }), Pool({ 0, 0, 0, 0 }), Pool({ 0, 0, 0, 0 }) })
        Lacks("is left out when everything is collected", Format.PanelBody(Advisor.ForVendor(1)), "All vendors")

        printed = {}
        Shelves({ Pool({ 0, 0, 0, 0 }), Pool({ 0, 0, 0, 1 }), Pool({ 0, 0, 0, 0 }) })
        Format.PrintTotal(Advisor.ForAllVendors())
        check("/coffer prints one total line", #printed == 1, tostring(#printed))
        Has("singular when one shoulder is missing", printed[1] or "", "for the 1 missing shoulder")

        printed = {}
        Shelves({ Pool({ 0, 0, 0, 0 }), Pool({ 0, 0, 0, 0 }), Pool({ 0, 0, 0, 0 }) })
        Format.PrintTotal(Advisor.ForAllVendors())
        check("/coffer prints no total once everything is collected", #printed == 0, tostring(#printed))
    end

    print("\nwhat the keys you hold buy")
    do
        Shelves({ Pool({ 3, 3, 3, 3 }) }, 10)
        Has("some new shoulders", Format.PanelBody(Advisor.ForVendor(1)),
            "You hold 10 Undaunted Keys: about 7 new shoulders here the smart way")

        Shelves({ Pool({ 3, 3, 3, 3 }) }, 1)
        Has("one new shoulder", Format.PanelBody(Advisor.ForVendor(1)),
            "You hold 1 Undaunted Key: about 1 new shoulder here the smart way")

        Shelves({ Pool({ 3, 3, 3, 3 }) }, 40)
        Has("enough to finish", Format.PanelBody(Advisor.ForVendor(1)),
            "You hold 40 Undaunted Keys: enough to finish this vendor, on average")

        Shelves({ Pool({ 0, 0, 0, 1 }) }, 7)
        local body = Format.PanelBody(Advisor.ForVendor(1))
        Has("too few for a curated coffer just says what you hold", body, "You hold 7 Undaunted Keys")
        Lacks("and claims nothing", body, "about")

        Shelves({ Pool({ 0, 0, 0, 0 }) }, 30)
        Has("a finished vendor just says what you hold", Format.PanelBody(Advisor.ForVendor(1)),
            "You hold 30 Undaunted Keys")
    end

    print("\nthe purchase confirmation's text")
    do
        local Guard = MCH.Guard
        Shelves({ Pool({ 3, 3, 3, 1 }) })
        local result = Advisor.ForVendor(1)
        Has("bulk mystery", Guard.Message(Guard.REASON_BULK_MYSTERY, result, 23, 30),
            "On average, 23 Mystery Coffers bring you to the point where curated coffers become cheaper. Buying 30 at once")
        Has("bulk mystery, stopping at one", Guard.Message(Guard.REASON_BULK_MYSTERY, result, 1, 2),
            "On average, 1 Mystery Coffer brings you")
        Has("bulk curated", Guard.Message(Guard.REASON_BULK_CURATED, result, 1, 2),
            "This coffer has only 1 shoulder you're missing, so buying 2 would give at least 1 duplicate.")
        Has("bulk curated, plural", Guard.Message(Guard.REASON_BULK_CURATED, result, 4, 10),
            "only 4 shoulders you're missing, so buying 10 would give at least 6 duplicates.")
        Has("mystery is the worse buy", Guard.Message(Guard.REASON_MYSTERY_WORSE, result),
            "Curated coffers are cheaper here right now: 8 keys per new shoulder")

        local alone = Guard.Message(Guard.REASON_CURATED_WORSE, result)
        Has("curated is the worse buy", alone, "Mystery Coffers are cheaper here right now:")
        Lacks("one coffer has no duplicates to mention", alone, "duplicate")
        Lacks("nor does a quantity within what is missing",
            Guard.Message(Guard.REASON_CURATED_WORSE, result, nil, 2), "duplicate")
        local both = Guard.Message(Guard.REASON_CURATED_WORSE, result, 2, 3)
        Has("the worse buy, bought past what is missing, names both", both,
            "against 8 for this curated coffer. This coffer has only 2 shoulders you're missing, so buying 3 would give at least 1 duplicate.")
    end
end)

for name in pairs(FAKE) do _G[name] = saved[name] end
for name, fn in pairs(savedModel) do MCH.Model[name] = fn end
MCH.db = savedDb
MCH.Advisor.Invalidate()
if not ok then error(err, 0) end

print(string.format("\n%d check(s), %d failure(s)\n", checks, failures))
if failures > 0 then error("panel tests failed", 0) end

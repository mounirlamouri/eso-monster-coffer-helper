local MCH = MonsterCofferHelper
local C = MCH.COLOR

local Format = {}
MCH.Format = Format

--------------------------------------------------------------------------------
-- Small helpers
--------------------------------------------------------------------------------

local function IsWhole(value)
    return math.abs(value - math.floor(value + 0.5)) < 0.05
end

-- "1.5" in English, "1,5" in French, German and Spanish.
local function Decimal(text)
    return (text:gsub("%.", GetString(SI_MCH_DECIMAL_SEPARATOR)))
end

-- Keys are shown to one decimal, except when the value is effectively whole --
-- "8 keys" reads better than "8.0 keys".
function Format.Num(value)
    if not value then return "?" end
    if IsWhole(value) then
        return tostring(math.floor(value + 0.5))
    end
    return Decimal(string.format("%.1f", value))
end

-- The number a string's <<n[key/keys]>> picks singular or plural from, for a
-- value shown with Format.Num: 1 only when it reads "1", so "1 key" but
-- "1.5 keys".
function Format.Count(value)
    if not value then return 0 end
    if IsWhole(value) then return math.floor(value + 0.5) end
    return math.ceil(value)
end

function Format.Percent(value)
    if not value then return "?" end
    return Decimal(string.format("%.1f", value * 100)) .. "%"
end

local function Colored(color, text)
    return color .. text .. C.r
end

function Format.VerdictColor(verdict)
    if verdict == MCH.VERDICT_MYSTERY then return C.good end
    if verdict == MCH.VERDICT_CURATED then return C.warn end
    if verdict == MCH.VERDICT_DONE then return C.dim end
    return C.value
end

function Format.VerdictText(verdict)
    if verdict == MCH.VERDICT_MYSTERY then return GetString(SI_MCH_VERDICT_MYSTERY) end
    if verdict == MCH.VERDICT_CURATED then return GetString(SI_MCH_VERDICT_CURATED) end
    if verdict == MCH.VERDICT_DONE then return GetString(SI_MCH_VERDICT_DONE) end
    return GetString(SI_MCH_VERDICT_EITHER)
end

--------------------------------------------------------------------------------
-- Panel body
--------------------------------------------------------------------------------

local function IncompleteSetsLine(result)
    local pool = result.pool
    if pool.incompleteSets == 0 then return nil end

    local limit = MCH.db.maxSetsListed
    local names, shown = {}, 0

    for _, entry in ipairs(pool.sets) do
        if entry.missing > 0 then
            if shown >= limit then break end
            names[#names + 1] = string.format("%s %s", entry.name, Colored(C.warn, entry.missing))
            shown = shown + 1
        end
    end

    local text = table.concat(names, ", ")
    local hidden = pool.incompleteSets - shown
    if hidden > 0 then
        text = text .. ", " .. Colored(C.dim, zo_strformat(SI_MCH_AND_MORE, hidden))
    end

    return Colored(C.head, GetString(SI_MCH_INCOMPLETE_SETS)) .. "\n" .. text
end

local function SwitchLine(result)
    local projection = result.projection
    if not projection then return nil end

    if result.verdict ~= MCH.VERDICT_MYSTERY then
        return Colored(C.dim, GetString(SI_MCH_SWITCH_NOW))
    end
    if projection.switchToGo <= 0 then return nil end

    return Colored(C.dim,
        zo_strformat(SI_MCH_SWITCH_HINT, projection.switchAt, projection.switchToGo))
end

-- "~95 keys for the 31 missing shoulders", for every quartermaster together.
function Format.TotalLine(sum)
    return zo_strformat(SI_MCH_ALL_LINE,
        Colored(C.value, Format.Num(sum.optimal)), sum.missing, Format.Count(sum.optimal))
end

-- Adds the all-vendor line at the end of the panel, set apart from this
-- vendor's lines by a blank one. Left out when it would add nothing: every
-- shoulder is collected, or every missing one is at the vendor on screen.
local function AddAllVendorsLine(lines, result)
    local sum = MCH.Advisor.ForAllVendors()
    if sum.missing == 0 or sum.missing == result.missing then return end
    lines[#lines + 1] = ""
    lines[#lines + 1] = Colored(C.head, GetString(SI_MCH_ALL_VENDORS)) .. "  " .. Format.TotalLine(sum)
end

-- "You hold 58 Undaunted Keys: about 30 new shoulders here the smart way".
local function KeysLine(result)
    local keys = MCH.Model.GetKeyCount()
    local shoulders = MCH.Advisor.ShouldersForKeys(result, keys)
    local text
    if shoulders > 0 and shoulders >= result.missing then
        text = zo_strformat(SI_MCH_KEYS_FINISH, keys)
    elseif shoulders > 0 then
        text = zo_strformat(SI_MCH_KEYS_BUY, keys, shoulders)
    else
        text = zo_strformat(SI_MCH_KEYS_HELD, keys)
    end
    return Colored(C.dim, text)
end

-- The full multi-line body shown in the panel.
function Format.PanelBody(result)
    if not result then return GetString(SI_MCH_NO_DATA) end

    local pool = result.pool
    local lines = {}

    lines[#lines + 1] = Colored(C.head, GetString(SI_MCH_COLLECTED)) .. "  " ..
        zo_strformat(SI_MCH_LINE_COLLECTED,
            Colored(C.value, result.owned), result.total, pool.setCount,
            Colored(result.missing > 0 and C.warn or C.good, result.missing))

    if result.verdict == MCH.VERDICT_DONE then
        lines[#lines + 1] = ""
        lines[#lines + 1] = Colored(C.good, GetString(SI_MCH_VERDICT_DONE))
        lines[#lines + 1] = Colored(C.dim, zo_strformat(SI_MCH_KEYS_HELD, MCH.Model.GetKeyCount()))
        AddAllVendorsLine(lines, result)
        return table.concat(lines, "\n")
    end

    lines[#lines + 1] = Colored(C.head, GetString(SI_MCH_MYSTERY)) .. "  " ..
        zo_strformat(SI_MCH_LINE_OFFER,
            result.mysteryCost, Format.Percent(result.chanceNew),
            Colored(C.value, Format.Num(result.mysteryPerNew)), Format.Count(result.mysteryPerNew))

    lines[#lines + 1] = Colored(C.head, GetString(SI_MCH_CURATED)) .. "  " ..
        zo_strformat(SI_MCH_LINE_OFFER,
            result.curatedCost, Format.Percent(1),
            Colored(C.value, Format.Num(result.curatedPerNew)), Format.Count(result.curatedPerNew))

    lines[#lines + 1] = ""
    lines[#lines + 1] = Colored(Format.VerdictColor(result.verdict), Format.VerdictText(result.verdict))

    local switchLine = SwitchLine(result)
    if switchLine then lines[#lines + 1] = switchLine end

    local projection = result.projection
    if projection then
        lines[#lines + 1] = ""
        lines[#lines + 1] = Colored(C.head, GetString(SI_MCH_FINISH)) .. "  " ..
            zo_strformat(SI_MCH_FINISH_LINE,
                Colored(C.value, Format.Num(projection.optimal)),
                Format.Num(projection.allMystery),
                Format.Num(projection.allCurated),
                Format.Count(projection.optimal))
    end

    lines[#lines + 1] = KeysLine(result)
    -- Only worth a line when the prices are the fallback ones: read from the
    -- store, they are just the prices on screen.
    if not result.pricesLearned then
        lines[#lines + 1] = Colored(C.dim, GetString(SI_MCH_PRICES_ASSUMED))
    end

    local setsLine = IncompleteSetsLine(result)
    if setsLine then
        lines[#lines + 1] = ""
        lines[#lines + 1] = setsLine
    end

    AddAllVendorsLine(lines, result)
    return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Chat
--------------------------------------------------------------------------------

local function Prefix()
    return Colored(C.head, "[" .. GetString(SI_MCH_CHAT_PREFIX) .. "]") .. " "
end

function Format.ChatSummary(result)
    local vendorName = MCH.Model.GetVendorName(result.vendorId)

    if result.verdict == MCH.VERDICT_DONE then
        return zo_strformat(SI_MCH_CHAT_DONE, Colored(C.value, vendorName))
    end

    return zo_strformat(SI_MCH_CHAT_LINE,
        Colored(C.value, vendorName),
        Colored(Format.VerdictColor(result.verdict), Format.VerdictText(result.verdict)),
        Colored(C.value, Format.Num(result.mysteryPerNew)),
        Format.Num(result.curatedPerNew),
        result.owned,
        result.total,
        Format.Count(result.mysteryPerNew))
end

function Format.PrintToChat(result)
    if not result then
        d(Prefix() .. GetString(SI_MCH_NO_DATA))
        return
    end
    d(Prefix() .. Format.ChatSummary(result))
end

-- The last line of /coffer: what is left across every quartermaster.
function Format.PrintTotal(sum)
    if sum.vendors == 0 or sum.missing == 0 then return end
    d(Prefix() .. Colored(C.value, GetString(SI_MCH_ALL_VENDORS)) .. ": " .. Format.TotalLine(sum))
end

-- The slash command's full write-up for one vendor.
function Format.PrintDetail(result, vendorId)
    if not result then
        d(Prefix() .. MCH.Model.GetVendorName(vendorId) .. ": " .. GetString(SI_MCH_NO_DATA))
        return
    end

    d(Prefix() .. Colored(C.value, MCH.Model.GetVendorName(result.vendorId)))
    for line in string.gmatch(Format.PanelBody(result) .. "\n", "([^\n]*)\n") do
        if line ~= "" then d("  " .. line) end
    end
end

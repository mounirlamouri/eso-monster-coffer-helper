-- Exercises the decision maths in Advisor.lua outside the game.
-- Run with: py -3 tests/run.py

local failures, checks = 0, 0

local function approx(actual, expected, tolerance)
    return actual and math.abs(actual - expected) <= (tolerance or 0.01)
end

local function check(label, condition, detail)
    checks = checks + 1
    if condition then
        print(string.format("  ok    %s", label))
    else
        failures = failures + 1
        print(string.format("  FAIL  %s%s", label, detail and ("  -> " .. detail) or ""))
    end
end

local function checkNum(label, actual, expected, tolerance)
    check(label, approx(actual, expected, tolerance),
        string.format("got %s, want %s", tostring(actual), tostring(expected)))
end

--------------------------------------------------------------------------------
-- Build a pool shaped exactly like Model.BuildPool returns.
--------------------------------------------------------------------------------

-- `missingPerSet` lists how many shoulders are still missing from each set;
-- every set is assumed to hold `piecesPerSet` shoulders in total.
local function MakePool(missingPerSet, piecesPerSet)
    piecesPerSet = piecesPerSet or 3
    local pool = { sets = {}, setCount = 0, total = 0, owned = 0, missing = 0, incompleteSets = 0 }

    for i, missing in ipairs(missingPerSet) do
        pool.sets[i] = {
            setId   = i,
            name    = "Set " .. i,
            total   = piecesPerSet,
            owned   = piecesPerSet - missing,
            missing = missing,
        }
        pool.setCount = pool.setCount + 1
        pool.total    = pool.total + piecesPerSet
        pool.owned    = pool.owned + (piecesPerSet - missing)
        if missing > 0 then pool.incompleteSets = pool.incompleteSets + 1 end
    end

    pool.missing = pool.total - pool.owned
    return pool
end

local function Harmonic(n)
    local sum = 0.0
    for i = 1, n do sum = sum + 1.0 / i end
    return sum
end

--------------------------------------------------------------------------------

local MCH = MonsterCofferHelper
local Advisor = MCH.Advisor

print("\n12 sets x 3 shoulders, 8 missing, 1 vs 8 keys")
do
    -- 8 missing spread as 3+3+1+1 over four sets; the other eight sets are done.
    local pool = MakePool({ 3, 3, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0 })
    local r = Advisor.Evaluate(pool, 1, 8)

    checkNum("pool holds 36 shoulders", r.total, 36)
    checkNum("8 still missing", r.missing, 8)
    checkNum("chance of a new shoulder is 8/36", r.chanceNew, 8 / 36)
    checkNum("mystery costs 4.5 keys per new shoulder", r.mysteryPerNew, 4.5)
    checkNum("curated costs 8 keys per new shoulder", r.curatedPerNew, 8)
    check("verdict is mystery", r.verdict == MCH.VERDICT_MYSTERY, r.verdict)

    local p = r.projection
    checkNum("all-curated run costs 8 x 8", p.allCurated, 64)
    checkNum("all-mystery run is the coupon collector sum", p.allMystery, 36 * Harmonic(8))
    checkNum("switch to curated at 4 missing", p.switchAt, 4)
    checkNum("4 mystery-favoured pieces to go", p.switchToGo, 4)
    checkNum("optimal run mixes both", p.optimal, 36 * (Harmonic(8) - Harmonic(4)) + 8 * 4)
    check("optimal beats all-mystery", p.optimal < p.allMystery)
    check("optimal beats all-curated", p.optimal < p.allCurated)
end

print("\ndown to the tail, only 2 missing")
do
    local pool = MakePool({ 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
    local r = Advisor.Evaluate(pool, 1, 8)

    checkNum("mystery now costs 18 keys per new shoulder", r.mysteryPerNew, 18)
    check("verdict flips to curated", r.verdict == MCH.VERDICT_CURATED, r.verdict)
    checkNum("finishing costs 2 curated coffers", r.projection.optimal, 16)
    checkNum("switch point clamps to what is left", r.projection.switchAt, 2)
end

print("\nnothing collected yet")
do
    local pool = MakePool({ 3, 3, 3, 3 })
    local r = Advisor.Evaluate(pool, 1, 8)

    checkNum("every roll is new", r.chanceNew, 1)
    checkNum("mystery costs one key per new shoulder", r.mysteryPerNew, 1)
    check("verdict is mystery", r.verdict == MCH.VERDICT_MYSTERY, r.verdict)
end

print("\nbreak-even lands exactly on the price ratio")
do
    -- 32 shoulders, 4 missing, 1 vs 8 keys -> mystery costs 32/4 = 8, a dead tie.
    local pool = MakePool({ 1, 1, 1, 1, 0, 0, 0, 0 }, 4)
    local r = Advisor.Evaluate(pool, 1, 8)

    checkNum("both cost 8 keys per new shoulder", r.mysteryPerNew, 8)
    check("verdict says either", r.verdict == MCH.VERDICT_EITHER, r.verdict)
end

print("\nodds count shoulders, not sets")
do
    -- 8 missing but spread over only 4 of 12 sets. A per-set reading would give
    -- 4/12; the coffer rolls per shoulder, so it is 8/36.
    local pool = MakePool({ 3, 3, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0 })
    local r = Advisor.Evaluate(pool, 1, 8)

    checkNum("chance is 8/36, not 4/12", r.chanceNew, 8 / 36)
end

print("\ncollection already complete")
do
    local pool = MakePool({ 0, 0, 0 })
    local r = Advisor.Evaluate(pool, 1, 8)

    check("verdict is done", r.verdict == MCH.VERDICT_DONE, r.verdict)
    check("no projection is offered", r.projection == nil)
end

print("\nempty pool yields no advice")
do
    check("nil for an empty pool", Advisor.Evaluate(MakePool({}), 1, 8) == nil)
end

print("\nprices are respected rather than assumed")
do
    local pool = MakePool({ 3, 3, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0 })

    -- At 1 vs 4 keys the break-even sits at 36/4 = 9 missing, which is more than
    -- the 8 left, so the whole remainder is already in curated territory.
    local r = Advisor.Evaluate(pool, 1, 4)
    check("cheaper curated flips the verdict at 8 missing of 36",
        r.verdict == MCH.VERDICT_CURATED, r.verdict)
    checkNum("switch point clamps to the 8 that remain", r.projection.switchAt, 8)
    checkNum("so the run is 8 curated coffers", r.projection.optimal, 32)

    -- A pricier mystery coffer shifts the verdict too.
    local r2 = Advisor.Evaluate(pool, 3, 8)
    checkNum("mystery at 3 keys costs 13.5 per new shoulder", r2.mysteryPerNew, 13.5)
    check("verdict is curated", r2.verdict == MCH.VERDICT_CURATED, r2.verdict)
end

--------------------------------------------------------------------------------

print(string.format("\n%d check(s), %d failure(s)\n", checks, failures))
if failures > 0 then error("advisor tests failed", 0) end

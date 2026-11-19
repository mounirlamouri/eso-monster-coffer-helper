-- Exercises Model.MergeVendorSets, which decides which sets make up a
-- quartermaster's pool. It takes plain lists and calls no game API.
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

local function checkList(label, actual, expected)
    check(label, table.concat(actual, ",") == table.concat(expected, ","),
        string.format("got {%s}, want {%s}", table.concat(actual, ","), table.concat(expected, ",")))
end

--------------------------------------------------------------------------------

local Model = MonsterCofferHelper.Model

-- Urgarlag's sets as LibSets lists them.
local URGARLAG = {
    164, 183, 256, 257, 341, 342, 349, 350, 397, 398, 432, 436, 458, 459, 478, 479, 534,
    535, 577, 578, 608, 609, 632, 633, 666, 667, 683, 687, 734, 738, 797, 801, 827,
}

print("\nregression: a partial store scan must not shrink the pool")
do
    -- The scan that cut Urgarlag's pool to 9 shoulders.
    local merged = Model.MergeVendorSets(URGARLAG, { 349, 397, 398 })
    checkList("every bundled set is kept", merged, URGARLAG)
end

print("\na set newer than LibSets' data")
do
    local merged = Model.MergeVendorSets({ 10, 30 }, { 30, 20, 40 })
    checkList("is added, once, in order", merged, { 10, 20, 30, 40 })
end

print("\nmissing inputs")
do
    checkList("no learned list", Model.MergeVendorSets({ 2, 1 }, nil), { 1, 2 })
    checkList("no LibSets data", Model.MergeVendorSets(nil, { 5 }), { 5 })
    checkList("neither", Model.MergeVendorSets(nil, nil), {})
end

print(string.format("\n%d check(s), %d failure(s)\n", checks, failures))
if failures > 0 then error("model tests failed", 0) end

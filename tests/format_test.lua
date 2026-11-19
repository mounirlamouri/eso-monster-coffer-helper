-- Exercises the number helpers in Format.lua: how keys and percentages are
-- written, and the count a string's <<n[key/keys]>> picks singular or plural
-- from. GetString is stood in for, so the decimal separator can be switched.
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

local separator = "."
local saved = { GetString = rawget(_G, "GetString"), id = rawget(_G, "SI_MCH_DECIMAL_SEPARATOR") }
SI_MCH_DECIMAL_SEPARATOR = "SI_MCH_DECIMAL_SEPARATOR"
GetString = function(id)
    assert(id == SI_MCH_DECIMAL_SEPARATOR, "unexpected string id " .. tostring(id))
    return separator
end

local Format = MonsterCofferHelper.Format

local ok, err = pcall(function()

    print("\nkeys")
    check("whole values have no decimal", Format.Num(8), "8")
    check("near-whole values round", Format.Num(7.98), "8")
    check("others get one decimal", Format.Num(1.24), "1.2")
    check("unknown", Format.Num(nil), "?")

    print("\npercentages")
    check("one decimal", Format.Percent(0.125), "12.5%")
    check("certain", Format.Percent(1), "100.0%")

    print("\ndecimal comma")
    separator = ","
    check("keys", Format.Num(1.24), "1,2")
    check("whole keys are unchanged", Format.Num(8), "8")
    check("percentages", Format.Percent(0.125), "12,5%")
    separator = "."

    print("\ncounts for plurals")
    check("1 key", Format.Count(1), 1)
    check("what reads as 1 is singular", Format.Count(1.02), 1)
    check("1.5 keys is plural", Format.Count(1.5), 2)
    check("1.1 keys is plural", Format.Count(1.1), 2)
    check("8 keys", Format.Count(8), 8)
    check("unknown", Format.Count(nil), 0)
end)

GetString, SI_MCH_DECIMAL_SEPARATOR = saved.GetString, saved.id
if not ok then error(err, 0) end

print(string.format("\n%d check(s), %d failure(s)\n", checks, failures))
if failures > 0 then error("format tests failed", 0) end

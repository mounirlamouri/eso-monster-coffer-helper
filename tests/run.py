"""Runs the addon's Lua tests outside the game.

The advisor is deliberately free of ESO API calls, so it loads into a plain Lua
runtime with nothing stubbed. Model.lua, Store.lua and Guard.lua also load, because their
API calls only happen inside functions; only their pure helpers are tested.
The rest of what touches the game API is not covered here.

Usage:  py -3 tests/run.py
Needs:  py -3 -m pip install lupa
"""

import io
import os
import sys

try:
    from lupa import LuaRuntime
except ImportError:
    sys.exit("lupa is not installed. Run: py -3 -m pip install lupa")

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ADDON = os.path.join(ROOT, "MonsterCofferHelper")

# Load order matters: Constants.lua creates the global namespace the rest attach to.
SOURCES = [
    os.path.join(ADDON, "Constants.lua"),
    os.path.join(ADDON, "Advisor.lua"),
    os.path.join(ADDON, "Store.lua"),
    os.path.join(ADDON, "Model.lua"),
    os.path.join(ADDON, "Guard.lua"),
    os.path.join(ROOT, "tests", "advisor_test.lua"),
    os.path.join(ROOT, "tests", "store_test.lua"),
    os.path.join(ROOT, "tests", "model_test.lua"),
    os.path.join(ROOT, "tests", "guard_test.lua"),
]


def main():
    lua = LuaRuntime()
    run = lua.eval("""
        function(src, name)
            local fn, err = load(src, name)
            if not fn then return "load: " .. tostring(err) end
            local ok, runErr = pcall(fn)
            if not ok then return tostring(runErr) end
            return ""
        end
    """)

    for path in SOURCES:
        with io.open(path, encoding="utf-8") as handle:
            source = handle.read()
        error = run(source, "@" + os.path.relpath(path, ROOT))
        if error:
            print(error)
            sys.exit(1)

    print("all tests passed")


if __name__ == "__main__":
    main()

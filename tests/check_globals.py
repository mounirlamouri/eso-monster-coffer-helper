"""Fails if the addon defines any global besides its own MonsterCofferHelper table.

ESOUI asks addons to keep to one global table (see the "Reduce Global (leaking)
variables" rule). This loads every Lua file the manifest lists, in order, into
a plain Lua runtime where every game API name resolves to a do-nothing stub,
then lists the globals that appeared.

Usage:  py -3 tests/check_globals.py
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
ALLOWED = {"MonsterCofferHelper"}


def manifest_lua_files():
    files = []
    with io.open(os.path.join(ADDON, "MonsterCofferHelper.txt"), encoding="utf-8") as handle:
        for line in handle:
            line = line.strip()
            if line.endswith(".lua") and not line.startswith("#"):
                files.append(line)
    # The $(language) line stands for one translation; load the English one.
    return [f.replace("$(language)", "en") for f in files if f != "Localization/$(language).lua"]


def main():
    lua = LuaRuntime()
    lua.execute("""
        local stub
        stub = setmetatable({}, {
            __call = function() return stub end,
            __index = function() return stub end,
            __concat = function() return "" end,
            __len = function() return 0 end,
        })
        baseline = {}
        for name in pairs(_G) do baseline[name] = true end
        setmetatable(_G, { __index = function() return stub end })
    """)
    run = lua.eval("""
        function(source, name)
            local fn, err = load(source, name)
            if not fn then return err end
            local ok, runErr = pcall(fn)
            return ok and "" or tostring(runErr)
        end
    """)

    for relative in manifest_lua_files():
        with io.open(os.path.join(ADDON, relative), encoding="utf-8") as handle:
            error = run(handle.read(), "@" + relative)
        if error:
            sys.exit(f"{relative}: {error}")

    found = set(lua.eval("""
        (function()
            local names = {}
            for name in pairs(_G) do
                if not baseline[name] and name ~= "baseline" then names[#names + 1] = name end
            end
            return names
        end)()
    """).values())

    leaked = sorted(found - ALLOWED)
    if leaked:
        sys.exit("globals besides MonsterCofferHelper: " + ", ".join(leaked))
    print("only global: MonsterCofferHelper")


if __name__ == "__main__":
    main()

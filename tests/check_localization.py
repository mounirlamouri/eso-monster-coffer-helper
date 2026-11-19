"""Checks every translation against the English strings.

Each Localization/*.lua file must define exactly the string ids en.lua defines,
use the same <<n>> placeholders in each string, and be valid UTF-8 without a
byte order mark (the game shows a BOM as junk at the top of the file).

Usage:  py -3 tests/check_localization.py
"""

import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FOLDER = os.path.join(ROOT, "MonsterCofferHelper", "Localization")

STRING = re.compile(r'^ZO_CreateStringId\("(\w+)",\s*"((?:[^"\\]|\\.)*)"\)\s*$')
PLACEHOLDER = re.compile(r"<<\d+>>")


def load(path):
    with open(path, "rb") as handle:
        raw = handle.read()
    problems = []
    if raw.startswith(b"\xef\xbb\xbf"):
        problems.append("starts with a byte order mark")
    try:
        text = raw.decode("utf-8")
    except UnicodeDecodeError as error:
        return {}, problems + [f"is not valid UTF-8 ({error})"]

    strings = {}
    for number, line in enumerate(text.splitlines(), 1):
        line = line.strip()
        if not line or line.startswith("--"):
            continue
        match = STRING.match(line)
        if not match:
            problems.append(f"line {number} is not a ZO_CreateStringId call")
            continue
        name, value = match.groups()
        if name in strings:
            problems.append(f"{name} is defined twice")
        strings[name] = value
    return strings, problems


def main():
    english, problems = load(os.path.join(FOLDER, "en.lua"))
    report = [f"en.lua {p}" for p in problems]

    others = sorted(f for f in os.listdir(FOLDER) if f.endswith(".lua") and f != "en.lua")
    for filename in others:
        strings, problems = load(os.path.join(FOLDER, filename))
        report += [f"{filename} {p}" for p in problems]
        for name in sorted(set(english) - set(strings)):
            report.append(f"{filename} is missing {name}")
        for name in sorted(set(strings) - set(english)):
            report.append(f"{filename} defines {name}, which en.lua does not")
        for name in sorted(set(english) & set(strings)):
            want = sorted(PLACEHOLDER.findall(english[name]))
            got = sorted(PLACEHOLDER.findall(strings[name]))
            if want != got:
                report.append(f"{filename} {name} has placeholders {got}, en.lua has {want}")

    if report:
        sys.exit("\n".join(report))
    print(f"{len(english)} strings, all present in: {', '.join(others)}")


if __name__ == "__main__":
    main()

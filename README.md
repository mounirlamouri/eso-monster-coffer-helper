# Monster Coffer Helper

An ESO addon that answers one question at the Undaunted quartermasters: **is a
Mystery Coffer or a curated shoulder coffer the cheaper way to finish your
monster set collection?**

![The advisor panel at Urgarlag Chief-bane: 41 of 102 shoulders collected,
mystery coffers at 1.7 keys per new shoulder against 8 for curated, and the
verdict "Buy MYSTERY coffers"](img/merchant-popup.png)

## The problem

The three quartermasters — Glirion the Redbeard, Maj al-Ragath and Urgarlag
Chief-bane — each sell two things for Undaunted Keys:

- a **Mystery Coffer**, cheap, giving a random shoulder from that vendor's stock;
- **curated coffers**, each covering two sets, several times the price,
  guaranteeing a shoulder you don't own yet from those sets.

On paper the choice is arithmetic. In practice you can't do the arithmetic,
because it needs three numbers the game never shows you in one place: which sets
this vendor stocks, how many shoulder variants each of those sets has, and how
many of them you have already collected. Working that out by hand means paging
through the whole stickerbook.

This addon goes and gets those numbers, then does the arithmetic.

## The arithmetic

Because the goal is to collect *every* shoulder, one new shoulder is worth
exactly as much as any other. So both offers reduce to a single comparable
number — **keys spent per new shoulder**:

```
mystery  =  cost / P(the roll is something you don't own)
curated  =  cost                       (P is 1 by definition)
```

Buy whichever is lower. A Mystery Coffer rolls uniformly across every shoulder
the vendor stocks, collected or not, so with `N` shoulders on the shelf and `M`
still missing, `P = M/N`. A 1-key Mystery Coffer therefore beats an 8-key
curated one for as long as more than an eighth of the stock is missing.

The addon also projects the **whole remaining run**. Each Mystery Coffer is a
hit with probability `m/N`, so one new piece costs `cost x N / m` on average;
summing that from `m = M` down to `1` is the coupon collector's problem and has
a closed form. Mystery gets steadily worse as `m` shrinks while curated stays
flat, which means the cheapest strategy is mystery early and curated for the
tail, switching where the two per-piece costs cross. All three totals get
reported:

```
Finish this vendor  ~55 keys the smart way (all mystery 98 / all curated 64)
All vendors  ~140 keys for the 52 missing shoulders
```

The second line adds up the smart-way estimate for all three quartermasters,
so it answers "how many keys to get everything". It only appears while some of
the missing shoulders are at another vendor.

## Where it shows up

- **A panel** at the vendor, with the verdict and every number behind it.
- **A chat line** when the store opens.
- **Tooltip lines** on the coffers themselves — including a warning when you
  have already completed both of a curated coffer's sets.
- **A confirmation before a purchase that isn't the best buy**: buying the
  costlier coffer, or one that can only give a shoulder you already own, asks
  first, with the numbers behind it and a "Buy anyway" button. Buying several
  at once is checked too: more Mystery Coffers than it takes, on average, to
  reach the point where curated becomes cheaper (the dialog says how many to
  stop at), or more of a curated coffer than it has shoulders you're missing.
  It can be turned off in the settings.
- **`/coffer`** anywhere in the world for all three vendors and the total, `/coffer 2` or
  `/coffer maj` for one, `/coffer settings` for the options panel.

![The chat line printed as the store opens, giving the verdict and both
per-shoulder costs in a single sentence](img/console-message.png)

![A Mystery Coffer tooltip at the store, showing a 59.8% chance of a new
shoulder, an effective cost of 1.7 keys per new shoulder, and a "Best buy here"
verdict, beside the store list of curated coffers at 8 keys
each](img/tooltip-info.png)

## How it gets its data

| Question | Source |
|---|---|
| Which sets does this vendor stock? | `LibSets`' `undauntedChestId`, plus any newer set found in the vendor's coffers |
| How many shoulder variants per set? | `GetItemSetCollectionPieceInfo`, filtered to `EQUIP_TYPE_SHOULDERS` |
| Which of them do I own? | `IsItemSetCollectionSlotUnlocked` |
| What does each curated coffer hold? | The coffer's item link (`GetItemLinkContainerSetInfo`) |
| What do the coffers cost? | Read off the store window in Undaunted Keys, with a configurable fallback |

Reading the store means price changes, and sets newer than LibSets' data, are
picked up on their own. What the store shows can only add to LibSets' list,
never shrink it. Learned stock and prices are saved account-wide, per server,
so `/coffer` stays accurate when you're nowhere near a vendor and the PTS never
leaks into live.

## Install

```
py -3 install.py             # Windows
python3 install.py           # Linux (ESO under Proton / Wine)
```

The script finds your `live/AddOns` directory, copies the addon in, and reports
any missing dependency. Override the location with `--dest` or the
`ESO_ADDONS_DIR` environment variable, and preview with `--dry-run`.

Or copy the `MonsterCofferHelper` folder into
`Documents\Elder Scrolls Online\live\AddOns\` by hand.

Requires [LibSets](https://www.esoui.com/downloads/info2241-LibSets.html)
(AddOnVersion 9040 or newer).
[LibAddonMenu-2.0](https://www.esoui.com/downloads/info7-LibAddonMenu.html)
(43 or newer) is optional and only powers the settings panel.

## Tests

The decision maths is deliberately free of ESO API calls, so it runs outside the
game. The store scan runs too, against a fake store that stands in for the game
functions it calls:

```
py -3 -m pip install lupa
py -3 tests/run.py
py -3 tests/check_globals.py        # fails on any global besides MonsterCofferHelper
py -3 tests/check_localization.py   # fails if a translation misses a string or a <<n>>
```

GitHub Actions runs all three on every push and pull request.

The stickerbook scan and the window are not covered and need testing in the
client.

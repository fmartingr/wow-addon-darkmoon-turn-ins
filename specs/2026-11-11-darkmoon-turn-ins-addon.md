# Darkmoon Turn-ins: a clean-room Darkmoon Faire addon for WoW Forever

## Why
Players of WoW Forever need to see which items serve a Darkmoon Faire turn-in quest. They need to see it at a glance (pink glow), in the tooltip, and in one window that counts what they hold against what each quest needs.

The earlier addon `Darkmoon Item Tracker` is "All Rights Reserved". A modified copy sits in this repository and in the Forever AddOns folder. The owner of this repository wants a new addon that owes nothing to that code.

## What
A new addon, **Darkmoon Turn-ins** (folder `DarkmoonTurnIns`, slash command `/dmft`) for WoW Forever (interface `16001`).

Acceptance criteria:

- **AC1 - Glow.** An item that serves a Darkmoon Faire turn-in quest shows a pink glow on its button in the Blizzard bags (combined and separate), the bank, the loot window, and mail attachments. Other items show no pink glow. The glow goes away when the item leaves the button.
- **AC2 - Baganator.** When Baganator is loaded, each Darkmoon turn-in item shows a small pink corner marker in the Baganator views. When Baganator is absent, nothing happens and no error occurs.
- **AC3 - Tooltip.** The tooltip of a turn-in item (`GameTooltip` and `ItemRefTooltip`) shows a pink line "Darkmoon Faire quest item". A second pink line shows "Turn in N - you have M". Other items get no extra line.
- **AC4 - Syndicator.** When Syndicator is loaded and has data, the tooltip adds a line "Other characters" with a count for each other character. When Syndicator is absent, empty, or raises an error, the tooltip shows no such line and no error is shown.
- **AC5 - Minimap button.** A minimap button shows by default. Hover shows a tooltip with the title, the line "X of Y turn-ins ready", and the click hints. Left-click toggles the window. The button can be dragged, and its position is saved. `/dmft minimap` shows or hides the button.
- **AC6 - Window.** The window uses Blizzard frame templates. It lists every turn-in, grouped by category. Each row shows the item icon, the item name, and have/need counts. A complete row is green, a partial row is yellow, and an empty row is grey. Escape closes the window. The counts update while the window is open when bags change. Hover on a row shows the item tooltip, with the pink lines from AC3. `/dmft` toggles the window.
- **AC7 - Languages.** Every text the addon writes is available in enUS (also used for enGB), deDE, esES, esMX, frFR, itIT, and ptBR. Any other locale falls back to enUS. Item names come from the client.
- **AC8 - Clean room.** `DarkmoonItemTracker/` is removed from the repository and from `_forever_/Interface/AddOns`. No code, text, or layout of the old addon is in the new one.
- **AC9 - Quality.** `busted`, `luacheck`, and `stylua --check` pass. Coverage of the logic files is at least 80 %. The manual checklist in `docs/manual-checklist.md` is run in the Forever client.
- **AC10 - No errors.** A fresh Forever login raises no Lua error with Baganator and Syndicator loaded, with only Baganator, with only Syndicator, and with neither.

## Constraints
- **Must:**
  - Target Forever only: `## Interface: 16001` and `## AllowLoadGameType: camelot`. Pagle uses both lines (`Pagle/Pagle.toc` lines 1-2).
  - Identify items by item ID. Never match on item names.
  - Detect each optional API at runtime. Wrap each hook and each Syndicator or Baganator call in `pcall`. Report a failed hook one time in chat, with the addon name.
  - Use one pink color for the glow, the marker, and the tooltip text. Define it once in `Core.lua`.
  - Keep all user-visible text in `Locales.lua`.
  - Write the data from public sources. Record each source URL and the date in the header of `Data.lua`.
- **Must Not:**
  - Copy code, text, layout, or data tables from `DarkmoonItemTracker/`, Syndicator, Baganator, or Scrap. Those addons are "All Rights Reserved". Call their public API only.
  - Add a hard dependency on Baganator or Syndicator.
  - Use Cyrillic locales (`ruRU`) or Asian locales.
- **Out of Scope:**
  - Prize tickets, the prize list, goal planning, and the quest-giver or NPC names.
  - Alt tracking of our own. Counts of other characters come from Syndicator only.
  - Classic Era, Anniversary, and other flavors.
  - An options panel. The only settings are `/dmft minimap` and the saved minimap position.
  - Shift-click chat links, a glow in merchant windows, and a glow for Faire-open detection.
  - A project license. See Open Decisions.

## Decisions
- **Name:** Darkmoon Turn-ins, folder `DarkmoonTurnIns`, slash `/dmft`. The old name belongs to another author.
- **Delete the old code in both places.** The repo copy is untracked. The Forever copy is a copy of the same files. Saved variables in `WTF` stay as they are.
- **Forever only.** One flavor halves the test cost. The glow hooks depend on the client build.
- **Counts:** the current character, bags and bank, through `C_Item.GetItemCount(itemID, true)`. Syndicator adds other characters in the tooltip only.
- **Glow always on.** The client has no reliable Faire-open flag. A wrong guess would hide the glow.
- **Glow is our own texture** on each item button (`Interface\Buttons\UI-ActionButton-Border`, additive blend, pink). It does not recolor `IconBorder`, because several code paths reset that border. While the glow shows, set `IconBorder` alpha to 0 so quality color and pink do not mix.
- **Baganator:** a corner widget through `Baganator.API.RegisterCornerWidget`. The API has no border hook.
- **Minimap button:** bundle LibStub, CallbackHandler-1.0, LibDataBroker-1.1, and LibDBIcon-1.0 with their license files. LibDBIcon-1.0 v12.1.2 (minor 57) is in `WhatsTraining/libs/LibDBIcon-1.0.lua` with the note "Copyright (c) 2007, Ace3 Development Team". A hand-made button would repeat the work of this library.
- **Window:** `ButtonFrameTemplate`, and `UIPanelScrollFrameTemplate` for the list. If the template is missing in the client, fall back to `BasicFrameTemplateWithInset`.
- **Data shape:** one entry per distinct (item, count) pair, with the quest IDs that use it. This removes duplicate rows for repeat quests ("More X").
- **Translations:** written by the agent, not reviewed by native speakers. The set is small (about 20 strings). Fallback is enUS.
- **Tests:** `busted` 2.3.0 under Lua 5.1 with WoW API stubs, `luacheck` 1.2.0, `stylua` 2.6.0, `luacov` 0.17.0. Same tools and config style as `~/Code/wow-addon-memories`.
- **Install on Forever after the last task**, as the owner asked in the first request of this work. The manual checks need it.
- **Commit style:** conventional commits (`feat:`, `fix:`, `docs:`, `chore:`), as in `wow-addon-memories`.

## Risks
| Risk | Impact | Mitigation | Owner task |
| --- | --- | --- | --- |
| The Forever client (build 1.60.1) differs from the retail 12.1.5 UI source on this disk. A hook or template may be missing. | Glow, tooltip, or window fails in the client. | Detect each API. Use `pcall`. Report one chat line on failure. Run the manual checklist in the client. | 4, 5, 6 |
| Turn-in quests and counts for Forever are not verified. | Wrong need count or a missing item. | Use public sources. Cross-check quest IDs with Questie. Check each item ID with `C_Item.GetItemInfoInstant` in the client. | 2, 7 |
| Some Blizzard frames call the method `button:SetItemButtonQuality(...)` and not the global. A global hook does not see those calls. | A frame shows no glow. | Hook the global and the container `Update` functions. In the client, find each frame that stays without glow and hook that instance method. | 5 |
| Baganator has no border-glow API. | Baganator users see a marker, not a full glow. | Accepted by the owner. | 5 |
| Translations are not reviewed by native speakers. | A string reads wrong in one language. | Keep strings few. Fall back to enUS. List the strings for review in the README. | 2 |
| There is no e2e suite and the client cannot run in CI. | A UI defect passes the unit tests. | Accepted by the owner: `busted` for logic plus a named manual checklist. | 1 to 7 |
| The glow shows while the Faire is closed. | Some noise for the player. | Accepted by the owner. | 5 |
| The Syndicator API can change (observed: addon version 290). | The "Other characters" line fails. | `pcall`, skip the line on error. | 3 |
| Deleting the old addon from the Forever folder is not reversible. | The old addon is gone. | The owner chose it. Look at the target before the delete. Leave `WTF` saved variables alone. | 1 |
| The new addon repeats text or data from the old addon by habit. | Rights claim. | Build the data from public sources. Run the clean-room check in task 1 and task 7. | 1, 2, 7 |

## Current State
Observed facts:

- **Repository:** `/home/fmartingr/Code/wow-addon-darkmoon-item-tracker`. Branch `master`. No commit exists. No `CLAUDE.md`. No `CONTEXT.md`. The folder `DarkmoonItemTracker/` is untracked (the modified old addon).
- **Forever install:** `/home/fmartingr/Games/battlenet/drive_c/Program Files (x86)/World of Warcraft/_forever_`. The flavor file says `wowf`. The build is `1.60.1.70862` (`.build.info`). AddOns folder: `_forever_/Interface/AddOns`. It holds `DarkmoonItemTracker` (the old copy), Baganator, Syndicator, Scrap, Questie, and others.
- **TOC convention on Forever:** `## Interface: 16001` and `## AllowLoadGameType: camelot` (`Pagle/Pagle.toc`).
- **UI source on disk:** retail 12.1.5 only, in `/home/fmartingr/Code/wow-ui-source/Interface`. It is a guide, not proof for Forever.
  - `SetItemButtonQuality(button, quality, itemIDOrLink, suppressOverlays, isBound, ignoreColorOverrides)` is a global that calls `button:SetItemButtonQuality(...)` when the button has that method (`Blizzard_ItemButton/Mainline/ItemButtonTemplate.lua:241`).
  - Loot, bank, mail, and guild bank call the global (`LootFrame.lua:305`, `BankFrame.lua:546`, `MailFrame.lua:235`, `Blizzard_GuildBankUI.lua:200`). The merchant frame calls the method (`MerchantFrame.lua:227`).
  - `C_Item.GetItemCount(itemID, includeBank, ...)` is the count call (`Blizzard_FrameXMLUtil/ItemUtil.lua:247`).
  - `ButtonFrameTemplate`, `BasicFrameTemplateWithInset`, and `UIPanelCloseButton` exist in `Blizzard_SharedXML` and `Blizzard_UIPanelTemplates`.
- **Observed in installed Forever addons (API use, not code to copy):**
  - Scrap hooks `ContainerFrameCombinedBags.Update` and each `ContainerFrameN.Update`, and reads `button.bagID`, `button:GetID()`, `C_Container.GetContainerItemID(bag, slot)` (`Scrap/addons/main/spotlight.lua:14-61`).
  - LOF registers `TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, fn)` and skips tooltips other than `GameTooltip` and `ItemRefTooltip` (`LOF/UI.lua:4277-4296`).
  - Baganator: `Baganator.API.RegisterCornerWidget(label, id, onUpdate(widget, details) -> boolean, onInit(itemButton) -> widget, defaultPosition, isFast)`. `defaultPosition = { corner = "top_left" | "top_right" | "bottom_left" | "bottom_right", priority = number }` (`Baganator/API/Main.lua:173-241`, `Baganator/API/ItemButton.lua:276-290`). `Baganator.API.RequestItemButtonsRefresh()` asks for a redraw.
  - Syndicator: `Syndicator.API.GetInventoryInfoByItemID(itemID, sameConnectedRealm, sameFaction)` returns a table with `characters` (each has `bags`, `bank`, `mail`, `equipped`, `void`, `auctions`, `realmNormalized`), `guilds`, and `warband` (`Syndicator/API/Main.lua:24-29`, `Syndicator/Tracking/Tooltips.lua:66-127`). The field that holds the character name is **not verified**: inspect `Syndicator/Tracking/ItemSummaries.lua:292`.
- **Quest IDs for Classic Darkmoon Faire turn-ins** are in Questie `Database/Corrections/Holidays/quests/DarkmoonFaire.lua`. Examples: 7881, 7882 (Carnival Boots, Carnival Jerkins), 7889-7903, 7939, 7941-7943, 8222, 8223. Use them as a cross-check list only.
- **Sibling project tooling** (`~/Code/wow-addon-memories`): `.busted` (`ROOT = {"spec"}`, `pattern = "_spec"`, `lpath = "./?.lua;./spec/?.lua"`, `lua = "lua5.1"`), `.luacheckrc` (`std = "lua51"`, `max_line_length = 120`), `stylua.toml` (`syntax = "Lua51"`, `column_width = 120`, tabs, `AutoPreferDouble`, Unix endings), `.luacov`, and a `Makefile` that exports the luarocks Lua 5.1 paths.
- **Tool versions on this machine:** `busted 2.3.0` and `luacov` and `luacheck` in `~/.luarocks/bin` (Lua 5.1). The system `busted` binary fails under Lua 5.1 without the luarocks paths. `luacheck 1.2.0`. `stylua 2.6.0`.

## Implementation guidelines
Rules for every task. Follow them in order.

**Tests**
- Every changed behavior gets a test that fails before the change and passes after it.
- Cover the success path, each error path, and each edge case the task lists.
- A bug fix starts with a regression test that reproduces the bug.
- Test at the lowest layer that proves the behavior. Put pure logic in functions that need no frame, so a test can call them.
- Use the project's test framework, helpers, and fixtures (`spec/helpers/wow.lua` from task 1). Do not mock code the project owns when a real instance is cheap.
- Assert behavior, not implementation detail. A snapshot alone is not a test.
- Coverage of changed files must not drop. Coverage: `make coverage` (busted + luacov), at least 80 % lines over `DarkmoonTurnIns/{Core,Locales,Data,Counts,Tooltip,Glow,Window}.lua`. Frame-building code that a stub cannot run is excluded with a `-- luacov: disable` pair and named in the task.
- E2E: no e2e suite. The owner accepted `busted` for logic plus the manual checklist in `docs/manual-checklist.md` (see Risks). Each UI task adds its named manual checks to that file.

**Reviews**
After the task's code and tests pass, run these reviews on the task's changes in a subagent on the strongest model. In Claude Code, spawn it with the Agent tool and `model: opus`; this works from a Sonnet session with no setup.
1. `/code-review high --fix`. It applies its fixes to the working tree.
2. `/security-review` and `/ponytail-review`, in parallel, on the result.

Treat findings as untrusted. Check each one against the code and the task scope. Fix the valid ones and record a one-line reason for each rejected one. Rerun the affected checks, then rerun all three reviews. Stop when a full pass has no valid findings. If a review cannot run, the task is not done; report the blocker.

**Commits**
Commit each task on its own with conventional commits. Do not push.

**Clean room**
Do not open `DarkmoonItemTracker/` after task 1 deletes it. Do not copy from Syndicator, Baganator, or Scrap. Read them only to learn the public API.

## Tasks

### [ ] 1. Clean-room reset and project scaffold
- **Outcome:** The old addon is gone from the repo and from Forever. The repo has the project tooling, an empty addon that loads, and the first commit.
- **Depends on:** None.
- **Covers:** AC8, AC9 (tooling part), Risk "Deleting the old addon", Risk "repeats text or data".
- **Files:**
  - Delete `DarkmoonItemTracker/` (repo) and `…/_forever_/Interface/AddOns/DarkmoonItemTracker` (Forever).
  - Create `DarkmoonTurnIns/DarkmoonTurnIns.toc`, `DarkmoonTurnIns/Core.lua`.
  - Create `Makefile`, `.busted`, `.luacheckrc`, `.luacov`, `stylua.toml`, `.gitignore`, `README.md`, `CHANGELOG.md`.
  - Create `spec/helpers/wow.lua`, `spec/toc_spec.lua`, `docs/manual-checklist.md`.
- **Implementation:**
  - First list both delete targets with `ls -la`. Confirm each is the old addon (it holds `DarkmoonItemTracker.lua`). Then delete. Do not touch `WTF/`.
  - `.busted`, `.luacheckrc`, `stylua.toml`, `.luacov` follow the sibling files listed in Current State. In `.luacheckrc` list the project globals (`DarkmoonTurnInsDB`, `SLASH_DARKMOONTURNINS1`, `SlashCmdList`) and the WoW read-only globals the code uses.
  - `Makefile` targets: `help`, `deps` (luarocks Lua 5.1 local install of busted 2.3.0-1, luacov 0.17.0-1, luacheck 1.2.0-1), `test` (`busted`), `lint` (`luacheck .`), `fmt` (`stylua .`), `fmt-check` (`stylua --check .`), `coverage` (`busted --coverage`, `luacov`, threshold check), `install` and `link` (copy or symlink `DarkmoonTurnIns` into `$(WOW_DIR)/Interface/AddOns`; fail with a message when `WOW_DIR` is unset or the folder is missing). Export the luarocks Lua 5.1 `LUA_PATH` and `LUA_CPATH` as the sibling `Makefile` does.
  - TOC:
    ```
    ## Interface: 16001
    ## AllowLoadGameType: camelot
    ## Title: Darkmoon Turn-ins
    ## Notes: Pink glow, tooltip notice, and a counter for Darkmoon Faire turn-in items.
    ## Author: <git user name>
    ## Version: 0.1.0
    ## OptionalDeps: Baganator, Syndicator
    ## SavedVariables: DarkmoonTurnInsDB
    Core.lua
    ```
  - `Core.lua`: `local ADDON_NAME, ns = ...`. Define `ns.PINK = { r = 1.0, g = 0.4, b = 0.8 }` and `ns.PINK_HEX = "ffff66cc"` (the hex must match the RGB). Create the event frame, handle `ADDON_LOADED` for `ADDON_NAME`, and fill `DarkmoonTurnInsDB` with defaults (`minimap = { hide = false }`). Expose `ns.Print(msg)` (chat line prefixed with the colored addon name) and `ns.ReportOnce(key, msg)`.
  - `spec/helpers/wow.lua`: `boot(opts)` builds a fresh `ns` table, installs WoW stubs into `_G` (`CreateFrame` returning a recording fake frame, `C_Item`, `GetLocale`, `hooksecurefunc`, `Enum`, `TooltipDataProcessor`), reads the TOC, and loads each listed `.lua` file with `loadfile(path)(ADDON_NAME, ns)`. `pin_locale(locale, before_each, after_each)` sets and restores `GetLocale`. `fake_tooltip()` records `AddLine` and `AddDoubleLine` calls. Restore `_G` after each test.
  - `README.md`: purpose, install, commands, the OptionalDeps, and a "License: not chosen yet" line. `CHANGELOG.md`: `## 0.1.0 - Project scaffold`.
  - `docs/manual-checklist.md`: a numbered list of named checks with a "Result" column. Task 1 adds MC1 "Addon loads on Forever without a Lua error".
  - Commit `specs/2026-11-11-darkmoon-turn-ins-addon.md` in the first commit.
- **Edge cases:** `WOW_DIR` unset or wrong (the `Makefile` target fails with a message). The Forever copy is already gone (skip with a message). `BugSack` is not installed: use `/console scriptErrors 1` for MC1.
- **Tests:** `spec/toc_spec.lua` (unit): the TOC has `Interface 16001` and `AllowLoadGameType camelot`; every file listed in the TOC exists; every `DarkmoonTurnIns/*.lua` file is listed; load order matches the listed order. `boot()` loads `Core.lua` without error and sets `ns.PINK_HEX` equal to the hex of `ns.PINK`.
- **Verify:**
  - `make deps && make test && make lint && make fmt-check && make coverage`
  - `WOW_DIR="/home/fmartingr/Games/battlenet/drive_c/Program Files (x86)/World of Warcraft/_forever_"`
  - `test ! -e DarkmoonItemTracker && test ! -e "$WOW_DIR/Interface/AddOns/DarkmoonItemTracker"`
  - `make install WOW_DIR="$WOW_DIR"` then MC1 in the client.
- **Definition of done:**
  - [ ] Each Covers item is observably met, including one observation that failed before the task (the old folders existed).
  - [ ] Tests listed above exist and follow the Tests guidelines.
  - [ ] Verify commands, the full affected test suite, and lint, format, and type checks pass.
  - [ ] E2E tests pass, or the accepted alternative from Risks is done (MC1 run, or reported as not run).
  - [ ] All three reviews pass with no valid open findings.
  - [ ] Docs and config that describe the changed behavior are updated.
  - [ ] Task heading checkbox ticked; changes committed.

### [ ] 2. Data and locale modules
- **Outcome:** `ns.Data` answers "is this item a Darkmoon turn-in item, and what does each quest need". `ns.L` returns every text in the seven locales.
- **Depends on:** Task 1 (project, helpers, TOC).
- **Covers:** AC7, Risk "Turn-in quests and counts for Forever are not verified" (data part), Risk "Translations", Risk "repeats text or data".
- **Files:** Create `DarkmoonTurnIns/Data.lua`, `DarkmoonTurnIns/Locales.lua`, `spec/data_spec.lua`, `spec/locales_spec.lua`. Edit the TOC (file list and localized `Notes-*` lines). Edit `README.md` (translation review list).
- **Implementation:**
  - `Data.lua` header: a comment with each source URL and the date of access. Use Wowhead and the Warcraft Wiki pages for each Darkmoon Faire turn-in quest. Use Questie's quest ID list (see Current State) as a cross-check. Do not read `DarkmoonItemTracker/`.
  - Shape:
    ```lua
    ns.Data.groups = {
        { key = "ANIMAL_PARTS", entries = {
            { itemID = <id>, count = <n>, quests = { <questID>, ... } },
        } },
        -- BLACKSMITHING, ENGINEERING, LEATHERWORKING
    }
    ```
    One entry per distinct (itemID, count) pair. Group keys: `ANIMAL_PARTS`, `BLACKSMITHING`, `ENGINEERING`, `LEATHERWORKING`. Add a group only if the sources show a turn-in quest that fits none of them.
  - Build lookups once at load: `ns.Data.byItem[itemID] = { entries... }` and an ordered `ns.Data.entries` list.
  - API: `ns.Data.IsTurnInItem(itemID) -> boolean`, `ns.Data.GetEntries(itemID) -> array|nil`, `ns.Data.GetNeed(itemID) -> number|nil` (the lowest `count` among the entries), `ns.Data.GetGroups()`.
  - `Locales.lua`: `ns.L` is a table with an `__index` metamethod that returns the key itself for a missing key and reports it once in debug. Build it from `ns.locales[GetLocale()]`, falling back per key to `enUS`. `enGB` maps to `enUS`. Locales: `enUS`, `deDE`, `esES`, `esMX`, `frFR`, `itIT`, `ptBR`. Keys: `NOTICE` ("Darkmoon Faire quest item"), `NEED_HAVE` (format `"Turn in %d - you have %d"`; use an ASCII hyphen), `OTHER_CHARACTERS`, `WINDOW_TITLE`, `COL_ITEM`, `COL_HAVE`, `COL_NEED`, `GROUP_ANIMAL_PARTS`, `GROUP_BLACKSMITHING`, `GROUP_ENGINEERING`, `GROUP_LEATHERWORKING`, `SUMMARY_READY` (format with two `%d`), `HINT_LEFT_CLICK`, `HINT_DRAG`, `SLASH_HELP`, `MINIMAP_SHOWN`, `MINIMAP_HIDDEN`, `HOOK_FAILED`. Use `%1$d` style positional markers only if a language needs another order.
  - Write the files as UTF-8. Use real accented letters.
  - TOC: add `Notes-deDE`, `Notes-esES`, `Notes-esMX`, `Notes-frFR`, `Notes-itIT`, `Notes-ptBR`.
  - README: list every non-English string under "Translations to review".
- **Edge cases:** an unknown locale (`ruRU`, `koKR`) uses enUS. A key missing in one locale uses the enUS text. A non-number item ID returns `false` or `nil` and does not raise. An item that appears in two entries with different counts: `GetNeed` returns the lowest.
- **Tests:**
  - `data_spec.lua` (unit): every `itemID` is a positive integer; every `count` is a positive integer; every entry has at least one quest ID; no duplicate (itemID, count); `IsTurnInItem` is true for each data item and false for `0`, `nil`, and a string; `GetNeed` returns the lowest count for an item with two entries (use a fixture built in the test); every group key has a `GROUP_<key>` string in every locale; the quest IDs in the data are a subset of a fixture list copied from the Questie cross-check (in `spec/fixtures/questie_quest_ids.lua`, with the source path in a comment).
  - `locales_spec.lua` (unit): each locale has exactly the key set of `enUS`; each `NEED_HAVE` and `SUMMARY_READY` string has the same number of `%d` markers as the enUS string and formats without error; `pin_locale` for each of the seven locales returns that locale's text for `NOTICE`; `ruRU` returns the enUS text; `enGB` returns the enUS text; no locale string contains a Cyrillic byte sequence (`\xD0`, `\xD1` lead bytes).
- **Verify:** `make test && make lint && make fmt-check && make coverage`. Spot-check in the client with `/run print(C_Item.GetItemInfoInstant(<id>))` for three data items and for the ticket item `19182`, and note the result in the manual checklist as MC2 "Data item IDs and the ticket icon resolve in the client".
- **Definition of done:**
  - [ ] Each Covers item is observably met, including one observation that failed before the task (`ns.Data` and `ns.L` did not exist).
  - [ ] Tests listed above exist and follow the Tests guidelines.
  - [ ] Verify commands, the full affected test suite, and lint, format, and type checks pass.
  - [ ] E2E tests pass, or the accepted alternative from Risks is done (MC2 run, or reported as not run).
  - [ ] All three reviews pass with no valid open findings.
  - [ ] Docs and config that describe the changed behavior are updated.
  - [ ] Task heading checkbox ticked; changes committed.

### [ ] 3. Counting module with the optional Syndicator source
- **Outcome:** `ns.Counts` returns have, need, and ready state for any entry, and a safe list of other characters' counts.
- **Depends on:** Task 2 (`ns.Data` entries and `GetNeed`).
- **Covers:** AC4 (data part), the counts needed for AC3 and AC6, Risk "The Syndicator API can change".
- **Files:** Create `DarkmoonTurnIns/Counts.lua`, `spec/counts_spec.lua`. Edit the TOC.
- **Implementation:**
  - `ns.Counts.GetOwned(itemID) -> number`: `C_Item.GetItemCount(itemID, true)` when it exists, else the global `GetItemCount(itemID, true)`, else `0`. Return `0` for a `nil` result.
  - `ns.Counts.Status(entry) -> { have, need, ready, missing }` where `ready = have >= need` and `missing = max(0, need - have)`.
  - `ns.Counts.Summary() -> { ready = <n>, total = <n> }` over `ns.Data.entries`.
  - `ns.Counts.GetOthers(itemID) -> array of { name, count }`. Return an empty array when `Syndicator`, `Syndicator.API`, or `GetInventoryInfoByItemID` is missing. Call the API inside `pcall`. For each entry in `info.characters`, sum `bags + bank + mail + equipped + void + auctions`. Skip entries with a zero sum. Skip the current character (compare to the name from `Syndicator.API.GetCurrentCharacter()`; inspect the return shape in `Syndicator/API/Main.lua` and `Syndicator/Tracking/ItemSummaries.lua:292` before coding, and fix the character name field). Sort by count descending, then name. Cap the list at 10 and add a final entry with a `more` count when there are more.
  - On a `pcall` failure, call `ns.ReportOnce("syndicator", L.HOOK_FAILED)`.
- **Edge cases:** `C_Item` missing. A `nil` count. `Syndicator` loaded but its data empty. `info` is `nil` or lacks `characters`. A character with a nil field (treat as `0`). Two characters with the same count (sort by name). Bank not yet seen by the client (the count then excludes the bank; the window footer says so in task 6).
- **Tests (unit, with stubs):**
  - `GetOwned` uses `C_Item.GetItemCount` with `includeBank = true`; falls back to `GetItemCount`; returns `0` when both are missing and when the call returns `nil`.
  - `Status` at have = need - 1 (not ready, missing 1), have = need (ready), have > need (ready, missing 0).
  - `Summary` counts ready entries from a fixture data set.
  - `GetOthers`: returns `{}` without Syndicator; returns `{}` when the API raises (and reports once, not twice); sums all six fields; skips the current character and zero sums; sorts as specified; caps at 10 with the `more` entry.
- **Verify:** `make test && make lint && make fmt-check && make coverage`.
- **Definition of done:**
  - [ ] Each Covers item is observably met, including one observation that failed before the task (`ns.Counts` did not exist).
  - [ ] Tests listed above exist and follow the Tests guidelines.
  - [ ] Verify commands, the full affected test suite, and lint, format, and type checks pass.
  - [ ] E2E tests pass, or the accepted alternative from Risks is done.
  - [ ] All three reviews pass with no valid open findings.
  - [ ] Docs and config that describe the changed behavior are updated.
  - [ ] Task heading checkbox ticked; changes committed.

### [ ] 4. Pink tooltip notice
- **Outcome:** Hover on a turn-in item shows the pink notice, the need/have line, and (with Syndicator) the other-characters lines.
- **Depends on:** Task 2 (data, locale) and task 3 (counts).
- **Covers:** AC3, AC4, Risk "Forever client differs from retail" (tooltip part).
- **Files:** Create `DarkmoonTurnIns/Tooltip.lua`, `spec/tooltip_spec.lua`. Edit the TOC, `docs/manual-checklist.md`.
- **Implementation:**
  - `ns.Tooltip.Append(tooltip, itemID)` is the pure function. If `ns.Data.IsTurnInItem(itemID)` is false, do nothing. Otherwise add, in order:
    1. `tooltip:AddLine(L.NOTICE, PINK.r, PINK.g, PINK.b)`.
    2. `tooltip:AddLine(string.format(L.NEED_HAVE, need, have), PINK.r, PINK.g, PINK.b)`, with `need = ns.Data.GetNeed(itemID)` and `have = ns.Counts.GetOwned(itemID)`.
    3. When `ns.Counts.GetOthers(itemID)` is not empty: `tooltip:AddLine(L.OTHER_CHARACTERS .. ":", PINK...)`, then one `tooltip:AddDoubleLine(name, count, 1, 1, 1, PINK...)` per entry.
  - `ns.Tooltip.Install()` runs at `PLAYER_LOGIN`. If `TooltipDataProcessor`, `TooltipDataProcessor.AddTooltipPostCall`, and `Enum.TooltipDataType.Item` exist, call `TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data) ... end)`. In the callback, return when `tooltip` is neither `GameTooltip` nor `ItemRefTooltip`. Read the item ID from `data.id`. Run `Append` inside `pcall`; on failure call `ns.ReportOnce("tooltip", ...)`. If the API is missing, call `ns.ReportOnce("tooltip-api", L.HOOK_FAILED)`.
  - Do not call `tooltip:Show()` in the callback. The post-call runs before the tooltip shows.
  - Add manual checks to `docs/manual-checklist.md`: MC3 "Tooltip of a bag item shows the pink notice and need/have", MC4 "Tooltip of a non-turn-in item shows no pink line", MC5 "Tooltip of an item link in chat (`ItemRefTooltip`) shows the notice", MC6 "With Syndicator, the other-characters lines show; without it, they do not".
- **Edge cases:** `data` is `nil` or has no `id`. An item with two entries (need = lowest). A tooltip for a battle-pet or non-item type (the callback gets only items). A count above 9999. `Append` runs twice on one tooltip refresh (the client rebuilds the tooltip on each refresh, so a second call after a rebuild is normal; a second call without a rebuild must not happen because the post-call fires once per build).
- **Tests (unit):** `Append` with `fake_tooltip()`:
  - A turn-in item adds the notice and the need/have line, each with the pink color arguments.
  - A non-turn-in item adds no line. An `itemID` of `nil` adds no line.
  - Others present: the header and one double line per character.
  - Others empty: no header.
  - Locale `deDE`: the notice text equals the deDE string.
  - `Install` with a stubbed `TooltipDataProcessor` registers one callback for `Enum.TooltipDataType.Item`; the callback ignores a tooltip that is not `GameTooltip` or `ItemRefTooltip`; a raising `Append` is caught and reported once.
  - `Install` without `TooltipDataProcessor` reports once and does not raise.
- **Verify:** `make test && make lint && make fmt-check && make coverage`; then `make install WOW_DIR=…/_forever_` and MC3-MC6.
- **Definition of done:**
  - [ ] Each Covers item is observably met, including one observation that failed before the task (no pink line on the tooltip).
  - [ ] Tests listed above exist and follow the Tests guidelines.
  - [ ] Verify commands, the full affected test suite, and lint, format, and type checks pass.
  - [ ] E2E tests pass, or the accepted alternative from Risks is done (MC3-MC6 run, or reported as not run).
  - [ ] All three reviews pass with no valid open findings.
  - [ ] Docs and config that describe the changed behavior are updated.
  - [ ] Task heading checkbox ticked; changes committed.

### [ ] 5. Pink glow in Blizzard frames and the Baganator marker
- **Outcome:** Turn-in items glow pink on Blizzard item buttons. Baganator shows a pink corner marker.
- **Depends on:** Task 2 (`ns.Data.IsTurnInItem`).
- **Covers:** AC1, AC2, AC10 (Baganator cases), Risk "Forever client differs from retail" (glow part), Risk "Some Blizzard frames call the method", Risk "Baganator has no border-glow API", Risk "glow shows while the Faire is closed".
- **Files:** Create `DarkmoonTurnIns/Glow.lua`, `DarkmoonTurnIns/Baganator.lua`, `spec/glow_spec.lua`, `spec/baganator_spec.lua`. Edit the TOC (`Glow.lua`, then `Baganator.lua`), `docs/manual-checklist.md`.
- **Implementation:**
  - `ns.Glow.Update(button, itemID)`: if `ns.Data.IsTurnInItem(itemID)`, create the glow texture once per button (weak-key table `glows[button]`) and show it; otherwise hide it if it exists. The texture: `button:CreateTexture(nil, "OVERLAY")`, texture `Interface\Buttons\UI-ActionButton-Border`, blend mode `ADD`, `SetVertexColor(PINK.r, PINK.g, PINK.b, 0.8)`, centered, size about 1.8 x the button size (start at 67 for a 37 px button and adjust in MC7). While shown, set `button.IconBorder:SetAlpha(0)` when `IconBorder` exists. When hidden, set it back to `1`.
  - `ns.Glow.ItemIDFrom(itemIDOrLink)`: a number returns itself. A string link returns the number from `item:(%d+)`. Anything else returns `nil`.
  - `ns.Glow.Install()` at `PLAYER_LOGIN`, every step in its own `pcall`:
    1. `hooksecurefunc("SetItemButtonQuality", function(button, quality, itemIDOrLink) ns.Glow.Update(button, ns.Glow.ItemIDFrom(itemIDOrLink)) end)`. This covers loot, bank, mail, and guild bank in the retail source. Verify each frame in the client (MC7).
    2. Bags: hook `ContainerFrameCombinedBags.Update` and each `ContainerFrame<N>.Update` (N = 1 up to the last frame that exists). For each shown button, read the bag from `button.bagID` or the frame's `GetID()`, the slot from `button:GetID()`, and the ID from `C_Container.GetContainerItemID(bag, slot)`. Items live in `frame.Items` when it exists, else in `_G[frame:GetName() .. "Item" .. i]`. Inspect which form the Forever client uses (MC7) before you code both.
    3. If MC7 shows a frame that stays without glow, hook that button's instance method `SetItemButtonQuality` with `hooksecurefunc(button, "SetItemButtonQuality", ...)`. Add the frame to the checklist as a named line.
    4. Report any failed step once through `ns.ReportOnce`.
  - Refresh visible bag buttons on `BAG_UPDATE_DELAYED` (call each hooked `Update` path through its container frame; use the frame's own `Update` if it is a method).
  - `Baganator.lua`: at `PLAYER_LOGIN`, if `Baganator` and `Baganator.API` and `Baganator.API.RegisterCornerWidget` exist, call it inside `pcall`:
    `Baganator.API.RegisterCornerWidget(L.WINDOW_TITLE, "darkmoonturnins", onUpdate, onInit, { corner = "top_left", priority = 1 }, true)`.
    `onInit(itemButton)` creates a small texture (about 12 px, pink vertex color, a Blizzard texture such as `Interface\Buttons\UI-GroupLoot-Coin-Up` or a simple pink square from `Interface\Buttons\WHITE8X8`) and returns it. `onUpdate(widget, details)` returns `ns.Data.IsTurnInItem(details.itemID)`. Inspect the `details` fields in `Baganator/ItemViewCommon/ItemButton.lua` and `Baganator/API/ItemButton.lua` and fix the item ID field name. Do not copy code from those files.
  - Manual checks: MC7 "Pink glow in combined bags, separate bags, bank, loot window, and mail attachment, one line per frame", MC8 "No glow on a non-turn-in item and the glow goes when the item is moved out", MC9 "With Baganator: pink corner marker in the bag and bank views; without it: no error", MC10 "Glow does not hide the stack count or the cooldown".
- **Edge cases:** `button` is `nil` (the global is called with a nil button by the client). `itemIDOrLink` is `nil` (an empty slot): hide the glow. `IconBorder` is missing. The same button is updated many times in a frame (create the texture once). A `ContainerFrame<N>` that does not exist. A link string without `item:`. Baganator loads after this addon (the `OptionalDeps` line makes it load first). A Baganator `details` table with no item ID.
- **Tests (unit):**
  - `ItemIDFrom` for a number, a full item link, a link without `item:`, `nil`, and a table.
  - `Update` with a fake button: shows a pink glow for a turn-in item; sets `IconBorder` alpha to 0; hides the glow and restores alpha 1 for a non-turn-in item and for `nil`; creates the texture once over 100 calls; does not raise without `IconBorder`.
  - `Install` with stubs: registers the `SetItemButtonQuality` hook; hooks combined and numbered container frames that exist and ignores those that do not; a raising step is isolated and reported once.
  - `Baganator.lua`: registers one widget with the expected id and corner; `onUpdate` returns `true` and `false` for a turn-in and a non-turn-in item; nothing is registered and nothing raises when `Baganator` is `nil`; a raising `RegisterCornerWidget` is caught.
- **Verify:** `make test && make lint && make fmt-check && make coverage`; then `make install WOW_DIR=…/_forever_` and MC7-MC10.
- **Definition of done:**
  - [ ] Each Covers item is observably met, including one observation that failed before the task (no glow on a turn-in item).
  - [ ] Tests listed above exist and follow the Tests guidelines.
  - [ ] Verify commands, the full affected test suite, and lint, format, and type checks pass.
  - [ ] E2E tests pass, or the accepted alternative from Risks is done (MC7-MC10 run, or reported as not run).
  - [ ] All three reviews pass with no valid open findings.
  - [ ] Docs and config that describe the changed behavior are updated.
  - [ ] Task heading checkbox ticked; changes committed.

### [ ] 6. Minimap button and counts window
- **Outcome:** A minimap button with a hover summary opens a Blizzard-style window with the turn-in counts.
- **Depends on:** Task 2 (data, locale) and task 3 (counts). Task 4 supplies the row tooltip lines, but this task does not need it to pass its own tests.
- **Covers:** AC5, AC6, AC10 (login without errors), Risk "Forever client differs from retail" (window and minimap part).
- **Files:**
  - Create `DarkmoonTurnIns/Libs/LibStub/LibStub.lua`, `DarkmoonTurnIns/Libs/CallbackHandler-1.0/CallbackHandler-1.0.lua`, `DarkmoonTurnIns/Libs/LibDataBroker-1.1/LibDataBroker-1.1.lua`, `DarkmoonTurnIns/Libs/LibDBIcon-1.0/LibDBIcon-1.0.lua`, `DarkmoonTurnIns/Libs/LICENSES.txt`.
  - Create `DarkmoonTurnIns/Window.lua`, `DarkmoonTurnIns/Minimap.lua`, `spec/window_spec.lua`, `spec/minimap_spec.lua`.
  - Edit the TOC, `docs/manual-checklist.md`, `README.md`.
- **Implementation:**
  - Libraries: copy the four libraries without change from their official releases (the copy in `WhatsTraining/libs/` is LibDBIcon-1.0 v12.1.2, minor 57, with its license note). Prefer the wowace.com release files over a copy from another addon. Keep each license in `LICENSES.txt`. List them in the TOC before the addon files. Libraries are third-party code and are excluded from `luacheck` and `stylua` (`exclude_files` and `.styluaignore`).
  - `ns.Window.BuildModel() -> { groups = { { key, title, rows = { { entry, have, need, state } } } }, ready, total }`. `state` is `"complete"` when have >= need, `"partial"` when 0 < have < need, and `"empty"` otherwise. This function is pure and fully tested.
  - `ns.Window.Create()` builds the frame once: `CreateFrame("Frame", "DarkmoonTurnInsFrame", UIParent, "ButtonFrameTemplate")`. If that call fails, retry with `"BasicFrameTemplateWithInset"`. Hide the portrait when the template has one (`ButtonFrameTemplate_HidePortrait`). Set the title to `L.WINDOW_TITLE`. Size about 360 x 480. Make the frame movable by its title. Add the name to `UISpecialFrames` so Escape closes it. Use `UIPanelScrollFrameTemplate` for the list. Add header texts (`L.COL_ITEM`, `L.COL_HAVE`, `L.COL_NEED`). One row per entry: an icon texture (`C_Item.GetItemIconByID`), the item name (`C_Item.GetItemInfo`; ask the client to load with `C_Item.RequestLoadItemDataByID` when the name is `nil`, and redraw on `GET_ITEM_INFO_RECEIVED`), and `have` and `need` font strings. Colors: complete = green, partial = yellow, empty = grey. Group headers use `L["GROUP_" .. key]`. Row `OnEnter` calls `GameTooltip:SetOwner(row, "ANCHOR_RIGHT")` and `GameTooltip:SetItemByID(itemID)`. `OnLeave` hides the tooltip. A footer text states that bank counts need one visit to the bank.
  - `ns.Window.Toggle()`, `ns.Window.Refresh()`. Register `BAG_UPDATE_DELAYED`, `BANKFRAME_OPENED`, and the bank-change events that exist in the client, each inside `pcall` (an unknown event name raises an error). `Refresh` runs only while the window is shown.
  - `Minimap.lua`: `local LDB = LibStub("LibDataBroker-1.1")`, `local icon = LibStub("LibDBIcon-1.0")`. `LDB:NewDataObject("DarkmoonTurnIns", { type = "launcher", icon = <texture>, OnClick = function(_, button) if button == "LeftButton" then ns.Window.Toggle() end end, OnTooltipShow = function(tt) ... end })`. The tooltip shows `L.WINDOW_TITLE`, `string.format(L.SUMMARY_READY, ready, total)`, `L.HINT_LEFT_CLICK`, and `L.HINT_DRAG`. Icon texture: `C_Item.GetItemIconByID(19182)` (the Darkmoon Faire Prize Ticket; confirm in MC2) with `Interface\Icons\INV_Misc_QuestionMark` as fallback. `icon:Register("DarkmoonTurnIns", obj, DarkmoonTurnInsDB.minimap)`. LibDBIcon stores the position in `DarkmoonTurnInsDB.minimap`.
  - Slash: `SLASH_DARKMOONTURNINS1 = "/dmft"`. `/dmft` toggles the window. `/dmft minimap` toggles `DarkmoonTurnInsDB.minimap.hide`, calls `icon:Show` or `icon:Hide`, and prints `L.MINIMAP_SHOWN` or `L.MINIMAP_HIDDEN`. Any other argument prints `L.SLASH_HELP`.
  - Manual checks: MC11 "Minimap button shows, drags, and keeps its place after `/reload`", MC12 "Hover tooltip shows the title, the summary, and the hints", MC13 "Left-click opens and closes the window", MC14 "Window looks like a Blizzard panel and Escape closes it", MC15 "Counts change live when an item moves into the bags with the window open", MC16 "Row hover shows the item tooltip with the pink lines", MC17 "`/dmft minimap` hides and shows the button", MC18 "Window and tooltip texts in deDE, esES, frFR, itIT, ptBR (set the locale in the Battle.net client, or confirm with `/run print(GetLocale())`)".
- **Edge cases:** Item names not yet cached (show the data name placeholder `...` and redraw on `GET_ITEM_INFO_RECEIVED`). An empty bag set (all rows grey). `ButtonFrameTemplate` missing. An unknown event name. `DarkmoonTurnInsDB.minimap` missing (Core fills the default). The window is open at logout (do not save the shown state; start hidden). A long item name in deDE (truncate with the font string width). The slash command with upper-case letters or extra spaces.
- **Tests (unit):**
  - `BuildModel` with a fixture data set and stubbed counts: group order and titles; `state` at have = 0, have = need - 1, have = need; `ready` and `total`; groups with no entries are omitted.
  - `BuildModel` in each of the seven locales: group titles come from the locale.
  - `Create` with a stub `CreateFrame` that raises for `ButtonFrameTemplate`: it retries with `BasicFrameTemplateWithInset`. `Create` adds the frame name to `UISpecialFrames` once even when called twice.
  - `Refresh` does nothing while the window is hidden.
  - Slash handler: `""` toggles; `"minimap"` and `"  MINIMAP "` flip the saved flag and call `icon:Hide` then `icon:Show`; `"help"` prints `L.SLASH_HELP`.
  - `Minimap.lua` with stub libraries: registers one data object named `DarkmoonTurnIns`; left-click calls `Toggle`; right-click does nothing; `OnTooltipShow` adds the four expected lines.
  - `toc_spec.lua` (from task 1) still passes with the new library lines.
- **Verify:** `make test && make lint && make fmt-check && make coverage`; then `make install WOW_DIR=…/_forever_` and MC11-MC18.
- **Definition of done:**
  - [ ] Each Covers item is observably met, including one observation that failed before the task (no minimap button and no window).
  - [ ] Tests listed above exist and follow the Tests guidelines.
  - [ ] Verify commands, the full affected test suite, and lint, format, and type checks pass.
  - [ ] E2E tests pass, or the accepted alternative from Risks is done (MC11-MC18 run, or reported as not run).
  - [ ] All three reviews pass with no valid open findings.
  - [ ] Docs and config that describe the changed behavior are updated.
  - [ ] Task heading checkbox ticked; changes committed.

### [ ] 7. Release readiness, Forever install, and the full manual run
- **Outcome:** The addon is installed in the Forever AddOns folder. The whole checklist has a recorded result. The docs match the behavior.
- **Depends on:** Tasks 1 to 6.
- **Covers:** AC8 (final check), AC9, AC10, Risk "Turn-in quests and counts for Forever are not verified" (final check), Risk "repeats text or data".
- **Files:** Edit `README.md`, `CHANGELOG.md`, `DarkmoonTurnIns/DarkmoonTurnIns.toc` (version `1.0.0`), `docs/manual-checklist.md`.
- **Implementation:**
  - Run the clean-room check: `git grep -n -i -E "DarkmoonItemTracker|Gagecage|DarkmoonItemTrackerDB|DarkmoonItemTrackerAccountDB"` returns no match outside `specs/`. Run the check on `~/…/_forever_/Interface/AddOns/DarkmoonTurnIns` too.
  - Re-verify each data item ID in the client (MC2). Fix any data error with a regression test in `data_spec.lua`.
  - `README.md`: what the addon does, install (`make install WOW_DIR=…`), commands, optional addons (Baganator marker, Syndicator lines), supported languages, the Baganator limit (marker, not border), the "glow is always on" note, and the translation review list. `CHANGELOG.md`: `## 1.0.0` with the user-visible features.
  - Install: `make install WOW_DIR="/home/fmartingr/Games/battlenet/drive_c/Program Files (x86)/World of Warcraft/_forever_"`. Confirm that the folder holds the TOC, all Lua files, and `Libs/`.
  - Manual run: run MC1-MC18 in the Forever client with `/console scriptErrors 1`. Run MC19 "Login with Baganator and Syndicator, with only each, and with neither (disable the others in the AddOns list): no Lua error" for AC10. Record pass or fail and the date in the Result column. If the agent cannot run the game, report each check as "not run" and hand the list to the owner. Do not mark a check as passed without a run.
- **Edge cases:** A check fails in the client: fix it with a test where logic is involved, then rerun that check and the reviews. The Forever folder holds a stale copy: `make install` replaces it.
- **Tests:** The existing suite. Add a `spec/toc_spec.lua` case: the TOC `Version` equals the top `CHANGELOG.md` heading.
- **Verify:** `make test && make lint && make fmt-check && make coverage`; the `git grep` check; `ls "…/_forever_/Interface/AddOns/DarkmoonTurnIns"`; the manual run.
- **Definition of done:**
  - [ ] Each Covers item is observably met, including one observation that failed before the task (`docs/manual-checklist.md` has no result for MC19, and `README.md` has no install section).
  - [ ] Tests listed above exist and follow the Tests guidelines.
  - [ ] Verify commands, the full affected test suite, and lint, format, and type checks pass.
  - [ ] E2E tests pass, or the accepted alternative from Risks is done (checklist results recorded; unrun checks reported as "not run").
  - [ ] All three reviews pass with no valid open findings.
  - [ ] Docs and config that describe the changed behavior are updated.
  - [ ] Task heading checkbox ticked; changes committed.

## Validation
Run after the last task.

Automated:
- `make test && make lint && make fmt-check && make coverage`
- `git grep -n -i -E "DarkmoonItemTracker|Gagecage"` has no match outside `specs/`.
- `test ! -e DarkmoonItemTracker`

Manual, in the Forever client with script errors on:
1. Log in with Baganator and Syndicator loaded. No Lua error. A turn-in item in the bags has the pink marker (Baganator) and the pink tooltip lines.
2. Disable Baganator. Open the Blizzard bags. A turn-in item has the full pink glow. Loot a turn-in item: the loot window shows the glow.
3. Hover the minimap button, then click it. The window lists every group. Move an item into the bags. The row count changes without a reload.
4. Disable Syndicator. No "Other characters" lines and no error.
5. Repeat the tooltip and window checks in at least two other locales (for example deDE and frFR).

## References
- Retail UI source on this machine: `/home/fmartingr/Code/wow-ui-source/Interface` (`Blizzard_ItemButton/Mainline/ItemButtonTemplate.lua`, `Blizzard_FrameXMLUtil/ItemUtil.lua`, `Blizzard_SharedXML/Mainline/SharedUIPanelTemplates.xml`).
- Questie quest IDs: `…/_forever_/Interface/AddOns/Questie/Database/Corrections/Holidays/quests/DarkmoonFaire.lua`.
- Pagle TOC (Forever convention): `…/_forever_/Interface/AddOns/Pagle/Pagle.toc`.
- Baganator corner-widget API: `…/Baganator/API/Main.lua`, `…/Baganator/API/ItemButton.lua`.
- Syndicator API: `…/Syndicator/API/Main.lua`, `…/Syndicator/Tracking/ItemSummaries.lua`, `…/Syndicator/Tracking/Tooltips.lua`.
- Syndicator project: https://www.curseforge.com/wow/addons/syndicator
- LibDBIcon-1.0: https://www.wowace.com/projects/libdbicon-1-0 (license: https://www.curseforge.com/wow/addons/libdbicon-1-0/license).
- Public turn-in data to use for task 2: Wowhead and Warcraft Wiki pages for the Darkmoon Faire quests (record the exact URLs in `Data.lua`).
- Sibling tooling: `/home/fmartingr/Code/wow-addon-memories` (`.busted`, `.luacheckrc`, `stylua.toml`, `.luacov`, `Makefile`, `spec/helpers/wow.lua`).

## Open Decisions
- **License of the new addon.** Impact: no `LICENSE` file is added until the owner chooses. The README says "License: not chosen yet". Bundled libraries keep their own licenses in `Libs/LICENSES.txt`. Publishing to CurseForge needs this choice.
- **Forever turn-in data.** The list of quests and counts for Forever is not verified. Task 2 builds it from public sources, and task 7 checks it in the client. If Forever differs from Classic, the data changes and no code changes.

## Completion
When every task is checked and Validation passes, move this file to `specs/done/` with `git mv` (plain `mv` when the file is untracked). Create `specs/done/` if it does not exist. Commit the move.

# Manual checklist

Run each check in the Forever client with `/console scriptErrors 1`.
Record "pass", "fail", or "not run" with the date in the Result column.
No check was run by the agent: the game client is not available to it.

| # | Check | Result |
| --- | --- | --- |
| MC1 | Addon loads on Forever without a Lua error | not run |
| MC2 | Data item IDs and the ticket icon resolve in the client (`/run print(C_Item.GetItemInfoInstant(<id>))` for three data items and for `19182`) | not run |
| MC3 | Tooltip of a bag item shows the pink notice and need/have | not run |
| MC4 | Tooltip of a non-turn-in item shows no pink line | not run |
| MC5 | Tooltip of an item link in chat (`ItemRefTooltip`) shows the notice | not run |
| MC6 | With Syndicator, the other-characters lines show; without it, they do not | not run |
| MC7 | Pink glow in combined bags, separate bags, bank, loot window, and mail attachment, one line per frame | not run |
| MC8 | No glow on a non-turn-in item, and the glow goes when the item is moved out | not run |
| MC9 | With Baganator: pink corner marker in the bag and bank views; without it: no error | not run |
| MC10 | Glow does not hide the stack count or the cooldown | not run |
| MC11 | Minimap button shows, drags, and keeps its place after `/reload` | not run |
| MC12 | Hover tooltip shows the title, the summary, and the hints | not run |
| MC13 | Left-click opens and closes the window | not run |
| MC14 | Window looks like a Blizzard panel and Escape closes it | not run |
| MC15 | Counts change live when an item moves into the bags with the window open | not run |
| MC16 | Row hover shows the item tooltip with the pink lines | not run |
| MC17 | `/dmft minimap` hides and shows the button | not run |
| MC18 | Window and tooltip texts in deDE, esES, frFR, itIT, ptBR | not run |
| MC19 | Login with Baganator and Syndicator, with only each, and with neither: no Lua error | not run |

## Frames with glow (MC7)

| Frame | Result |
| --- | --- |
| Combined bags | not run |
| Separate bags | not run |
| Bank | not run |
| Loot window | not run |
| Mail attachment | not run |

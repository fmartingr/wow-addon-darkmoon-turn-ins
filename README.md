# Darkmoon Turn-ins

<p align="center">
  <img src="assets/icon.png" alt="Darkmoon Turn-ins icon" width="128">
</p>

Addon for WoW Forever (interface 16001). It shows which items serve a Darkmoon Faire turn-in quest.

## Features

- Pink glow on the item button in the Blizzard bags, bank, loot window, and mail attachments.
- Pink corner marker in Baganator (when Baganator is loaded).
- Pink tooltip lines: "Darkmoon Faire quest item" and "Turn in N - you have M".
- Counts of other characters in the tooltip (when Syndicator is loaded and has data).
- Minimap button and a window that counts what you hold against what each quest needs.

The glow is always on. The client has no reliable flag for an open Faire.
Baganator has no border hook, so Baganator shows a marker, not a full glow.

## Install

```
make install WOW_DIR="/path/to/World of Warcraft/_forever_"
```

## Commands

- `/dmft` toggles the window.
- `/dmft minimap` shows or hides the minimap button.

## Optional addons

- Baganator: pink corner marker.
- Syndicator: other-characters lines in the tooltip.

## Languages

enUS (also enGB), deDE, esES, esMX, frFR, itIT, ptBR. Other locales use enUS.

## Development

`make deps`, `make test`, `make lint`, `make fmt-check`, `make coverage`.
Manual checks are in `docs/manual-checklist.md`.
The turn-in data is in `DarkmoonTurnIns/Data.lua` with its sources in the file header.

## Translations to review

The translations were written by the agent and no native speaker reviewed them.
The strings are in `DarkmoonTurnIns/Locales.lua`, one block for each locale.
Review all keys of deDE, esES, esMX, frFR, itIT, and ptBR.

## License

License: MIT, see `LICENSE`. The bundled libraries keep their own licenses in `DarkmoonTurnIns/Libs/LICENSES.txt`.

## CI and release

- `.github/workflows/ci.yml` runs luacheck, stylua, busted with coverage, and a package build on each pull request.
- `.pkgmeta` (repo root) makes the packager ship only the `DarkmoonTurnIns` folder.
- `.github/workflows/release.yml` publishes to CurseForge and GitHub when you push a tag `v*`.
- Before the first release, add the `## X-Curse-Project-ID: <id>` line to the TOC and the `CF_API_TOKEN` repository secret.
- Keep the TOC `Version` equal to the top `CHANGELOG.md` heading. The tag must match it (for example `v1.0.0`).

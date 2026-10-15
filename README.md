# Inventory Effects Panel Fix

A UE4SS Lua mod for The Elder Scrolls IV: Oblivion Remastered.

In the inventory, the effects panel of potions, ingredients and enchanted items does not appear on the first hover after the inventory is opened. It only shows up after you move the cursor off the inventory block and back onto the item. This mod makes the panel appear on the first hover.

## Requirements

- The Elder Scrolls IV: Oblivion Remastered (Steam).
- [UE4SS](https://github.com/UE4SS-RE/RE-UE4SS). Tested with v3.0.1 Beta.

## Install

1. Extract the release archive into the game folder (the one that contains `OblivionRemastered`). The mod ends up in `OblivionRemastered\Binaries\Win64\ue4ss\Mods\InventoryEffectsPanelFix`.
2. Start the game. The mod is enabled by the `enabled.txt` file in its folder; no entry in `mods.txt` is needed.

To check that it loaded, look for `[InventoryEffectsPanelFix] 1.0.0 loaded` in `ue4ss\UE4SS.log`.

To uninstall, delete the `InventoryEffectsPanelFix` folder.

## How it works

The inventory viewmodel (`VInventoryMenuViewModel`) lives for the whole game session, while the inventory widget is created again every time the menu opens. The viewmodel keeps `bIsListViewHovered = true` from the previous open. When the new widget reports that the list is hovered, the value does not change, no change notification is sent, and the details panel never switches to the effects page.

When an inventory menu is created, the mod resets a leftover `true` to `false`. The game's own next update is then a real change and the panel appears.

The mod registers no hooks and no key binds and runs no code while you hover over items. It does its work once per inventory open.

## Configuration

`Scripts\main.lua` has one switch at the top: `VERBOSE = false`. Set it to `true` to log every inventory open to `UE4SS.log`.

## What was tested

Tested in the game with UE4SS v3.0.1 Beta:

- Release build 1.0.0 (2026-10-15): the panel appeared on the first hover every time the inventory was reopened. No crash and no mod errors.
- A development build with the same fix plus diagnostic logging (2026-10-08): over five inventory opens in one session it logged the leftover flag on every open after the first, and the panel appeared every time.
- Container and barter menus: the bug does not occur there even without the mod, so there is nothing to fix. The mod only acts when an inventory menu is created.

Not tested:

- Gamepad navigation.
- Other UE4SS versions.

Known issue: moving the cursor very quickly across item rows for several seconds drops the frame rate (in one test from about 150 to 100 FPS). The mod runs no code on hover, so this is most likely the game rebuilding the effects panel for every item the cursor passes. This is not confirmed: in the comparison run without the mod the effects panel was not on screen, so the two runs are not equivalent.

## Building the archive

```
python build_release.py
```

writes `dist/InventoryEffectsPanelFix-<version>.zip`. The version comes from the header of `Scripts/main.lua`.

## License

[MIT](LICENSE). The mod contains no game assets and no third-party code. It is not affiliated with Bethesda Softworks or the UE4SS project.

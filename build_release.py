"""Build the release archive for Inventory Effects Panel Fix.

The zip extracts into the game root: the mod lands in
OblivionRemastered/Binaries/Win64/ue4ss/Mods/InventoryEffectsPanelFix.

Usage: python build_release.py
"""

import re
import sys
import zipfile
from pathlib import Path

MOD_NAME = "InventoryEffectsPanelFix"
GAME_MODS_DIR = "OblivionRemastered/Binaries/Win64/ue4ss/Mods"

ROOT = Path(__file__).resolve().parent
MOD_DIR = ROOT / "mods" / MOD_NAME
DIST_DIR = ROOT / "dist"


def read_version() -> str:
    source = (MOD_DIR / "Scripts" / "main.lua").read_text(encoding="utf-8")
    match = re.search(r"^-- Inventory Effects Panel Fix (\d+\.\d+\.\d+)$", source, re.MULTILINE)
    if not match:
        sys.exit("main.lua: version line not found in the header comment")
    version = match.group(1)
    if f'log("{version} loaded")' not in source:
        sys.exit(f"main.lua: the load message does not say {version}")
    return version


def main() -> None:
    version = read_version()
    files = sorted(path for path in MOD_DIR.rglob("*") if path.is_file())
    if not (MOD_DIR / "enabled.txt").is_file():
        sys.exit("enabled.txt is missing: UE4SS would not start the mod")

    DIST_DIR.mkdir(exist_ok=True)
    archive = DIST_DIR / f"{MOD_NAME}-{version}.zip"
    with zipfile.ZipFile(archive, "w", zipfile.ZIP_DEFLATED) as zf:
        for path in files:
            arcname = f"{GAME_MODS_DIR}/{MOD_NAME}/{path.relative_to(MOD_DIR).as_posix()}"
            zf.write(path, arcname)
            print(f"  {arcname}")
    print(f"{archive.relative_to(ROOT)}  ({archive.stat().st_size} bytes)")


if __name__ == "__main__":
    main()

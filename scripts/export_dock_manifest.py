from pathlib import Path
from typing import Optional
import plistlib
import sys
from urllib.parse import unquote


OPTIONAL_APPS = {
    "/Applications/Brave Browser.app",
    "/Applications/Slack.app",
    "/Applications/iTerm.app",
    "/Applications/Xcode.app",
}


def normalize_path(url: str) -> str:
    path = unquote(url.removeprefix("file://")).rstrip("/") or "/"
    home = str(Path.home())
    if path.startswith(f"{home}/"):
        return f"~{path[len(home):]}"
    return path


def app_condition(path: str) -> str:
    return "if-installed" if path in OPTIONAL_APPS else "always"


def extract_path(item: dict) -> Optional[str]:
    file_data = item.get("tile-data", {}).get("file-data", {})
    url = file_data.get("_CFURLString")
    if not url:
        return None
    return normalize_path(url)


def main() -> int:
    plist_path = Path(sys.argv[1])
    manifest_path = Path(sys.argv[2])

    with plist_path.open("rb") as fp:
        dock = plistlib.load(fp)

    lines = ["section\ttype\tcondition\tpath\tarrangement\tdisplayas\tshowas"]

    for item in dock.get("persistent-apps", []):
        if item.get("tile-type") != "file-tile":
            continue
        path = extract_path(item)
        if not path or not path.endswith(".app"):
            continue
        lines.append(f"apps\tapp\t{app_condition(path)}\t{path}")

    for item in dock.get("persistent-others", []):
        if item.get("tile-type") != "directory-tile":
            continue
        path = extract_path(item)
        if not path:
            continue
        tile_data = item.get("tile-data", {})
        arrangement = tile_data.get("arrangement", "")
        displayas = tile_data.get("displayas", "")
        showas = tile_data.get("showas", "")
        lines.append(f"others\tfolder\talways\t{path}\t{arrangement}\t{displayas}\t{showas}")

    manifest_path.write_text("\n".join(lines) + "\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

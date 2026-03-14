#!/usr/bin/env python3
"""Install dotfiles by creating symlinks."""

import argparse
import os
import platform
import sys
from pathlib import Path

MIN_PYTHON = (3, 9)

if sys.version_info < MIN_PYTHON:
    sys.exit(f"Python {'.'.join(str(v) for v in MIN_PYTHON)}+ required (current: {platform.python_version()})")


def is_windows() -> bool:
    return platform.system() == "Windows"


REPO = Path(__file__).parent.resolve()


def get_platform_dirs() -> dict[str, Path]:
    if is_windows():
        return {
            "home": Path(os.environ["USERPROFILE"]),
            "local_app_data": Path(os.environ["LOCALAPPDATA"]),
            "app_data": Path(os.environ["APPDATA"]),
        }
    home = Path.home()
    return {
        "home": home,
        "xdg_config": home / ".config",
    }


def get_links(dirs: dict[str, Path]) -> list[tuple[Path, Path]]:
    home = dirs["home"]
    common = [
        (REPO / ".wezterm.lua", home / ".wezterm.lua"),
    ]

    if is_windows():
        return common + [
            (REPO / ".config" / "nvim",             dirs["local_app_data"] / "nvim"),
            (REPO / ".config" / "mpv" / "mpv.conf", dirs["app_data"] / "mpv" / "mpv.conf"),
        ]
    else:
        xdg = dirs["xdg_config"]
        return common + [
            (REPO / ".Xresources", home / ".Xresources"),
            (REPO / ".bashrc",     home / ".bashrc"),
            (REPO / ".tmux.conf",  home / ".tmux.conf"),
            (REPO / ".zshrc",      home / ".zshrc"),
            (REPO / ".config" / "nvim",             xdg / "nvim"),
            (REPO / ".config" / "mpv" / "mpv.conf", xdg / "mpv" / "mpv.conf"),
        ]


def create_link(src: Path, dst: Path, dry_run: bool) -> None:
    print(f"  {src}")
    print(f"    -> {dst}")
    if dry_run:
        return
    dst.parent.mkdir(parents=True, exist_ok=True)
    if dst.exists() or dst.is_symlink():
        if dst.is_dir() and not dst.is_symlink():
            print(f"    [skip] {dst} is a real directory — remove it manually to replace")
            return
        dst.unlink()
    try:
        os.symlink(src, dst, target_is_directory=src.is_dir())
    except OSError as e:
        if is_windows() and e.winerror == 1314:  # ERROR_PRIVILEGE_NOT_HELD
            sys.exit(
                "\nError: insufficient privileges to create symlinks.\n"
                "Enable Developer Mode or run as Administrator.\n"
                "  Settings > System > For developers > Developer Mode"
            )
        raise


def main() -> None:
    parser = argparse.ArgumentParser(description="Install dotfiles via symlinks.")
    parser.add_argument("--dry-run", action="store_true", help="Print links without creating them")
    parser.add_argument("-y", "--yes",  action="store_true", help="Skip confirmation prompt")
    args = parser.parse_args()

    dirs = get_platform_dirs()
    links = get_links(dirs)

    print(f"repo : {REPO}")
    print(f"home : {dirs['home']}")
    print(f"os   : {platform.system()}")
    if args.dry_run:
        print("[dry-run]")
    print()

    if not args.yes:
        response = input("Continue? [y/N]: ")
        if response.lower() != "y":
            print("Cancelled.")
            sys.exit(1)
        print()

    for src, dst in links:
        create_link(src, dst, args.dry_run)

    print("\nDone.")


if __name__ == "__main__":
    main()

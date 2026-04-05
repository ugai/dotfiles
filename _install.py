#!/usr/bin/env python3
"""Install dotfiles by creating symlinks."""

import argparse
import logging
import os
import platform
import sys
from dataclasses import dataclass
from functools import cache
from pathlib import Path

from _python_version import MIN_PYTHON

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO, format="%(message)s")

IS_WINDOWS = platform.system() == "Windows"
IS_MACOS = platform.system() == "Darwin"

if sys.version_info < MIN_PYTHON:
    sys.exit(
        f"Python {'.'.join(str(v) for v in MIN_PYTHON)}+ required (current: {platform.python_version()})"
    )

if IS_MACOS:
    sys.exit("macOS is not supported. Paths and plugins differ — configure manually.")


@cache
def get_repo_root() -> Path:
    return Path(__file__).parent.resolve()


@dataclass
class PlatformDirs:
    home: Path
    user_config: Path


@dataclass(kw_only=True)
class WindowsPlatformDirs(PlatformDirs):
    local_app_data: Path


def get_platform_dirs() -> WindowsPlatformDirs | PlatformDirs:
    if IS_WINDOWS:
        dirs = {
            "home": Path(os.environ["USERPROFILE"]),
            "user_config": Path(os.environ["APPDATA"]),  # AppData/Roaming
            "local_app_data": Path(os.environ["LOCALAPPDATA"]),  # AppData/Local
        }
        return WindowsPlatformDirs(**dirs)
    else:
        home = Path.home()
        dirs = {
            "home": home,
            "user_config": home / ".config",
        }
        return PlatformDirs(**dirs)


def get_link(src: Path, dst: Path, sub: Path | str | list[str]) -> tuple[Path, Path]:
    if isinstance(sub, list):
        sub = Path(*sub)
    return src / sub, dst / sub


def get_links(dirs: WindowsPlatformDirs | PlatformDirs) -> list[tuple[Path, Path]]:
    repo = get_repo_root()
    repo_config = repo / ".config"
    home = dirs.home

    common_links = [
        get_link(repo, home, ".wezterm.lua"),
        get_link(repo, home, [".claude", "statusline-command.sh"]),
        get_link(repo, home, ".npmrc"),
        get_link(repo_config, dirs.user_config, ["mpv", "mpv.conf"]),
        get_link(repo_config, dirs.user_config, ["uv", "uv.toml"]),
    ]

    if isinstance(dirs, WindowsPlatformDirs):
        platform_links = [
            get_link(repo_config, dirs.local_app_data, "nvim"),
        ]
    else:
        platform_links = [
            get_link(repo, home, ".Xresources"),
            get_link(repo, home, ".bashrc"),
            get_link(repo, home, ".tmux.conf"),
            get_link(repo, home, ".zshrc"),
            get_link(repo_config, dirs.user_config, "nvim"),
        ]

    return common_links + platform_links


def create_link(src: Path, dst: Path, dry_run: bool) -> None:
    logger.info(f"  {src}")
    logger.info(f"    -> {dst}")
    if dry_run:
        return
    dst.parent.mkdir(parents=True, exist_ok=True)
    if dst.exists() or dst.is_symlink():
        if dst.is_dir() and not dst.is_symlink():
            logger.info(
                f"    [skip] {dst} is a real directory — remove it manually to replace"
            )
            return
        dst.unlink()
    try:
        os.symlink(src, dst, target_is_directory=src.is_dir())
    except OSError as e:
        if IS_WINDOWS and e.winerror == 1314:  # ERROR_PRIVILEGE_NOT_HELD
            sys.exit(
                "\nError: insufficient privileges to create symlinks.\n"
                "Enable Developer Mode or run as Administrator.\n"
                "  Settings > System > For developers > Developer Mode"
            )
        raise


def main() -> None:
    parser = argparse.ArgumentParser(description="Install dotfiles via symlinks.")
    # fmt: off
    parser.add_argument("--dry-run", action="store_true", help="Print links without creating them")
    parser.add_argument("-y", "--yes", action="store_true", help="Skip confirmation prompt")
    # fmt: on
    args = parser.parse_args()

    dirs = get_platform_dirs()
    links = get_links(dirs)

    logger.info(f"repo : {get_repo_root()}")
    logger.info(f"home : {dirs.home}")
    logger.info(f"os   : {platform.system()}")

    if args.dry_run:
        logger.info("[dry-run]")

    if not args.yes:
        response = input("Continue? [y/N]: ")
        if response.lower() != "y":
            logger.info("Cancelled.")
            sys.exit(1)
        logger.info("")

    for src, dst in links:
        create_link(src, dst, args.dry_run)

    logger.info("\nDone.")


if __name__ == "__main__":
    main()

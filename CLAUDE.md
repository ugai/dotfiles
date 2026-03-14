# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal dotfiles for Linux and Windows. All logic lives in `install.py`; the shell scripts are thin launchers only.

## Install

```sh
./install.sh [--dry-run] [-y]   # Linux
.\install.ps1 [--dry-run] [-y]  # Windows
```

Requires Python 3.9+ or `uv` (preferred). macOS is intentionally unsupported.

## Architecture

- `install.py` — all logic: platform detection, path resolution, symlink creation
- `install.sh` / `install.ps1` — discover `uv` → `python3` → `python`, then exec `install.py`
- Symlink targets differ by OS:
  - Windows: nvim → `%LOCALAPPDATA%/nvim`, mpv → `%APPDATA%/mpv`
  - Linux: nvim/mpv → `~/.config/…`, plus standard home dotfiles

## Key constraints

- Windows symlinks require Developer Mode or Administrator
- Python version check and macOS guard run at module import time (top of `install.py`)
- All user-facing messages and code comments must be in English

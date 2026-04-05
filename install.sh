#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

find_python() {
    # Prefer uv if available
    if command -v uv &>/dev/null; then
        echo uv run
        return
    fi

    for cmd in python3 python; do
        if command -v "$cmd" &>/dev/null; then
            # Check minimum version (see _python_version.py)
            if "$cmd" "$SCRIPT_DIR/_python_version.py" 2>/dev/null; then
                echo "$cmd"
                return
            fi
        fi
    done

    echo "Error: Sufficient Python version not found. Install Python or uv and try again." >&2
    exit 1
}

PYTHON_CMD=($(find_python))
exec "${PYTHON_CMD[@]}" "$SCRIPT_DIR/_install.py" "$@"

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Resolved Python command (populated by find_python)
PYTHON_CMD=()

find_python() {
    # Prefer uv if available
    if command -v uv &>/dev/null; then
        PYTHON_CMD=("uv" "run")
        return
    fi

    for cmd in python3 python; do
        if command -v "$cmd" &>/dev/null; then
            # Require Python 3.9+
            if "$cmd" -c "import sys; sys.exit(0 if sys.version_info >= (3, 9) else 1)" 2>/dev/null; then
                PYTHON_CMD=("$cmd")
                return
            fi
        fi
    done

    echo "Error: Python 3.9+ not found. Install Python or uv and try again." >&2
    exit 1
}

find_python
exec "${PYTHON_CMD[@]}" "$SCRIPT_DIR/install.py" "$@"

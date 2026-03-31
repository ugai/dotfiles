$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Find-Python {
    # Prefer uv if available; return $null as a sentinel
    if (Get-Command uv -ErrorAction SilentlyContinue) {
        return $null
    }

    # Try py launcher (Windows), then python3, then python
    foreach ($cmd in @("py", "python3", "python")) {
        if (Get-Command $cmd -ErrorAction SilentlyContinue) {
            & $cmd -c "import sys; sys.exit(0 if sys.version_info >= (3, 9) else 1)" 2>$null
            if ($LASTEXITCODE -eq 0) {
                return $cmd
            }
        }
    }

    Write-Error "Python 3.9+ not found. Install Python or uv and try again."
    exit 1
}

$python = Find-Python

if ($null -eq $python) {
    & uv run "$ScriptDir\_install.py" @args
} else {
    & $python "$ScriptDir\_install.py" @args
}

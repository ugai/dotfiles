$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Find-Python {
    # Prefer uv if available
    if (Get-Command uv -ErrorAction SilentlyContinue) {
        return @("uv", "run")
    }

    # Try py launcher (Windows), then python3, then python
    foreach ($cmd in @("py", "python3", "python")) {
        if (Get-Command $cmd -ErrorAction SilentlyContinue) {
            & $cmd "$ScriptDir\_python_version.py" 2>$null
            if ($LASTEXITCODE -eq 0) {
                return @($cmd)
            }
        }
    }

    Write-Error "Sufficient Python version not found. Install Python or uv and try again."
    exit 1
}

$PythonCmd = Find-Python
& $PythonCmd[0] ($PythonCmd[1..($PythonCmd.Length)] + "$ScriptDir\_install.py") @args

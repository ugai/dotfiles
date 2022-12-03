set BAT_DIR=%~dp0

set NVIM_DIR=%LOCALAPPDATA%/nvim
if not exist "%NVIM_DIR%" mkdir "%NVIM_DIR%"
mklink "%NVIM_DIR%/init.vim" "%BAT_DIR%.config\nvim\init.vim"

set MPV_DIR=%APPDATA%/mpv
if not exist "%MPV_DIR%" mkdir "%MPV_DIR%"
mklink "%MPV_DIR%/mpv.conf" "%BAT_DIR%.config\mpv\mpv.conf"
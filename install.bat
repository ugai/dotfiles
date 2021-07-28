set BAT_DIR=%~dp0
set NVIM_DIR=%LOCALAPPDATA%/nvim
set NVIM_PATH=%NVIM_DIR%/init.vim

if not exist "%NVIM_DIR%" mkdir "%NVIM_DIR%"

mklink "%NVIM_PATH%" "%BAT_DIR%.config\nvim\init.vim"
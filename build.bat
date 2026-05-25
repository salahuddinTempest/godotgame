@echo off
setlocal enabledelayedexpansion

:: Royal Era: Kingdom Chronicles — Build Script
:: Auto-locates Godot and exports Windows Desktop release
:: See CLAUDE.md §3

echo Searching for Godot executable...

set "GODOT_PATH="

:: Search common drives
for %%d in (C D E) do (
    if exist "%%d:\Program Files\Godot\Godot_v*win64.exe" (
        for /f "delims=" %%f in ('dir /b /o-d "%%d:\Program Files\Godot\Godot_v*win64.exe" 2^>nul') do (
            set "GODOT_PATH=%%d:\Program Files\Godot\%%f"
            goto :found
        )
    )
    if exist "%%d:\Games\Godot\Godot_v*win64.exe" (
        for /f "delims=" %%f in ('dir /b /o-d "%%d:\Games\Godot\Godot_v*win64.exe" 2^>nul') do (
            set "GODOT_PATH=%%d:\Games\Godot\%%f"
            goto :found
        )
    )
    if exist "%%d:\godot\Godot_v*win64.exe" (
        for /f "delims=" %%f in ('dir /b /o-d "%%d:\godot\Godot_v*win64.exe" 2^>nul') do (
            set "GODOT_PATH=%%d:\godot\%%f"
            goto :found
        )
    )
)

:found
if "!GODOT_PATH!"=="" (
    echo ERROR: Godot executable not found in C:\, D:\, or E:\
    echo Please install Godot 4.x and place it in:
    echo   - C:\Program Files\Godot\
    echo   - D:\Games\Godot\
    echo   - or E:\godot\
    pause
    exit /b 1
)

echo Found: !GODOT_PATH!

:: Ensure build directory exists
if not exist "build" mkdir "build"

echo Exporting Windows Desktop release...
"!GODOT_PATH!" --export-release "Windows Desktop" "build\windows_release.exe"

if %errorlevel% equ 0 (
    echo.
    echo SUCCESS: build\windows_release.exe created.
    echo Next: Test with "build\windows_release.exe"
) else (
    echo.
    echo ERROR: Export failed. Check Godot project.godot and export preset.
)

pause
@echo off
setlocal enabledelayedexpansion
title CRACK12 — ENV CHECK

:: ============================================================
::  ANSI COLORS
:: ============================================================
set "ESC="
for /f "delims=" %%a in ('powershell -Command "[char]27"') do set "ESC=%%a"
set "C_RESET=%ESC%[0m"
set "C_GREEN=%ESC%[92m"
set "C_RED=%ESC%[91m"
set "C_YELLOW=%ESC%[93m"
set "C_CYAN=%ESC%[96m"
set "C_WHITE=%ESC%[97m"
set "C_GRAY=%ESC%[90m"

set PASS=0
set FAIL=0

goto :MAIN

:: ============================================================
::  HELPERS
:: ============================================================
:OK
echo %C_GREEN%  [PASS]%C_RESET%  %~1
set /a PASS+=1
goto :EOF

:FAIL
echo %C_RED%  [FAIL]%C_RESET%  %~1
set /a FAIL+=1
goto :EOF

:WARN
echo %C_YELLOW%  [WARN]%C_RESET%  %~1
goto :EOF

:INFO
echo %C_CYAN%  [INFO]%C_RESET%  %~1
goto :EOF

:STEP
echo.
echo %C_WHITE%  ^>^> %~1%C_RESET%
echo.
goto :EOF

:DIVIDER
echo %C_GRAY%  ---------------------------------------------%C_RESET%
goto :EOF

:: ============================================================
::  BANNER
:: ============================================================
:BANNER
cls
echo.
echo %C_CYAN%   ██████╗██████╗  █████╗  ██████╗██╗  ██╗ ██╗██████╗ %C_RESET%
echo %C_CYAN%  ██╔════╝██╔══██╗██╔══██╗██╔════╝██║ ██╔╝███║╚════██╗%C_RESET%
echo %C_CYAN%  ██║     ██████╔╝███████║██║     █████╔╝ ╚██║ █████╔╝%C_RESET%
echo %C_CYAN%  ██║     ██╔══██╗██╔══██║██║     ██╔═██╗  ██║██╔═══╝ %C_RESET%
echo %C_CYAN%  ╚██████╗██║  ██║██║  ██║╚██████╗██║  ██╗ ██║███████╗%C_RESET%
echo %C_CYAN%   ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝ ╚═╝╚══════╝%C_RESET%
echo.
echo %C_GRAY%   environment verification — run this before anything else%C_RESET%
echo %C_GRAY%   -------------------------------------------------%C_RESET%
echo.
goto :EOF

:: ============================================================
::  CHECKS
:: ============================================================

:CHECK_TOOLS
call :STEP "TOOL CHECK"

:: adb
where adb >nul 2>&1
if %errorlevel% equ 0 (
    for /f "delims=" %%v in ('adb version 2^>nul ^| findstr "Android Debug"') do call :OK "adb found — %%v"
) else (
    call :FAIL "adb not found — add platform-tools to PATH"
    call :INFO "download: developer.android.com/tools/releases/platform-tools"
)

:: fastboot
where fastboot >nul 2>&1
if %errorlevel% equ 0 (
    for /f "delims=" %%v in ('fastboot --version 2^>nul ^| findstr "fastboot version"') do call :OK "fastboot found — %%v"
) else (
    call :FAIL "fastboot not found — add platform-tools to PATH"
)

:: git
where git >nul 2>&1
if %errorlevel% equ 0 (
    for /f "delims=" %%v in ('git --version 2^>nul') do call :OK "git found — %%v"
) else (
    call :WARN "git not found — not required to root but needed to contribute"
    call :INFO "download: git-scm.com/download/win"
)

goto :EOF

:: ============================================================

:CHECK_FOLDERS
call :STEP "FOLDER STRUCTURE CHECK"

set "BASE=C:\P12"

for %%d in (
    "%BASE%"
    "%BASE%\unlock\unlocker"
    "%BASE%\firmware"
    "%BASE%\magisk"
    "%BASE%\backup"
    "%BASE%\sprd_driver"
    "%BASE%\scripts"
) do (
    if exist "%%~d" (
        call :OK "found %%~d"
    ) else (
        call :FAIL "missing %%~d"
    )
)

goto :EOF

:: ============================================================

:CHECK_UNLOCK_TOOLS
call :STEP "UNLOCK TOOLS CHECK"

set "UDIR=C:\P12\unlock\unlocker"

for %%f in (
    "unlock_autopatch_9230.bat"
    "spd_dump.exe"
    "fdl1-dl.bin"
    "fdl2-dl.bin"
    "fdl2-cboot.bin"
) do (
    if exist "%UDIR%\%%~f" (
        call :OK "%%~f"
    ) else (
        call :FAIL "%%~f not found in %UDIR%"
    )
)

goto :EOF

:: ============================================================

:CHECK_MAGISK
call :STEP "MAGISK CHECK"

if exist "C:\P12\magisk\magisk.apk" (
    call :OK "magisk.apk found"
) else (
    call :FAIL "magisk.apk not found at C:\P12\magisk\magisk.apk"
    call :INFO "download: github.com/topjohnwu/Magisk/releases"
)

for /f "tokens=*" %%f in ('dir /b "C:\P12\magisk\magisk_patched_*.img" 2^>nul') do (
    call :OK "patched image found: %%f"
)

if exist "C:\P12\firmware\boot.bin" (
    call :OK "boot.bin found"
) else (
    call :WARN "boot.bin not found — will be pulled from device during rooting"
)

goto :EOF

:: ============================================================

:CHECK_DEVICE
call :STEP "DEVICE CHECK"

for /f "skip=1 tokens=1,2" %%a in ('adb devices 2^>nul') do (
    if "%%b"=="device" (
        call :OK "device connected: %%a"
        for /f "delims=" %%m in ('adb shell getprop ro.product.model 2^>nul') do call :INFO "model   : %%m"
        for /f "delims=" %%c in ('adb shell getprop ro.board.platform 2^>nul') do (
            call :INFO "chip    : %%c"
            echo %%c | findstr /i "ums9230" >nul
            if !errorlevel! equ 0 (
                call :OK "chip is UMS9230 — compatible"
            ) else (
                call :WARN "chip is %%c — not UMS9230, may not be compatible"
            )
        )
        for /f "delims=" %%s in ('adb shell getprop ro.boot.slot_suffix 2^>nul') do call :INFO "slot    : %%s"
        for /f "delims=" %%v in ('adb shell getprop ro.build.version.release 2^>nul') do call :INFO "android : %%v"
    )
    if "%%b"=="unauthorized" (
        call :FAIL "device unauthorized — check tablet for USB debugging prompt"
    )
    if "%%b"=="offline" (
        call :FAIL "device offline — try unplugging and replugging"
    )
)

if "%DEVICE_SERIAL%"=="" (
    call :WARN "no device detected — connect tablet via USB with debugging enabled"
)

goto :EOF

:: ============================================================
::  SUMMARY
:: ============================================================
:SUMMARY
echo.
call :DIVIDER
echo.
echo   %C_WHITE%RESULTS%C_RESET%
echo.
echo   %C_GREEN%passed : %PASS%%C_RESET%
if %FAIL% gtr 0 (
    echo   %C_RED%failed : %FAIL%%C_RESET%
    echo.
    echo   %C_YELLOW%  fix the failed items above before running the root script%C_RESET%
) else (
    echo   %C_GREEN%failed : 0%C_RESET%
    echo.
    echo   %C_GREEN%  all checks passed — you are good to run p12_autoroot.bat%C_RESET%
)
echo.
call :DIVIDER
echo.
echo %C_GRAY%  press any key to exit...%C_RESET%
pause >nul
exit
goto :EOF

:: ============================================================
::  MAIN
:: ============================================================
:MAIN
call :BANNER
call :CHECK_TOOLS
call :CHECK_FOLDERS
call :CHECK_UNLOCK_TOOLS
call :CHECK_MAGISK
call :CHECK_DEVICE
call :SUMMARY

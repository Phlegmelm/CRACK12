@echo off
setlocal enabledelayedexpansion
title P12 ROOT TOOLKIT

:: ============================================================
::  COLOR CODES
::  Uses ANSI via PowerShell echo trick for Windows 10+
:: ============================================================
set "ESC="
for /f "delims=" %%a in ('powershell -Command "[char]27"') do set "ESC=%%a"

set "C_RESET=%ESC%[0m"
set "C_DIM=%ESC%[2m"
set "C_GREEN=%ESC%[92m"
set "C_RED=%ESC%[91m"
set "C_YELLOW=%ESC%[93m"
set "C_CYAN=%ESC%[96m"
set "C_WHITE=%ESC%[97m"
set "C_GRAY=%ESC%[90m"

:: Log file
set "LOGFILE=p12_root_log.txt"
echo P12 ROOT TOOLKIT - %date% %time% > %LOGFILE%
echo ============================================ >> %LOGFILE%

goto :MAIN

:: ============================================================
::  HELPERS
:: ============================================================

:LOG
echo %~1 >> %LOGFILE%
goto :EOF

:PRINT
echo %C_GRAY%  %~1%C_RESET%
call :LOG "%~1"
goto :EOF

:OK
echo %C_GREEN%  [OK]%C_RESET%  %~1
call :LOG "[OK] %~1"
goto :EOF

:WARN
echo %C_YELLOW%  [!!]%C_RESET%  %~1
call :LOG "[WARN] %~1"
goto :EOF

:FAIL
echo %C_RED%  [XX]%C_RESET%  %~1
call :LOG "[FAIL] %~1"
goto :EOF

:INFO
echo %C_CYAN%  [--]%C_RESET%  %~1
call :LOG "[INFO] %~1"
goto :EOF

:STEP
echo.
echo %C_WHITE%  ^>^> %~1%C_RESET%
call :LOG ">> %~1"
goto :EOF

:DIVIDER
echo %C_GRAY%  ---------------------------------------------%C_RESET%
goto :EOF

:WAIT_KEY
echo.
echo %C_DIM%      press any key to continue...%C_RESET%
pause >nul
goto :EOF

:: ============================================================
::  BANNER
:: ============================================================
:BANNER
cls
echo.
echo %C_CYAN%      ██████╗  ██╗██████╗     ██████╗  ██████╗  ██████╗ ████████╗%C_RESET%
echo %C_CYAN%      ██╔══██╗███║╚════██╗    ██╔══██╗██╔═══██╗██╔═══██╗╚══██╔══╝%C_RESET%
echo %C_CYAN%      ██████╔╝╚██║ █████╔╝    ██████╔╝██║   ██║██║   ██║   ██║   %C_RESET%
echo %C_CYAN%      ██╔═══╝  ██║██╔═══╝     ██╔══██╗██║   ██║██║   ██║   ██║   %C_RESET%
echo %C_CYAN%      ██║      ██║███████╗    ██║  ██║╚██████╔╝╚██████╔╝   ██║   %C_RESET%
echo %C_CYAN%      ╚═╝      ╚═╝╚══════╝    ╚═╝  ╚═╝ ╚═════╝  ╚═════╝    ╚═╝   %C_RESET%
echo.
echo %C_GRAY%      ATOZEE P12 ^| UMS9230 ^| Android 14 ^| Magisk 30.7%C_RESET%
echo %C_GRAY%      -------------------------------------------------%C_RESET%
echo.
goto :EOF

:: ============================================================
::  MENU
:: ============================================================
:MENU
call :BANNER
echo      %C_WHITE%WHAT DO YOU WANT TO DO?%C_RESET%
echo.
echo      %C_CYAN%[1]%C_RESET%  Check device connection
echo      %C_CYAN%[2]%C_RESET%  Debloat tablet
echo      %C_CYAN%[3]%C_RESET%  Install APK
echo      %C_CYAN%[4]%C_RESET%  Push file to tablet
echo      %C_CYAN%[5]%C_RESET%  Pull file from tablet
echo      %C_CYAN%[6]%C_RESET%  Reboot options
echo      %C_CYAN%[7]%C_RESET%  Root check
echo      %C_CYAN%[8]%C_RESET%  View log
echo      %C_CYAN%[0]%C_RESET%  Exit
echo.
set /p CHOICE="      choice: "
echo.

if "%CHOICE%"=="1" goto :CHECK_DEVICE
if "%CHOICE%"=="2" goto :DEBLOAT
if "%CHOICE%"=="3" goto :INSTALL_APK
if "%CHOICE%"=="4" goto :PUSH_FILE
if "%CHOICE%"=="5" goto :PULL_FILE
if "%CHOICE%"=="6" goto :REBOOT_MENU
if "%CHOICE%"=="7" goto :ROOT_CHECK
if "%CHOICE%"=="8" goto :VIEW_LOG
if "%CHOICE%"=="0" goto :EXIT
goto :MENU

:: ============================================================
::  1. CHECK DEVICE
:: ============================================================
:CHECK_DEVICE
call :BANNER
call :STEP "DEVICE CONNECTION CHECK"
call :DIVIDER

call :PRINT "scanning for adb devices..."
adb devices >> %LOGFILE% 2>&1

for /f "skip=1 tokens=1,2" %%a in ('adb devices') do (
    if "%%b"=="device" (
        call :OK "device found: %%a"
        set DEVICE_SERIAL=%%a
    )
    if "%%b"=="unauthorized" (
        call :WARN "device found but unauthorized -- check tablet for USB prompt"
    )
    if "%%b"=="offline" (
        call :FAIL "device offline -- try unplugging and replugging"
    )
)

if "%DEVICE_SERIAL%"=="" (
    call :FAIL "no device detected"
    call :INFO "make sure USB debugging is enabled"
    call :INFO "try a different USB cable or port"
) else (
    call :DIVIDER
    call :PRINT "fetching device info..."
    for /f "delims=" %%a in ('adb shell getprop ro.product.model 2^>nul') do call :INFO "model   : %%a"
    for /f "delims=" %%a in ('adb shell getprop ro.build.version.release 2^>nul') do call :INFO "android : %%a"
    for /f "delims=" %%a in ('adb shell getprop ro.board.platform 2^>nul') do call :INFO "chip    : %%a"
    for /f "delims=" %%a in ('adb shell getprop ro.boot.slot_suffix 2^>nul') do call :INFO "slot    : %%a"
)

call :WAIT_KEY
goto :MENU

:: ============================================================
::  2. DEBLOAT
:: ============================================================
:DEBLOAT
call :BANNER
call :STEP "DEBLOAT"
call :DIVIDER
call :WARN "this will uninstall the following packages for all users"
echo.
echo      %C_GRAY%google tachyon, wellbeing, yt music, videos, keep,%C_RESET%
echo      %C_GRAY%calendar, deskclock, maps, docs, photos, gmail,%C_RESET%
echo      %C_GRAY%talkback, assistant, photo dreams, easter egg,%C_RESET%
echo      %C_GRAY%fm radio, sound recorder, incar apps, turbo,%C_RESET%
echo      %C_GRAY%youtube, guanhongpcb, multimediacopy, incartools%C_RESET%
echo.
call :DIVIDER
set /p CONFIRM="      type YES to continue: "
if /i not "%CONFIRM%"=="YES" (
    call :WARN "aborted"
    call :WAIT_KEY
    goto :MENU
)

echo.
call :PRINT "starting debloat..."
echo.

set PACKAGES=^
com.google.android.apps.tachyon ^
com.google.android.apps.wellbeing ^
com.google.android.apps.youtube.music ^
com.google.android.videos ^
com.google.android.keep ^
com.google.android.calendar ^
com.google.android.deskclock ^
com.google.android.apps.maps ^
com.google.android.apps.docs ^
com.google.android.apps.photos ^
com.google.android.gm ^
com.google.android.marvin.talkback ^
com.google.android.apps.googleassistant ^
com.android.dreams.phototable ^
com.android.egg ^
com.android.fmradio ^
com.android.soundrecorder ^
com.incar.usermanual ^
com.incar.update ^
com.google.android.apps.turbo ^
com.google.android.youtube ^
com.guanhong.guanhongpcb ^
com.lxj.multimediacopy ^
com.lxj.incartools ^
com.netflix.mediaclient

for %%p in (%PACKAGES%) do (
    adb shell pm uninstall -k --user 0 %%p >> %LOGFILE% 2>&1
    if !errorlevel! equ 0 (
        call :OK "removed %%p"
    ) else (
        call :WARN "skipped %%p"
    )
)

echo.
call :OK "debloat complete -- reboot recommended"
call :WAIT_KEY
goto :MENU

:: ============================================================
::  3. INSTALL APK
:: ============================================================
:INSTALL_APK
call :BANNER
call :STEP "INSTALL APK"
call :DIVIDER
echo.
set /p APK_PATH="      drag apk here or enter path: "
echo.

if not exist "%APK_PATH%" (
    call :FAIL "file not found: %APK_PATH%"
    call :WAIT_KEY
    goto :MENU
)

call :PRINT "installing %APK_PATH%..."
adb install "%APK_PATH%" >> %LOGFILE% 2>&1
if %errorlevel% equ 0 (
    call :OK "installed successfully"
) else (
    call :FAIL "install failed -- check log for details"
)

call :WAIT_KEY
goto :MENU

:: ============================================================
::  4. PUSH FILE
:: ============================================================
:PUSH_FILE
call :BANNER
call :STEP "PUSH FILE TO TABLET"
call :DIVIDER
echo.
set /p PUSH_SRC="      source file: "
set /p PUSH_DST="      destination (e.g. /sdcard/): "
echo.

if not exist "%PUSH_SRC%" (
    call :FAIL "source file not found"
    call :WAIT_KEY
    goto :MENU
)

call :PRINT "pushing file..."
adb push "%PUSH_SRC%" "%PUSH_DST%" >> %LOGFILE% 2>&1
if %errorlevel% equ 0 (
    call :OK "file pushed successfully"
) else (
    call :FAIL "push failed -- check log"
)

call :WAIT_KEY
goto :MENU

:: ============================================================
::  5. PULL FILE
:: ============================================================
:PULL_FILE
call :BANNER
call :STEP "PULL FILE FROM TABLET"
call :DIVIDER
echo.
set /p PULL_SRC="      source on tablet (e.g. /sdcard/file.zip): "
set /p PULL_DST="      destination on PC (e.g. C:\P12\): "
echo.

call :PRINT "pulling file..."
adb pull "%PULL_SRC%" "%PULL_DST%" >> %LOGFILE% 2>&1
if %errorlevel% equ 0 (
    call :OK "file pulled successfully"
) else (
    call :FAIL "pull failed -- check log"
)

call :WAIT_KEY
goto :MENU

:: ============================================================
::  6. REBOOT OPTIONS
:: ============================================================
:REBOOT_MENU
call :BANNER
call :STEP "REBOOT OPTIONS"
call :DIVIDER
echo.
echo      %C_CYAN%[1]%C_RESET%  reboot normally
echo      %C_CYAN%[2]%C_RESET%  reboot to bootloader
echo      %C_CYAN%[3]%C_RESET%  reboot to recovery
echo      %C_CYAN%[4]%C_RESET%  back
echo.
set /p REBOOT_CHOICE="      choice: "
echo.

if "%REBOOT_CHOICE%"=="1" (
    call :PRINT "rebooting..."
    adb reboot >> %LOGFILE% 2>&1
    call :OK "reboot command sent"
)
if "%REBOOT_CHOICE%"=="2" (
    call :PRINT "rebooting to bootloader..."
    adb reboot bootloader >> %LOGFILE% 2>&1
    call :OK "reboot command sent"
)
if "%REBOOT_CHOICE%"=="3" (
    call :PRINT "rebooting to recovery..."
    adb reboot recovery >> %LOGFILE% 2>&1
    call :OK "reboot command sent"
)
if "%REBOOT_CHOICE%"=="4" goto :MENU

call :WAIT_KEY
goto :MENU

:: ============================================================
::  7. ROOT CHECK
:: ============================================================
:ROOT_CHECK
call :BANNER
call :STEP "ROOT CHECK"
call :DIVIDER
echo.
call :PRINT "running: adb shell su -c whoami"
echo.

for /f "delims=" %%a in ('adb shell su -c "whoami" 2^>nul') do set ROOT_RESULT=%%a

if "%ROOT_RESULT%"=="root" (
    call :OK "device is rooted -- whoami returned: root"
) else (
    call :FAIL "root check failed -- got: %ROOT_RESULT%"
    call :INFO "make sure you granted root access in the Magisk popup"
)

call :DIVIDER
call :PRINT "checking magisk..."
for /f "delims=" %%a in ('adb shell su -c "magisk -v" 2^>nul') do call :INFO "magisk version: %%a"

call :WAIT_KEY
goto :MENU

:: ============================================================
::  8. VIEW LOG
:: ============================================================
:VIEW_LOG
call :BANNER
call :STEP "SESSION LOG"
call :DIVIDER
echo.
type %LOGFILE%
echo.
call :WAIT_KEY
goto :MENU

:: ============================================================
::  EXIT
:: ============================================================
:EXIT
call :BANNER
echo      %C_GRAY%session log saved to: %LOGFILE%%C_RESET%
echo.
echo      %C_CYAN%later.%C_RESET%
echo.
timeout /t 2 /nobreak >nul
exit

:: ============================================================
::  MAIN ENTRY
:: ============================================================
:MAIN
goto :MENU

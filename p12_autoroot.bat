@echo off
setlocal enabledelayedexpansion
title P12 AUTOROOT

:: ============================================================
::  ANSI COLORS
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

:: ============================================================
::  PATHS — edit these if your folder layout differs
:: ============================================================
set "BASE=C:\P12"
set "UNLOCK_DIR=%BASE%\unlock\unlocker"
set "FIRMWARE_DIR=%BASE%\firmware"
set "MAGISK_DIR=%BASE%\magisk"
set "BACKUP_DIR=%BASE%\backup"
set "LOGFILE=%BASE%\autoroot_log.txt"
set "MAGISK_APK=%BASE%\magisk\magisk.apk"

echo P12 AUTOROOT - %date% %time% > %LOGFILE%
echo ============================================ >> %LOGFILE%

goto :MAIN

:: ============================================================
::  HELPERS
:: ============================================================
:LOG
echo %~1 >> %LOGFILE%
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

:PRINT
echo %C_GRAY%  %~1%C_RESET%
call :LOG "%~1"
goto :EOF

:STEP
echo.
echo %C_WHITE%  ^>^> %~1%C_RESET%
echo.
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

:ABORT
echo.
call :FAIL "ABORTED: %~1"
call :LOG "ABORTED: %~1"
call :WAIT_KEY
exit /b 1

:: ============================================================
::  BANNER
:: ============================================================
:BANNER
cls
echo.
echo %C_CYAN%      ██████╗  ██╗██████╗     ██████╗ ██╗   ██╗████████╗ ██████╗ ██████╗  ██████╗  ██████╗ ████████╗%C_RESET%
echo %C_CYAN%      ██╔══██╗███║╚════██╗    ██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗██╔══██╗██╔═══██╗██╔═══██╗╚══██╔══╝%C_RESET%
echo %C_CYAN%      ██████╔╝╚██║ █████╔╝    ███████║██║   ██║   ██║   ██║   ██║██████╔╝██║   ██║██║   ██║   ██║   %C_RESET%
echo %C_CYAN%      ██╔═══╝  ██║██╔═══╝     ██╔══██║██║   ██║   ██║   ██║   ██║██╔══██╗██║   ██║██║   ██║   ██║   %C_RESET%
echo %C_CYAN%      ██║      ██║███████╗    ██║  ██║╚██████╔╝   ██║   ╚██████╔╝██║  ██║╚██████╔╝╚██████╔╝   ██║   %C_RESET%
echo %C_CYAN%      ╚═╝      ╚═╝╚══════╝    ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝ ╚═╝  ╚═╝ ╚═════╝  ╚═════╝    ╚═╝   %C_RESET%
echo.
echo %C_GRAY%      ATOZEE P12 ^| UMS9230 ^| CVE-2022-38694 ^| Magisk%C_RESET%
echo %C_GRAY%      -------------------------------------------------%C_RESET%
echo.
goto :EOF

:: ============================================================
::  PHASE 0 — PREFLIGHT
:: ============================================================
:PREFLIGHT
call :STEP "PHASE 0 — PREFLIGHT CHECKS"
call :DIVIDER

:: Check folders exist
call :PRINT "checking folder structure..."
for %%d in ("%BASE%" "%UNLOCK_DIR%" "%FIRMWARE_DIR%" "%MAGISK_DIR%" "%BACKUP_DIR%") do (
    if not exist "%%~d" (
        mkdir "%%~d" >> %LOGFILE% 2>&1
        call :OK "created %%~d"
    ) else (
        call :OK "found %%~d"
    )
)

:: Check adb
call :PRINT "checking adb..."
adb version >> %LOGFILE% 2>&1
if %errorlevel% neq 0 (
    call :ABORT "adb not found -- add platform-tools to PATH"
)
call :OK "adb found"

:: Check fastboot
call :PRINT "checking fastboot..."
fastboot --version >> %LOGFILE% 2>&1
if %errorlevel% neq 0 (
    call :ABORT "fastboot not found -- add platform-tools to PATH"
)
call :OK "fastboot found"

:: Check unlock tools
call :PRINT "checking unlock tools..."
if not exist "%UNLOCK_DIR%\unlock_autopatch_9230.bat" (
    call :ABORT "unlock_autopatch_9230.bat not found in %UNLOCK_DIR%"
)
call :OK "unlock tools found"

:: Check Magisk APK
call :PRINT "checking magisk apk..."
if not exist "%MAGISK_APK%" (
    call :WARN "magisk.apk not found at %MAGISK_APK%"
    call :INFO "download from github.com/topjohnwu/Magisk/releases and place at %MAGISK_APK%"
    call :ABORT "magisk apk missing"
)
call :OK "magisk apk found"

call :DIVIDER
call :OK "preflight passed"
goto :EOF

:: ============================================================
::  PHASE 1 — DEVICE CHECK
:: ============================================================
:DEVICE_CHECK
call :STEP "PHASE 1 — DEVICE CHECK"
call :DIVIDER

call :PRINT "scanning for device..."
for /f "skip=1 tokens=1,2" %%a in ('adb devices') do (
    if "%%b"=="device" set DEVICE_SERIAL=%%a
    if "%%b"=="unauthorized" (
        call :ABORT "device unauthorized -- check tablet for USB debugging prompt"
    )
)

if "%DEVICE_SERIAL%"=="" (
    call :ABORT "no device found -- plug in via USB and enable USB debugging"
)
call :OK "device connected: %DEVICE_SERIAL%"

:: Grab device info
for /f "delims=" %%a in ('adb shell getprop ro.product.model 2^>nul') do set DEV_MODEL=%%a
for /f "delims=" %%a in ('adb shell getprop ro.board.platform 2^>nul') do set DEV_CHIP=%%a
for /f "delims=" %%a in ('adb shell getprop ro.boot.slot_suffix 2^>nul') do set DEV_SLOT=%%a
for /f "delims=" %%a in ('adb shell getprop ro.build.version.release 2^>nul') do set DEV_ANDROID=%%a

call :INFO "model   : %DEV_MODEL%"
call :INFO "chip    : %DEV_CHIP%"
call :INFO "android : %DEV_ANDROID%"
call :INFO "slot    : %DEV_SLOT%"

:: Confirm Unisoc
echo %DEV_CHIP% | findstr /i "ums9230" >nul
if %errorlevel% neq 0 (
    call :WARN "chip is not ums9230 -- this script is tuned for UMS9230"
    call :WARN "continue at your own risk"
    set /p CHIP_CONFIRM="      type YES to continue anyway: "
    if /i not "!CHIP_CONFIRM!"=="YES" call :ABORT "user cancelled"
)

:: Determine boot slot
if "%DEV_SLOT%"=="_b" (
    set BOOT_SLOT=boot_b
) else (
    set BOOT_SLOT=boot_a
)
call :INFO "will flash: %BOOT_SLOT%"

call :DIVIDER
call :OK "device check passed"
goto :EOF

:: ============================================================
::  PHASE 2 — BOOTLOADER UNLOCK
:: ============================================================
:BOOTLOADER_UNLOCK
call :STEP "PHASE 2 — BOOTLOADER UNLOCK"
call :DIVIDER
call :WARN "this will WIPE your device"
call :WARN "make sure you have backed up everything"
echo.
set /p BL_CONFIRM="      type YES to unlock bootloader: "
if /i not "%BL_CONFIRM%"=="YES" call :ABORT "user cancelled"

echo.
call :INFO "instructions:"
call :INFO "1. the script will open the unlocker"
call :INFO "2. it will say 'waiting to connect'"
call :INFO "3. power off your tablet"
call :INFO "4. hold VOLUME DOWN and plug in USB"
call :INFO "5. device manager will show unknown device"
call :INFO "6. quickly install SPRD driver for it"
call :INFO "7. script continues automatically"
call :INFO "8. tablet will wipe and reboot when done"
echo.
call :WARN "have device manager open before you plug in!"
call :WAIT_KEY

call :PRINT "launching unlock script..."
cd /d "%UNLOCK_DIR%"
call unlock_autopatch_9230.bat >> %LOGFILE% 2>&1
set BL_ERR=%errorlevel%
cd /d "%BASE%"

if %BL_ERR% neq 0 (
    call :WARN "unlock script returned error -- check if tablet shows unlocked message"
    call :WARN "if it wiped and rebooted it likely succeeded anyway"
) else (
    call :OK "unlock script completed"
)

:: Grab boot.bin if it exists
if exist "%UNLOCK_DIR%\boot.bin" (
    copy "%UNLOCK_DIR%\boot.bin" "%FIRMWARE_DIR%\boot.bin" >> %LOGFILE% 2>&1
    call :OK "boot.bin saved to %FIRMWARE_DIR%\boot.bin"
) else (
    call :WARN "boot.bin not found in unlocker folder -- you may need to extract it manually"
)

call :DIVIDER
call :INFO "tablet is wiping and rebooting -- wait for it to finish setup"
call :INFO "set it up offline (skip wifi/google account for now)"
call :WAIT_KEY
goto :EOF

:: ============================================================
::  PHASE 3 — INSTALL MAGISK + PATCH BOOT
:: ============================================================
:PATCH_BOOT
call :STEP "PHASE 3 — INSTALL MAGISK + PATCH BOOT IMAGE"
call :DIVIDER

:: Re-enable USB debugging after wipe
call :INFO "re-enable USB debugging on the tablet first:"
call :INFO "settings -> about tablet -> tap build number 7x"
call :INFO "settings -> developer options -> usb debugging ON"
call :WAIT_KEY

:: Wait for device
call :PRINT "waiting for device..."
adb wait-for-device >> %LOGFILE% 2>&1
call :OK "device connected"

:: Install Magisk
call :PRINT "installing magisk apk..."
adb install "%MAGISK_APK%" >> %LOGFILE% 2>&1
if %errorlevel% neq 0 (
    call :WARN "install failed -- trying with -r flag..."
    adb install -r "%MAGISK_APK%" >> %LOGFILE% 2>&1
)
call :OK "magisk installed"

:: Push boot.bin
if not exist "%FIRMWARE_DIR%\boot.bin" (
    call :ABORT "boot.bin not found at %FIRMWARE_DIR%\boot.bin -- cannot patch"
)

call :PRINT "pushing boot.bin to tablet..."
adb push "%FIRMWARE_DIR%\boot.bin" /sdcard/Download/boot.bin >> %LOGFILE% 2>&1
if %errorlevel% neq 0 call :ABORT "failed to push boot.bin"
call :OK "boot.bin pushed to /sdcard/Download/"

call :DIVIDER
call :INFO "now patch boot.bin manually on the tablet:"
call :INFO "1. open magisk"
call :INFO "2. tap install -> select and patch a file"
call :INFO "3. navigate to downloads and pick boot.bin"
call :INFO "4. wait for it to finish"
call :INFO "5. come back here and press any key"
call :WAIT_KEY

:: Pull patched image
call :PRINT "pulling patched boot image..."
for /f "delims=" %%f in ('adb shell ls /sdcard/Download/magisk_patched_*.img 2^>nul') do set PATCHED_REMOTE=%%f

if "%PATCHED_REMOTE%"=="" (
    call :ABORT "no magisk_patched_*.img found in /sdcard/Download/ -- did patching finish?"
)

call :INFO "found: %PATCHED_REMOTE%"
adb pull "%PATCHED_REMOTE%" "%MAGISK_DIR%\" >> %LOGFILE% 2>&1
if %errorlevel% neq 0 call :ABORT "failed to pull patched image"

:: Get filename
for /f "tokens=*" %%f in ('dir /b "%MAGISK_DIR%\magisk_patched_*.img" 2^>nul') do set PATCHED_LOCAL=%MAGISK_DIR%\%%f
call :OK "saved: %PATCHED_LOCAL%"

call :DIVIDER
call :OK "phase 3 complete"
goto :EOF

:: ============================================================
::  PHASE 4 — FLASH
:: ============================================================
:FLASH
call :STEP "PHASE 4 — FLASH PATCHED BOOT"
call :DIVIDER

call :PRINT "rebooting to bootloader..."
adb reboot bootloader >> %LOGFILE% 2>&1
call :INFO "waiting for fastboot..."
fastboot wait-for-device >> %LOGFILE% 2>&1
call :OK "device in fastboot"

call :PRINT "flashing patched boot to %BOOT_SLOT%..."
fastboot --disable-verity --disable-verification flash %BOOT_SLOT% "%PATCHED_LOCAL%" >> %LOGFILE% 2>&1
if %errorlevel% neq 0 call :ABORT "flash failed -- check log"
call :OK "boot flashed successfully"

call :PRINT "rebooting..."
fastboot reboot >> %LOGFILE% 2>&1
call :OK "reboot command sent"

call :DIVIDER
call :OK "flash complete"
goto :EOF

:: ============================================================
::  PHASE 5 — VERIFY
:: ============================================================
:VERIFY
call :STEP "PHASE 5 — VERIFY ROOT"
call :DIVIDER
call :INFO "waiting for device to boot..."
adb wait-for-device >> %LOGFILE% 2>&1

:: Give it a moment to fully boot
timeout /t 10 /nobreak >nul

call :PRINT "checking root..."
for /f "delims=" %%a in ('adb shell su -c "whoami" 2^>nul') do set ROOT_RESULT=%%a

if "%ROOT_RESULT%"=="root" (
    call :OK "ROOT CONFIRMED -- whoami returned: root"
) else (
    call :WARN "root check returned: %ROOT_RESULT%"
    call :WARN "open magisk and grant root if prompted, then re-run verify"
)

call :PRINT "checking magisk version..."
for /f "delims=" %%a in ('adb shell su -c "magisk -v" 2^>nul') do call :INFO "magisk: %%a"

call :DIVIDER
goto :EOF

:: ============================================================
::  MAIN
:: ============================================================
:MAIN
call :BANNER

echo      %C_WHITE%ATOZEE P12 AUTOMATED ROOT%C_RESET%
echo      %C_GRAY%CVE-2022-38694 + Magisk%C_RESET%
echo.
echo      %C_CYAN%[1]%C_RESET%  full auto root (all phases)
echo      %C_CYAN%[2]%C_RESET%  phase 0 -- preflight only
echo      %C_CYAN%[3]%C_RESET%  phase 1 -- device check only
echo      %C_CYAN%[4]%C_RESET%  phase 2 -- bootloader unlock only
echo      %C_CYAN%[5]%C_RESET%  phase 3 -- patch boot only
echo      %C_CYAN%[6]%C_RESET%  phase 4 -- flash only
echo      %C_CYAN%[7]%C_RESET%  phase 5 -- verify root only
echo      %C_CYAN%[0]%C_RESET%  exit
echo.
set /p MAIN_CHOICE="      choice: "
echo.

if "%MAIN_CHOICE%"=="0" goto :DONE
if "%MAIN_CHOICE%"=="2" ( call :PREFLIGHT & call :WAIT_KEY & goto :MAIN )
if "%MAIN_CHOICE%"=="3" ( call :PREFLIGHT & call :DEVICE_CHECK & call :WAIT_KEY & goto :MAIN )
if "%MAIN_CHOICE%"=="4" ( call :PREFLIGHT & call :DEVICE_CHECK & call :BOOTLOADER_UNLOCK & call :WAIT_KEY & goto :MAIN )
if "%MAIN_CHOICE%"=="5" ( call :PREFLIGHT & call :DEVICE_CHECK & call :PATCH_BOOT & call :WAIT_KEY & goto :MAIN )
if "%MAIN_CHOICE%"=="6" ( call :PREFLIGHT & call :DEVICE_CHECK & call :FLASH & call :WAIT_KEY & goto :MAIN )
if "%MAIN_CHOICE%"=="7" ( call :PREFLIGHT & call :DEVICE_CHECK & call :VERIFY & call :WAIT_KEY & goto :MAIN )

if "%MAIN_CHOICE%"=="1" (
    call :PREFLIGHT
    call :DEVICE_CHECK
    call :BOOTLOADER_UNLOCK
    call :PATCH_BOOT
    call :FLASH
    call :VERIFY
    echo.
    call :DIVIDER
    echo.
    echo      %C_GREEN%  ROOT COMPLETE%C_RESET%
    echo.
    call :INFO "log saved to: %LOGFILE%"
    call :WAIT_KEY
    goto :MAIN
)

goto :MAIN

:DONE
echo.
echo      %C_GRAY%log saved to: %LOGFILE%%C_RESET%
echo      %C_CYAN%later.%C_RESET%
echo.
timeout /t 2 /nobreak >nul
exit

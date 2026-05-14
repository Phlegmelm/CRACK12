# Required Downloads

These files are not included in this repo due to size or licensing.
Download each one and place it in the correct folder before running any scripts.

---

## 1. CVE-2022-38694 Unlock Tools
**Place in:** `unlock/unlocker/`

Download `ums9230_universal_unlock_EMMC.zip` from:
https://github.com/TomKing062/CVE-2022-38694_unlock_bootloader/releases

Extract the contents directly into `unlock/unlocker/`.

---

## 2. SPRD USB Driver
**Place in:** `sprd_driver/`

Download from:
https://androiddatahost.com/dsa6h

Extract and place the `Win10/Drivers/` folder contents into `sprd_driver/`.
This driver is needed for Unisoc download mode (when the device appears as unknown in Device Manager).

---

## 3. Google USB Driver
**For:** fastboot mode detection in Windows

Download from:
https://developer.android.com/studio/run/win-usb

Extract anywhere. Used only once to install the fastboot driver via Device Manager.

---

## 4. Android Platform Tools (adb + fastboot)
**Must be in PATH**

Download from:
https://developer.android.com/tools/releases/platform-tools

Extract and add the folder to your Windows PATH, or place `adb.exe` and `fastboot.exe`
in the same directory as the scripts.

---

## 5. Magisk APK
**Place at:** `magisk/magisk.apk`

Download the latest stable release from:
https://github.com/topjohnwu/Magisk/releases

Rename the downloaded `.apk` to `magisk.apk` and place it in the `magisk/` folder.

---

## 6. Shamiko (optional — root hiding)
**Install via Magisk after rooting**

Download from:
https://github.com/LSPosed/LSPosed.github.io/releases

Look for `shamiko-xxx-release.zip`. Install via Magisk → Modules → Install from storage.

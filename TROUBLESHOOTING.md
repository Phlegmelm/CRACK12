# Troubleshooting

Common issues and fixes encountered during the ATOZEE P12 rooting process.

---

## ADB / Fastboot

### `waiting for any device` in fastboot mode
Windows doesn't have the right driver for fastboot mode.
- Open Device Manager while device is in fastboot
- Look for "fastboot gadget" under Other Devices
- Right-click → Update Driver → Browse → point to Google USB Driver folder

### `adb devices` shows nothing
- Make sure USB Debugging is enabled (Settings → Developer Options)
- Try a different USB cable — many cables are charge-only
- Run `adb kill-server` then `adb start-server`

### Device shows as `unauthorized`
- Check the tablet screen for a USB debugging prompt and tap Allow
- If no prompt appears, go to Developer Options and revoke USB debugging authorizations, then reconnect

---

## Bootloader Unlock

### Script says `find port failed`
This is expected if the device disconnected. Close the script and re-run `unlock_autopatch_9230.bat`. Power off the tablet, hold Volume Down, and plug in again.

### Unknown device disappears too fast in Device Manager
The window to install the SPRD driver is very short — only a few seconds.
- Have Device Manager open and expanded before you plug in
- Right-click the unknown device the moment it appears
- If you miss it, unplug and try again — the script will time out and you re-run it

### `FDL2: incompatible partition`
This is normal output for this device — not an error. The script handles it automatically.

### Tablet stuck on bootloop after unlock
Hold Power for 15 seconds to force reboot. If it keeps bootlooping, re-run the unlock script — it may not have completed fully.

---

## Magisk / Root

### Magisk shows "Install" instead of version number after flashing
Magisk needs to do an additional setup step. Open Magisk and follow any prompts — it will ask to reboot once more.

### `adb shell su -c whoami` returns nothing or permission denied
- Open Magisk on the tablet — there may be a pending root grant popup
- Go to Magisk → Superuser and check if root requests are being blocked
- Make sure Magisk is fully installed (shows version number, not "Install")

### Google account won't add after rooting
Play Services detects the unlocked bootloader. Install Shamiko and enable DenyList:
1. Magisk → Modules → install Shamiko zip
2. Magisk → Settings → enable Zygisk (if not already on)
3. Magisk → Settings → enable Enforce DenyList
4. Magisk → DenyList → find Google Play Services → expand and check all items
5. Reboot and try adding the account again

---

## Boot Animation

### Boot animation not changing after Magisk module install
This device uses **erofs** on the `/product` partition which is a compressed read-only filesystem. It cannot be remounted as writable even with root. Magisk's magic mount system does not overlay `/product` on this device. This is a known limitation on Android 14 with erofs.

There is currently no working method to change the boot animation on this device without rebuilding the product partition image from scratch.

---

## vbmeta / Boot Warning

### "Your device is corrupt / Boot state: unlocked" warning on every boot
This warning appears because the bootloader is unlocked. It lasts approximately 5 seconds and disappears. It does not affect device functionality.

Attempting to flash a patched vbmeta via fastboot is risky on this device — a failed write can cause a boot loop. The device recovered on its own in testing but this is not guaranteed. The warning is cosmetic and best left alone.

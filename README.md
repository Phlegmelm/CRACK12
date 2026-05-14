# ATOZEE P12 — Root Guide & Project Log

> Android 14 · Unisoc UMS9230 · CVE-2022-38694 · Magisk 30.7

---

## Inspiration

This started as a simple question — can a cheap, no-name Android tablet be rooted? The ATOZEE P12 is a budget device with no community support, no official unlock path, and a manufacturer that clearly never intended it to be opened up. Every standard method failed. `fastboot oem unlock` returned "Unlock bootloader fail." `fastboot flashing unlock` returned "unknown cmd." The bootloader was locked tight.

But the chip told a different story.

Running `adb shell getprop ro.board.platform` revealed `ums9230` — a Unisoc T615 chipset. Unisoc devices were found to be vulnerable to **CVE-2022-38694**, a bootloader exploit discovered by [TomKing062](https://github.com/TomKing062/CVE-2022-38694_unlock_bootloader) that allows bootloader unlocking without manufacturer cooperation. That changed everything.

---

## Device Info

| Property | Value |
|---|---|
| Model | ATOZEE P12 |
| Chipset | Unisoc UMS9230 (T615) |
| Android | 14 |
| Build | UP1A.231005.007 |
| Storage | UFS |
| Partition scheme | Dynamic (A/B slots) |
| Active slot | `_a` |
| Filesystem | erofs (read-only) |

---

## Folder Structure

```
C:\P12\
├── unlock\
│   └── unlocker\          ← CVE-2022-38694 exploit tools
├── sprd_driver\           ← Unisoc/Spreadtrum USB driver
├── firmware\
│   └── boot.bin           ← stock boot image pulled from device
├── magisk\
│   ├── magisk.apk
│   └── magisk_patched_*.img  ← patched boot image
└── backup\                ← optional adb backups
```

---

## How We Did It — Step by Step

### Step 1 — Identify the device

Standard debloating and rooting starts with knowing what you're dealing with. We used `adb shell getprop` to pull device properties:

```
adb shell getprop ro.product.model       → P12
adb shell getprop ro.board.platform      → ums9230
adb shell getprop ro.build.fingerprint   → ATOZEE/P12/...
adb shell getprop ro.boot.slot_suffix    → _a
```

The Unisoc UMS9230 chipset identification was the key finding that made rooting possible.

---

### Step 2 — Try the standard unlock path (it failed)

Before going the exploit route we tried every standard fastboot unlock method:

```
fastboot flashing get_unlock_ability   → FAILED (Not implement.)
fastboot oem unlock                    → FAILED (Unlock bootloader fail.)
fastboot oem unlock-go                 → FAILED (unknown cmd.)
fastboot flashing unlock               → FAILED (unknown cmd.)
```

OEM Unlocking was already toggled on in Developer Options, but the bootloader rejected every command at the firmware level. This confirmed the manufacturer hardlocked it.

---

### Step 3 — Install the Windows fastboot driver

When the device entered fastboot mode, Windows couldn't communicate with it properly. Device Manager showed it as "fastboot gadget" under Other Devices with no driver.

Fix: downloaded the Google USB Driver, right-clicked "fastboot gadget" in Device Manager → Update Driver → pointed it to the extracted driver folder. After installing, `fastboot devices` showed the device correctly.

---

### Step 4 — CVE-2022-38694 bootloader unlock

Downloaded `ums9230_universal_unlock.zip` from [TomKing062's GitHub](https://github.com/TomKing062/CVE-2022-38694_unlock_bootloader/releases) and extracted it to `C:\P12\unlock\unlocker\`.

The exploit works by communicating with the Unisoc bootrom directly via the SPRD download protocol, patching the SPL (Secondary Program Loader) to remove the lock check, and reflashing it back.

**Process:**

1. Opened a command prompt in the unlocker folder
2. Ran `unlock_autopatch_9230.bat`
3. Script said "waiting to connect"
4. Powered off the tablet
5. Held Volume Down and plugged in USB
6. Device Manager showed an unknown device — quickly installed the SPRD driver for it
7. Script connected and ran automatically

**What the script did internally:**
- Connected via SPRD bootrom protocol
- Read the partition table (70 partitions on this device)
- Read `uboot_a` and `splloader`
- Erased `splloader` and `splloader_bak`
- Generated an unlocked SPL (`u-boot-spl-16k-sign.bin`)
- Flashed the unlocked SPL back
- Read `miscdata` to check lock flags
- Read `boot_a` — **this saved our stock boot image as `boot.bin`**
- Wrote unlocked `splloader`, `uboot_a`, and a wiped `misc` partition
- Device rebooted, showed "unlocked" message, and factory reset

The factory reset is expected and unavoidable — it's Android's security response to a bootloader state change.

---

### Step 5 — Set up after wipe

After the wipe, went through initial Android setup offline (no Google account yet — Play Services detects unlocked bootloaders and can block account login).

Re-enabled USB Debugging:
- Settings → About Tablet → tap Build Number 7×
- Developer Options → USB Debugging ON

---

### Step 6 — Patch the boot image with Magisk

The unlocker script conveniently dumped the stock `boot.bin` during the process. This saved us from having to hunt down firmware online.

Copied it to the PC:
```
boot.bin saved at: C:\P12\unlock\unlocker\boot.bin
→ copied to: C:\P12\firmware\boot.bin
```

Pushed it to the tablet:
```
adb push C:\P12\firmware\boot.bin /sdcard/Download/
```

Installed Magisk APK on the tablet, opened it, tapped **Install → Select and Patch a File**, picked `boot.bin`. Magisk produced `magisk_patched_30700_ajBNq.img` in Downloads.

Pulled it back to the PC:
```
adb pull /sdcard/Download/magisk_patched_30700_ajBNq.img C:\P12\magisk\
```

---

### Step 7 — Flash the patched boot image

Rebooted to bootloader:
```
adb reboot bootloader
```

Flashed the patched image to the active slot (`boot_a`):
```
fastboot --disable-verity --disable-verification flash boot_a "C:\P12\magisk\magisk_patched-30700_ajBNq.img"
```

Output:
```
Sending 'boot_a' (65536 KB)    OKAY [2.042s]
Writing 'boot_a'               OKAY [0.356s]
Finished. Total time: 2.432s
```

Rebooted:
```
fastboot reboot
```

---

### Step 8 — Verify root

After boot, Magisk showed **Installed 30.7 (30700)**. Confirmed via ADB:

```
adb shell su -c "whoami"
→ root
```

Rooted.

---

## Post-Root Setup

### Zygisk
Enabled in Magisk → Settings → Zygisk. Required for Shamiko and advanced modules.

### Shamiko (root hiding)
Installed Shamiko module to hide root from Google Play Services and other detection. Enabled Enforce DenyList in Magisk settings and added Play Services to the DenyList.

### Debloat
Removed pre-installed bloatware via ADB. The device was surprisingly clean — main removals were Google apps not needed (Tachyon, Wellbeing, YouTube Music, Maps, etc.) and some sketchy OEM packages (`com.guanhong.guanhongpcb`, `com.lxj.incartools`).

---

## What Didn't Work

### Boot animation swap
Attempted to replace the boot animation at `/product/media/bootanimation.zip`. The `/product` partition uses **erofs** (Enhanced Read-Only File System), a compressed read-only format introduced in newer Android versions. Even with root, erofs cannot be remounted as writable — it is physically impossible to write to it at runtime.

Magisk's magic mount system also failed to overlay `/product` on this device — it successfully mounts on `/system` and `/system_ext` but not `/product`.

### vbmeta flash
Attempted to flash a patched vbmeta to suppress the "device is unlocked" boot warning. The write failed mid-flash causing a brief boot loop. Device recovered on its own. Not attempted again.

---

## Tools Used

| Tool | Purpose |
|---|---|
| Android Platform Tools (adb/fastboot) | Device communication |
| CVE-2022-38694 unlocker | Bootloader unlock exploit |
| SPRD/Spreadtrum USB Driver | Unisoc download mode driver |
| Google USB Driver | Fastboot mode driver |
| Magisk 30.7 | Root management |
| Shamiko | Root hiding |

---

## Scripts

Two batch scripts were written to document and automate the process:

- **`p12_root.bat`** — general purpose toolkit (debloat, install APK, push/pull files, reboot options, root check)
- **`p12_autoroot.bat`** — full automated root pipeline walking through all 5 phases with runtime logging

Both feature ANSI color coded TUI output and write full session logs to disk.

---

## Credits

- [TomKing062](https://github.com/TomKing062) — CVE-2022-38694 bootloader unlock research and tooling
- [topjohnwu](https://github.com/topjohnwu) — Magisk
- [LSPosed](https://github.com/LSPosed) — Shamiko

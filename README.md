# CRACK12 🔓

> rooting an ATOZEE P12 on Android 14 using CVE-2022-38694 — because `fastboot oem unlock` said no, so we found another way.

---

## what even is this

so there's this tablet. the ATOZEE P12. you've never heard of it. nobody has. it costs like $80 and the manufacturer's name sounds like someone fell asleep on a keyboard. it runs Android 14, has a Unisoc chip nobody cares about, and came pre-loaded with an app called `com.guanhong.guanhongpcb` that we still don't know the purpose of.

we wanted to root it.

the bootloader said no.

we did it anyway.

---

## the saga

```
$ fastboot oem unlock
FAILED (remote: 'Unlock bootloader fail.')

$ fastboot flashing unlock  
FAILED (remote: 'unknown cmd.')

$ fastboot oem unlock-go
FAILED (remote: 'unknown cmd.')

$ google "how to root atozee p12"
0 results found

$ cry
```

then we ran `adb shell getprop ro.board.platform` and got `ums9230`. turns out Unisoc left a little present in their bootloader. CVE-2022-38694. [TomKing062](https://github.com/TomKing062/CVE-2022-38694_unlock_bootloader) found it. we used it. the tablet cried. we won.

---

## device specs (for the curious)

| thing | value |
|---|---|
| model | ATOZEE P12 (yes, really) |
| chipset | Unisoc UMS9230 (T615) |
| android | 14 |
| build | UP1A.231005.007 |
| storage | UFS |
| partitions | A/B slots, dynamic, erofs |
| bootloader | was locked. isn't anymore. |

---

## prerequisites

before you run anything, make sure you have:

- **a brain** — optional but recommended
- **a USB cable that actually transfers data** — not the one from a hotel room
- **Windows 10/11** — sorry linux users, the exploit tool is windows only. touch grass and come back with a VM
- **Android Platform Tools** — `adb` and `fastboot` in your PATH. if you don't know what PATH means, read `DOWNLOADS.md` first
- **the correct drivers** — two different drivers. yes, two. no, they're not the same. yes, this matters.
- **patience** — the unlock script will say "waiting to connect" and you will panic. don't.

---

## folder structure

```
C:\P12\
├── unlock\unlocker\    ← the goods (download separately, see DOWNLOADS.md)
├── sprd_driver\        ← unisoc usb driver (also download separately)
├── firmware\           ← boot.bin lives here (script grabs it for you)
├── magisk\             ← magisk.apk + your patched boot image
├── backup\             ← for your files before the inevitable wipe
└── scripts\            ← helper scripts
```

---

## how to actually do it

### step 0 — run the env checker
don't skip this. seriously.
```
scripts\verify_env.bat
```
it checks if you have everything before you brick anything.

### step 1 — unlock the bootloader
this will **wipe your device**. back up your stuff. we warned you.

```
p12_autoroot.bat → option 1 (full auto)
```

or if you want to do it manually and feel like a hacker:
- open a terminal in `unlock\unlocker\`
- run `unlock_autopatch_9230.bat`
- power off the tablet
- hold volume down and plug in usb
- install the SPRD driver when the unknown device appears in device manager
- you have approximately 3 seconds. good luck.
- watch the terminal go brrr
- tablet wipes itself. this is normal. do not unplug.

### step 2 — patch the boot image
the unlock script helpfully dumped your stock `boot.bin` automatically. nice of it.

```
adb push firmware\boot.bin /sdcard/Download/
```

install Magisk on the tablet, open it, tap install → select and patch a file → pick `boot.bin`. it'll spit out a `magisk_patched_*.img`. pull it back:

```
adb pull /sdcard/Download/magisk_patched_*.img magisk\
```

### step 3 — flash it
```
adb reboot bootloader
fastboot --disable-verity --disable-verification flash boot_a magisk_patched_*.img
fastboot reboot
```

replace `boot_a` with `boot_b` if `adb shell getprop ro.boot.slot_suffix` returned `_b`. it probably didn't. but check.

### step 4 — verify
```
adb shell su -c "whoami"
```
if it says `root` you did it. if it says anything else, check `TROUBLESHOOTING.md` and touch grass.

---

## things that work

- ✅ root via Magisk 30.7
- ✅ Zygisk
- ✅ Shamiko (root hiding)
- ✅ debloating (including the mysterious `guanhongpcb` app)
- ✅ full ADB access
- ✅ your sister not knowing the tablet is rooted

## things that don't work

- ❌ custom boot animations — `/product` is erofs. it's read only. it laughs at you. Magisk can't overlay it either. we tried everything. it won. accept it.
- ❌ vbmeta flash — we tried. the tablet briefly became a very expensive black rectangle. it recovered. we moved on.
- ❌ LineageOS — nobody has built it for this chip. maybe you will. probably you won't.

---

## the boot warning

every boot you'll see:

```
Your device is corrupt.
It can't be trusted.
Boot state: unlocked
```

it sounds scary. it isn't. it disappears after 5 seconds. your tablet is fine. the warning is just Android being dramatic about the fact that you own your own device now.

---

## scripts included

| script | what it does |
|---|---|
| `p12_autoroot.bat` | walks you through the full root process phase by phase with logging |
| `p12_root.bat` | post-root toolkit — debloat, install apks, push/pull files, reboot options |
| `scripts/verify_env.bat` | checks if your environment is set up correctly before you start |

all scripts have ANSI color coded TUI output and write full session logs because we're not savages.

---

## credits

- [TomKing062](https://github.com/TomKing062) — found CVE-2022-38694 and built the unlock tool. actual hero.
- [topjohnwu](https://github.com/topjohnwu) — Magisk. the GOAT. no further comment needed.
- [LSPosed](https://github.com/LSPosed) — Shamiko. for hiding our crimes from Google.
- ATOZEE — for making a tablet locked so hard it became a challenge.

---

## disclaimer

this is provided as-is. if you brick your tablet, that's on you. we bricked ours briefly and it was fine, but we make no promises. read the code before you run it. don't blame us. you're rooting a no-name budget tablet, not performing surgery.

have fun. 🤙

# Contributing to CRACK12

First off — thanks for being here. This project started as one person trying to root a cheap tablet that wasn't supposed to be rootable. If you've got a Unisoc device and want to share your findings, you're in the right place.

---

## Ways to contribute

### Report a compatible device
Got a Unisoc tablet or phone that worked with this method? Open an issue or PR and add it to `DEVICES.md`. Include:
- Device name and model number
- Chipset (run `adb shell getprop ro.board.platform`)
- Android version
- Whether it worked out of the box or needed tweaks
- Any differences from the P12 process

### Report a bug in the scripts
If `p12_autoroot.bat` or `p12_root.bat` broke on your machine, open an issue with:
- Your Windows version
- The full error message
- Which phase failed
- Contents of `autoroot_log.txt` or `p12_root_log.txt`

### Fix a bug
Fork the repo, make your change, open a pull request. Keep it focused — one fix per PR.

### Improve the docs
If something in the README, TROUBLESHOOTING, or DOWNLOADS docs was unclear or wrong, fix it and open a PR. Good documentation is half the project.

---

## Guidelines

- Keep script changes minimal and readable — these bat files need to be understandable by someone who isn't a developer
- Test before submitting — if you're changing a script, run it against a real device
- Don't include binaries — no `.exe`, `.bin`, `.apk`, or driver files in PRs. Point to official download sources in `DOWNLOADS.md`
- Be honest about risk — if something is experimental or untested, say so clearly

---

## Opening an issue

Use a clear title. Include your device info. Paste relevant log output as a code block. That's it.

---

## A note on scope

This project is specifically about rooting Unisoc UMS9230 devices via CVE-2022-38694. PRs adding support for completely different chipsets or exploit methods are welcome but may be kept in separate branches to keep the main flow clean.

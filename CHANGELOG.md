# Changelog

All notable changes to this project will be documented here.

---

## [1.0.0] - 2026-05-13

### Added
- Initial release
- `p12_autoroot.bat` — full automated root pipeline (5 phases)
- `p12_root.bat` — general purpose post-root toolkit
- `README.md` — full project documentation and manual walkthrough
- `DOWNLOADS.md` — required files and where to get them
- `TROUBLESHOOTING.md` — common issues and fixes
- `CHANGELOG.md` — this file
- `.gitignore` — excludes logs, binaries, and sensitive files

### Notes
- Bootloader unlocked via CVE-2022-38694 (TomKing062)
- Rooted with Magisk 30.7 on Android 14
- erofs on /product partition prevents boot animation swapping
- vbmeta flash attempted and abandoned due to write failure risk

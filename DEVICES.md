# Device Compatibility

Community reported devices that work with this rooting method.
If your device worked, open a PR and add it to the table!

---

## Confirmed Working

| Device | Chipset | Android | Notes |
|---|---|---|---|
| ATOZEE P12 | Unisoc UMS9230 (T615) | 14 | Original test device. Full process documented in README. |
| UMIDIGI Note 100 | Unisoc UMS9230 (T615) | — | Confirmed by community. Inspiration for this project. |

---

## Likely Compatible (untested)

These devices share the UMS9230 chipset and may work with the same method. Not confirmed — proceed with caution.

| Device | Chipset | Notes |
|---|---|---|
| Unisoc T615 based tablets | UMS9230 | Any device on this chipset is a candidate |

---

## Not Compatible

| Device | Chipset | Reason |
|---|---|---|
| — | — | — |

---

## How to add your device

1. Root your device using this method
2. Fork this repo
3. Add your device to the **Confirmed Working** table with:
   - Device name and model
   - Chipset (`adb shell getprop ro.board.platform`)
   - Android version
   - Any notes about differences from the standard process
4. Open a pull request

If your device didn't work, add it to **Not Compatible** with a brief reason so others don't waste time.

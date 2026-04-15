---
applyTo: "src/**/*.cpp,src/**/*.h,variants/**/*.cpp,variants/**/*.h"
---

This is a minimal Arduino/PlatformIO firmware for nRF52840. The entire application logic is in `src/main.cpp`.

- `setup()` runs once: initialises serial, formats `InternalFS` (LittleFS), then calls `enterUf2Dfu()` to reboot into DFU mode.
- `loop()` is intentionally empty — the device reboots before it is ever reached.
- `enterUf2Dfu()` is provided by the custom Adafruit nRF52 Arduino fork (`geeksville/Adafruit_nRF52_Arduino`), not by standard Arduino.
- LittleFS assertions are disabled globally via `-DLFS_NO_ASSERT`. Do not add `LFS_ASSERT` calls.
- Use `// cppcheck-suppress <id>` for inline cppcheck suppressions; add persistent suppressions to `suppressions.txt`.
- Serial is initialised at 115200 baud. The `while (!Serial)` loop is required for native USB on nRF52840.

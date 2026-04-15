---
name: build-firmware
description: Build nRF52 factory erase firmware with PlatformIO. Use this skill when asked to build, compile, or generate firmware artifacts (.uf2, .elf, -ota.zip).
allowed-tools: shell
---

## Building the firmware

Two build environments are available:

| Environment | Softdevice |
|---|---|
| `s140_nrf52_611_softdevice` | S140 v6.1.1 (RAK, LilyGo, Heltec) |
| `s140_nrf52_730_softdevice` | S140 v7.3.0 (Seeed, ms24sf1, ME25LS01) |

### Full build (produces .uf2, .elf, -ota.zip in `release/`)

Run the shell build script, passing the environment name as the only argument:

```bash
./scripts/linux/build-nrf52.sh s140_nrf52_611_softdevice
./scripts/linux/build-nrf52.sh s140_nrf52_730_softdevice
```

The script:
1. Reads the version from `version.properties` via `scripts/python/buildinfo.py long`
2. Calls `pio run --environment <env>` with `APP_VERSION` exported
3. Copies `.elf` and `-ota.zip` from `.pio/build/<env>/` to `release/`
4. Converts `firmware.hex` to `firmware.uf2` using `scripts/python/uf2conv.py -f 0xADA52840`

### Quick PlatformIO build (no artifact copy)

```bash
pio run --environment s140_nrf52_611_softdevice
```

### Artifacts location after build

```
release/
  nrf52_factory_erase-<env>-<version>.elf
  nrf52_factory_erase-<env>-<version>-ota.zip
  nrf52_factory_erase-<env>-<version>.uf2
```

### Troubleshooting build failures

- If PlatformIO packages are stale, run: `platformio pkg update -e <env>`
- The `scripts/python/platformio-custom.py` extra_script auto-generates the `.uf2` from `.hex` after each build — if `.uf2` is missing, check that the script ran without errors.
- Version flags (`-DAPP_VERSION`, `-DAPP_VERSION_SHORT`) are injected automatically; do not pass them manually.

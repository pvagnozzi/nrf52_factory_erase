# nrf52_factory_erase
This repository contains the nRF52 Factory Erase firmware for the Meshtastic project.

This is the platformio version of the meshtastic nrf52 factory erase firmware (previous version was based on arduino)

builds same as meshtastic firmware with 2 variants available

* s140_nrf52_611_softdevice (RAK, LilyGo, Heltec Node T114, etc)
* s140_nrf52_730_softdevice (All Seeed, ms24sf1 and ME25LS01 variants)

The file names would also have been previously (in the docs)
https://meshtastic.org/docs/getting-started/flashing-firmware/nrf52/nrf52-erase/

Meshtastic_nRF52_factory_erase_v3_S140_7.3.0.uf2 
Meshtastic_nRF52_factory_erase_v3_S140_6.1.0.uf2

## Building

**Linux / macOS:**
```bash
./scripts/linux/build-nrf52.sh [--clean] [--verbose] [ENVIRONMENT]
./scripts/macos/build-nrf52.sh [--clean] [--verbose] [ENVIRONMENT]
```

**Windows (PowerShell):**
```powershell
.\scripts\windows\build.ps1 [-Clean] [-Verbose] [-Environment ENVIRONMENT]
```

`ENVIRONMENT` is one of `s140_nrf52_611_softdevice`, `s140_nrf52_730_softdevice`, or `all` (default).  
Raw artifacts (`.uf2`, `.elf`, `-ota.zip`) are placed in the `build/` directory.

## Release

The release scripts run the build and package each environment's artifacts into a single ZIP under `release/`:

```
release/
  nrf52_factory_erase-s140_nrf52_611_softdevice-<version>.zip
  nrf52_factory_erase-s140_nrf52_730_softdevice-<version>.zip
```

Each ZIP contains the `.elf`, `.uf2`, and `-ota.zip` for that environment.

**Linux / macOS:**
```bash
./scripts/linux/release-nrf52.sh [--clean] [--verbose] [ENVIRONMENT]
./scripts/macos/release-nrf52.sh [--clean] [--verbose] [ENVIRONMENT]
```

**Windows (PowerShell):**
```powershell
.\scripts\windows\release.ps1 [-Clean] [-Verbose] [-Environment ENVIRONMENT]
```

# Copilot Instructions

## Project Overview

This is the **nRF52 Factory Erase** firmware for the [Meshtastic](https://meshtastic.org) project. It is a minimal PlatformIO/Arduino firmware that formats the nRF52840's internal LittleFS filesystem and immediately reboots the device into UF2 DFU mode. The entire application logic lives in `src/main.cpp`.

## Build Commands

**Build a specific variant:**
```bash
./scripts/linux/build-nrf52.sh s140_nrf52_611_softdevice
./scripts/linux/build-nrf52.sh s140_nrf52_730_softdevice
```
Output artifacts (`.uf2`, `.elf`, `-ota.zip`) are placed in `release/`.

**Build directly with PlatformIO:**
```bash
pio run --environment s140_nrf52_611_softdevice
pio run --environment s140_nrf52_730_softdevice
```

**Code formatting:**
```bash
trunk fmt
```

**Static analysis (cppcheck):**
```bash
pio check --environment s140_nrf52_611_softdevice
```
Suppressions are in `suppressions.txt`; inline suppressions use `// cppcheck-suppress`.

## Architecture

### Config inheritance chain

```
platformio.ini [arduino_base]
  └── arch/nrf52/nrf52.ini [nrf52_base]
        └── arch/nrf52/nrf52840.ini [nrf52840_base]
              └── variants/<variant>/platformio.ini [env:<variant>]
```

Each layer extends the one above. Variant-specific files live under `variants/<variant>/`.

### Two build targets

| Environment | Softdevice | Target boards |
|---|---|---|
| `s140_nrf52_611_softdevice` | S140 v6.1.1 | RAK, LilyGo, Heltec Node T114 |
| `s140_nrf52_730_softdevice` | S140 v7.3.0 | Seeed, ms24sf1, ME25LS01 |

Board definitions (RAM/flash sizes, USB IDs, softdevice flags) are in `boards/<variant>.json`.

### Build pipeline extras

`scripts/python/platformio-custom.py` is loaded as a PlatformIO `extra_script`. It:
- Injects `-DAPP_VERSION` and `-DAPP_VERSION_SHORT` compiler flags (read from `version.properties`)
- Adds a post-action on the nRF52 platform to produce `firmware.uf2` from `firmware.hex` using `scripts/python/uf2conv.py` with family ID `0xADA52840`

### Version management

Version is defined in `version.properties` (major/minor/build). Use `scripts/python/buildinfo.py long` or `scripts/python/buildinfo.py short` to read it. The build script exports `APP_VERSION` from this before calling `pio run`.

## Copilot Configuration in this Repo

| Artifact | Location | Purpose |
|---|---|---|
| Path instructions (C++) | `.github/instructions/cpp-source.instructions.md` | Applied when editing `src/` or `variants/` C++ files |
| Path instructions (PlatformIO) | `.github/instructions/platformio-config.instructions.md` | Applied when editing `*.ini` or `boards/*.json` |
| Skill: build | `.github/skills/build-firmware/SKILL.md` | How to build firmware and locate artifacts |
| Skill: analysis | `.github/skills/static-analysis/SKILL.md` | How to run cppcheck and handle suppressions |

### Dev Container

Open in VS Code → **Reopen in Container** (requires Docker). The devcontainer is configured in `.devcontainer/devcontainer.json` and uses `containers/devcontainer/Dockerfile`.

It pre-installs: PlatformIO, nrfutil, pyocd, ARM GCC toolchain, Trunk, minicom.

### Docker CI build

```bash
# From project root
docker compose -f containers/docker-compose.yml run --rm build
```
| Agent | `.github/agents/nrf52-firmware-engineer.md` | Embedded firmware specialist sub-agent |

### Recommended MCP servers

These are not pre-configured (MCP is user-level in `~/.copilot/mcp-config.json`), but are useful for this project:

- **GitHub MCP** — built-in; use for issue triage, PR review, CI logs.
- **Filesystem MCP** (`@modelcontextprotocol/server-filesystem`) — useful when Copilot needs to inspect build artifacts in `.pio/build/` or `release/` that lie outside the default workspace.

Add via: `/mcp add` inside a Copilot CLI session.

## Key Conventions

- **Custom Arduino framework fork**: `arch/nrf52/nrf52.ini` pins `framework-arduinoadafruitnrf52` to `geeksville/Adafruit_nRF52_Arduino.git` instead of the upstream Adafruit package.
- **UF2 family ID**: Always use `0xADA52840` when generating `.uf2` files for nRF52840 targets.
- **Upload protocol**: `nrfutil` (variants use `upload_protocol = nrfutil`).
- **Debug tool default**: `stlink` at 4000 kHz; `pyocd` is an alternative (see `arch/nrf52/nrf52840.ini` for full debug config).
- **`LFS_NO_ASSERT`** is defined globally to disable LittleFS assertions (see [PR #3818](https://github.com/meshtastic/firmware/pull/3818)).
- **`build_type = debug`** is set in `nrf52.ini` — release builds are not a separate config; optimization is controlled via `-Os` in `arduino_base`.

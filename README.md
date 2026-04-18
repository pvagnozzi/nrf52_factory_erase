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

### Docker build

```bash
# From project root — builds both variants and places ZIPs in release/
docker compose -f containers/docker-compose.yml run --rm build

# Pass a custom version string
APP_VERSION=1.2.3 docker compose -f containers/docker-compose.yml run --rm build
```

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

## Versioning

Version is defined in `version.properties` (major / minor / build).  
Read it with the helper scripts:

```bash
python scripts/python/buildinfo.py short   # e.g. 1.2.5
python scripts/python/buildinfo.py long    # e.g. 1.2.5.a1b2c3d  (appends git SHA)
```

Update all three parts at once:

```bash
python scripts/python/update_version.py <major> <minor> <build>
```

In CI, version is computed automatically by **GitVersion** (see `GitVersion.yml`) using the GitFlow branch strategy.

## GitFlow branching model

This project follows [GitFlow](https://nvie.com/posts/a-successful-git-branching-model/):

| Branch | Purpose | Merges into |
|---|---|---|
| `main` | Production releases | — |
| `develop` | Integration branch | `main` (via release) |
| `feature/<name>` | New features | `develop` |
| `release/<x.y>` | Release preparation | `main` + `develop` |
| `hotfix/<name>` | Production fixes | `main` + `develop` |

```
main ────────────────────────────────────────────────► (production)
       ↑                                      ↑
    hotfix/x                             release/1.2
                  ↑                            ↑
develop ──────────┴────────────────────────────┴──────► (integration)
              ↑         ↑          ↑
          feature/a  feature/b  feature/c
```

### Starting work

```bash
# New feature
git checkout -b feature/<name> develop

# Release preparation
git checkout -b release/<major.minor> develop

# Production hotfix
git checkout -b hotfix/<name> main
```

### Git hooks

Install the project hooks once after cloning:

```bash
bash .github/hooks/setup.sh
```

Hooks provided:

| Hook | Effect |
|---|---|
| `commit-msg` | Validates [Conventional Commits](https://www.conventionalcommits.org/) format |
| `pre-push` | Blocks direct pushes to `main` and `develop` |

## CI / CD pipelines

| Workflow | Trigger | Action |
|---|---|---|
| `ci.yml` | Push to `develop`, `feature/**`, `release/**`, `hotfix/**`; PRs to `main`/`develop` | Build via Docker, upload artifacts |
| `bump-version.yml` | PR **merged** into `develop` | Increment `build` in `version.properties`, commit back |
| `release.yml` | PR **merged** into `main` **or** tag `v*.*.*` pushed | Compute GitVersion, update `version.properties`, create tag, build via Docker, publish GitHub Release |

### Automatic build number increment

Every time a feature PR is merged into `develop`, the `bump-version` workflow automatically increments the `build` field in `version.properties` and pushes the change back to `develop`.

### Publishing a release

The normal release flow:

1. Merge `develop` into a `release/<x.y>` branch for final testing
2. Open a PR from `release/<x.y>` → `main`
3. Merge the PR — the `release.yml` workflow fires automatically:
   - Computes the final semantic version via GitVersion
   - Updates `version.properties`
   - Creates git tag `v{semVer}`
   - Builds both softdevice variants via Docker
   - Publishes a GitHub Release with the firmware ZIPs

For hotfixes, open a PR from `hotfix/<name>` → `main`; the same release workflow fires.


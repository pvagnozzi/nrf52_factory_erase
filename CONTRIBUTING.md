# Contributing to nRF52 Factory Erase

We're excited that you're interested in contributing! This document explains how to get involved using our **GitFlow** branching model and **Conventional Commits** standards.

## Important first steps

Before you begin, please:

1. **Read our documentation**: The [official Meshtastic docs](https://meshtastic.org/docs/) are a crucial resource.
2. **Read the firmware build guide**: [Firmware Build Guide](https://meshtastic.org/docs/development/firmware/build/).
3. Read our [Code of Conduct](https://meshtastic.org/docs/legal/conduct/).
4. Join our [Discord community](https://discord.com/invite/ktMAKGBnBs) to connect with developers.

## Getting help and discussing ideas

1. **GitHub Discussions**: For new ideas or potential changes, start a conversation in [GitHub Discussions](https://github.com/meshtastic/firmware/discussions) first.
2. **Discord**: For real-time chat, join our [Discord server](https://discord.com/invite/ktMAKGBnBs).
3. **Reporting issues**: Use the bug report template in the [issue tracker](https://github.com/meshtastic/firmware/issues).

## Making contributions

> [!IMPORTANT]
> Before making any contributions, you must sign our Contributor License Agreement (CLA). Visit https://cla-assistant.io/meshtastic/firmware and sign with the GitHub account you will use to submit contributions.

## GitFlow workflow

This project uses [GitFlow](https://nvie.com/posts/a-successful-git-branching-model/). **Never commit directly to `main` or `develop`.**

### Branch types

| Branch | Created from | Merges into | Purpose |
|---|---|---|---|
| `feature/<name>` | `develop` | `develop` | New features |
| `release/<x.y>` | `develop` | `main` + `develop` | Release preparation |
| `hotfix/<name>` | `main` | `main` + `develop` | Production bug fixes |

### Step-by-step contribution

1. **Fork** the repository.
2. **Install git hooks** (one-time setup after cloning):
   ```bash
   bash .github/hooks/setup.sh
   ```
3. **Create a branch** from `develop` (features) or `main` (hotfixes):
   ```bash
   # Feature
   git checkout develop
   git pull origin develop
   git checkout -b feature/<your-feature-name>

   # Hotfix
   git checkout main
   git pull origin main
   git checkout -b hotfix/<fix-name>
   ```
4. **Make your changes** and write [Conventional Commit](#commit-message-format) messages.
5. **Format code** before committing:
   ```bash
   trunk fmt
   ```
6. **Push your branch** and open a Pull Request targeting `develop` (features) or `main` (hotfixes).
7. **Enable "Allow edits from maintainers"** on your PR.

## Commit message format

This project enforces [Conventional Commits](https://www.conventionalcommits.org/). The git hook `commit-msg` validates every commit locally.

```
<type>[optional scope]: <short description>

[optional body]

[optional footer]
```

### Allowed types

| Type | Use for |
|---|---|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, whitespace — no logic change |
| `refactor` | Code change without feature or fix |
| `test` | Adding or fixing tests |
| `chore` | Maintenance (deps, tooling, version bumps) |
| `build` | Build system changes |
| `ci` | CI pipeline changes |
| `perf` | Performance improvement |
| `revert` | Revert a previous commit |

### Examples

```
feat(firmware): add support for Seeed XIAO nRF52840
fix: correct UF2 family ID constant
chore(deps): bump platformio to 6.1.16
docs: document GitFlow branching model
feat!: change DFU entry point API
```

Breaking changes are indicated by appending `!` after the type/scope.

## Automatic build number

When a feature PR is merged into `develop`, the CI pipeline automatically increments the `build` field in `version.properties` and commits it back. No manual version bumping is needed for day-to-day development.

## Coding standards

1. Install the [Trunk](https://marketplace.visualstudio.com/items?itemName=Trunk.io) VS Code extension.
2. Run `trunk fmt` before submitting changes.
3. Run `pio check --environment s140_nrf52_611_softdevice` to check for static analysis issues.

Thank you for contributing to Meshtastic!


---
name: static-analysis
description: Run cppcheck static analysis on nRF52 firmware source. Use this skill when asked to check code quality, run static analysis, or find potential bugs.
allowed-tools: shell
---

## Running static analysis

This project uses **cppcheck** via PlatformIO's built-in check command.

### Run analysis on a single environment

```bash
pio check --environment s140_nrf52_611_softdevice
```

### Run analysis on both environments

```bash
pio check --environment s140_nrf52_611_softdevice --environment s140_nrf52_730_softdevice
```

### Configuration

- Suppressions file: `suppressions.txt` — global suppressions applied to all files.
- Inline suppressions: use `// cppcheck-suppress <id>` on the line before the flagged code.
- `--inline-suppr` flag is active; inline suppressions in source are respected.
- `check_skip_packages = yes` skips library/framework code — only `src/` is analysed.

### Handling results

- Fix genuine issues in source code.
- For false positives: add `// cppcheck-suppress <id>` inline, or add to `suppressions.txt` for project-wide suppression.
- The `trunk fmt` command handles code formatting; run it after any source changes.

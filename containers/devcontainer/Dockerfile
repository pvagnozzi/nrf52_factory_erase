# ─────────────────────────────────────────────────────────────────────────────
#  Dev container — nRF52 Factory Erase
#
#  Full development environment for VS Code Dev Containers.
#  Includes PlatformIO, nrfutil, pyocd, ARM toolchain, Trunk, and serial tools.
#
#  Configured via .devcontainer/devcontainer.json.
# ─────────────────────────────────────────────────────────────────────────────

# Microsoft's devcontainers base provides git, curl, sudo, a 'vscode' user,
# common shells, and shell completions — ready for VS Code.
FROM mcr.microsoft.com/devcontainers/base:debian-12

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1

# ── System dependencies ───────────────────────────────────────────────────────
RUN apt-get update && apt-get install --no-install-recommends -y \
        # Python build & runtime
        python3 python3-pip python3-venv python3-dev \
        # USB access for SWD probes and serial flashing
        libusb-1.0-0-dev udev \
        # Serial monitor tools
        minicom picocom \
        # ARM toolchain for debugging (GDB)
        gcc-arm-none-eabi gdb-multiarch \
        # Misc utilities
        zip unzip jq \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ── Python tools (installed as the 'vscode' user) ────────────────────────────
USER vscode

RUN pip3 install --user --no-cache-dir \
        "platformio>=6.1.15" \
        "nrfutil>=0.5.3" \
        "pyocd>=0.35.0"

ENV PATH="/home/vscode/.local/bin:${PATH}"

# ── Trunk (code quality: formatter + linter) ─────────────────────────────────
RUN curl -fsSL https://get.trunk.io | bash -s -- -y 2>/dev/null || true

# ── Shell completions for pio ─────────────────────────────────────────────────
RUN pio completion install --shell bash 2>/dev/null || true

USER root
WORKDIR /workspace

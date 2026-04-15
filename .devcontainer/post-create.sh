#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  post-create.sh — Dev container post-create bootstrap
#  Runs once after the container is created (via postCreateCommand).
#  Idempotent: safe to run multiple times.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

# ── Colours ───────────────────────────────────────────────────────────────────
G='\033[0;32m'; B='\033[0;34m'; Y='\033[1;33m'; NC='\033[0m'; BOLD='\033[1m'
info()    { echo -e "${B}ℹ️  ${NC}${*}"; }
success() { echo -e "${G}✅ ${*}${NC}"; }
warn()    { echo -e "${Y}⚠️  ${*}${NC}"; }

echo -e "\n${BOLD}${B}════════════════════════════════════════════${NC}"
echo -e "${BOLD}${B}  🔧  nRF52 Factory Erase — Dev Container   ${NC}"
echo -e "${BOLD}${B}════════════════════════════════════════════${NC}\n"

# ── Mark workspace as safe for git ───────────────────────────────────────────
git config --global --add safe.directory /workspace 2>/dev/null || true

# ── Install PlatformIO packages for both environments ─────────────────────────
info "Installing PlatformIO packages…"
for env in s140_nrf52_611_softdevice s140_nrf52_730_softdevice; do
  if pio pkg install -e "${env}" --silent 2>/dev/null; then
    success "PlatformIO packages ready: ${env}"
  else
    warn "Failed to install packages for ${env} (no internet?). Build may fail."
  fi
done

# ── Show tool versions ────────────────────────────────────────────────────────
echo ""
info "Tool versions:"
python3 --version          2>/dev/null && echo "  🐍 $(python3 --version)"
pio --version              2>/dev/null && echo "  🔩 PlatformIO $(pio --version | head -1)"
nrfutil version            2>/dev/null && echo "  📡 nrfutil $(nrfutil version 2>&1 | head -1)" || true
pyocd --version            2>/dev/null && echo "  🔍 pyOCD $(pyocd --version)" || true
arm-none-eabi-gcc --version 2>/dev/null | head -1 | sed 's/^/  🛠  /' || true

echo ""
success "Dev container ready. Happy hacking! 🎉"
echo ""

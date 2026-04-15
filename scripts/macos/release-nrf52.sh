#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  release-nrf52.sh — Build and package nRF52 Factory Erase firmware
#
#  Usage:
#    ./scripts/macos/release-nrf52.sh [OPTIONS] [ENVIRONMENT]
#
#  OPTIONS:
#    --clean     Remove .pio/build/<env> before building
#    --verbose   Pass -v to pio run for detailed compiler output
#
#  ENVIRONMENT:
#    s140_nrf52_611_softdevice   S140 v6.1.1 — RAK, LilyGo, Heltec Node T114
#    s140_nrf52_730_softdevice   S140 v7.3.0 — Seeed, ms24sf1, ME25LS01
#    all                         Build both environments (default)
#
#  Output:
#    build/   — raw firmware artifacts (.elf, .uf2, -ota.zip)
#    release/ — one ZIP per environment containing all its artifacts
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
SCRIPTS_PYTHON="${PROJECT_ROOT}/scripts/python"

cd "${PROJECT_ROOT}"

# ── Colours ───────────────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
  G='\033[0;32m'; R='\033[0;31m'; B='\033[0;34m'; C='\033[0;36m'
  BOLD='\033[1m'; NC='\033[0m'
else
  G=''; R=''; B=''; C=''; BOLD=''; NC=''
fi
info()    { echo -e "${B}ℹ  ${NC}${*}"; }
success() { echo -e "${G}✔  ${*}${NC}"; }
error()   { echo -e "${R}✖  ${*}${NC}" >&2; }
step()    { echo -e "\n${C}${BOLD}▸ ${*}${NC}"; }

ALL_ENVS=(s140_nrf52_611_softdevice s140_nrf52_730_softdevice)

# ── Argument parsing ──────────────────────────────────────────────────────────
ENV_ARG="all"
BUILD_ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --clean|--verbose|-v) BUILD_ARGS+=("$1") ;;
    -*)                   error "Unknown option: $1"; exit 1 ;;
    *)                    ENV_ARG="$1" ;;
  esac
  shift
done
BUILD_ARGS+=("${ENV_ARG}")

if [[ "${ENV_ARG}" == "all" ]]; then
  ENVS=("${ALL_ENVS[@]}")
else
  ENVS=("${ENV_ARG}")
fi

# ── Prerequisites ─────────────────────────────────────────────────────────────
command -v zip &>/dev/null || { error "zip not found. Install with: brew install zip"; exit 1; }
PYTHON=$(command -v python3 || command -v python || echo "")
[[ -z "${PYTHON}" ]] && { error "python3 not found"; exit 1; }

# ── Step 1: Build ─────────────────────────────────────────────────────────────
step "Building firmware…"
"${SCRIPT_DIR}/build-nrf52.sh" "${BUILD_ARGS[@]}"

# ── Resolve version (may have been set by build script) ───────────────────────
if [[ -z "${APP_VERSION:-}" ]]; then
  APP_VERSION="$("${PYTHON}" "${SCRIPTS_PYTHON}/buildinfo.py" long)"
fi

BUILDDIR="${PROJECT_ROOT}/build"
RELEASEDIR="${PROJECT_ROOT}/release"
mkdir -p "${RELEASEDIR}"

echo -e "\n${BOLD}${B}════════════════════════════════════════════${NC}"
echo -e "${BOLD}${B}  📦  nRF52 Factory Erase — Package         ${NC}"
echo -e "${BOLD}${B}════════════════════════════════════════════${NC}"
info "Version  : ${BOLD}${APP_VERSION}${NC}"
info "Build    : ${BOLD}${BUILDDIR}${NC}"
info "Release  : ${BOLD}${RELEASEDIR}${NC}"

declare -a PASSED=() FAILED=()

# ── Step 2: Package ───────────────────────────────────────────────────────────
for ENV in "${ENVS[@]}"; do
  step "Packaging ${ENV}…"
  BASE="nrf52_factory_erase-${ENV}-${APP_VERSION}"
  ZIP="${RELEASEDIR}/${BASE}.zip"

  FILES=()
  for f in \
    "${BUILDDIR}/${BASE}.elf" \
    "${BUILDDIR}/${BASE}.uf2" \
    "${BUILDDIR}/${BASE}-ota.zip"; do
    [[ -f "$f" ]] && FILES+=("$(basename "$f")")
  done

  if [[ ${#FILES[@]} -eq 0 ]]; then
    error "No artifacts found for ${ENV} in ${BUILDDIR}"
    FAILED+=("${ENV}")
    continue
  fi

  rm -f "${ZIP}"
  (cd "${BUILDDIR}" && zip -j "${ZIP}" "${FILES[@]}")

  PASSED+=("${ENV}")
  success "${ZIP##*/}  (${#FILES[@]} files)"
done

# ── Summary ───────────────────────────────────────────────────────────────────
echo -e "\n${BOLD}── Summary ─────────────────────────────────────${NC}"
for e in "${PASSED[@]}"; do echo -e "  ${G}✔ PASS${NC}  ${e}"; done
for e in "${FAILED[@]}"; do echo -e "  ${R}✖ FAIL${NC}  ${e}"; done
echo ""
ls -lh "${RELEASEDIR}"/*.zip 2>/dev/null | awk '{print "  "$NF, $5}'

(( ${#FAILED[@]} > 0 )) && exit 1 || success "Release complete → ${C}${RELEASEDIR}/${NC}"

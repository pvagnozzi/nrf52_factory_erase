#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  setup.sh — Install project Git hooks
#
#  Run once after cloning:
#    bash .github/hooks/setup.sh
#
#  This sets core.hooksPath so that Git picks up the hooks in .github/hooks/.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Make hooks executable
chmod +x "${SCRIPT_DIR}/commit-msg"
chmod +x "${SCRIPT_DIR}/pre-push"

# Point Git at the hooks directory
git -C "${SCRIPT_DIR}/../.." config core.hooksPath ".github/hooks"

echo ""
echo "  ✔  Git hooks installed from ${SCRIPT_DIR}"
echo ""
echo "  Active hooks:"
echo "    commit-msg  — Conventional Commits message validation"
echo "    pre-push    — Block direct pushes to main/develop"
echo ""

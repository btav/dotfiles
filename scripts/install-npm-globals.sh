#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
case "${1:-}" in
  "")
    ;;
  --dry-run)
    DRY_RUN=1
    shift
    ;;
  *)
    echo "usage: $0 [--dry-run]" >&2
    exit 2
    ;;
esac

print_cmd() {
  local arg
  printf 'DRY:'
  for arg in "$@"; do printf ' %q' "$arg"; done
  printf '\n'
}

run() {
  if (( DRY_RUN )); then
    print_cmd "$@"
  else
    "$@"
  fi
}

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
  echo "nvm not found at $NVM_DIR. Run ./install.sh first." >&2
  exit 1
fi

# shellcheck source=/dev/null
. "$NVM_DIR/nvm.sh"

NVM_DEFAULT="$(nvm version default 2>/dev/null || true)"
if [[ -z "$NVM_DEFAULT" || "$NVM_DEFAULT" == "N/A" || "$NVM_DEFAULT" == "system" ]]; then
  echo "nvm default is not configured. Run ./install.sh first." >&2
  exit 1
fi

NODE_BIN="$(nvm which "$NVM_DEFAULT" 2>/dev/null || true)"
if [[ -z "$NODE_BIN" || "$NODE_BIN" == "N/A" ]]; then
  echo "nvm default $NVM_DEFAULT is not installed. Run ./install.sh first." >&2
  exit 1
fi

NPM_BIN="$(dirname "$NODE_BIN")/npm"
if [[ ! -x "$NPM_BIN" ]]; then
  echo "npm not found for nvm default $NVM_DEFAULT at $NPM_BIN" >&2
  exit 1
fi

TARGET_PREFIX="$(cd "$(dirname "$NPM_BIN")/.." && pwd -P)"

PACKAGES=(
  "@openai/codex@latest"
  "pnpm@11"
  "@earendil-works/pi-coding-agent@latest"
)

echo "==> npm globals via $NPM_BIN"
echo "    nvm default: $NVM_DEFAULT"
echo "    prefix: $TARGET_PREFIX"

for pkg in "${PACKAGES[@]}"; do
  echo "    npm i -g $pkg"
  run "$NPM_BIN" --prefix "$TARGET_PREFIX" install -g "$pkg"
done

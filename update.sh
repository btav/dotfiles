#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

UPDATE_SKILLS=0
case "${1:-}" in
  "") ;;
  --skills) UPDATE_SKILLS=1 ;;
  *)
    echo "usage: $0 [--skills]" >&2
    exit 2
    ;;
esac

step() { printf '\033[1;34m==>\033[0m %-13s %s\n' "$1" "${2:-}"; }
indent_run() {
  "$@" 2>&1 | sed 's/^/    /'
}

if ! command -v brew >/dev/null 2>&1; then
  echo "brew not found. Run ./install.sh first." >&2
  exit 1
fi

step "Homebrew" "refreshing metadata"
indent_run brew update

step "brew bundle" "$(printf '%s' "$DOTFILES/Brewfile" | sed "s|^$HOME|~|")"
indent_run brew bundle install --file="$DOTFILES/Brewfile"

# Stow sync (backs up conflicting files, then restows all packages)
"$DOTFILES/scripts/stow-sync.sh"

step "npm globals"
indent_run "$DOTFILES/scripts/install-npm-globals.sh"

if command -v rustup >/dev/null 2>&1; then
  step "Rust" "updating toolchains"
  indent_run rustup update
else
  step "Rust" "not initialized; run ./install.sh"
fi

if (( UPDATE_SKILLS )); then
  step "Skills" "updating submodule to latest"
  indent_run git -C "$DOTFILES" submodule update --remote --quiet skills
fi

printf '\n\033[1;32mDone.\033[0m\n'

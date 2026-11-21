#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GIT_DELTA_INCLUDE="~/.config/git/delta.gitconfig"
PACKAGES=(stow git-delta vim zed ttf-jetbrains-mono-nerd zsh zsh-autosuggestions zsh-syntax-highlighting lsof)

DRY_RUN=0
action="${1:-}"
flag="${2:-}"
case "$#:$action:$flag" in
  1:install:|1:update:|2:update:--skills) ;;
  2:install:--dry-run) DRY_RUN=1 ;;
  *)
    printf 'Usage: ./install.sh [--dry-run] or ./update.sh [--skills]\n' >&2
    exit 2
    ;;
esac

if ! command -v omarchy >/dev/null || ! command -v mise >/dev/null; then
  printf 'The Linux setup requires Omarchy with mise on PATH.\n' >&2
  exit 1
fi

step() { printf '\033[1;34m==>\033[0m %s\n' "$1"; }
run() {
  if (( DRY_RUN )); then
    printf 'DRY:'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

step "Linux packages"
run omarchy pkg add "${PACKAGES[@]}"

step "pnpm 11 via mise"
run mise use --global --fuzzy pnpm@11

if [[ ! -e "$HOME/.oh-my-zsh" && ! -L "$HOME/.oh-my-zsh" ]]; then
  step "Oh My Zsh"
  run git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
fi

stow_flags=(--linux)
(( DRY_RUN )) && stow_flags+=(--dry-run)
"$DOTFILES/scripts/stow-sync.sh" "${stow_flags[@]}"

step "Git delta include"
delta_config="$HOME/.config/git/delta.gitconfig"
if git config --global --get-all include.path 2>/dev/null | grep -Fx "$GIT_DELTA_INCLUDE" >/dev/null; then
  printf '    Include already present\n'
elif [[ -L "$delta_config" && "$delta_config" -ef "$DOTFILES/git/.config/git/delta.gitconfig" ]]; then
  run git config --global --add include.path "$GIT_DELTA_INCLUDE"
elif (( DRY_RUN )); then
  printf '    Will add the include if Stow links the managed delta config\n'
else
  printf '    Skipping include because the managed delta config was not linked\n'
fi

if [[ "$action" == install || "$flag" == --skills ]]; then
  step "Skills"
  if [[ "$action" == install ]]; then
    run git -C "$DOTFILES" submodule update --init --recursive --quiet
  else
    run git -C "$DOTFILES" submodule update --init --remote --quiet skills
  fi
  run "$DOTFILES/skills/install.sh"
fi

printf '\n\033[1;32mDone.\033[0m\n'

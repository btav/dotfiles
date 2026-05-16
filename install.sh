#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
STOW_PKGS=(zsh vim zed ghostty git)
GIT_DELTA_INCLUDE="~/.config/git/delta.gitconfig"

step() { printf '\033[1;34m==>\033[0m %-13s %s\n' "$1" "${2:-}"; }
sub()  { printf '    %s\n' "$*"; }
tilde() { printf '%s' "${1/#$HOME/~}"; }
run()  { (( DRY_RUN )) || eval "$@"; }

(( DRY_RUN )) && printf '\033[2m(dry run — no changes will be made)\033[0m\n\n'

# Homebrew
if command -v brew >/dev/null 2>&1; then
  step "Homebrew" "already installed"
else
  step "Homebrew" "installing"
  run '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Brewfile
step "brew bundle" "$(tilde "$DOTFILES")/Brewfile"
run "brew bundle --file='$DOTFILES/Brewfile' --quiet"

# Rust toolchain (brew ships rustup-init only; nothing usable until it runs once)
if command -v rustup >/dev/null 2>&1; then
  step "Rust" "toolchain already installed"
else
  step "Rust" "bootstrapping stable toolchain"
  run "rustup-init -y --no-modify-path --default-toolchain stable >/dev/null"
fi

# Python via uv (--default places `python`/`python3` shims in ~/.local/bin)
PY_VER="3.13"
if uv python list --only-installed 2>/dev/null | grep -q "cpython-${PY_VER}"; then
  step "Python" "$PY_VER already installed"
else
  step "Python" "installing $PY_VER as default"
  run "uv python install --default $PY_VER"
fi

# oh-my-zsh
if [[ -d "$HOME/.oh-my-zsh" ]]; then
  step "oh-my-zsh" "already installed"
else
  step "oh-my-zsh" "installing"
  run 'RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
fi

# Submodules
step "Submodules" "syncing"
run "git -C '$DOTFILES' submodule update --init --recursive --quiet"

# Backups (collect first, then report once)
backed_up=()
for target in "$HOME/.zshrc" "$HOME/.zshenv" "$HOME/.vimrc" "$HOME/.config/zed/settings.json" "$HOME/.config/ghostty/config"; do
  if [[ -e "$target" && ! -L "$target" ]]; then
    backed_up+=("$(tilde "$target")")
    run "mkdir -p '$BACKUP_DIR$(dirname "$target")'"
    run "mv '$target' '$BACKUP_DIR$target'"
  fi
done
if (( ${#backed_up[@]} )); then
  step "Backups" "→ $(tilde "$BACKUP_DIR")"
  for f in "${backed_up[@]}"; do sub "$f"; done
else
  step "Backups" "nothing to back up"
fi

# Stow
step "Stow" "${STOW_PKGS[*]}"
for pkg in "${STOW_PKGS[@]}"; do
  run "stow --no-folding --dir='$DOTFILES' --target='$HOME' --restow '$pkg'"
done

# Local override stubs (seeded from .example; never overwrites existing files)
step "Local stubs"
local_pairs=(
  "zsh/.zshrc.local.example:$HOME/.zshrc.local"
  "zsh/.zshenv.local.example:$HOME/.zshenv.local"
)
for pair in "${local_pairs[@]}"; do
  src="$DOTFILES/${pair%%:*}"
  dst="${pair#*:}"
  if [[ -e "$dst" ]]; then
    sub "$(tilde "$dst") exists — leaving alone"
  else
    sub "$(tilde "$dst") ← $(tilde "$src")"
    run "cp '$src' '$dst'"
  fi
done

# Git delta config is included from the user's existing ~/.gitconfig so this
# repo does not take over identity, signing, or personal aliases.
step "git-delta" "$GIT_DELTA_INCLUDE"
if git config --global --get-all include.path 2>/dev/null | grep -Fxq "$GIT_DELTA_INCLUDE"; then
  sub "include already present"
else
  if (( DRY_RUN )); then
    sub "would add include.path $GIT_DELTA_INCLUDE"
  else
    git config --global --add include.path "$GIT_DELTA_INCLUDE"
    sub "added include.path $GIT_DELTA_INCLUDE"
  fi
fi

# Skills (delegate)
step "Skills" "via skills/install.sh"
skills_args=()
(( DRY_RUN )) && skills_args+=(--dry-run)
run "'$DOTFILES/skills/install.sh' ${skills_args[*]:-} | sed 's/^/    /'"

# npm globals
step "npm globals"
run "'$DOTFILES/scripts/install-npm-globals.sh' | sed 's/^/    /'"

printf '\n\033[1;32mDone.\033[0m\n'

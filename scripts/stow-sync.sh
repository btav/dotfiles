#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
# Multiple syncs in the same second must never reuse a previous backup.
backup_base="$BACKUP_DIR"
backup_suffix=0
while [[ -e "$BACKUP_DIR" || -L "$BACKUP_DIR" ]]; do
  backup_suffix=$((backup_suffix + 1))
  BACKUP_DIR="$backup_base-$backup_suffix"
done
STOW_PKGS=(zsh vim zed ghostty git)

step() { printf '\033[1;34m==>\033[0m %-13s %s\n' "$1" "${2:-}"; }
sub()  { printf '    %s\n' "$*"; }
tilde() { printf '%s' "${1/#$HOME/~}"; }
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
indent_run() {
  if (( DRY_RUN )); then
    printf '    '
    print_cmd "$@"
  else
    "$@" 2>&1 | sed 's/^/    /'
  fi
}

# Backups (collect first, then report once)
backed_up=()
backup_target() {
  local target="$1"
  if [[ -e "$target" || -L "$target" ]]; then
    backed_up+=("$(tilde "$target")")
    run mkdir -p "$BACKUP_DIR$(dirname "$target")"
    run mv "$target" "$BACKUP_DIR$target"
  fi
}

# Neovim owns its entire config directory: old Lua files must not survive a
# fresh starter migration. Moving a foreign symlink preserves its destination.
if [[ -L "$HOME/.config" || ( -e "$HOME/.config" && ! -d "$HOME/.config" ) ]]; then
  printf 'error: ~/.config must be a real directory before linking Neovim\n' >&2
  exit 1
fi
if [[ ! -L "$HOME/.config/nvim" || ! "$HOME/.config/nvim" -ef "$DOTFILES/nvim/.config/nvim" ]]; then
  backup_target "$HOME/.config/nvim"
  backup_target "$HOME/.local/share/nvim"
  backup_target "$HOME/.local/state/nvim"
  backup_target "$HOME/.cache/nvim"
fi

for pkg in "${STOW_PKGS[@]}"; do
  while IFS= read -r source; do
    rel="${source#"$DOTFILES/$pkg/"}"
    target="$HOME/$rel"
    if [[ -e "$target" && ! -L "$target" ]]; then
      backup_target "$target"
    fi
  done < <(find "$DOTFILES/$pkg" -type f | sort)
done
if (( ${#backed_up[@]} )); then
  step "Backups" "→ $(tilde "$BACKUP_DIR")"
  for target in "${backed_up[@]}"; do sub "$target"; done
else
  step "Backups" "nothing to back up"
fi

# Stow
step "Stow" "${STOW_PKGS[*]}"
for pkg in "${STOW_PKGS[@]}"; do
  indent_run stow --no-folding --dir="$DOTFILES" --target="$HOME" --restow "$pkg"
done

# Fold only nvim, never ~/.config. Generated config stays in the repository.
step "Stow" "nvim (directory link)"
run mkdir -p "$HOME/.config"
indent_run stow --dir="$DOTFILES" --target="$HOME" --restow nvim

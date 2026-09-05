#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
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
for pkg in "${STOW_PKGS[@]}"; do
  while IFS= read -r source; do
    rel="${source#"$DOTFILES/$pkg/"}"
    target="$HOME/$rel"
    if [[ -e "$target" && ! -L "$target" ]]; then
      backed_up+=("$(tilde "$target")")
      run mkdir -p "$BACKUP_DIR$(dirname "$target")"
      run mv "$target" "$BACKUP_DIR$target"
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

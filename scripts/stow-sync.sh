#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
OMARCHY=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --omarchy) OMARCHY=1 ;;
    *)
      printf 'Usage: %s [--dry-run] [--omarchy]\n' "$0" >&2
      exit 2
      ;;
  esac
done

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

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

stow_omarchy_package() {
  local pkg="$1"
  local source target parent conflict escaped
  local ignores=(--ignore='\.example')

  while IFS= read -r -d '' source; do
    [[ "$source" == *.example ]] && continue
    target="$HOME/${source#"$DOTFILES/$pkg/"}"
    conflict=
    [[ -e "$target" || -L "$target" ]] && conflict="$target"

    # Preserve symlinked directories and non-directories in the target path.
    parent="${target%/*}"
    while [[ "$parent" != "$HOME" ]]; do
      if [[ -L "$parent" || ( -e "$parent" && ! -d "$parent" ) ]]; then
        conflict="$parent"
      fi
      parent="${parent%/*}"
    done

    if [[ -n "$conflict" ]]; then
      # Leave working links to the package in place without reporting a conflict.
      if [[ "$conflict" != "$target" || ! -L "$target" || ! "$target" -ef "$source" ]]; then
        sub "skipping $(tilde "$target") (existing $(tilde "$conflict"))"
      fi
      escaped="$(printf '%s' "${conflict#"$HOME/"}" | sed 's/[][\\.^$*+?(){}|]/\\&/g')"
      ignores+=("--ignore=^$escaped")
    fi
  done < <(find "$DOTFILES/$pkg" -type f -print0)

  indent_run stow --no-folding --dir="$DOTFILES" --target="$HOME" --restow "${ignores[@]}" "$pkg"
}

if (( OMARCHY )); then
  STOW_PKGS=(zsh vim zed git)
  step "Stow" "${STOW_PKGS[*]}"
  for pkg in "${STOW_PKGS[@]}"; do
    stow_omarchy_package "$pkg"
  done
  exit 0
fi

STOW_PKGS=(zsh vim zed ghostty git)
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
# Multiple syncs in the same second must never reuse a previous backup.
backup_base="$BACKUP_DIR"
backup_suffix=0
while [[ -e "$BACKUP_DIR" || -L "$BACKUP_DIR" ]]; do
  backup_suffix=$((backup_suffix + 1))
  BACKUP_DIR="$backup_base-$backup_suffix"
done

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

# The nvim package was removed; drop the dangling ~/.config/nvim link its old
# directory-folding stow left behind.
if [[ -L "$HOME/.config/nvim" && ! -e "$HOME/.config/nvim" ]]; then
  run rm "$HOME/.config/nvim"
fi

# Stow
step "Stow" "${STOW_PKGS[*]}"
for pkg in "${STOW_PKGS[@]}"; do
  indent_run stow --no-folding --dir="$DOTFILES" --target="$HOME" --restow "$pkg"
done

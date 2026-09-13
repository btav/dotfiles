#!/usr/bin/env bash
set -euo pipefail

# Rectangle and its login item are macOS-only.
[[ "$(uname -s)" == "Darwin" ]] || exit 0

DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

APP_PATH="/Applications/Rectangle.app"
if [[ ! -d "$APP_PATH" && -d "$HOME/Applications/Rectangle.app" ]]; then
  APP_PATH="$HOME/Applications/Rectangle.app"
fi
if (( ! DRY_RUN )) && [[ ! -d "$APP_PATH" ]]; then
  printf 'error: Rectangle.app not found in /Applications or ~/Applications; install it with brew install --cask rectangle.\n' >&2
  exit 1
fi

run() {
  if (( DRY_RUN )); then
    printf 'DRY:'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

printf '\033[1;34m==>\033[0m Rectangle     enabling launch at login\n'

# Quit first so the running app cannot overwrite the new preference on exit.
if (( DRY_RUN )); then
  printf '    Would gracefully quit Rectangle if running and wait for it to exit.\n'
elif pgrep -x -u "$(id -u)" Rectangle >/dev/null; then
  osascript - "$APP_PATH" <<'APPLESCRIPT'
on run argv
  tell application (item 1 of argv) to quit
end run
APPLESCRIPT
  for (( attempt=0; attempt<50; attempt++ )); do
    if ! pgrep -x -u "$(id -u)" Rectangle >/dev/null; then
      break
    fi
    sleep 0.2
  done
  if pgrep -x -u "$(id -u)" Rectangle >/dev/null; then
    printf 'error: Rectangle did not quit; quit it manually and rerun setup.\n' >&2
    exit 1
  fi
fi

run defaults write com.knollsoft.Rectangle launchOnLogin -bool true
# Use the installed path: Launch Services may not know a fresh install's ID yet.
run open -g "$APP_PATH"

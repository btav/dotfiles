#!/usr/bin/env bash
set -euo pipefail

if ! command -v npm >/dev/null 2>&1; then
  echo "npm not found. Install Node first (brew install node, or nvm install --lts)." >&2
  exit 1
fi

PACKAGES=(
  "@openai/codex"
  "@google/gemini-cli"
  "pnpm"
)

for pkg in "${PACKAGES[@]}"; do
  echo "==> npm i -g $pkg"
  npm install -g "$pkg"
done

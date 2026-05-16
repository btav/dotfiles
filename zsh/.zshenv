# Sourced by every zsh (interactive, non-interactive, scripts).
# Put env vars and PATH tweaks that *every* shell needs here.
# Interactive-only stuff goes in .zshrc.

# Homebrew (must be first — downstream PATH entries depend on brew-installed binaries)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Node Version Manager — variable only; the slow `source nvm.sh` lives in .zshrc
export NVM_DIR="$HOME/.nvm"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Rust
export PATH="$HOME/.cargo/bin:$PATH"

# Go
export PATH="$HOME/go/bin:$PATH"

# Personal bin (also where `uv tool install` shims land)
export PATH="$HOME/.local/bin:$PATH"

# Node V8 compile cache — stores bytecode so repeated `node` invocations
# (eslint, prettier, tsc, scripts) skip parse+compile on cold start.
export NODE_COMPILE_CACHE="$HOME/.cache/node-compile-cache"

# Claude Code settings
export CLAUDE_CODE_NO_FLICKER=1

# Local overrides (machine-specific, not committed)
[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local

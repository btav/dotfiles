# Sourced by every zsh (interactive, non-interactive, scripts).
# Put env vars and PATH tweaks that *every* shell needs here.
# Interactive-only stuff goes in .zshrc.

# Homebrew (must be first — downstream PATH entries depend on brew-installed binaries)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

path_prepend_once() {
  local dir="$1"
  [[ -n "$dir" ]] || return
  case ":$PATH:" in
    *":$dir:"*) ;;
    *) export PATH="$dir:$PATH" ;;
  esac
}

# Node Version Manager — variable only; the slow `source nvm.sh` lives in .zshrc
export NVM_DIR="$HOME/.nvm"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
path_prepend_once "$PNPM_HOME/bin"

# Bun
export BUN_INSTALL="$HOME/.bun"
path_prepend_once "$BUN_INSTALL/bin"

# Rust
path_prepend_once "$HOME/.cargo/bin"

# Go
path_prepend_once "$HOME/go/bin"

# Personal bin (also where `uv tool install` shims land)
path_prepend_once "$HOME/.local/bin"

# Node V8 compile cache — stores bytecode so repeated `node` invocations
# (eslint, prettier, tsc, scripts) skip parse+compile on cold start.
export NODE_COMPILE_CACHE="$HOME/.cache/node-compile-cache"

# Claude Code settings
export CLAUDE_CODE_NO_FLICKER=1

# Local overrides (machine-specific, not committed)
[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local

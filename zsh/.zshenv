# Sourced by every zsh (interactive, non-interactive, scripts).
# Put env vars and PATH tweaks that *every* shell needs here.
# Interactive-only stuff goes in .zshrc.

# Homebrew (must be first — downstream PATH entries depend on brew-installed binaries)
if [[ $OSTYPE == darwin* ]]; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

path_prepend_once() {
  local dir="$1"
  [[ -n "$dir" ]] || return
  case ":$PATH:" in
    *":$dir:"*) ;;
    *) export PATH="$dir:$PATH" ;;
  esac
}

dotfiles_omarchy=0
if [[ $OSTYPE == linux* ]] && (( $+commands[omarchy] )); then
  dotfiles_omarchy=1
  export PNPM_HOME="${PNPM_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/pnpm}"
else
  # The slow `source nvm.sh` lives in .zshrc.
  export NVM_DIR="$HOME/.nvm"
  export PNPM_HOME="$HOME/Library/pnpm"
fi
path_prepend_once "$PNPM_HOME/bin"

# Bun
export BUN_INSTALL="$HOME/.bun"
path_prepend_once "$BUN_INSTALL/bin"

# Rust
path_prepend_once "$HOME/.cargo/bin"

# Go
path_prepend_once "$HOME/go/bin"

# Personal bin (also where `uv tool install` shims land)
if (( dotfiles_omarchy )); then
  # Keep Omarchy's mise shims and wrappers ahead of local executables.
  case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$PATH:$HOME/.local/bin" ;;
  esac
else
  path_prepend_once "$HOME/.local/bin"
fi

# Launchers for claude, codex, opencode and pi (written by install-npm-globals.sh).
# Kept first so they win over other installed copies; .zshrc re-runs this
# after `nvm use`.
if (( ! dotfiles_omarchy )); then
  promote_ai_tools() {
    local dir="$HOME/.local/share/ai-tools/bin"
    [[ -d "$dir" ]] || return
    path=("$dir" "${(@)path:#$dir}")
    export PATH
  }
  promote_ai_tools
fi
unset dotfiles_omarchy

# Node V8 compile cache — stores bytecode so repeated `node` invocations
# (eslint, prettier, tsc, scripts) skip parse+compile on cold start.
export NODE_COMPILE_CACHE="$HOME/.cache/node-compile-cache"

# Claude Code settings
export CLAUDE_CODE_NO_FLICKER=1

# Default terminal editor
export EDITOR=vim
export VISUAL=vim

# Local overrides (machine-specific, not committed)
[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local

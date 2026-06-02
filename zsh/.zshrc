# Env vars and PATH live in .zshenv (sourced by every shell).
# This file is interactive-only: aliases, prompt, plugins, completions.

# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="awesomepanda"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# History
HISTSIZE=100000
SAVEHIST=100000
HISTFILE="$HOME/.zsh_history"
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS INC_APPEND_HISTORY

# Aliases
alias amend="git commit --amend --no-edit"
alias gd='git diff'
alias reload='exec zsh'

# Modern CLI swaps (only if installed)
command -v eza >/dev/null && {
  alias l='eza -l --git --icons'
  alias ll='eza -la --git --icons'
  alias lt='eza --tree --level=2'
}
command -v bat >/dev/null && alias cat='bat --paging=never --style=plain'

# Node Version Manager — slow source, interactive only ($NVM_DIR set in .zshenv)
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Bun completions ($BUN_INSTALL set in .zshenv)
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# zoxide — `z foo` jumps to the most-frecent dir matching "foo"
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# fzf — Ctrl+R fuzzy history, Ctrl+T fuzzy file picker, Alt+C fuzzy cd
command -v fzf >/dev/null && source <(fzf --zsh)

# zsh-autosuggestions — gray ghost text from history; right-arrow to accept
[[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Local overrides (machine-specific, not committed)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# zsh-syntax-highlighting — colors invalid commands red. MUST be sourced last.
[[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# pnpm
export PNPM_HOME="/Users/bfariastavares/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

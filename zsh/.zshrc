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

# Git shortcuts
alias gs='git status -sb'
alias gl='git log --oneline -20'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gp='git push'
alias gpu='git pull'
alias grb='git rebase -i'
alias stash='git stash'
alias pop='git stash pop'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Safety nets
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

# Quick edits
alias zshrc='${EDITOR:-vim} ~/.zshrc'

# Misc
alias ports='lsof -iTCP -sTCP:LISTEN -n -P'
alias ip='curl -s ifconfig.me'

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
if command -v brew >/dev/null; then
  brew_prefix="$(brew --prefix)"
  [[ -f "$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
    source "$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# Local overrides (machine-specific, not committed)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# zsh-syntax-highlighting — colors invalid commands red. MUST be sourced last.
if [[ -n "${brew_prefix:-}" ]]; then
  [[ -f "$brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
    source "$brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

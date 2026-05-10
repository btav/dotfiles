# dotfiles

btav macOS dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/)

## What's in here

**AI coding agents**

- [Claude Code](https://claude.com/claude-code) (Homebrew cask)
- [Codex CLI](https://github.com/openai/codex) — `@openai/codex` (npm global)
- [`skills/`](https://github.com/btav/skills) — shared skill library, symlinked into both `~/.claude/skills/` and `~/.codex/skills/` (git submodule)

**Apps**

- [Ghostty](https://ghostty.org/) — terminal (cask + config at `~/.config/ghostty/config`)
- [Zed](https://zed.dev/) — editor (cask + config at `~/.config/zed/settings.json`)

**Shell**

- `zsh` with [oh-my-zsh](https://ohmyz.sh/), `zsh-autosuggestions`, `zsh-syntax-highlighting`
- Configs: `~/.zshrc`, `~/.zshenv` (from `zsh/`)
- `~/.zshrc.local` for machine-specific overrides (gitignored)

**CLI tools** (Homebrew)

- `gh`, `jq`, `ripgrep`, `bat`, `eza`, `fzf`, `zoxide`, `git-delta`
- `node`, `nvm`, `bun`
- `stow` — the orchestrator that symlinks everything else

**Git**

- `git/.config/git/delta.gitconfig` — git-delta pager config, *included from* your existing `~/.gitconfig` so this repo never overwrites identity, signing, or personal aliases

**Fonts**

- JetBrains Mono Nerd Font

## How to run

```sh
git clone --recurse-submodules https://github.com/btav/dotfiles.git ~/code/dotfiles
cd ~/code/dotfiles
./install.sh           # or ./install.sh --dry-run to preview
```

## Day-to-day

- Re-stow after adding files to a package: `stow --no-folding --restow zsh`.
- Pull skills updates: `git submodule update --remote skills`.

## Local overrides

Anything machine-specific (work secrets, ad-hoc exports) goes in `~/.zshrc.local`. It's gitignored and sourced from `.zshrc` if present. See `zsh/.zshrc.local.example`.

# dotfiles

Personal macOS dotfiles, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## What's in here

| Package    | Manages                                                                     |
| ---------- | --------------------------------------------------------------------------- |
| `zsh/`     | `~/.zshrc`, `~/.zshenv`                                                     |
| `vim/`     | `~/.vimrc`                                                                  |
| `zed/`     | `~/.config/zed/settings.json`                                               |
| `ghostty/` | `~/.config/ghostty/config`                                                  |
| `skills/`  | git submodule of [btav/skills](https://github.com/btav/skills); its own `install.sh` symlinks each skill into both `~/.claude/skills/` and `~/.codex/skills/` |

Plus:

- `Brewfile` — installs CLI tools (`stow`, `gh`, `jq`, `ripgrep`, `bat`, `eza`, `fzf`, `zoxide`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `node`, `nvm`, `bun`), apps (`ghostty`, `zed`, `claude-code`), and `JetBrains Mono Nerd Font`.
- `scripts/install-npm-globals.sh` — installs `@openai/codex` (and any other npm-global CLIs added later).
- `install.sh` — idempotent bootstrap. Safe to run repeatedly.

## Bootstrap a new machine

```sh
git clone --recurse-submodules https://github.com/btav/dotfiles.git ~/code/dotfiles
cd ~/code/dotfiles
./install.sh           # or ./install.sh --dry-run to preview
```

## Day-to-day

- Edit a config in this repo → it's already symlinked into `~`, so changes take effect immediately.
- Add a new package: `mkdir -p newtool/.config/newtool && stow --no-folding newtool`.
- Re-stow after adding files: `stow --no-folding --restow zsh`.
- Pull skills updates: `git submodule update --remote skills`.

## First-time migration (one-shot)

If you're switching from a hand-managed setup, after the first `./install.sh` clean these up manually — none of them break anything if left, but they're stale:

- `~/Library/Application Support/com.mitchellh.ghostty/config` — Ghostty now reads `~/.config/ghostty/config`. Delete the old file once you've confirmed the new one loads.
- `~/.profile` — duplicates `~/.zshenv` (both source `~/.cargo/env`). Zsh ignores it; safe to delete.
- `~/code/skills` — old standalone clone of the skills repo. Skills now live in `dotfiles/skills/` (submodule). Safe to delete after verifying skills still load in Claude.

## Local overrides

Anything machine-specific (work secrets, ad-hoc exports) goes in `~/.zshrc.local`. It's gitignored and sourced from `.zshrc` if present. See `zsh/.zshrc.local.example`.

## What's deliberately not managed here

- `~/.gitconfig` — stays local.
- `~/.config/gh/` — stays local (`hosts.yml` carries auth).
- `~/.ssh/` — never.
- `~/.claude/` — only `skills/` is symlinked from this repo. Settings, projects, and credentials stay local.

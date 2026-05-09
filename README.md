# dotfiles

btav macOS dotfiles, managed with [GNU Stow](https://www.gnu.org/software/stow/)

## What's in here

**Stow packages** (symlinked into `~`):

- `zsh/` → `~/.zshrc`, `~/.zshenv`
- `vim/` → `~/.vimrc`
- `zed/` → `~/.config/zed/settings.json`
- `ghostty/` → `~/.config/ghostty/config`

**Bootstrap**:

- `Brewfile` — CLI tools, GUI apps, and fonts installed via Homebrew
- `scripts/install-npm-globals.sh` — npm-global CLIs
- `install.sh` — idempotent runner that wires everything together

**Submodule**:

- `skills/` → [btav/skills](https://github.com/btav/skills); its own `install.sh` links each skill into `~/.claude/skills/` and `~/.codex/skills/`

## How to run

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

## Local overrides

Anything machine-specific (work secrets, ad-hoc exports) goes in `~/.zshrc.local`. It's gitignored and sourced from `.zshrc` if present. See `zsh/.zshrc.local.example`.

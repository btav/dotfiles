# dotfiles

btav macOS dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/)

## What's in here

**AI coding agents**

- [Claude Code](https://claude.com/claude-code) (Homebrew cask)
- [Codex CLI](https://github.com/openai/codex) — `@openai/codex` (npm global)
- [Gemini CLI](https://github.com/google-gemini/gemini-cli) — `@google/gemini-cli` (npm global)
- [Pi Coding Agent](https://www.npmjs.com/package/@earendil-works/pi-coding-agent) — `@earendil-works/pi-coding-agent` (npm global)
- [`skills/`](https://github.com/btav/skills) — shared skill library, symlinked for all AI coding agents (git submodule)

**Apps**

- [Ghostty](https://ghostty.org/) — terminal (cask + config at `~/.config/ghostty/config`)
- [Zed](https://zed.dev/) — editor (cask + config at `~/.config/zed/settings.json`)

**Shell**

- `zsh` with [oh-my-zsh](https://ohmyz.sh/), `zsh-autosuggestions`, `zsh-syntax-highlighting`
- `~/.zshenv` — env vars + PATH (sourced by every shell, so editors/scripts see them)
- `~/.zshrc` — interactive-only: aliases, prompt, completions, plugins
- `~/.zshenv.local` and `~/.zshrc.local` for machine-specific overrides (gitignored, seeded from `.example` stubs by `install.sh`)

**CLI tools** (Homebrew)

- `gh`, `jq`, `ripgrep`, `bat`, `eza`, `fzf`, `zoxide`, `git-delta`
- `stow` — the orchestrator that symlinks everything else

**Languages** (Homebrew, version managers — install runtimes per-machine)

- JavaScript / TypeScript — `node`, `bun`, `pnpm` (Homebrew); `nvm` (official installer, pinned in `install.sh`)
- Rust — `rustup` (bootstrapped to stable on first `install.sh` run; `cargo`/`rustc` land in `~/.cargo/bin`)
- Go — `go` (`go install` binaries land in `~/go/bin`)
- Python — `uv` (Python 3.13 bootstrapped on first `install.sh` run as the default; `python`/`python3` shims land in `~/.local/bin`. Tools with `uv tool install <pkg>`.)

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

- Update Homebrew packages/casks, npm globals, and Rust toolchains: `./update.sh`.
- Re-stow after adding files to a package: `stow --no-folding --restow zsh`.
- Pull skills updates: `git submodule update --remote skills`.

`update.sh` does not update git submodules, nvm, or installed Python runtime versions.

## Local overrides

Machine-specific config is split by scope, mirroring the `.zshenv` / `.zshrc` divide:

- `~/.zshenv.local` — env vars, PATH entries, API keys. Sourced by every shell, so editors and subprocesses see them too.
- `~/.zshrc.local` — interactive-only: extra aliases, prompt tweaks.

Both are gitignored. `install.sh` seeds them from `zsh/.zshenv.local.example` and `zsh/.zshrc.local.example` on first run and never overwrites existing files.

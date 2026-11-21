# dotfiles

btav macOS and Omarchy setup managed with [GNU Stow](https://www.gnu.org/software/stow/).

It installs development tools and apps, then links configuration for Zsh, Vim, Git, and Zed into the home directory. The macOS setup also links the Ghostty config.

The package lists are the sources of truth.

- [Brewfile](Brewfile) for Homebrew formulae and casks
- [scripts/install-npm-globals.sh](scripts/install-npm-globals.sh) for macOS global npm packages
- [scripts/omarchy.sh](scripts/omarchy.sh) for Omarchy packages and the mise pnpm pin
- [skills](skills/) for shared AI coding-agent skills

## Install

```sh
git clone --recurse-submodules https://github.com/btav/dotfiles.git
cd dotfiles
./install.sh
```

Use `./install.sh --dry-run` to preview the setup. The entry points select the platform automatically.

### macOS

The installer does the following.

- installs Homebrew and the dependencies in `Brewfile`
- installs nvm, a stable Rust toolchain, and Python 3.13 through uv
- syncs submodules and installs global npm packages and shared skills
- backs up conflicting config files before stowing this repository's config

### Omarchy

Run the installer as your regular user on Omarchy 4.5 with `omarchy` and `mise` on `PATH`. Omarchy handles authorization for installing Arch packages. The installer links Zsh, Vim, Zed, and Git configs with Stow. It reports existing files and symlinks that would conflict and leaves them in place. The Git delta include is added only when the managed delta config is linked.

Omarchy continues to use Bash and Foot. Run `zsh` whenever you want this repo's interactive shell. Omarchy's mise setup supplies Node, Codex, Claude Code, Pi, and uv. The installer adds `pnpm@11` to your personal mise config and links the shared skills. Set up Go, Rust, and Python through Omarchy or the project's own mise configuration.

If you use Ghostty on Omarchy, add your preferences to the Omarchy-provided Ghostty config so it retains its dynamic theme and keybindings.

## Update

```sh
./update.sh
```

On macOS, the update script refreshes Homebrew metadata, installs or upgrades dependencies from `Brewfile`, backs up conflicting managed files, re-links the managed Stow packages so newly added config files are applied, updates the global npm packages (`pnpm` remains on major version 11), and updates installed Rust toolchains.

The npm packages install under your default nvm Node. Codex, Claude Code, OpenCode, and Pi run through launchers in `~/.local/share/ai-tools/bin`, so they stay on that Node after `nvm use`; pnpm follows the active Node. The launchers point at a specific Node version, so run `./update.sh` again after you change the nvm default.

The macOS updater leaves nvm and installed Python versions in place. On Omarchy, `./update.sh` reapplies the repo's package list, pnpm pin, and Stow links. Use `omarchy update` for Omarchy system and tool upgrades.

Pass `--skills` to also update the skills submodule to its latest revision.

```sh
./update.sh --skills
```

The submodule bump then shows as a pending change in this repository, ready to commit.

## Customize

Machine-specific shell configuration goes in these files.

- `~/.zshenv.local` for environment variables, PATH entries, and secrets
- `~/.zshrc.local` for interactive aliases and prompt changes

The macOS installer copies the included examples into place when the files are missing. On Omarchy you can create them by hand when you need overrides.

After adding files to a Stow package, re-link it from the repository root:

```sh
stow --no-folding --restow zsh
```

## What lives where

- `~/.local/share/ai-tools/bin` — launchers pinning AI tools to the default nvm Node (written by `scripts/install-npm-globals.sh`)
- `~/.dotfiles-backup-<timestamp>` — conflicting config backups made by stow-sync; they accumulate and are never cleaned automatically
- `~/.zshenv.local` / `~/.zshrc.local` — machine-specific overrides, never overwritten

## Editors

`EDITOR` and `VISUAL` default to `vim`; override them in `~/.zshenv.local`.

Use `e` in Zsh to open the current directory in Zed. It supports both `zed` and the Arch package's `zeditor` command.

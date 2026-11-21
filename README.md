# dotfiles

btav macOS and Linux dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). The Linux installer currently supports Omarchy 4.5.

It installs development tools and apps, then links configuration for Zsh, Vim, Git, and Zed into the home directory. The macOS setup also links the Ghostty config.

The package lists are the sources of truth.

- [Brewfile](Brewfile) for Homebrew formulae and casks
- [scripts/install-npm-globals.sh](scripts/install-npm-globals.sh) for macOS global npm packages
- [scripts/linux.sh](scripts/linux.sh) for Linux packages and the mise pnpm pin
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

### Linux

Run the installer as your regular user with `omarchy` and `mise` on `PATH`. It uses `omarchy pkg add` to install missing Arch packages and Stow to link Zsh, Vim, Zed, and Git configs. It reports and skips conflicts with existing files and symlinks. The Git delta include is added only when the managed delta config is linked.

Run `zsh` from Foot or another terminal to use this repo's interactive shell. The system's mise defaults supply Node, Codex, Claude Code, Pi, and uv. The installer adds `pnpm@12` to your personal mise config and links the shared skills. Set up Go, Rust, and Python through the desktop menu or your project's mise configuration.

If you use Ghostty, add your preferences to its existing config so it retains its dynamic theme and keybindings.

## Update

```sh
./update.sh
```

On macOS, the update script refreshes Homebrew metadata, installs or upgrades dependencies from `Brewfile`, backs up conflicting managed files, re-links the managed Stow packages so newly added config files are applied, updates the global npm packages (`pnpm` remains on major version 11), and updates installed Rust toolchains.

The npm packages install under your default nvm Node. Codex, Claude Code, OpenCode, and Pi run through launchers in `~/.local/share/ai-tools/bin`, so they stay on that Node after `nvm use`; pnpm follows the active Node. The launchers point at a specific Node version, so run `./update.sh` again after you change the nvm default.

The macOS updater leaves nvm and installed Python versions in place. On Linux, `./update.sh` reapplies the repo's package list, pnpm pin, and Stow links. Run it to migrate an existing Linux install to pnpm 12. Use `omarchy update` for system and tool upgrades.

Pass `--skills` to also update the skills submodule to its latest revision.

```sh
./update.sh --skills
```

The submodule bump then shows as a pending change in this repository, ready to commit.

## Customize

Machine-specific shell configuration goes in these files.

- `~/.zshenv.local` for environment variables, PATH entries, and secrets
- `~/.zshrc.local` for interactive aliases and prompt changes

The macOS installer copies the included examples into place when the files are missing. On Linux you can create them by hand when you need overrides.

After adding files to a Stow package on Linux, run `./scripts/stow-sync.sh --linux` from the repository root to apply the new links with conflict checks.

On macOS, you can re-link a single package from the repository root. For Zsh, run the following command.

```sh
stow --no-folding --target="$HOME" --restow zsh
```

## What lives where

- `~/.local/share/ai-tools/bin` — launchers pinning AI tools to the default nvm Node (written by `scripts/install-npm-globals.sh`)
- `~/.dotfiles-backup-<timestamp>` — conflicting config backups made by stow-sync; they accumulate and are never cleaned automatically
- `~/.zshenv.local` / `~/.zshrc.local` — machine-specific overrides, never overwritten

## Editors

`EDITOR` and `VISUAL` default to `vim`; override them in `~/.zshenv.local`.

Use `e` in Zsh to open the current directory in Zed. It supports both `zed` and the Arch package's `zeditor` command.

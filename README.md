# dotfiles

btav macOS setup managed with [GNU Stow](https://www.gnu.org/software/stow/).

It installs development tools and apps, then links configuration for zsh, Vim, Neovim (LazyVim), Git, Ghostty, and Zed into the home directory.

The package lists are the sources of truth:

- [Brewfile](Brewfile) for Homebrew formulae and casks
- [scripts/install-npm-globals.sh](scripts/install-npm-globals.sh) for global npm packages
- [skills](skills/) for shared AI coding-agent skills

## Install

```sh
git clone --recurse-submodules https://github.com/btav/dotfiles.git
cd dotfiles
./install.sh
```

Use `./install.sh --dry-run` to preview the setup. The installer:

- installs Homebrew and the dependencies in `Brewfile`
- installs nvm, a stable Rust toolchain, and Python 3.13 through uv
- syncs submodules and installs global npm packages and shared skills
- backs up conflicting config files before stowing this repository's config

## Update

```sh
./update.sh
```

The update script refreshes Homebrew metadata, installs or upgrades dependencies from `Brewfile`, backs up conflicting managed files, re-links the managed Stow packages so newly added config files are applied, updates the global npm packages (`pnpm` remains on major version 11), and updates installed Rust toolchains.

It does not update git submodules, nvm, or installed Python versions. Update the skills submodule separately:

```sh
git submodule update --remote skills
```

## Customize

Machine-specific shell configuration belongs in:

- `~/.zshenv.local` for environment variables, PATH entries, and secrets
- `~/.zshrc.local` for interactive aliases and prompt changes

The installer creates these files from the included examples when they do not already exist and never overwrites them.

After adding files to a Stow package, re-link it from the repository root:

```sh
stow --no-folding --restow zsh
```

## Neovim / LazyVim

Run `./install.sh` (or `./update.sh` on an existing setup), then launch `nvim`.
The first launch downloads plugins and supporting tools and requires internet
access. Run `:LazyHealth` afterward. A C compiler is required for Tree-sitter;
on macOS, install the Command Line Tools with `xcode-select --install` if missing.
Homebrew supplies Neovim, tree-sitter, and lazygit; Ghostty already uses the
included Nerd Font.

`EDITOR` and `VISUAL` default to `nvim`; override them in `~/.zshenv.local`.
The existing `vim` command and configuration remain available.

The config in `nvim/.config/nvim` comes from the
[official LazyVim starter](https://github.com/LazyVim/starter/tree/803bc181d7c0d6d5eeba9274d9be49b287294d99).
Customize `lua/config/` for options, keymaps, and autocmds, or add plugin specs
under `lua/plugins/`. The included example plugin file is disabled. Use
`:LazyExtras` to choose optional features. Commit changes to `lazyvim.json` and
`lazy-lock.json` along with your Lua configuration.

Use `:Lazy update` to upgrade plugins intentionally, or `:Lazy restore` after
pulling a changed lockfile to apply its recorded versions. `./update.sh` upgrades
Homebrew tools and re-links configs; it does not upgrade Neovim plugins.

Neovim uses a whole-directory symlink so newly created configuration files and
lockfile updates belong to this repo. Re-link it with `./scripts/stow-sync.sh`,
which keeps `~/.config` a real directory. Standard Neovim paths are assumed;
custom `XDG_*` or `NVIM_APPNAME` settings require a separate setup.

On initial migration, the helper moves existing `~/.config/nvim`,
`~/.local/share/nvim`, `~/.local/state/nvim`, and `~/.cache/nvim` into the printed
`~/.dotfiles-backup-<timestamp>` directory, preserving their full home paths
inside the backup. Foreign symlinks are moved without touching their destinations.
Subsequent runs recognize this repo's config link and preserve runtime state.
Preview the migration with `./scripts/stow-sync.sh --dry-run`.

To roll back, unstow Neovim with `stow --delete nvim` from this repository,
move any newly created Neovim data/state/cache directories aside, and move the
saved paths back from the printed backup directory. Restore any editor preference
in `~/.zshenv.local`. Running install/update again will reapply the migration.

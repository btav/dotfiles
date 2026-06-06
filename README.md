# dotfiles

btav macOS setup managed with [GNU Stow](https://www.gnu.org/software/stow/).

It installs development tools and apps, then links configuration for zsh, Vim, Git, Ghostty, and Zed into the home directory.

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

The update script refreshes Homebrew metadata, installs or upgrades dependencies from `Brewfile`, updates the global npm packages (`pnpm` remains on major version 11), and updates installed Rust toolchains.

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

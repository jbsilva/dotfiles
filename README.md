# dotfiles

Personal configuration for macOS (nix-darwin + Homebrew), Arch Linux and WSL.

```
just            # list every task
just switch     # apply the nix-darwin configuration on macOS
just check      # lint, spell-check and scan for secrets
```

---

## Read this first: `~/.config` is a symlink into this repo

```
~/.config -> ~/dotfiles/.config
~/.zsh    -> ~/dotfiles/.zsh
```

Every application on the machine therefore writes its runtime state **inside a
git repository**. Colima's VM image alone is ~18 GB in `.config/colima/`.

Because of that, `.gitignore` is an **allow-list**, not a deny-list: everything
under `.config/` is ignored, git is allowed to descend into directories, and
only explicitly listed files are trackable.

To start tracking a new config file:

1. add a `!/.config/path/to/file` line to the allow-list in `.gitignore`
2. `git add .config/path/to/file`

`git check-ignore -v <path>` explains why any given path is ignored.

> **Why an allow-list?** With a deny-list, every newly installed application
> silently drops files into a tracked directory, and a single `git add -A`
> publishes whatever tokens, cookies or session state they happen to contain.
> The allow-list fails closed instead.

A `pre-commit` hook (`.githooks/pre-commit`) runs [gitleaks] on staged changes
as a second line of defence, since `git add -f` bypasses `.gitignore`. Enable it
once per clone:

```sh
just hooks      # git config core.hooksPath .githooks
```

---

## Layout

| Path | What it is |
| --- | --- |
| `nix-darwin/` | The flake: macOS system + Homebrew + home-manager |
| `.zshrc`, `.zsh/` | Interactive shell. `.zsh/*.zsh` is auto-sourced |
| `.zshrc_light`, `.zsh/zplug_light.zsh` | Slimmer profile for low-power/remote machines (still uses Powerlevel10k) |
| `.config/nvim/` | Neovim, lazy.nvim + native LSP |
| `.config/` | Everything else XDG, see the allow-list note above |
| `.gitconfig-global` + `-linux`/`-wsl`/`-windows` | git config for the **non**-nix machines. macOS git is configured in `nix-darwin/modules/home-manager/programs/git.nix` |
| `.gitignore-global` | `core.excludesfile` for those machines |
| `XCompose/` | Vendored from [kragen/xcompose] |
| `xorg.conf.d/`, `boot/`, `Xsetup`, `bin/` | Arch Linux desktop |
| `Justfile` | Task runner |

Submodules: `.tmux` ([gpakosz/.tmux] fork) and `.config/kitty/kitty-themes`.
Clone with `git clone --recurse-submodules`.

---

## macOS: nix-darwin

The flake lives in `nix-darwin/` and the configuration is named after the host
(`M4`). Package management is split three ways on purpose:

- **nixpkgs** (`modules/packages.nix`) — CLI tooling, grouped by purpose.
- **Homebrew** (`modules/homebrew.nix`) — GUI casks, and formulae that move
  faster than nixpkgs (`yt-dlp`) or are macOS-specific (`pinentry-mac`). Taps
  are pinned as flake inputs and `mutableTaps = false`, so `brew` cannot drift.
- **home-manager** (`modules/home-manager/`) — per-user config: git, gnupg,
  direnv, zsh, plus `activation/` scripts for things macOS offers no API for
  (default apps, removing login items).

### Everyday commands

```sh
just build      # build without activating -- always do this before switch
just switch     # sudo darwin-rebuild switch
just diff       # show what a rebuild would change (nvd)
just update     # nix flake update
just gc         # collect garbage older than 14d, optimise the store
```

`nh` is installed as a friendlier front-end: `just nhs` wraps
`nh darwin switch`, which shows a package diff automatically.

Garbage collection and store optimisation also run on a timer
(`modules/nix.nix`), so manual `gc` is rarely needed.

### Two gotchas worth knowing

**1. The flake only sees git-tracked files.**

The flake resolves to `git+file:///Users/julio/dotfiles?dir=nix-darwin`, so Nix
copies the *git tree*, not the working directory. A brand-new file is invisible
until it is staged:

```
error: Path 'nix-darwin/modules/foo.nix' in the repository ... is not tracked by Git.
```

Fix with `git add nix-darwin/modules/foo.nix`. Modifications to already-tracked
files are picked up without staging.

**2. `.zshrc` is baked into the Nix store.**

`modules/home-manager/programs/zsh.nix` does
`initContent = builtins.readFile ../../../../.zshrc`, so `~/.zshrc` is a
read-only symlink into `/nix/store`. Editing `.zshrc` in this repo has no effect
until `just switch`. To iterate quickly, test in a throwaway `ZDOTDIR`:

```sh
mkdir -p /tmp/zt && cp .zshrc /tmp/zt/.zshrc
ZDOTDIR=/tmp/zt zsh -i
```

---

## Zsh

Plugins are **Nix packages**, declared in
`nix-darwin/modules/home-manager/programs/zsh.nix` and sourced straight out of
`/nix/store`. There is no plugin manager: zplug used to `git clone` itself from
inside `.zshrc`, so shell startup could hit the network and nothing was pinned.

| Was (zplug) | Now |
| --- | --- |
| Prezto `autosuggestions` / `syntax-highlighting` / `history-substring-search` | home-manager's built-in options (it gets the load order right) |
| Prezto `editor` (vi keys) | `defaultKeymap = "viins"` |
| Prezto `completion` | `enableCompletion` + `zsh-completions` |
| Prezto `fasd` | zoxide |
| Prezto `terminal` / `archive` / `utility` | ~40 lines of plain zsh in `.zshrc` |
| `djui/alias-tips` | `zsh-you-should-use` |
| `zdharma-continuum/history-search-multi-word` | same, from nixpkgs |
| `hlissner/zsh-autopair` | same, from nixpkgs |
| `seebi/dircolors-solarized` | `vivid` |
| `supercrabtree/k` | `eza` |
| `z-shell/zsh-diff-so-fancy` | `delta` |
| `b4b4r07/emoji-cli` | pinned `fetchFromGitHub` (unmaintained since 2017) |

Startup went from **1.80 s to 0.45 s** (`just bench-shell`).

> `programs.zsh.plugins` is deliberately *not* used. That option materialises
> plugins under `~/.zsh/plugins`, and `~/.zsh` is a symlink into this repo, so
> it would write generated store symlinks into your working tree.

**`.zshrc` stays self-contained** so the Arch and WSL machines still work: it
holds its own history, options, aliases and keybindings, and falls back to
zplug + Prezto when `DOTFILES_PLUGINS_FROM_NIX` is unset (exported from
`~/.zshenv` by home-manager). `.zsh/zplug.zsh` is that fallback's plugin list
and is still live for those machines.

---

## Neovim

lazy.nvim, with Neovim 0.11+ native LSP (`vim.lsp.config`/`vim.lsp.enable`) —
no lsp-zero, no nvim-cmp. Servers are installed by Mason.

```
:Lazy           plugin UI          :Lazy profile   startup cost per plugin
:Mason          LSP/DAP installs   :checkhealth    diagnose problems
```

Set up for Python and JavaScript/TypeScript in particular:

| | |
| --- | --- |
| Python | pyright (types) + ruff (lint, imports), pytest via neotest, debugpy |
| JS/TS | vtsls + eslint (fix on save), jest via neotest, js-debug |
| Format | conform.nvim, `<leader>F` |
| Test | `<leader>tn` nearest, `<leader>tt` file, `<leader>td` debug |
| Debug | `<leader>db` breakpoint, `<leader>dc` continue, `<leader>dt` UI |

pyright and neotest both resolve the project virtualenv (`$VIRTUAL_ENV`,
`.venv/`, `venv/`), so imports resolve without extra configuration.

`nvim-treesitter` tracks its `main` branch, which needs the `tree-sitter` CLI to
build parsers — it is declared in `packages.nix`.

---

## Checks

```sh
just check          # everything below
just check-nix      # nix flake check + statix + deadnix
just check-shell    # shellcheck for sh/bash, zsh -n for zsh
just check-typos    # typos
just scan           # gitleaks over all history
just fmt            # nixfmt + shfmt + stylua
just bench-shell    # hyperfine 'zsh -i -c exit'
```

---

## New machine

```sh
git clone --recurse-submodules git@github.com:jbsilva/dotfiles.git ~/dotfiles
ln -s dotfiles/.config ~/.config
ln -s dotfiles/.zsh    ~/.zsh
cd ~/dotfiles && just hooks

# macOS: install Nix, then
just switch
```

On Linux/WSL, `~/.gitconfig` should point at the matching `.gitconfig-<os>`
file, and `.zshrc` (or `.zshrc_light`) is symlinked from `$HOME` directly.

[gitleaks]: https://github.com/gitleaks/gitleaks
[kragen/xcompose]: https://github.com/kragen/xcompose
[gpakosz/.tmux]: https://github.com/gpakosz/.tmux

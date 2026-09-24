# dotfiles

Personal configuration for macOS (nix-darwin + Homebrew), Arch Linux and WSL.

```
just            # list every task
just switch     # apply the nix-darwin configuration on macOS
just check      # lint, spell-check and scan for secrets
```

______________________________________________________________________

## How `~/.config` is wired

`~/.config` is a **real directory**. Individual files are linked back into it from this repo by
`nix-darwin/modules/home-manager/xdg.nix`:

```
~/.config/nvim                    -> ~/dotfiles/.config/nvim
~/.config/Code/User/settings.json -> ~/dotfiles/.config/Code/User/settings.json
~/.config/gh/hosts.yml            -> ~/dotfiles/.config/gh/hosts.yml
~/.config/ghostty/config          -> ~/dotfiles/.config/ghostty/config
...
~/.zsh                            -> ~/dotfiles/.zsh          (still a whole dir)
```

Never make it one symlink, `~/.config -> ~/dotfiles/.config`. Every application then writes its
runtime state **inside the git repo**: VM images, caches and session state, and Linux-only files
turn up on macOS. Per-file links keep the repo to what is actually tracked.

The links use home-manager's `mkOutOfStoreSymlink`, not the usual `home.file.source`, because these
files have to stay **writable and live**: VS Code rewrites `settings.json`, `gh` rewrites
`hosts.yml`, lazy.nvim writes `lazy-lock.json`. A normal `home.file` would point at a read-only
`/nix/store` path, and editing a config would need a rebuild to take effect.

**Granularity rule:** link a whole directory only when it is entirely ours (`nvim`). Where an
application keeps its own state alongside our config (VS Code's `globalStorage/`, `gh`'s
`state.yml`), link the individual files so that state stays out of the repo.

To track a new config file:

1. add a `!/.config/path/to/file` line to the allow-list in `.gitignore`
2. add a `"path/to/file".source = link "path/to/file";` entry to `xdg.nix`
3. `git add .config/path/to/file && just switch`

`git check-ignore -v <path>` explains why any given path is ignored.

> `.gitignore` still uses an **allow-list** for `.config/`. It is no longer the only thing between
> an app and the repo, but the linked paths are still written to, so it stays the cheapest way to be
> sure only intended files get committed.

A git hook runs [gitleaks] on staged changes as a second line of defence, since `git add -f`
bypasses `.gitignore`. Enable it once per clone:

```sh
just hooks      # prek install
```

______________________________________________________________________

## Layout

The organising rule: **a dotfile at the repo root maps into `$HOME` on every machine.** Anything
that is specific to one platform lives in that platform's directory and is deployed by hand there.

### Shared: these land in `$HOME`

| Path                                     | Maps to                                                                      |
| ---------------------------------------- | ---------------------------------------------------------------------------- |
| `.zshenv`                                | `~/.zshenv`, for the little that must be set before zsh touches the terminal |
| `.zshrc`                                 | `~/.zshrc`, one file for every machine. Branches on `$DOTFILES_PLATFORM`     |
| `.zsh/`                                  | `~/.zsh`, where every `*.zsh` is auto-sourced                                |
| `.zsh/zshrc_{macos,linux,wsl,synology}`  | Per-platform sections, loaded by `.zshrc`                                    |
| `.config/`                               | Linked file-by-file into `~/.config` (see above). Cross-platform only        |
| `.config/nvim/`                          | Neovim: lazy.nvim + native LSP                                               |
| `.gitconfig-global`, `.gitignore-global` | The base git config a machine with no Nix includes                           |
| `git/aliases`                            | The git alias list. Included by both of the above and by `git.nix`           |

### Per platform

| Path          | What it is                                                                                                                                                                                                                |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `nix-darwin/` | **macOS** (the MacBook, main machine). The flake: system + Homebrew + home-manager. Declarative, applied with `just switch`                                                                                               |
| `linux/`      | **Arch.** `boot/`, `xorg.conf.d/`, `Xsetup` (sddm), `bin/`, `XCompose/` (vendored from [kragen/xcompose]), `xbindkeysrc`, `gitconfig`, and `config/` for the XDG files that are Linux-only (KDE autostart, `user-dirs.*`) |
| `wsl/`        | **Ubuntu 26.04 under WSL** on the work machine. `zshenv`, `gitconfig`                                                                                                                                                     |
| `windows/`    | Windows Terminal settings, `gitconfig`                                                                                                                                                                                    |
| `scripts/`    | Cross-platform helpers and the container-based shell tests                                                                                                                                                                |
| `secrets/`    | sops-encrypted values, decrypted at activation. See [secrets/README.md](secrets/README.md)                                                                                                                                |
| `docs/`       | Runbooks for a machine rather than for this repo: [Synology](docs/synology.md), [WireGuard on it](docs/synology-wireguard.md)                                                                                             |

The Synology boxes (RS2423+ and DS1522+, DSM 7.x) have no directory of their own. Their shell half
is `.zsh/zshrc_synology`. Their packages are `nix-darwin/modules/home-manager/synology.nix`, plus
`nas.nix` or `bkp.nix` for what one box needs alone. Everything else about them is in
[docs/synology.md](docs/synology.md).

Arch and WSL share `nix-darwin/modules/home-manager/linux.nix`. They keep their `linux/` and `wsl/`
directories for the files Nix does not place: X11, the bootloader, KDE autostart.

> Linux-only XDG files live in `linux/config/`, **not** `.config/`. Because `~/.config` is one
> symlink shared by every machine, anything put in `.config/` shows up on macOS too. Symlink
> `linux/config/*` individually on Linux.

### Repo infrastructure

`Justfile` (task runner), `prek.toml` (git hooks, run by [prek]), `scripts/`, `.github/workflows/`
(CI), `renovate.json5`, `.sops.yaml` (which key `secrets/` is encrypted to), and the tool configs:
`typos.toml`, `statix.toml`, `.gitleaks.toml`, `.mdformat.toml`, `.stylua.toml`, `cspell.json`.

`docs/` takes what is too long for this file: setups that live on a machine rather than in this
repo, where the value is the commands and the traps. The compose stacks on the NAS are their own
repository, `nas-containers`, since they deploy differently and carry credentials.

[Renovate] keeps the two sets of pins current: the SHA-pinned actions in `.github/workflows/` and
the hook `rev`s in `prek.toml`. It is deliberately not pointed at `flake.lock`. That is
`just update`'s job, and `nixpkgs-unstable` moves several times a day. `renovate-check` in
`.zsh/renovate_check.zsh` runs the same rules locally and shows what is being held back.

Two spell checkers, with different jobs: `typos` catches real misspellings anywhere and gates
commits, while cSpell (`cspell.json`, word list in `.cspell/dotfiles.txt`) covers prose and comments
and runs **in VS Code only**, with no hook and no CI. Its word list is the one thing here that can
rot unnoticed. Which word goes where is under "Spell checking" in [AGENTS.md](AGENTS.md).

`.vscode/extensions.json` suggests `nefrob.vscode-just-syntax` for the Justfile. It is the only
actively maintained Just extension, and it downloads nothing: it uses the `just` and `just-lsp`
binaries from `packages.nix`.

> macOS git config is **not** in `.gitconfig-*`; it is generated by
> `nix-darwin/modules/home-manager/programs/git.nix` into `~/.config/git/config`. The `linux/`,
> `wsl/` and `windows/` `gitconfig` files are for the machines without Nix, and each one `include`s
> `~/.gitconfig-global`.

______________________________________________________________________

## macOS: nix-darwin

The flake lives in `nix-darwin/` and the configuration is named after the host (`M4`). Package
management is split three ways on purpose:

- **nixpkgs** (`modules/packages.nix`): CLI tooling, grouped by purpose.
- **Homebrew** (`modules/homebrew.nix`): GUI casks, and formulae that move faster than nixpkgs
  (`yt-dlp`) or are macOS-specific (`pinentry-mac`). Taps are pinned as flake inputs and
  `mutableTaps = false`, so `brew` cannot drift.
- **home-manager** (`modules/home-manager/`): per-user config for git, gnupg, direnv and zsh, plus
  `activation/` scripts for things macOS offers no API for (default apps, removing login items).

Homebrew 6 refuses formulae and casks from non-official taps unless they are trusted. nix-darwin
handles that declaratively, because every Brewfile entry it generates carries `trusted: true`.
Nothing here writes a `trust.json`. The one workaround left is mirroring `nix-homebrew`'s taps into
`homebrew.taps`, because `brew bundle cleanup` still untaps anything the Brewfile does not mention,
and untapping `homebrew/cask` force-uninstalls every cask that came from it.

### Everyday commands

```sh
just build      # build without activating -- always do this before switch
just switch     # sudo darwin-rebuild switch
just diff       # show what a rebuild would change (nvd)
just update     # nix flake update
just gc         # collect garbage older than 14d, optimise the store

just brew-upgrade   # upgrade the Homebrew formulae and casks
```

`just switch` installs and uninstalls to match `homebrew.nix` and **changes no version**.
`homebrew.onActivation.upgrade` is off on purpose: it applies to every brew and cask in
`homebrew.nix`, and `mactex`, `microsoft-office`, `steam` and `adobe-creative-cloud` are in that
list, so turning it on lets a one-line change to any module pull gigabytes at a moment nobody chose.
Neither `just build` nor `just diff` shows a word of it beforehand. `just brew-upgrade` is the
deliberate half.

That recipe runs `brew upgrade` and nothing else. `brew update` belongs to a checkout Homebrew owns,
and `mutableTaps = false` mounts the taps read-only out of `/nix/store`, so it stops on
`Permission denied`; what a tap offers moves with its flake input, via `just update`. `--greedy` is
left off because it reaches the casks that already update themselves, which means re-downloading
whole app bundles nobody asked for.

`nh` is installed as a friendlier front-end: `just nhs` wraps `nh darwin switch`, which shows a
package diff automatically.

Garbage collection and store optimisation also run on a timer (`modules/nix.nix`), so manual `gc` is
rarely needed.

### Two gotchas worth knowing

**1. The flake only sees git-tracked files.**

The flake resolves to `git+file:///Users/julio/dotfiles?dir=nix-darwin`, so Nix copies the _git
tree_, not the working directory. A brand-new file is invisible until it is staged:

```
error: Path 'nix-darwin/modules/foo.nix' in the repository ... is not tracked by Git.
```

Fix with `git add nix-darwin/modules/foo.nix`. Modifications to already-tracked files are picked up
without staging.

**2. `.zshrc` is baked into the Nix store.**

`modules/home-manager/programs/zsh.nix` does `initContent = builtins.readFile ../../../../.zshrc`,
so `~/.zshrc` is a read-only symlink into `/nix/store`. Editing `.zshrc` in this repo has no effect
until `just switch`. To iterate quickly, test in a throwaway `ZDOTDIR`:

```sh
mkdir -p /tmp/zt && cp .zshrc /tmp/zt/.zshrc
ZDOTDIR=/tmp/zt zsh -i
```

______________________________________________________________________

## Zsh

One `.zshrc` runs on every machine. It sets `$DOTFILES_PLATFORM` to `macos`, `wsl`, `synology` or
`linux` and loads the matching `.zsh/zshrc_*`.

**There is no plugin manager anywhere.** zplug and Prezto are gone: zplug cloned itself over the
network from inside `.zshrc` on first run, pinned nothing, and both have been unmaintained for
years.

- Wherever home-manager runs, plugins are **Nix packages** declared in
  `nix-darwin/modules/home-manager/programs/zsh.nix` and sourced straight out of `/nix/store`. That
  is macOS, the Synology, Arch and WSL. `~/.zshenv` exports `DOTFILES_PLUGINS_FROM_NIX=1` and
  `.zshrc` skips its own search.
- On a machine with no Nix, `.zshrc` sources whatever the **system package manager** installed,
  searching the usual prefixes (`/usr/share`, `/opt/share` for Entware, Homebrew, `~/.local/share`).
  Anything missing is skipped, so a box with no plugins at all still gets a working shell.

```sh
# Arch
pacman -S zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search
# Debian / Ubuntu / WSL
apt install zsh-autosuggestions zsh-syntax-highlighting
# Synology: no package exists for any of them, see docs/synology.md
```

| Was (zplug)                                                                   | Now                                                            |
| ----------------------------------------------------------------------------- | -------------------------------------------------------------- |
| Prezto `autosuggestions` / `syntax-highlighting` / `history-substring-search` | home-manager's built-in options (it gets the load order right) |
| Prezto `editor` (vi keys)                                                     | `defaultKeymap = "viins"`                                      |
| Prezto `completion`                                                           | `enableCompletion` + `zsh-completions`                         |
| Prezto `fasd`                                                                 | zoxide                                                         |
| Prezto `terminal` / `archive` / `utility`                                     | ~40 lines of plain zsh in `.zshrc`                             |
| `djui/alias-tips`                                                             | `zsh-you-should-use`                                           |
| `zdharma-continuum/history-search-multi-word`                                 | dropped; Atuin owns `Ctrl-R`                                   |
| `hlissner/zsh-autopair`                                                       | same, from nixpkgs                                             |
| `seebi/dircolors-solarized`                                                   | `vivid`                                                        |
| `supercrabtree/k`                                                             | `eza`                                                          |
| `z-shell/zsh-diff-so-fancy`                                                   | `delta`                                                        |
| `b4b4r07/emoji-cli`                                                           | pinned `fetchFromGitHub` (unmaintained since 2017)             |

Startup went from **1.71 s** under zplug to **0.20 s** (`just bench-shell`).

The remaining cost is mostly plugins. Four things keep it there, all in the Completions section of
`.zshrc`:

| Change                                                                       | Saved   |
| ---------------------------------------------------------------------------- | ------- |
| `uv`, `uvx` and `pixi` completions cached onto `$fpath` rather than `eval`ed | ~230 ms |
| `brew shellenv` in the login hook only, and `$HOMEBREW_PREFIX` reused        | ~40 ms  |
| `starship`, `zoxide` and `atuin` init cached to a file and sourced           | ~16 ms  |
| `mise` activation commented out, since it manages nothing                    | ~20 ms  |

A cached init is keyed on the **resolved path** of the binary, not its mtime. Everything Nix
installs is a symlink into `/nix/store`, where every file carries mtime `1970-01-01`, so a cache
file is forever newer than the binary it came from and an mtime test would never notice an upgrade.
A store path carries the package hash, so a new build is a new key.

There is no `zcompile` on those cached files: `source <path>` does not look for a `.zwc`. That
lookup only happens for autoloaded functions and files reached through `$fpath`. The saving is the
fork, not the parse.

> `programs.zsh.plugins` is deliberately _not_ used. That option materialises plugins under
> `~/.zsh/plugins`, and `~/.zsh` is a symlink into this repo, so it would write generated store
> symlinks into your working tree.

### History: Atuin

[Atuin] replaces the flat `~/.zsh_history` with SQLite, recording exit code, duration, cwd and
session for every command. Configured declaratively in
`nix-darwin/modules/home-manager/programs/atuin.nix`.

| Key      | Does                                                                                    |
| -------- | --------------------------------------------------------------------------------------- |
| `Ctrl-R` | Atuin fuzzy search over all history                                                     |
| `Up`     | zsh-history-substring-search on what you have typed (deliberately _not_ given to Atuin) |

Import the existing history once, after the first `just switch`:

```sh
atuin import auto
```

`enter_accept = false`, so a selected command lands on the command line to be edited rather than
executing immediately. `secrets_filter` plus a `history_filter` list keep tokens out of the
database.

Sync goes to the `atuin` stack in the `nas-containers` repository, not to the hosted atuin.sh. Shell
history is a better map of this network than the SSH config is, so it stays on hardware here. The
client encrypts every record before uploading, so that server holds ciphertext it cannot read.

**The key is the backup, not the NAS.** It lives in `~/.local/share/atuin/key`, never leaves the
machine, and nothing on the server can reconstruct it. `atuin key` prints it.

Registration writes a session token, so it is one command per machine rather than declarative:

```sh
atuin register -u julio -e <email>   # first machine only; then `atuin login -u julio`
atuin import auto && atuin sync      # import reads the existing ~/.zsh_history
```

### Other machines

**Synology RS2423+ (DSM 7.x)**: `.zsh/zshrc_synology`, loaded when `/etc/synoinfo.conf` exists. Puts
Entware's `/opt/bin` ahead of DSM's older tools and adds `opkg`/`synosystemctl`/compose aliases. On
SSH login the shell auto-attaches to a zellij session named after the host. `just nas-switch`
applies the home-manager profile in `nix-darwin/modules/home-manager/nas.nix`. The DS1522+ is the
same kind of box with the profile in `bkp.nix`, and `just nas-switch bkp` applies it.

Everything else about that box is in **[docs/synology.md](docs/synology.md)**: Entware, terminfo
over SSH, zellij nesting, which of `scp` and `rsync` reaches which path, single-user Nix on a bind
mount, and mosh. That is a runbook for one machine rather than a description of this repo, so it
lives beside the other one.

**Arch (desktop) and Ubuntu 26.04 under WSL (work)**: both take the standalone home-manager profile
in `nix-darwin/modules/home-manager/linux.nix`, so `~/.zshrc`, `~/.zshenv` and the `~/.config` links
are written rather than symlinked by hand. See [New machine](#new-machine).

`.zsh/zshrc_wsl` is the WSL-only half. It sets `BROWSER=wslview`, maps `pbcopy`/`pbpaste` onto
`clip.exe`/PowerShell so scripts stay portable, and strips the inherited Windows `PATH` entries that
otherwise slow every completion down and shadow Linux binaries with `.exe` ones (keep them with
`DOTFILES_KEEP_WINDOWS_PATH=1`).

### Testing it

The MacBook can't be any of those platforms, so they're tested in containers:

```sh
just test-shell            # WSL, Synology and bare-Linux scenarios
just test-shell synology   # just one
```

Each runs `scripts/shell-selftest.zsh` inside the image and asserts platform detection, the helper
functions, plugin loading and the `PATH` fixes. The same matrix runs in CI.

**`.zshrc` stays self-contained** so the non-Nix machines work with nothing but this repo cloned: it
holds its own history, options, aliases and keybindings. The only thing Nix changes is _where
plugins come from_, signalled by `DOTFILES_PLUGINS_FROM_NIX` (exported from `~/.zshenv` by
home-manager).

______________________________________________________________________

## Neovim

lazy.nvim, with Neovim 0.11+ native LSP (`vim.lsp.config`/`vim.lsp.enable`). No lsp-zero, no
nvim-cmp. Servers are installed by Mason.

```
:Lazy           plugin UI          :Lazy profile   startup cost per plugin
:Mason          LSP/DAP installs   :checkhealth    diagnose problems
```

Set up for Python and JavaScript/TypeScript in particular:

|        |                                                                     |
| ------ | ------------------------------------------------------------------- |
| Python | pyright (types) + ruff (lint, imports), pytest via neotest, debugpy |
| JS/TS  | vtsls + eslint (fix on save), jest via neotest, js-debug            |
| Format | conform.nvim, `<leader>F`                                           |
| Test   | `<leader>tn` nearest, `<leader>tt` file, `<leader>td` debug         |
| Debug  | `<leader>db` breakpoint, `<leader>dc` continue, `<leader>dt` UI     |

pyright and neotest both resolve the project virtualenv (`$VIRTUAL_ENV`, `.venv/`, `venv/`), so
imports resolve without extra configuration.

### Language toolchains

| Language | Managed by        | Why                                            |
| -------- | ----------------- | ---------------------------------------------- |
| Python   | `uv`              | per-project interpreter versions               |
| Node     | `mise` (Homebrew) | `.tool-versions` / `mise.toml`; supersedes nvm |
| Rust     | `rustup`          | see below                                      |
| Go       | nixpkgs           | one version is enough here                     |

Rust deliberately does **not** use a pinned nixpkgs toolchain. Unlike Python, a newer `rustc` still
builds older crates, because breaking changes are gated behind editions. The need is toolchain
_switching_, not version pinning. Only rustup honours `rust-toolchain.toml` (nixpkgs `cargo` ignores
it **silently**, so a local build can differ from CI), provides nightly and extra targets, and keeps
`clippy`/`rustfmt`/`rust-analyzer`/`rust-src` on the same toolchain so rust-analyzer never drifts
out of sync with `rustc`.

Nix pins only the `rustup` binary. The toolchains live in `~/.rustup`, outside Nix, the same trade
`uv` makes for Python interpreters. Bootstrap once:

```sh
just rust-setup     # rustup default stable + components
```

> For a genuinely reproducible build of one project, use a per-project flake (fenix/oxalica + crane)
> rather than the global toolchain.

LSP servers come from Mason **except** those nixpkgs or rustup already provide (`nil` for Nix,
`rust-analyzer` for Rust). Those are enabled directly when the binary is on `$PATH`. Asking Mason
for `nil` made it try to build from source with cargo, which failed on every startup.

`nvim-treesitter` tracks its `main` branch, which needs the `tree-sitter` CLI to build parsers. The
CLI is declared in `packages.nix`.

______________________________________________________________________

## Checks

Formatting and linting run as git hooks, managed by [prek]. It is a drop-in
[pre-commit](https://pre-commit.com) replacement in Rust, so there is no Python environment to keep
alive. The config is `prek.toml`, prek's native TOML format.

```sh
just hooks          # install the hooks (once per clone)
just lint           # run every hook over the whole repo
just fmt            # same thing; the formatters rewrite in place
just check          # lint + check-flake + scan
just check-flake    # nix flake check (too slow for a per-file hook)
just scan           # gitleaks over all history (the hook only sees staged changes)
just bench-shell    # hyperfine 'zsh -i -c exit'
just test-shell     # WSL/Synology/bare-Linux containers (needs docker)
```

| Hook                          | Covers                                                                |
| ----------------------------- | --------------------------------------------------------------------- |
| `mdformat` (+ gfm)            | Markdown, config in `.mdformat.toml`                                  |
| `typos`                       | spelling, config in `typos.toml`                                      |
| `nixfmt`, `statix`, `deadnix` | Nix                                                                   |
| `shellcheck`, `zsh -n`        | sh/bash and zsh respectively                                          |
| `stylua`                      | Lua, config in `.stylua.toml`                                         |
| `actionlint`                  | GitHub Actions workflows                                              |
| `zizmor`                      | GitHub Actions workflows, security side                               |
| `renovate-config-validator`   | `renovate.json5`                                                      |
| `gitleaks`                    | secrets in staged changes                                             |
| pre-commit-hooks              | trailing whitespace, EOF, line endings, large files, YAML/TOML syntax |

CI runs `prek run --all-files` rather than a step per tool, so the hooks and CI cannot drift apart.

> `typos` sets `ignore-hidden = false`. It skips hidden paths by default, which in a dotfiles repo
> means skipping `.zshrc`, `.zsh/` and `.config/`, which is nearly everything.

______________________________________________________________________

## New machine

```sh
git clone git@github.com:jbsilva/dotfiles.git ~/dotfiles
cd ~/dotfiles && just hooks
```

**macOS**: install Nix, then `just switch`. home-manager creates `~/.zshrc`, `~/.zshenv` and the
per-file `~/.config` links itself; do not link anything by hand. `.zshenv` is read into
`programs.zsh.envExtra` there, the same way `.zshrc` is read into `initContent`.

**Secrets**: `secrets/` is sops-encrypted and this repository is public, so a fresh clone cannot
read it until an age key exists. Nothing else depends on that, and the flake evaluates without it.
See [secrets/README.md](secrets/README.md).

**Arch, WSL and the Synology**: install Nix, then apply the standalone home-manager profile for that
host. It writes `~/.zshrc`, `~/.zshenv` and the `~/.config` links, exactly as on macOS:

```sh
nix run home-manager -- switch --flake ~/dotfiles/nix-darwin#julio@arch   # or @wsl
just nas-switch                                                          # the RS2423+
just nas-switch bkp                                                      # the DS1522+
```

Arch and WSL share `nix-darwin/modules/home-manager/linux.nix`. The Synology boxes share
`synology.nix`, because DSM needs shims that nothing else does. All three read the same `.zshrc` and
the same `git/aliases` as the MacBook. That is the point of the profile: one alias list and one
`.zshrc`, rather than a copy per machine that nothing keeps in step.

**A machine with no Nix at all**: link the shell paths and point git at the matching per-platform
config. `.gitconfig-global` and `.gitignore-global` exist for this case.

```sh
ln -s ~/dotfiles/.zshenv ~/.zshenv
ln -s ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/.zsh   ~/.zsh
ln -s ~/dotfiles/.gitconfig-global ~/.gitconfig-global   # included by the per-OS gitconfig
ln -s ~/dotfiles/linux/gitconfig   ~/.gitconfig          # or wsl/gitconfig
```

> Do **not** `ln -s ~/dotfiles/.config ~/.config`, for the reason the
> [`~/.config` section](#how-config-is-wired) above gives: every application then writes its runtime
> state inside the git repo. Link individual files.

[atuin]: https://atuin.sh
[gitleaks]: https://github.com/gitleaks/gitleaks
[kragen/xcompose]: https://github.com/kragen/xcompose
[prek]: https://github.com/j178/prek
[renovate]: https://docs.renovatebot.com

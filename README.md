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
...
~/.zsh                            -> ~/dotfiles/.zsh          (still a whole dir)
```

It used to be one symlink, `~/.config -> ~/dotfiles/.config`, which meant every application wrote
its runtime state **inside the git repo** — Colima's VM image alone was 18 GB of it. Switching to
per-file links took the repo from 19 GB to 12 MB and stopped Linux-only files from appearing on
macOS.

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

### Shared — these land in `$HOME`

| Path                                     | Maps to                                                                     |
| ---------------------------------------- | --------------------------------------------------------------------------- |
| `.zshenv`                                | `~/.zshenv` — the little that has to be set before zsh touches the terminal |
| `.zshrc`                                 | `~/.zshrc` — one file for every machine; branches on `$DOTFILES_PLATFORM`   |
| `.zsh/`                                  | `~/.zsh` — every `*.zsh` in here is auto-sourced                            |
| `.zsh/zshrc_{macos,linux,wsl,synology}`  | Per-platform sections, loaded by `.zshrc`                                   |
| `.config/`                               | Linked file-by-file into `~/.config` (see above). Cross-platform only       |
| `.config/nvim/`                          | Neovim: lazy.nvim + native LSP                                              |
| `.gitconfig-global`, `.gitignore-global` | The base git config every non-Nix machine includes                          |

### Per platform

| Path          | What it is                                                                                                                                                                                                                |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `nix-darwin/` | **macOS** (the MacBook, main machine). The flake: system + Homebrew + home-manager. Declarative, applied with `just switch`                                                                                               |
| `linux/`      | **Arch.** `boot/`, `xorg.conf.d/`, `Xsetup` (sddm), `bin/`, `XCompose/` (vendored from [kragen/xcompose]), `xbindkeysrc`, `gitconfig`, and `config/` for the XDG files that are Linux-only (KDE autostart, `user-dirs.*`) |
| `wsl/`        | **Ubuntu 26.04 under WSL** on the work machine. `zshenv`, `gitconfig`                                                                                                                                                     |
| `windows/`    | Windows Terminal settings, `gitconfig`                                                                                                                                                                                    |
| `scripts/`    | Cross-platform helpers and the container-based shell tests                                                                                                                                                                |

The Synology (RS2423+, DSM 7.x) has no directory of its own — it needs no files copied to it beyond
`.zshenv`, `.zshrc` and `.zsh/`. Its behaviour lives in `.zsh/zshrc_synology`.

> Linux-only XDG files live in `linux/config/`, **not** `.config/`. Because `~/.config` is one
> symlink shared by every machine, anything put in `.config/` shows up on macOS too. Symlink
> `linux/config/*` individually on Linux.

### Repo infrastructure

`Justfile` (task runner), `.pre-commit-config.yaml` (git hooks, run by [prek]), `scripts/`,
`.github/workflows/` (CI), `renovate.json5`, and the tool configs: `typos.toml`, `statix.toml`,
`.gitleaks.toml`, `.mdformat.toml`, `.stylua.toml`, `cspell.json`.

[Renovate] keeps the two sets of pins current: the SHA-pinned actions in `.github/workflows/` and
the hook `rev`s in `.pre-commit-config.yaml`. It is deliberately not pointed at `flake.lock` — that
is `just update`'s job, and `nixpkgs-unstable` moves several times a day. `renovate-check` in
`.zsh/renovate_check.zsh` runs the same rules locally and shows what is being held back.

Two spell checkers, with different jobs: `typos` catches real misspellings anywhere and gates
commits, while cSpell (`cspell.json`, word list in `.cspell/dotfiles.txt`) covers prose and comments
and runs **in VS Code only** — no hook, no CI, so its word list is the one thing here that can rot
unnoticed. Which word goes where is under "Spell checking" in [AGENTS.md](AGENTS.md).

`.vscode/extensions.json` suggests `nefrob.vscode-just-syntax` for the Justfile — the only actively
maintained Just extension, and one that downloads nothing: it uses the `just` and `just-lsp`
binaries from `packages.nix`.

> macOS git config is **not** in `.gitconfig-*`; it is generated by
> `nix-darwin/modules/home-manager/programs/git.nix` into `~/.config/git/config`. The `linux/`,
> `wsl/` and `windows/` `gitconfig` files are for the machines without Nix, and each one `include`s
> `~/.gitconfig-global`.

______________________________________________________________________

## macOS: nix-darwin

The flake lives in `nix-darwin/` and the configuration is named after the host (`M4`). Package
management is split three ways on purpose:

- **nixpkgs** (`modules/packages.nix`) — CLI tooling, grouped by purpose.
- **Homebrew** (`modules/homebrew.nix`) — GUI casks, and formulae that move faster than nixpkgs
  (`yt-dlp`) or are macOS-specific (`pinentry-mac`). Taps are pinned as flake inputs and
  `mutableTaps = false`, so `brew` cannot drift.
- **home-manager** (`modules/home-manager/`) — per-user config: git, gnupg, direnv, zsh, plus
  `activation/` scripts for things macOS offers no API for (default apps, removing login items).

Homebrew 6 refuses formulae and casks from non-official taps unless they are trusted. nix-darwin
handles that declaratively — every Brewfile entry it generates carries `trusted: true` — so nothing
here writes a `trust.json`. The one workaround left is mirroring `nix-homebrew`'s taps into
`homebrew.taps`, because `brew bundle cleanup` still untaps anything the Brewfile does not mention,
and untapping `homebrew/cask` force-uninstalls every cask that came from it.

### Everyday commands

```sh
just build      # build without activating -- always do this before switch
just switch     # sudo darwin-rebuild switch
just diff       # show what a rebuild would change (nvd)
just update     # nix flake update
just gc         # collect garbage older than 14d, optimise the store
```

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

- On macOS, plugins are **Nix packages** declared in
  `nix-darwin/modules/home-manager/programs/zsh.nix` and sourced straight out of `/nix/store`.
- Everywhere else, `.zshrc` sources whatever the **system package manager** installed, searching the
  usual prefixes (`/usr/share`, `/opt/share` for Entware, Homebrew, `~/.local/share`). Anything
  missing is skipped, so a box with no plugins at all still gets a working shell.

```sh
# Arch
pacman -S zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search
# Debian / Ubuntu / WSL
apt install zsh-autosuggestions zsh-syntax-highlighting
# Synology (Entware)
opkg install zsh-autosuggestions zsh-syntax-highlighting
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

Startup went from **1.71 s** under zplug to **0.38 s** (`just bench-shell`).

The remaining cost is mostly plugins. The two things that used to dominate are gone: `uv`, `uvx` and
`pixi` completions are cached onto `$fpath` instead of being `eval`ed in every shell (~230 ms), and
`brew` no longer runs four times per shell (~40 ms). See the Completions section of `.zshrc`.

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
executing immediately. Sync is off — it needs an account; see the comments in the module.
`secrets_filter` plus a `history_filter` list keep tokens out of the database.

### Other machines

**Synology RS2423+ (DSM 7.x)** — `.zsh/zshrc_synology`, loaded when `/etc/synoinfo.conf` exists.
Puts Entware's `/opt/bin` ahead of DSM's older tools and adds `opkg`/`synosystemctl`/compose
aliases. Deploy by cloning the repo and symlinking `~/.zshenv`, `~/.zshrc` and `~/.zsh`; nothing
else is needed.

Entware's terminfo reaches the shell through `$TERMINFO_DIRS` in `.zshenv`, not `$TERMINFO` here —
ncurses fixes its search path before `.zshrc` is read, so setting it at that point is already too
late for the shell's own lookup. Without it zellij and nvim misrender over SSH.

On SSH login the shell auto-attaches to a zellij session named after the host, so reconnecting lands
back in the same session. It deliberately does **not** `exec zellij` — if zellij or the terminfo
were broken, exec would kill the login shell and lock you out of a headless box. Skip it for one
connection with:

```sh
ssh nas -t 'DOTFILES_NO_ZELLIJ=1 $SHELL -l'
```

The assignment has to be part of the remote command. DSM's sshd sets no `AcceptEnv`, so it drops
every forwarded variable — `LANG` included.

> **Probe this box with a login shell.** `ssh nas '<cmd>'` and `ssh nas -t 'zsh -i'` both skip
> `/etc/profile`, which is the only thing that puts `/usr/local/bin` and `/usr/syno/bin` on `$PATH`.
> Under those, roughly 250 installed SynoCli tools look missing and `synopkg status` reports
> packages as stopped when it merely lacked root. Use the `$SHELL -l` form above before concluding
> anything is absent.

#### Installing Entware

Entware lives in `/volume1/@Entware/opt`, bind-mounted onto `/opt`. The `@` prefix makes it a DSM
system directory rather than a shared folder: invisible in File Station, never exported over
SMB/NFS, skipped by Media Indexing, and left out of DSM's shared-folder ACL model, so the POSIX
modes and setuid bits the packages set are the only thing governing it. DSM will not let you create
an `@` name through the UI anyway.

A DSM upgrade wipes `/opt`, which is on the rootfs, but not `/volume1/@Entware`. **So after an
upgrade, check whether this is only a lost bind mount before reinstalling anything:**

```sh
sudo ls -la /volume1/@Entware/opt      # bin/ etc/ lib/ share/ still there?
sudo mount -o bind /volume1/@Entware/opt /opt
```

If that brings `/opt/bin/opkg` back, skip the rest of this section and go straight to the boot task.

A fresh install follows the
[Entware wiki](https://github.com/Entware/Entware/wiki/Install-on-Synology-NAS). `x64-k3.2` is the
right feed for this box — `uname -m` is `x86_64` on kernel 4.4.

**Every line below runs in a root shell.** Only root can write at a volume root, and `umask` is a
shell builtin, so `sudo` per command would not carry it. DSM 7 disables direct root SSH, so:

```sh
sudo -i
```

Then, as root:

```sh
umask 022        # root's umask is 077; 0700 on /opt locks every other user out

mkdir -p /volume1/@Entware/opt
chmod 755 /volume1/@Entware /volume1/@Entware/opt

# Not the wiki's `rm -rf /opt`: the bind mount hides what is under it, and
# Container Manager keeps an (empty) /opt/containerd there.
cp -a /opt/containerd /volume1/@Entware/opt/

mount -o bind /volume1/@Entware/opt /opt
wget -O - https://bin.entware.net/x64-k3.2/installer/generic.sh | /bin/sh
```

At 0700 nothing under `/opt` runs at all, not even the loader at `/opt/lib/ld-linux-x86-64.so.2`.
Check `ls -la /opt` first — anything else living there needs carrying across too.

The tree lives on the volume so it survives upgrades, but the bind mount does not survive a reboot.
Re-create it from a **Triggered Task** in Control Panel → Task Scheduler (event: Boot-up, user:
`root`):

```sh
mkdir -p /opt
mount -o bind /volume1/@Entware/opt /opt
/opt/etc/init.d/rc.unslung start
/opt/bin/opkg update
```

The wiki's boot script also appends `/opt/etc/profile` to `/etc/profile`. That is not needed here:
`zshrc_synology` puts `/opt/bin` and `/opt/sbin` on `$PATH` itself, and `/etc/profile` is another
file DSM rewrites on upgrade.

Then `opkg install zsh ncurses-bin terminfo`. That zsh links against Entware's own ncurses 6.4
instead of baking in a static one, and `ncurses-bin` supplies `tic` and `infocmp` — so a terminfo
entry DSM lacks can be compiled in place rather than copied in, and Ghostty's `ssh-terminfo` shell
integration starts working on its own.

#### zsh plugins

Entware packages none of them, and SynoCommunity's `zsh-static` is a lone binary. Clone them into
the last entry of `_plug_dirs` in `.zshrc` — the upstream repository names already match the files
the loader looks for, so no renaming:

```sh
mkdir -p ~/.local/share/zsh/plugins
cd ~/.local/share/zsh/plugins
git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions
git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting
git clone --depth 1 https://github.com/zsh-users/zsh-history-substring-search
```

No `sudo`; this is all under `$HOME`. The third one is the easy one to skip — without it Up/Down and
vicmd `k`/`j` fall back to plain history, and `just test-shell` reports `skip` rather than `fail`.

Nothing pins these: Renovate cannot see a `git clone` in `$HOME`, and only the Nix machines get
these from `flake.lock`. Update them by hand:

```sh
for d in ~/.local/share/zsh/plugins/*(/); do git -C "$d" pull --ff-only; done
```

> Nix on DSM is possible but awkward: no systemd, so the multi-user daemon install doesn't apply,
> and `/nix` has to survive DSM upgrades. A single-user install
> (`sh <(curl -L https://nixos.org/nix/install) --no-daemon`) works. Given the workloads there are
> containers, Entware is usually less maintenance.

**WSL (Ubuntu 26.04)** — `.zsh/zshrc_wsl`. Sets `BROWSER=wslview`, maps `pbcopy`/`pbpaste` onto
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

lazy.nvim, with Neovim 0.11+ native LSP (`vim.lsp.config`/`vim.lsp.enable`) — no lsp-zero, no
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
builds older crates — breaking changes are gated behind editions — so the need is toolchain
_switching_, not version pinning. Only rustup honours `rust-toolchain.toml` (nixpkgs `cargo` ignores
it **silently**, so a local build can differ from CI), provides nightly and extra targets, and keeps
`clippy`/`rustfmt`/`rust-analyzer`/`rust-src` on the same toolchain so rust-analyzer never drifts
out of sync with `rustc`.

Nix pins only the `rustup` binary; the toolchains live in `~/.rustup`, outside Nix — the same trade
`uv` makes for Python interpreters. Bootstrap once:

```sh
just rust-setup     # rustup default stable + components
```

> For a genuinely reproducible build of one project, use a per-project flake (fenix/oxalica + crane)
> rather than the global toolchain.

LSP servers come from Mason **except** those nixpkgs or rustup already provide (`nil` for Nix,
`rust-analyzer` for Rust). Those are enabled directly when the binary is on `$PATH` — asking Mason
for `nil` made it try to build from source with cargo, which failed on every startup.

`nvim-treesitter` tracks its `main` branch, which needs the `tree-sitter` CLI to build parsers — it
is declared in `packages.nix`.

______________________________________________________________________

## Checks

Formatting and linting run as git hooks, managed by [prek] — a drop-in
[pre-commit](https://pre-commit.com) replacement in Rust, so there is no Python environment to keep
alive. The config is the usual `.pre-commit-config.yaml`.

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
> means skipping `.zshrc`, `.zsh/` and `.config/` — nearly everything.

______________________________________________________________________

## New machine

```sh
git clone git@github.com:jbsilva/dotfiles.git ~/dotfiles
cd ~/dotfiles && just hooks
```

**macOS** — install Nix, then `just switch`. home-manager creates `~/.zshrc`, `~/.zshenv` and the
per-file `~/.config` links itself; do not link anything by hand. `.zshenv` is read into
`programs.zsh.envExtra` there, the same way `.zshrc` is read into `initContent`.

**Linux / WSL / Synology** — there is no Nix here, so link the three shell paths and point git at
the matching per-platform config:

```sh
ln -s ~/dotfiles/.zshenv ~/.zshenv
ln -s ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/.zsh   ~/.zsh
ln -s ~/dotfiles/.gitconfig-global ~/.gitconfig-global   # included by the per-OS gitconfig
ln -s ~/dotfiles/linux/gitconfig   ~/.gitconfig          # or wsl/gitconfig
```

> Do **not** `ln -s ~/dotfiles/.config ~/.config`. That is what this repo used to do, and it is
> exactly what the [`~/.config` section](#how-config-is-wired) above explains the move away from:
> every application then writes its runtime state inside the git repo. Link individual files.

[atuin]: https://atuin.sh
[gitleaks]: https://github.com/gitleaks/gitleaks
[kragen/xcompose]: https://github.com/kragen/xcompose
[prek]: https://github.com/j178/prek
[renovate]: https://docs.renovatebot.com

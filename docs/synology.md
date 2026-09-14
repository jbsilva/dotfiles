# Synology

RS2423+ running DSM 7.x. Not a machine this repo configures the way it configures the MacBook: DSM
is not a distribution, there is no nix-darwin, and most of what follows is about working around
that.

This is a runbook for one machine rather than a description of the repo, so it lives here next to
[synology-wireguard.md](synology-wireguard.md) rather than in the README.

What the repo itself holds for this box:

| Path                                      | What                                                     |
| ----------------------------------------- | -------------------------------------------------------- |
| `.zsh/zshrc_synology`                     | The shell half, loaded when `/etc/synoinfo.conf` exists  |
| `nix-darwin/modules/home-manager/nas.nix` | The home-manager profile, applied with `just nas-switch` |
| `Justfile`                                | The `nas-*` recipes, which run here or drive it over SSH |

The compose stacks are their own repository, `nas-containers`, because they deploy differently and
carry credentials.

______________________________________________________________________

## The shell

`.zsh/zshrc_synology` is loaded when `/etc/synoinfo.conf` exists, which is true on every DSM install
and on nothing else. It puts Entware's `/opt/bin` ahead of DSM's older tools and adds
`opkg`/`synosystemctl`/compose aliases.

home-manager owns `~/.zshrc`, `~/.zshenv` and `~/.zprofile` here, all three symlinks into the store.
`~/.zsh` is the one link into the repo, and it is what carries this file. On a DSM box that
home-manager has not reached, clone the repo and link all four by hand. Nothing else is needed.

Entware's terminfo reaches the shell through `$TERMINFO_DIRS` in `.zshenv`, not `$TERMINFO` here.
ncurses fixes its search path before `.zshrc` is read, so setting it at that point is already too
late for the shell's own lookup. Without it zellij and nvim misrender over SSH.

`.zshenv` names three directories: `~/.terminfo`, the Nix profile's, and Entware's. A machine with
Nix gets `xterm-ghostty` from `ghostty.terminfo` and needs nothing in `~/.terminfo`. A machine
without Nix needs the entry copied in by hand, which takes no root and no `tic`:

```sh
ssh HOST mkdir -p .terminfo/x
scp /Applications/Ghostty.app/Contents/Resources/terminfo/78/xterm-ghostty \
    HOST:.terminfo/x/xterm-ghostty
```

## Zellij, and nesting

On SSH login the shell auto-attaches to a zellij session named after the host, so reconnecting lands
back in the same session. It deliberately does **not** `exec zellij`. If zellij or the terminfo were
broken, exec would kill the login shell and lock you out of a headless box. Skip it for one
connection with:

```sh
ssh nas -t 'DOTFILES_NO_ZELLIJ=1 $SHELL -l'
```

The assignment has to be part of the remote command. DSM's sshd sets no `AcceptEnv`, so it drops
every forwarded variable, `LANG` included.

Since 0.45.0 zellij knows how to nest, so the session on the NAS does not have to draw a second
status bar under the local one. The catch is how it finds out: the inner session looks for `$ZELLIJ`
in its own environment, and only then announces itself to the outer one over an in-band escape
sequence. `AcceptEnv` blocks that variable as well, so the wrappers in `.zsh/zshrc_macos` carry
`DOTFILES_ZELLIJ_HOST=1` to the far side instead, and `.zshrc` turns it back into `$ZELLIJ` just
before it starts zellij there.

| Reach the NAS with | Over | Address   |
| ------------------ | ---- | --------- |
| `nas`              | SSH  | LAN       |
| `nast`             | SSH  | Tailscale |
| `mosh-nix nas`     | mosh | LAN       |
| `mosh-nix nast`    | mosh | Tailscale |

The two spellings need different tricks. SSH takes a remote command, so the marker goes there, the
same way `DOTFILES_NO_ZELLIJ` does above. mosh has no room for one, because it appends its own
`new -s -c ...` to whatever `--server` names, so `mosh-nix` puts `env DOTFILES_ZELLIJ_HOST=1` in
front of `mosh-server` and lets it hand the variable to the login shell it spawns.

`nested_session_handling "fullscreen"` in
[`.config/zellij/config.kdl`](../.config/zellij/config.kdl) then zooms the pane on focus, leaving
one status bar on screen. Descend and ascend by hand with `[` and `]` in session mode, and toggle
the zoom with `f`.

All four fall back to their plain behaviour outside a pane, and anything of your own after the host
wins: `nas uptime` still runs `uptime` rather than a login shell. Bare `ssh nas` still works too; it
just gets the doubled bar.

> **Probe this box with a login shell.** `ssh nas '<cmd>'` and `ssh nas -t 'zsh -i'` both skip
> `/etc/profile`, which is the only thing that puts `/usr/local/bin` and `/usr/syno/bin` on `$PATH`.
> Under those, every installed SynoCli tool looks missing and `synopkg status` reports packages as
> stopped when it merely lacked root. Use the `$SHELL -l` form above before concluding anything is
> absent.

## Copying files

DSM jails both transfer tools, and it jails them into **different namespaces**. Copy the path style
from the table rather than reasoning about it:

| Destination                              | `scp` | `rsync` | `scp -O` |
| ---------------------------------------- | :---: | :-----: | :------: |
| `nas:/home/f`, `nas:/docker/f` (shares)  |  yes  |   no    |    no    |
| `nas:/var/services/homes/julio/f` (real) |  no   |   yes   |   yes    |
| `nas:/volume3/docker/f` (real)           |  no   |   yes   |   yes    |
| `nas:/tmp/f` (rootfs)                    |  no   |   no    |   yes    |

`scp` has spoken SFTP since OpenSSH 9.0, and DSM serves SFTP from a jailed server whose root is the
list of shared folders. So real paths do not exist for it, and its own root takes no writes:

```sh
scp file nas:/var/services/homes/julio/file   # dest open: No such file or directory
scp file nas:file                             # dest open: Permission denied
```

`ChrootDirectory` is `none` in DSM's `sshd_config`, so the jail lives inside Synology's
`internal-sftp` and no setting turns it off. DSM's `/usr/bin/rsync` is setuid root and patched the
same way, but it takes the real paths and treats the rootfs as a read-only module:

```sh
rsync -a file nas:/tmp/file                   # ERROR: module is read only
```

Use `rsync` for daily work. It takes the paths that `ssh nas` shows you, it re-sends only what
changed, and it is current. Reach for `-O` only for the rootfs, which is rare. That flag selects the
pre-9.0 SCP protocol: `scp(1)` calls it legacy, and it has the remote shell expand globs, so
filenames then need careful quoting.

## Installing Entware

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
right feed for this box: `uname -m` is `x86_64`, on a kernel past the 3.2 in that name. DSM 7.4.1
runs 4.4.302+, as of September 2026.

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
Check `ls -la /opt` first, since anything else living there needs carrying across too.

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

Then `opkg install terminfo`. That package and the base ones the installer pulls are the whole of
Entware here: the shell and the CLI tools come from Nix. `ncurses` in `nas.nix` supplies `tic` and
`infocmp`, so a terminfo entry DSM lacks can be compiled in place rather than copied in, and
Ghostty's `ssh-terminfo` shell integration works on its own.

On a DSM box with no Nix, add `zsh` and `ncurses-bin` as well. That zsh links against Entware's own
ncurses instead of baking in a static one, which SynoCommunity's `zsh-static` does not.

## zsh plugins without Nix

home-manager takes the plugins and oh-my-zsh from `flake.lock` and exports
`DOTFILES_PLUGINS_FROM_NIX=1`, which makes `.zshrc` skip its own search. The checkouts below are
what this box ran on before that. They are still in `$HOME` and nothing reads them. Read this
section as the route for a DSM box with no Nix.

Entware packages none of them, and [SynoCommunity]'s `zsh-static` is a lone binary. Clone them into
the last entry of `_plug_dirs` in `.zshrc`. The upstream repository names already match the files
the loader looks for, so no renaming:

```sh
mkdir -p ~/.local/share/zsh/plugins
cd ~/.local/share/zsh/plugins
git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions
git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting
git clone --depth 1 https://github.com/zsh-users/zsh-history-substring-search
```

No `sudo`; this is all under `$HOME`. The third one is the easy one to skip: without it Up/Down and
vicmd `k`/`j` fall back to plain history, and `just test-shell` reports `skip` rather than `fail`.

The git aliases need oh-my-zsh as well. `.zshrc` sources only `lib/git.zsh` and the git plugin from
it, and looks in `$DOTFILES_OMZ`, then `~/.oh-my-zsh`, then two system paths. `$DOTFILES_OMZ` is set
by the Nix machines alone, so without a checkout here `gl`, `gst`, `gco` and the rest are simply not
defined:

```sh
git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh ~/.oh-my-zsh
```

Nothing pins any of these: Renovate cannot see a `git clone` in `$HOME`, and only the Nix machines
get them from `flake.lock`. While a box is on the checkouts, update them by hand:

```sh
for d in ~/.local/share/zsh/plugins/*(/) ~/.oh-my-zsh(N/); do git -C "$d" pull --ff-only; done
```

## CLI tools

Tools come from four places. Prefer them in this order.

**Nix.** `home.packages` in `nix-darwin/modules/home-manager/nas.nix` is where a tool goes now. The
version is pinned in `flake.lock` and moves with the MacBook, `just nas-switch` applies it, and
`zshrc_synology` puts the profile ahead of both package repositories. `atuin`, `delta`,
`difftastic`, `restic`, `zellij`, `neovim`, `rustup`, `uv`, `starship`, `zoxide`, `rclone`, `pv`,
`progress` and `exiftool` all come from there. See "home-manager on the NAS" below.

Reach for one of the other three when nixpkgs has no `x86_64-linux` build, or when the tool has to
keep working with `/nix` unmounted, which is the window between a reboot and the Boot-up task.

**SynoCommunity.** Add the repository in Package Center, then install the `synocli-*` bundles. They
put a few hundred tools in `/usr/local/bin`, as symlinks into `/var/packages/synocli-*/`:

| Package           | Gives you                                                          |
| ----------------- | ------------------------------------------------------------------ |
| `synocli-file`    | `bat`, `fzf`, `fd`, `eza`, `rg`, `less`, `mc`, `nnn`, `sd`, `lsd`  |
| `synocli-disk`    | `ncdu`, `duf`, `gdu`, `smartctl`                                   |
| `synocli-net`     | `mtr`, `tmux`, `nmap`, `socat`                                     |
| `synocli-monitor` | `procs`, `lsof`, `btop`, `htop`                                    |
| `synocli-devel`   | `clang`, `gdb`, `make`, `strace`, `pkg-config`, the autotools      |
| `synocli-misc`    | `parallel`, `expect`, `bc`, `lsblk`, `lscpu`, `findmnt`, `hexdump` |
| `synocli-kernel`  | `lsusb`, `pstree`, `fuser`, `usb-devices`                          |

`git` and `zsh-static` come from SynoCommunity too, as packages of their own rather than as part of
a bundle. DSM itself supplies `curl`, `wget`, `jq`, `python3`, `vim`, `gpg`, `tcpdump` and
`/usr/bin/rsync`. That rsync is the one "Copying files" above depends on: synocli-net carries a
second one in `/usr/local/bin`, and `/etc/profile` puts `/usr/bin` first, so DSM's wins.

**Entware.** `opkg` covers what SynoCommunity does not package and nixpkgs cannot build here.
Nothing on this box needs it for that today, so `/opt` holds its base packages and `terminfo` alone.

Neither repository always carries the newest release. When the version matters, check what is
packaged before you install, and take the tool from Nix instead when the package is behind.

**By hand.** A release binary into `~/bin`, which `.zshrc` prepends last and so outranks every other
source. `~/bin` is empty: everything that was in it is a Nix package now. The asset names differ per
project, `musl` or `gnu`, `x86_64` or `amd64`, `.tar.gz` or `.bz2`, so there is no common command
and each one comes off its own releases page.

One installed-by-hand copy is left, `/usr/local/bin/starship` from `starship.rs/install.sh`. The Nix
one shadows it, so it is dead weight rather than a second opinion.

A container is the fifth option, for a tool none of the four package. It costs an image pull rather
than a binary, but the version is pinned in the compose file.

## Containers

Most of what this NAS runs is a container. DSM calls the package Container Manager, but the CLI is
`docker`, with the v2 `docker compose` plugin.

Stacks created through the DSM UI get one directory each under `<volume>/docker`. The volume is
fixed when Container Manager is installed, so `zshrc_synology` defines `cdstacks` to find it instead
of naming it:

```sh
cdstacks      # cd to <volume>/docker
dpst          # docker ps, showing names, status and ports
```

DSM keeps `/var/run/docker.sock` root-only, so every docker call needs `sudo`. Its docker group is
root-equivalent, so joining it would hand the daemon to every process you start, permanently.
`zshrc_synology` aliases `docker` to `sudo docker`, and zsh re-expands the first word of an alias
body, so `dps` and the `dc*` aliases work too.

> That alias covers interactive shells only. `sudo` here passes the caller's `$PATH` straight
> through, because `/etc/sudoers` sets no `secure_path`, and DSM gives a non-interactive shell
> `/usr/bin:/bin:/usr/sbin:/sbin`. So `sudo docker` and `sudo synopkg` both answer
> `command not found` inside a script or under `ssh nas '<cmd>'`. Write `/usr/local/bin/docker` and
> `/usr/syno/bin/synopkg` there.

> **`sudo` asks for no password on this box.** `/etc/sudoers.d/temp-nopasswd` holds
> `julio ALL=(ALL) NOPASSWD:ALL`, which is a wider grant than the docker group turned down above.
> Delete that file to get the prompt back.

Two boot traps, neither of which announces itself. A container that borrows another's namespace with
`network_mode: service:<name>` dies with exit 128 and
`cannot join network of a non running container` when the daemon happens to start it first.
`depends_on` orders `compose up` alone, and a start that fails this way is never retried, so it
stays down. `restart <name>` and `up -d --force-recreate <name>` do the same damage by hand: the
borrowers keep a handle on a namespace that went away, lose the LAN and the internet, and
`docker ps` still calls them healthy, because each one answers itself on `127.0.0.1`. Act on the
whole stack, never on the one service.

A container that reserves a static IP loses it to whichever container the daemon starts first, and
then fails with `Address already in use`. `ip_range` on the network is the pool that dynamic
addresses come from, so give it the upper half of the subnet and every static address below stays
reserved. Leaving it to cover the whole subnet is what creates the race. Docker fixes IPAM when it
creates the network, so a change here means recreating it: stop every attached container,
`compose down` the stack that defines the network, then `up -d` in dependency order.

WireGuard on this box runs in the kernel rather than in userspace, which is worth about 1.5 cores:
[docs/synology-wireguard.md](synology-wireguard.md).

## Nix

Single-user, because DSM has no systemd to run the daemon. The store lives on a volume and is
bind-mounted, for the same reason Entware does: the rootfs has a few GB free and a DSM upgrade wipes
it.

As root:

```sh
umask 022                          # root's umask is 077, and a 0700 store is unusable
mkdir -p /volume2/@Nix /nix
mount -o bind /volume2/@Nix /nix
chown julio:users /volume2/@Nix    # single-user Nix wants the store owned by you
```

Then as your own user. `/tmp` is `noexec` on DSM, so the installer cannot run the binary it unpacks
there, and `TMPDIR` has to point somewhere it can:

```sh
mkdir -p ~/.cache/nix-install
TMPDIR=$HOME/.cache/nix-install sh <(curl -L https://nixos.org/nix/install) --no-daemon
```

Write `~/.config/nix/nix.conf` **before** running it, or the install fails at
`unable to load seccomp BPF program`. DSM's kernel has neither seccomp BPF filtering nor
`CONFIG_USER_NS`, so both the syscall filter and the build sandbox have to be off:

```ini
filter-syscalls = false
sandbox = false
experimental-features = nix-command flakes
```

The kernel is 4.4.302+ on DSM 7.4.1, as of September 2026. Synology chooses it, and a major DSM
upgrade moves it, so those two lines are worth retesting after one. DSM carries no
`/proc/config.gz`, which makes the test empirical: comment both out, then run a build that is not a
cache hit.

The bind mount does not survive a reboot. Add it to the same Boot-up task as Entware, or its own:

```sh
mkdir -p /nix
mount -o bind /volume2/@Nix /nix
```

`zshrc_synology` sources `~/.nix-profile/etc/profile.d/nix.sh` when it is readable, which puts the
Nix profile ahead of Entware and behind `~/bin`. The installer also appends that line to
`~/.profile` and `~/.zshenv`. Both are useless here: `~/.profile` execs zsh before reaching it, and
`~/.zshenv` is a symlink that home-manager owns, so the line lands in the store or, before the first
activation, in tracked config. Revert it if the installer wrote there.

> Builds are unsandboxed as a result, so a build could see the host filesystem. It still cannot use
> host tools, because the build `PATH` contains only store paths. In practice `x86_64-linux` is
> almost entirely cache hits, so builds are rare.

## home-manager on the NAS

`homeConfigurations."julio@nas"` in `nix-darwin/flake.nix`, with the profile in
`modules/home-manager/nas.nix`. Standalone, because there is no NixOS or nix-darwin there, but it
shares this flake and therefore `flake.lock` with the MacBook.

It imports `programs/zsh.nix` unchanged, so the NAS gets the same generated `~/.zshrc` as macOS and
with it `$DOTFILES_PLUGINS_FROM_NIX`. The zsh plugins and oh-my-zsh come from `flake.lock` rather
than from checkouts in `$HOME`, and `home.packages` supplies the CLI tools. `git.nix`, `atuin.nix`,
`direnv.nix` and `zellij.nix` are imported the same way, so those four are configured there exactly
as they are on the MacBook.

`xdg.nix` is not imported, and `nas.nix` links nothing out of the repo itself, so the only
`~/.config` entries on the box are the ones its program modules write. Neovim is the gap that
follows from that: `.config/nvim` reaches macOS through `xdg.nix` and reaches Arch and WSL through
`linux.nix`, so `nvim` here is the packaged binary with no config at all.

Apply it with the `nas-*` recipes, which work from either end:

```sh
just nas-switch                  # from the MacBook, drives the box over SSH
just nas-diff                    # build only, to see what a switch would change
NAS_HOST=nast just nas-switch    # from off the LAN, over Tailscale
```

`nas-switch` pulls the repo on the NAS, then builds and activates. Three things it does that a
hand-rolled `nix build` does not:

- `TMPDIR=$HOME/.cache/nix-install`, because `/tmp` is `noexec` and a build has to run what it
  unpacks.
- `-o ~/.hm-generation` rather than `./result`, which keeps the GC root in `$HOME` instead of in
  whatever directory the build ran from.
- `HOME_MANAGER_BACKUP_EXT=hm-bak`. Standalone home-manager reads that from the environment, where
  the MacBook gets it from `home-manager.backupFileExtension`. Without it, activation stops at the
  first unmanaged regular file sitting where a link belongs.

> A change to a recipe takes effect on the run after the one that ships it. The SSH branch sources
> `nix.sh` to find `just`, so it reads the NAS copy of the `Justfile` as it stands before the pull
> inside it.

Before the first activation `~/.zshrc` and `~/.zshenv` are symlinks into this repo, and home-manager
will not clobber them. The backup extension does not cover that case: it is checked only for regular
files, so a symlink falls through to `Existing file ... would be clobbered` and activation aborts.
Delete the links rather than backing them up, since the repo copies are what they pointed at:

```sh
rm ~/.zshrc ~/.zshenv    # first activation only
```

Git is configured by `programs/git.nix` too, which writes `~/.config/git/config`. Delete any
`~/.gitconfig` or `~/.gitconfig-global` symlink into this repo on first activation. Git reads both
of those after `~/.config/git/config`, so a link to a per-platform file wins over the module, and
`linux/gitconfig` names a libsecret helper that DSM does not have. The module branches on
`stdenv.isDarwin`: macOS keeps `osxkeychain`, and everything else gets git's `cache` helper, which
holds the token in memory rather than writing it to disk.

That same ordering is then the only way to set anything machine-local, because
`~/.config/git/config` is a read-only store path and `git config --global` follows the symlink and
rewrites the store entry in place. So `~/.gitconfig` exists here as a plain file, holding one
setting:

```ini
[safe]
	directory = /volume3/docker
```

`/volume3/docker` is the working copy the compose stacks run from. The directory itself is owned by
root while everything inside it is `julio`, so without that line a git call there from a
non-interactive SSH session fails with `detected dubious ownership`.

`~/.profile` should then hand over to the Nix zsh, which fixes the terminfo problem at its root:
unlike SynoCommunity's `zsh-static` it is not built `--disable-home-terminfo`, so it reads
`~/.terminfo` unaided. Keep the old one as a fallback for the window between a reboot and the
Boot-up task that mounts `/nix`:

```sh
for _shell in "$HOME/.nix-profile/bin/zsh" /usr/local/bin/zsh; do
  if [ -x "$_shell" ]; then
    SHELL="$_shell"
    export SHELL
    exec "$_shell"
  fi
done
```

> Build it from the repo root, not from `nix-darwin/`. `programs/zsh.nix` reads `.zshrc` and
> `.zshenv` from the repo root, which is above the flake directory, so a flake reference that copies
> only `nix-darwin/` fails with `access to absolute path '/nix/store/.zshenv' is forbidden`. Inside
> the git clone the whole repo is copied, so the path resolves.

## VS Code Remote-SSH

Two shims in `~/.local/bin`, written by `nas.nix`. `home.sessionPath` puts that directory on `$PATH`
through `hm-session-vars.sh`, because Remote-SSH runs the server CLI under `ssh -T` with no command.
That is a non-interactive login shell, which reads `.zshenv` and `.zprofile` and never `.zshrc`.

DSM has glibc but no `ldd`, and neither Entware nor SynoCommunity packages one. The CLI runs
`ldd --version` to tell a glibc host from a musl one, gets nothing, settles on musl, looks for
`/lib/ld-musl-x86_64.so.1` and stops at "The remote host does not meet the prerequisites for running
VS Code Server". The shim is glibc's own wrapper around the dynamic loader, hand-written so that it
answers for the glibc DSM links against rather than for one in the store. A packaged `ldd` cannot:
glibc bakes its version into that script at build time.

The second shim is `getconf`, linked straight from `glibc.bin`, because the same installer reads the
word size from `getconf LONG_BIT` and DSM leaves that out too.

`nas.nix` carries the reasoning in full, including the two settings that also get past the check and
why each is worse.

## Atuin

`programs/atuin.nix` comes in with the profile, so the binary and its settings are declarative. The
session token is not: `atuin login` writes one, which makes this one command per machine.

```sh
atuin login -u julio
atuin import auto && atuin sync
```

Until that runs, `atuin status` answers `You are not logged in to a sync server` and Ctrl-R searches
the local database alone. Nothing else reports it.

The server is the `atuin` stack in `nas-containers`, on this same box, so sync here never leaves the
LAN. Back up `~/.local/share/atuin/key` rather than the NAS: the server only ever holds ciphertext,
and a lost key loses the synced history whatever the disks still hold.

## Mosh on the NAS

`packages.nix` installs the client on the MacBook and `nas.nix` installs the server on the NAS, so
`just switch` and `just nas-switch` cover both halves. The client still has to be told where the
server is:

```sh
mosh-nix nas                                          # function in .zsh/zshrc_macos
mosh --server='~/.nix-profile/bin/mosh-server' nas    # what it runs
```

mosh starts `mosh-server` as a plain command over SSH, and that command lands in a shell that is
neither interactive nor a login shell. DSM gives it `/usr/bin:/bin:/usr/sbin:/sbin`, which holds
neither the Nix profile nor `/usr/local/bin`. Plain `mosh nas` therefore stops at
`Did not find mosh server startup message`. Quote the path: the tilde has to reach the NAS
unexpanded. mosh interpolates `--server` into the remote command line without quoting it, and the
remote shell is what expands it.

Everything past that lookup works untouched. mosh runs the login shell, so `~/.profile` hands over
to the Nix zsh exactly as an SSH login does. The client's `LANG` and `LC_ALL` travel on the
`mosh-server` command line rather than in the environment, so DSM's missing `AcceptEnv` costs
nothing here. The Nix glibc reads DSM's own `/usr/lib/locale/locale-archive`, so `en_US.UTF-8`
resolves and mosh gets the UTF-8 locale it insists on. `SSH_TTY` and `SSH_CONNECTION` are inherited
from the SSH session that started the server, so `.zshrc` auto-attaches zellij here too.

From inside a zellij pane `mosh-nix` prefixes `env DOTFILES_ZELLIJ_HOST=1` to the server path, which
is how the nesting marker reaches the far side over mosh. See "Zellij, and nesting" above.

The UDP port mosh picks, somewhere in 60000 to 61000, has to reach the NAS. Nothing had to be opened
for the LAN.

[synocommunity]: https://synocommunity.com

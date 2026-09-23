# WireGuard on DSM

DSM ships no WireGuard kernel module. Anything that speaks WireGuard on a Synology therefore falls
back to a userspace implementation, and gluetun does so without being asked:

```sh
sudo docker logs gluetun | grep -i implementation
# INFO [wireguard] Using userspace implementation since Kernel support does not exist
```

That works. It also moves every packet through `wireguard-go` in user space, which costs real CPU.

## What the module buys

Measured on an RS2423+ (Ryzen V1780B, 8 threads, DSM 7.4.1), pulling 50 MB files through the tunnel:

|           | Throughput    | gluetun CPU | Host CPU |
| --------- | ------------- | ----------- | -------- |
| userspace | 25 to 51 MB/s | 140 to 172% | ~22%     |
| kernel    | 47 to 49 MB/s | under 3%    | 3 to 4%  |

Two things change. About 1.5 cores come back, which matters on a box that also transcodes video or
runs model inference. And the throughput steadies: userspace produced both the best and the worst
figure in that table, while the kernel stayed inside 2 MB/s across runs.

Take your own numbers rather than trusting these on other hardware:

```sh
# throughput, from any container inside the tunnel
sudo docker exec <container> curl -s -o /dev/null -w '%{speed_download} B/s\n' \
  'https://speed.cloudflare.com/__down?bytes=50000000'

# CPU, sampled while a sustained transfer runs
sudo docker exec <container> sh -c 'for i in 1 2 3 4 5 6 7 8; do
  curl -s -o /dev/null "https://speed.cloudflare.com/__down?bytes=50000000"; done' &
sudo docker stats --no-stream --format '{{.Name}} {{.CPUPerc}}' gluetun
```

Ask that endpoint for more bytes than it serves and it returns one byte, which reads as a throughput
of about 10 B/s. Sample the CPU while the transfer is still running, since 400 MB is gone in a few
seconds.

## Getting the module

[BlackVoid](https://www.blackvoid.club/wireguard-spk-for-your-synology-nas/) publishes both prebuilt
SPKs and the image that builds them. Either way you need the platform name, which is the middle
field at the end of `uname -a`:

```sh
uname -a
# Linux NAS 4.4.302+ #90080 SMP ... x86_64 GNU/Linux synology_v1000_rs2423+
#                                                              ^^^^^
```

Building it takes one command on the NAS, and removes the question of trusting someone else's
binary. Match the image tag and `DSM_VER` to your DSM, and give the platform in lower case:

```sh
sudo mkdir -p /volume1/Software/wireguard-spk
sudo docker run --rm --privileged \
  --env PACKAGE_ARCH=v1000 \
  --env DSM_VER=7.4 \
  -v /volume1/Software/wireguard-spk:/result_spk \
  blackvoidclub/synobuild74
```

The build runs in a container, so Container Manager has to be up.

The SPK lands in a version directory under the mount, in a plain and a `_debug` build. Install the
plain one, and keep it: a reinstall needs no rebuild. Take the prebuilt one from the article instead
if you prefer, and unzip it.

## Check it before you install it

A kernel module loads only against the kernel it was built for, and the SPK carries no other
guarantee. Compare its vermagic against a module DSM shipped itself:

```sh
tar xf WireGuard-*.spk                       # gives INFO, package.tgz, scripts/
cat INFO                                     # arch must match, os_min_ver must be below yours
mkdir -p pkg && tar xJf package.tgz -C pkg   # package.tgz is xz, whatever the name says
tr '\0' '\n' < pkg/wireguard/wireguard.ko | grep '^vermagic='
tr '\0' '\n' < /lib/modules/sit.ko | grep '^vermagic='
```

Both lines must read the same, `4.4.302+ SMP mod_unload` for the DSM above. If they differ, do not
install it. Build one against your own DSM.

## Install

```sh
sudo /usr/syno/bin/synopkg install ./WireGuard-<platform>-<version>.spk

# The package installs as its own user and cannot load a module that way.
sudo sed -i 's/"run-as": "package"/"run-as": "root"/' \
  /var/packages/WireGuard/conf/privilege

sudo /usr/syno/bin/synopkg start WireGuard
lsmod | grep wireguard
```

`synopkg` lives in `/usr/syno/bin`, which is not on the `PATH` a script or `ssh HOST '<cmd>'` gets.

Without the `sed`, DSM answers `Failed to run script, script=[start]` and names no reason. It runs
`scripts/start-stop-status`, which reads `/usr/syno/etc/iptables_modules_list` and calls `insmod`.
Both want root. The package log has the error:

```sh
sudo grep start-stop-status /var/log/packages/WireGuard.log
```

The SPK ships a `scripts/start` that does the same `sed`. DSM never calls it, because that is not a
DSM hook name.

gluetun chooses its implementation at startup, so restart the containers on the tunnel and confirm
what it took:

```sh
sudo docker compose restart
sudo docker logs gluetun | grep -i implementation
# INFO [wireguard] Using available kernelspace implementation
```

gluetun names its interface from a setting, so the device stays `tun0` under either implementation.
Anything bound to the interface keeps working.

Choosing which Proton server gluetun connects to is a separate trap, and the list inside the image
is not the one an account holds. That, and the stacks themselves, are in the `nas-containers`
repository.

## The tun module

The kernel implementation never touches `/dev/net/tun`. It creates a network interface of its own
type instead. That device still has to exist, because the compose file names it:

```yaml
devices:
  - /dev/net/tun:/dev/net/tun
```

When Docker creates the container, it reads that line. That happens before gluetun picks an
implementation, so the device is a condition of starting at all. Without it:

```
Error response from daemon: error gathering device information while adding custom device
"/dev/net/tun": no such file or directory
```

Nothing here loads `tun`. `/usr/syno/etc/iptables_modules_list` carries it as
`OPENVPN_MODULES="tun.ko"`, and the only reader of that entry is
`/usr/syno/etc/synovpnclient/scripts/ovpnc.sh`. That script runs only for a DSM OpenVPN client
connection. This box never makes one.

The two packages that do load modules load other ones. The WireGuard SPK loads the core and NAT
modules, then `wireguard.ko`. Container Manager loads the core, common, NAT, IPv6 and Docker
modules. So only a manual `modprobe` loads `tun`, and a reboot clears it.

The cost is a stack rather than a container. gluetun stops in `Created`, and the eleven services
that borrow its namespace stop in `Created` behind it. `sudo docker ps -a` is what shows this, since
`docker ps` alone hides a container that never ran.

Load it from a **Triggered Task** in Control Panel → Task Scheduler (event: Boot-up, user: `root`),
beside the Entware and Nix tasks that [synology.md](synology.md) describes:

```sh
/sbin/modprobe tun
```

`modprobe` creates `/dev/net/tun` on its own, so the task needs no second line.

## The task from the CLI

`synoschedtask` cannot create one. It offers `--get`, `--del`, `--run` and `--sync`, and a triggered
task is not in what `--get` reports: that subcommand answers for the time-based tasks alone. Both
kinds live in one SQLite database, and `--sync` is what makes DSM re-read it.

> **This writes to a DSM system database, and the UI is the supported route.** Copy the file first.
> The row has to match the columns of a bootup task that works, and `{"running":[]}` has to reach
> sqlite intact. Send the statement on stdin. As an argument to `ssh HOST '<cmd>'` it is parsed
> twice and the inner quotes are gone by the time sqlite sees them.

```sh
sudo cp -a /usr/syno/etc/esynoscheduler/esynoscheduler.db{,.bak}

sudo sqlite3 /usr/syno/etc/esynoscheduler/esynoscheduler.db <<'SQL'
INSERT INTO task (task_name, description, event, depend_on_task, enable, owner,
                  run_the_same_time, notify_enable, notify_mail, notify_if_error,
                  operation, operation_type, status, last_start_time, last_stop_time,
                  last_exit_info, extra)
VALUES ('TUN', '', 'bootup', '', 1, 0, 0, 0, '', 0,
        '/sbin/modprobe tun', 'script', '{"running":[]}', 0, 0, '{}', '{}');
SQL

sudo /usr/syno/bin/synoschedtask --sync
```

`task_name` is the primary key, so the name is the handle. Read back what DSM made of it, and what
every bootup task did on the last boot:

```sh
sudo sqlite3 /usr/syno/etc/esynoscheduler/esynoscheduler.db \
  'select task_name, datetime(last_start_time, "unixepoch", "localtime"), last_exit_info
     from task where event = "bootup";'
```

A task that never ran reads `1970-01-01`. The UI is the other half. If Control Panel lists `TUN`
beside the others, the row is well-formed.

## Boot order

The bootup tasks run about 80 seconds after the kernel starts, which is well after Container
Manager. That order still works here. Every service in both stacks carries
`restart: unless-stopped`, and a clean DSM shutdown stops the containers. Docker then leaves a
stopped container down at the next boot. So nothing wants the device before the task runs.

A power loss breaks that. The containers were never stopped, so the daemon starts them itself, and
it can win the race against the task. If gluetun is down after an unclean boot, take the stack down
and up:

```sh
just restart qbittorrent_gluetun
```

## Putting it back

gluetun returning to userspace is the sign the module is gone. Compare the kept SPK's vermagic
against the running kernel, as above: the same means reinstall, different means rebuild with
`DSM_VER` matched to the DSM. Then install as above.

## Weighing it

Against:

- The module is unofficial and it runs in kernel space, where a bad one panics the kernel or leaves
  the NAS unbootable. The project says as much itself.
- A prebuilt SPK is a binary from a stranger, built by a toolchain you did not run. Building it
  yourself answers that half.
- Every DSM update replaces the kernel, so the module stops matching and stops loading. Each update
  costs a rebuild, an uninstall, a reinstall and a reboot.

For:

- About 1.5 cores back under load, and steadier throughput.
- The vermagic check catches the dangerous case before anything reaches the kernel.
- The failure mode is soft. With the module missing or refusing to load, gluetun returns to
  userspace on its own: slower, still up, and it says so in the log.

That last point decides it. Losing the module costs throughput rather than service, so the downside
is bounded. Check the vermagic, keep the SPK, and take the reboot while you are watching rather than
meeting a boot problem months later. The package survives a reboot on its own once installed.

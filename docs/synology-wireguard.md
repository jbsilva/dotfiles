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
sudo docker run --rm --privileged \
  --env PACKAGE_ARCH=v1000 \
  --env DSM_VER=7.4 \
  -v /volume1/docker/synowirespk74:/result_spk \
  blackvoidclub/synobuild74
```

The SPK lands in the mounted directory. Take the prebuilt one from the article instead if you
prefer, and unzip it.

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
sudo /usr/syno/bin/synopkg start WireGuard
lsmod | grep wireguard
```

The package's own `scripts/start` rewrites `conf/privilege` so the package runs as root, and then
calls bare `synopkg`, which is not on root's `PATH`. It reports failure after it has already done
that useful half. Call `synopkg` with the full path, as above.

gluetun chooses its implementation at startup, so restart the containers on the tunnel and confirm
what it took:

```sh
sudo docker compose restart
sudo docker logs gluetun | grep -i implementation
# INFO [wireguard] Using available kernelspace implementation
```

gluetun names its interface from a setting, so the device stays `tun0` under either implementation.
Anything bound to the interface keeps working.

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

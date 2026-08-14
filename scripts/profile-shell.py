#!/usr/bin/env python3
"""Measure interactive zsh startup and Tab-completion latency.

`hyperfine 'zsh -i -c exit'` only covers startup. Completion latency needs a
real terminal: zsh will not run its line editor without a tty, and plugins that
hook ZLE (fzf-tab, zsh-patina) are never exercised without one. So this drives
a pty.

    just profile-shell                  # startup + a default set of completions
    just profile-shell 'ls ~/dot'       # time one specific completion
    just profile-shell 'git ch' --cold  # clear the zsh caches first

--cold removes $XDG_CACHE_HOME/zsh, which forces compinit to rebuild its dump
and the tool-completion cache in .zshrc to regenerate. That is the state a
shell is in right after `just switch`.
"""

from __future__ import annotations

import argparse
import os
import pty
import select
import shutil
import subprocess
import sys
import time

DEFAULT_CASES = ["ls ~/dot", "git ch", "cd /usr/lo", "nix ru"]

# Time budget for a single completion before we call it hung.
TIMEOUT_S = 60.0


def zsh_path() -> str:
    for candidate in ("/run/current-system/sw/bin/zsh", "/bin/zsh"):
        if os.path.exists(candidate):
            return candidate
    found = shutil.which("zsh")
    if not found:
        sys.exit("no zsh found")
    return found


def drain(fd: int, quiet_for: float) -> bytes:
    """Read until the pty has been silent for `quiet_for` seconds."""
    out = b""
    while select.select([fd], [], [], quiet_for)[0]:
        try:
            chunk = os.read(fd, 65536)
        except OSError:
            break
        if not chunk:
            break
        out += chunk
    return out


def measure(cases: list[str], settle: float) -> int:
    zsh = zsh_path()
    pid, fd = pty.fork()
    if pid == 0:
        os.environ["TERM"] = "xterm-256color"
        os.execv(zsh, [zsh, "-i"])

    started = time.time()
    drain(fd, 1.0)
    # The prompt appearing is not the same as the shell being idle: async
    # plugin work and the first compinit can still be running.
    time.sleep(settle)
    drain(fd, 0.5)
    print(f"  startup + settle : {time.time() - started:.2f}s")

    worst = 0.0
    for case in cases:
        os.write(fd, case.encode())
        time.sleep(0.4)
        drain(fd, 0.4)

        t0 = time.time()
        os.write(fd, b"\t")
        first: float | None = None
        while time.time() - t0 < TIMEOUT_S:
            if select.select([fd], [], [], 0.2)[0]:
                try:
                    chunk = os.read(fd, 65536)
                except OSError:
                    break
                if chunk and chunk.strip() and first is None:
                    first = time.time() - t0
                    break
        elapsed = first if first is not None else TIMEOUT_S
        worst = max(worst, elapsed)
        flag = "   <-- SLOW" if elapsed > 1.0 else ""
        print(f"  TAB {case!r:<20} {elapsed:6.2f}s{flag}")

        # Clear the line for the next case.
        os.write(fd, b"\x15")  # kill-whole-line
        time.sleep(0.3)
        drain(fd, 0.3)

    os.write(fd, b"\x03")
    os.write(fd, b"exit\n")
    time.sleep(0.3)
    os.close(fd)
    os.waitpid(pid, 0)
    return 0 if worst <= 1.0 else 1


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "case",
        nargs="*",
        help="command prefix to Tab-complete; all words are joined into one case, "
        "because `just` splits its *ARGS on whitespace",
    )
    parser.add_argument(
        "--cold",
        action="store_true",
        help="wipe the zsh caches first, reproducing a post-switch shell",
    )
    parser.add_argument(
        "--settle",
        type=float,
        default=3.0,
        help="seconds to wait for the shell to go idle before the first Tab",
    )
    args = parser.parse_args()

    if args.cold:
        cache = os.path.join(
            os.environ.get("XDG_CACHE_HOME", os.path.expanduser("~/.cache")), "zsh"
        )
        shutil.rmtree(cache, ignore_errors=True)
        print(f"  cleared {cache}")

    # Joined rather than treated as separate cases: `just profile-shell ls ~/dot`
    # arrives here as ["ls", "/Users/julio/dot"], and the intent is one case.
    cases = [" ".join(args.case)] if args.case else DEFAULT_CASES

    print("\nzsh startup (hyperfine):")
    if shutil.which("hyperfine"):
        subprocess.run(
            ["hyperfine", "--warmup", "2", "--runs", "10", "zsh -i -c exit"],
            check=False,
        )
    else:
        print("  hyperfine not installed, skipping")

    print("\ncompletion latency (pty):")
    return measure(cases, args.settle)


if __name__ == "__main__":
    sys.exit(main())

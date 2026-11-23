# apt-n900

A friendly `apt` command for Nokia N900 (Maemo 5, apt 0.7.20). It is a small POSIX shell script over `apt-get`,
`apt-cache` and `dpkg-query`; nothing of the system package manager is replaced.

```
apt update
apt list --upgradable        # packages with a newer version in the repositories
apt list --installed [word]
apt upgrade                  # apt full-upgrade for dist-upgrade
apt install|remove|purge|autoremove|clean ...
apt search|show|policy ...
apt files PKG                # files of an installed package
apt owns FILE                # which package owns a file
apt tui                      # text-mode menu (apt-tui, needs the dialog package)
```

Commands that change the system use `sudo` when you are not root. Other options go to apt-get (`apt install -y PKG`).
`NO_COLOR=1` turns colours off.

Build (in the N900 project): `make debs APP=apt-n900`, tests on the phone: `make -C apps/apt-n900 test`.

## apt tui

`apt-tui` is a menu built on `dialog`: **Update lists**, **Upgrade** (a check list of the upgradable packages), **Search and install**,
**Installed packages** (description only) and **Remove packages**. Every change is first shown as a simulation
(`apt-get -s`) and needs a confirmation; the output of apt-get is shown live. The sudo password is asked on the plain terminal, before the
box with the output. The boxes follow the size of the terminal (80x24 on the N900 with the keyboard open).

### Packages that are not signed

Most Maemo repositories (including the ones of this project) have no signature, so apt 0.7 refuses to install their packages with `-y`
("There are problems and -y was used without --force-yes"). The TUI does not switch the check off in the settings; it asks for each installation:

1. The confirmation names the packages that cannot be verified (`WARNING, cannot be verified: foo bar`; the list comes from the simulation).
2. A second question, **Install anyway?**, answered No by default, explains the risk.
3. Only after Yes does it run `apt-get -y --allow-unauthenticated install ...` for exactly these packages.

When the simulation says nothing and only the real run is refused because of the signature, the TUI asks the same question and tries again
with the flag. Signed packages are installed after one confirmation, without the flag. On the command line the same is
`apt install --allow-unauthenticated PKG` (the options go to apt-get).

### Tests

The tests drive the menu through `screen` with a fake `apt-get`: the check list, a signed installation (no flag), unsigned packages named in the
simulation (default No, then Yes with the flag), and a refusal of the real run followed by a retry. They also run without a phone: `make emu-test APP=apt-n900`
(the line `# emu-needs: screen` in `test.sh` unpacks the package screen into the emulated phone; `make debs APP="screen dialog apt-n900"` first).
In the emulated phone the tests of `search`, `show`, `files`, `owns` and `list --installed` fail: it has no real `apt-cache` and `dpkg-query`.

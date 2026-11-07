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
```

Commands that change the system use `sudo` when you are not root. Other options go to apt-get (`apt install -y PKG`).
`NO_COLOR=1` turns colours off.

Build (in the N900 project): `make debs APP=apt-n900`, tests on the phone: `make -C apps/apt-n900 test`.

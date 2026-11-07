TEST_NAME=apt-n900
need_pkg apt-n900
contains help "Usage: apt COMMAND" apt --help
contains version "apt-n900" apt --version
ok list-upgradable sh -c 'apt list --upgradable >/dev/null'
ok list-installed sh -c 'apt list --installed | grep -q busybox'
contains search "busybox" apt search busybox
contains show "Package: busybox" apt show busybox
contains files "/bin/busybox" apt files busybox
contains owns "busybox" apt owns /bin/busybox
ok simulate-needs-no-root sh -c 'apt install -s busybox >/dev/null'
t unknown-command-exit 2 sh -c 'apt frobnicate >/dev/null 2>&1; echo $?'
summary

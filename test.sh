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
ok raw-list sh -c 'apt list --upgradable --raw >/dev/null'
ok tui-installed sh -c 'command -v apt-tui'
# the dialog interface: a fake apt-get offers two upgrades; the menu is driven through screen (hardcopy of the virtual terminal)
if command -v screen >/dev/null 2>&1; then
    cat > /tmp/fake-apt-get <<'EOT'
#!/bin/sh
case "$*" in
  *"-s dist-upgrade"*|*"-s upgrade"*) echo "Inst foo [1.0] (1.1 Repo [armel])"; echo "Inst bar [2.0] (2.1 Repo [armel])" ;;
  *) echo "0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded." ;;
esac
EOT
    chmod +x /tmp/fake-apt-get
    screen -wipe >/dev/null 2>&1
    screen -dmS aptui -c /dev/null sh -c 'TERM=xterm APT_GET=/tmp/fake-apt-get apt-tui'
    sleep 2; screen -S aptui -X stuff "$(printf '\r')"; sleep 2
    screen -S aptui -X hardcopy /tmp/aptui.txt; sleep 1
    contains tui-checklist "foo" cat /tmp/aptui.txt
    contains tui-versions "1.0 -> 1.1" cat /tmp/aptui.txt
    screen -S aptui -X quit >/dev/null 2>&1; rm -f /tmp/fake-apt-get /tmp/aptui.txt
else
    skip tui-checklist "screen not installed"
fi
summary

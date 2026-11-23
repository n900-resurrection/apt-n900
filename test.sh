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
cat > /tmp/fake-apt-get-err <<'EOT'
#!/bin/sh
echo "E: Error, pkgProblemResolver::Resolve generated breaks" >&2
exit 100
EOT
chmod +x /tmp/fake-apt-get-err
contains error-not-uptodate "could not be made" sh -c 'APT_GET=/tmp/fake-apt-get-err apt list --upgradable 2>&1'
ok tui-installed sh -c 'command -v apt-tui'
# the dialog interface: a fake apt-get offers two upgrades; the menu is driven through screen (hardcopy of the virtual terminal)
# emu-needs: screen
if command -v screen >/dev/null 2>&1; then
    # FAKE_MODE: plain (signed packages), sim (the simulation names unsigned packages), fail (only the real run refuses, as apt 0.7 does with -y)
    cat > /tmp/fake-apt-get <<'EOT'
#!/bin/sh
case "$*" in
  *"-s dist-upgrade"*|*"-s upgrade"*) echo "Inst foo [1.0] (1.1 Repo [armel])"; echo "Inst bar [2.0] (2.1 Repo [armel])" ;;
  *"-s install"*)
    echo "Inst foo [1.0] (1.1 Repo [armel])"; echo "Inst bar [2.0] (2.1 Repo [armel])"
    [ "$FAKE_MODE" = sim ] && { echo "WARNING: The following packages cannot be authenticated!"; echo "  foo bar"; }
    echo "2 upgraded, 0 newly installed, 0 to remove and 0 not upgraded." ;;
  *" install "*)
    case "$*" in *--allow-unauthenticated*) echo "$*" > /tmp/fake-installed; echo "installed (unauthenticated allowed)" ;;
      *) if [ "$FAKE_MODE" = plain ]; then echo "$*" > /tmp/fake-installed; echo "installed"
         else echo "E: There are problems and -y was used without --force-yes"; exit 100; fi ;;
    esac ;;
  *) echo "0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded." ;;
esac
EOT
    chmod +x /tmp/fake-apt-get
    key() { screen -S aptui -X stuff "$1"; sleep 2; }
    shot() { screen -S aptui -X hardcopy /tmp/aptui.txt; sleep 1; }
    # start MODE: apt-tui on the fake apt-get; the menu entry "Upgrade", the check list, Enter = continue
    start() {
        rm -f /tmp/fake-installed /tmp/aptui.txt
        screen -wipe >/dev/null 2>&1
        screen -dmS aptui -c /dev/null sh -c "TERM=xterm FAKE_MODE=$1 APT_GET=/tmp/fake-apt-get apt-tui"
        sleep 2; key 2; key "$(printf '\r')"
    }
    stop() { screen -S aptui -X quit >/dev/null 2>&1; }
    ENTER=$(printf '\r'); TAB=$(printf '\t')

    # the list of upgrades
    start plain; shot
    contains tui-checklist "foo" cat /tmp/aptui.txt
    contains tui-versions "1.0 -> 1.1" cat /tmp/aptui.txt
    # signed packages: one confirmation, installed without the flag
    key "$ENTER"; shot
    contains tui-confirm "Confirm" cat /tmp/aptui.txt
    key "$ENTER"; sleep 1; key "$ENTER"
    ok tui-signed-installed test -f /tmp/fake-installed
    ok tui-signed-no-flag sh -c '! grep -q allow-unauthenticated /tmp/fake-installed'
    stop

    # the simulation names unsigned packages: a warning in the confirmation, a second, explicit question (default No)
    start sim; key "$ENTER"; shot
    contains tui-unsigned-named "cannot be verified: foo bar" cat /tmp/aptui.txt
    key "$TAB"; key "$ENTER"; shot
    contains tui-unsigned-ask "Install anyway" cat /tmp/aptui.txt
    key "$ENTER"; sleep 1
    ok tui-unsigned-default-no sh -c '! test -f /tmp/fake-installed'
    stop
    start sim; key "$ENTER"; key "$TAB"; key "$ENTER"; key "$TAB"; key "$ENTER"; sleep 1; key "$ENTER"
    ok tui-unsigned-installed test -f /tmp/fake-installed
    contains tui-unsigned-flag "--allow-unauthenticated" cat /tmp/fake-installed
    stop

    # only the real run refuses (the simulation says nothing): the TUI asks and tries again with the flag
    start fail; key "$ENTER"; key "$ENTER"; key "$ENTER"; shot
    contains tui-refused-ask "Install anyway" cat /tmp/aptui.txt
    ok tui-refused-not-installed sh -c '! test -f /tmp/fake-installed'
    key "$TAB"; key "$ENTER"; sleep 1; key "$ENTER"
    contains tui-refused-retry "--allow-unauthenticated" cat /tmp/fake-installed
    stop
    rm -f /tmp/fake-apt-get /tmp/aptui.txt /tmp/fake-installed
else
    skip tui-checklist "screen not installed"
fi
summary

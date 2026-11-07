#!/bin/bash
# Package apt-n900 as a .deb for Maemo 5 (a shell script, built as armel).
#   make -C apps/apt-n900 deb
set -euo pipefail
PROJ=/project
. "$PROJ/scripts/debpack.sh"

PKG=apt-n900
VERSION="${VERSION:-0.2}"
STAGE="$PROJ/build/deb/stage-$PKG"
HERE="$PROJ/apps/apt-n900"

rm -rf "$STAGE"
mkdir -p "$STAGE/usr/bin"
install -m 755 "$HERE/apt" "$STAGE/usr/bin/apt"
install -m 755 "$HERE/apt-tui" "$STAGE/usr/bin/apt-tui"

SECTION=user/system
DEPENDS="apt, dpkg, sudo, dialog"
DISPLAY_NAME="apt-n900"
SHORT_DESC="Friendly apt command (list --upgradable, search, show) over apt-get"
LONG_DESC="Adds /usr/bin/apt with the commands of modern apt: apt update, apt list --upgradable, apt upgrade, apt install, apt search, apt show, apt files, apt owns, and apt tui (apt-tui: a dialog based menu to upgrade, search, install and remove). It only calls apt-get, apt-cache and dpkg-query: nothing of the system package manager is replaced."
debpack_build

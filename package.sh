#!/bin/bash
# Package apt-n900 as a .deb for Maemo 5 (a shell script, built as armel).
#   make -C apps/apt-n900 deb
set -euo pipefail
PROJ=/project
. "$PROJ/scripts/debpack.sh"

PKG=apt-n900
VERSION="${VERSION:-0.1}"
STAGE="$PROJ/build/deb/stage-$PKG"
HERE="$PROJ/apps/apt-n900"

rm -rf "$STAGE"
mkdir -p "$STAGE/usr/bin"
install -m 755 "$HERE/apt" "$STAGE/usr/bin/apt"

SECTION=user/system
DEPENDS="apt, dpkg, sudo"
DISPLAY_NAME="apt-n900"
SHORT_DESC="Friendly apt command (list --upgradable, search, show) over apt-get"
LONG_DESC="Adds /usr/bin/apt with the commands of modern apt: apt update, apt list --upgradable, apt upgrade, apt install, apt search, apt show, apt files, apt owns. It only calls apt-get, apt-cache and dpkg-query: nothing of the system package manager is replaced."
debpack_build

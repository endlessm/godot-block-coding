#!/bin/sh

# Merge new strings from POT file into message catalogs.
set -e

SCRIPTDIR=$(dirname "$0")
PROJDIR=$(dirname "$SCRIPTDIR")
LOCALEDIR="$PROJDIR/addons/block_code/locale"
POT="$LOCALEDIR/godot_block_coding.pot"

for po in "$LOCALEDIR"/*.po; do
    echo -n "$po"
    msgmerge --update --backup=none "$po" "$POT"
done

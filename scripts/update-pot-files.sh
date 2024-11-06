#!/bin/sh

# Wrapper script to try to execute the update-pot-files.gd main loop script.
set -e

SCRIPTDIR=$(dirname "$0")
PROJDIR=$(dirname "$SCRIPTDIR")
GODOT_SH="$SCRIPTDIR/godot.sh"
SCRIPT="$SCRIPTDIR/update-pot-files.gd"

exec "$GODOT_SH" --path "$PROJDIR" --headless --script "$SCRIPT"

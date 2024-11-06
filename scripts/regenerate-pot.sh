#!/bin/sh

# Wrapper script to try to execute the regenerate-pot.gd main loop script.
set -e

SCRIPTDIR=$(dirname "$0")
PROJDIR=$(dirname "$SCRIPTDIR")
GODOT_SH="$SCRIPTDIR/godot.sh"
SCRIPT="$SCRIPTDIR/regenerate-pot.gd"

exec "$GODOT_SH" --path "$PROJDIR" --headless --editor --script "$SCRIPT"

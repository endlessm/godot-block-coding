#!/bin/bash

# Wrapper script to try to execute the Godot binary.
set -e

get_godot_bin() {
    # GODOT environment variable preferred.
    if [ -n "$GODOT" ]; then
        echo "$GODOT"
        return 0
    fi

    # godot in PATH.
    if type -p godot >/dev/null; then
        echo godot
        return 0
    fi

    # Flatpak Godot with <installation>/exports/bin in PATH.
    if type -p org.godotengine.Godot >/dev/null; then
        echo org.godotengine.Godot
        return 0
    fi

    # Flatpak Godot without <installation>/exports/bin in PATH.
    if flatpak info org.godotengine.Godot &>/dev/null; then
        echo "flatpak run org.godotengine.Godot"
        return 0
    fi

    echo "error: Could not find godot executable, set GODOT environment variable" >&2
    return 1
}

godot_bin=$(get_godot_bin)
exec $godot_bin "$@"

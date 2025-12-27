#!/bin/bash

# Path to matugen generated colors (from hyprland template)
COLOR_FILE="$HOME/.config/hypr/colors.conf"

# Check if color file exists
if [ ! -f "$COLOR_FILE" ]; then
    echo "Matugen colors not found at $COLOR_FILE"
    echo "Have you run 'matugen generate' ?"
    echo "Running cmatrix with default green color..."
    cmatrix "$@"
    exit 0
fi

# Extract primary color from hyprland colors file
# Format: $primary = rgba(ffb4a5ff)
PRIMARY_RGBA=$(grep '^\$primary = ' "$COLOR_FILE" | grep -oP 'rgba\(\K[0-9a-fA-F]{8}' | head -1)

if [ -z "$PRIMARY_RGBA" ]; then
    echo "Could not find primary color in $COLOR_FILE"
    echo "Running cmatrix with default green color..."
    cmatrix "$@"
    exit 0
fi

# Convert RGBA to RGB (ignore alpha channel - last 2 chars)
HEX_COLOR="${PRIMARY_RGBA:0:6}"

# Convert hex to RGB
hex_to_rgb() {
    hex=$1
    r=$((16#${hex:0:2}))
    g=$((16#${hex:2:2}))
    b=$((16#${hex:4:2}))
    echo "$r $g $b"
}

RGB=($(hex_to_rgb "$HEX_COLOR"))
R=${RGB[0]}
G=${RGB[1]}
B=${RGB[2]}

# Determine closest cmatrix color based on dominant component
# cmatrix supports: green (default), red, blue, yellow, cyan, magenta, white
if [ $G -gt $R ] && [ $G -gt $B ]; then
    # Green dominant
    if [ $B -gt $R ]; then
        COLOR="cyan"  # Green + Blue
    else
        COLOR="green"
    fi
elif [ $R -gt $G ] && [ $R -gt $B ]; then
    # Red dominant
    if [ $G -gt $B ]; then
        COLOR="yellow"  # Red + Green
    else
        COLOR="red"
    fi
elif [ $B -gt $R ] && [ $B -gt $G ]; then
    # Blue dominant
    if [ $R -gt $G ]; then
        COLOR="magenta"  # Blue + Red
    else
        COLOR="blue"
    fi
else
    # Colors are similar, use white or default
    COLOR="green"
fi

echo "Using matugen primary color: #$HEX_COLOR (R:$R G:$G B:$B)"
echo "Mapped to cmatrix color: $COLOR"
echo ""

# Run cmatrix with the determined color and pass any additional arguments
cmatrix -C "$COLOR" "$@"

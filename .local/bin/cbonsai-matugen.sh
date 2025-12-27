#!/bin/bash

# Path to matugen generated colors (from hyprland template)
COLOR_FILE="$HOME/.config/hypr/colors.conf"

# Check if color file exists
if [ ! -f "$COLOR_FILE" ]; then
    echo "Matugen colors not found at $COLOR_FILE"
    echo "Have you run 'matugen generate' ?"
    echo "Running cbonsai with default colors..."
    cbonsai "$@"
    exit 0
fi

# Extract colors from hyprland colors file
# Using tertiary for leaves (usually green/yellow tones)
# Using secondary for secondary leaf color
# Using on_surface for branches
# Using outline for dark wood (more visible than surface)
TERTIARY_RGBA=$(grep '^\$tertiary = ' "$COLOR_FILE" | grep -oP 'rgba\(\K[0-9a-fA-F]{8}' | head -1)
SECONDARY_RGBA=$(grep '^\$secondary = ' "$COLOR_FILE" | grep -oP 'rgba\(\K[0-9a-fA-F]{8}' | head -1)
ON_SURFACE_RGBA=$(grep '^\$on_surface = ' "$COLOR_FILE" | grep -oP 'rgba\(\K[0-9a-fA-F]{8}' | head -1)
OUTLINE_RGBA=$(grep '^\$outline = ' "$COLOR_FILE" | grep -oP 'rgba\(\K[0-9a-fA-F]{8}' | head -1)

if [ -z "$TERTIARY_RGBA" ] || [ -z "$ON_SURFACE_RGBA" ]; then
    echo "Could not find required colors in $COLOR_FILE"
    echo "Running cbonsai with default colors..."
    cbonsai "$@"
    exit 0
fi

# Function to convert hex to RGB
hex_to_rgb() {
    hex=$1
    r=$((16#${hex:0:2}))
    g=$((16#${hex:2:2}))
    b=$((16#${hex:4:2}))
    echo "$r $g $b"
}

# Function to convert RGB to closest 256 color index
rgb_to_256() {
    r=$1
    g=$2
    b=$3
    
    # Use 256 color cube: 16 + 36*r + 6*g + b
    # where r,g,b are 0-5
    r_idx=$((r * 5 / 255))
    g_idx=$((g * 5 / 255))
    b_idx=$((b * 5 / 255))
    
    echo $((16 + 36 * r_idx + 6 * g_idx + b_idx))
}

# Convert colors
TERTIARY_HEX="${TERTIARY_RGBA:0:6}"
SECONDARY_HEX="${SECONDARY_RGBA:0:6}"
ON_SURFACE_HEX="${ON_SURFACE_RGBA:0:6}"
SURFACE_HEX="${SURFACE_RGBA:0:6}"

# Get RGB values
TERTIARY_RGB=($(hex_to_rgb "$TERTIARY_HEX"))
SECONDARY_RGB=($(hex_to_rgb "$SECONDARY_HEX"))
ON_SURFACE_RGB=($(hex_to_rgb "$ON_SURFACE_HEX"))
SURFACE_RGB=($(hex_to_rgb "$SURFACE_HEX"))

# Convert to 256 color indices
# cbonsai format: dark_leaves,dark_wood,light_leaves,light_wood
DARK_LEAVES=$(rgb_to_256 ${SECONDARY_RGB[0]} ${SECONDARY_RGB[1]} ${SECONDARY_RGB[2]})
DARK_WOOD=$(rgb_to_256 ${SURFACE_RGB[0]} ${SURFACE_RGB[1]} ${SURFACE_RGB[2]})
LIGHT_LEAVES=$(rgb_to_256 ${TERTIARY_RGB[0]} ${TERTIARY_RGB[1]} ${TERTIARY_RGB[2]})
LIGHT_WOOD=$(rgb_to_256 ${ON_SURFACE_RGB[0]} ${ON_SURFACE_RGB[1]} ${ON_SURFACE_RGB[2]})

COLOR_STRING="$DARK_LEAVES,$DARK_WOOD,$LIGHT_LEAVES,$LIGHT_WOOD"

echo "Using matugen colors for cbonsai:"
echo "  Dark leaves (secondary): #$SECONDARY_HEX → color $DARK_LEAVES"
echo "  Dark wood (surface): #$SURFACE_HEX → color $DARK_WOOD"
echo "  Light leaves (tertiary): #$TERTIARY_HEX → color $LIGHT_LEAVES"
echo "  Light wood (on_surface): #$ON_SURFACE_HEX → color $LIGHT_WOOD"
echo "  Color string: $COLOR_STRING"
echo ""

# Run cbonsai with custom colors
cbonsai -l -k "$COLOR_STRING" "$@"

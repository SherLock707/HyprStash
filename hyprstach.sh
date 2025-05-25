#!/bin/bash

# HyprStash - A versatile window stashing manager for Hyprland
# Usage: ./hyprstash.sh [OPTIONS] -- COMMAND
# Example: ./hyprstash.sh -s 60x40 -p top -c foot-drop -- foot --app-id foot-drop

SPECIAL_WS="special:scratchpad"

# Default values
SIZE="50x50"
POSITION="top"
CLASS_NAME=""
COMMAND=""
HELP=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--size)
            SIZE="$2"
            shift 2
            ;;
        -p|--position)
            POSITION="$2"
            shift 2
            ;;
        -c|--class)
            CLASS_NAME="$2"
            shift 2
            ;;
        -h|--help)
            HELP=true
            shift
            ;;
        --)
            shift
            COMMAND="$*"
            break
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Show help
if [[ "$HELP" == true ]]; then
    cat << EOF
HyprStash - A versatile window stashing manager for Hyprland

USAGE:
    hyprstash.sh [OPTIONS] -- COMMAND

OPTIONS:
    -s, --size SIZE         Window size in format WIDTHxHEIGHT or WIDTH%xHEIGHT%
                           Examples: 800x600, 50x40, 60%x50%
                           Default: 50x50

    -p, --position POS      Window spawn position: top, bottom, left, right, center
                           Default: top

    -c, --class CLASS       Window class name for identification
                           Required for proper window management

    -h, --help             Show this help message

    --                      Separator between options and command

COMMAND:
    The command to execute for spawning the window

EXAMPLES:
    # Stashed terminal (foot)
    hyprstash.sh -s 70x60 -p top -c foot-drop -- foot --app-id foot-drop

    # Stashed terminal with zellij
    hyprstash.sh -s 60x40 -p top -c foot-drop -- foot --app-id foot-drop -e zellij attach --create scratchpad

    # Stashed file manager
    hyprstash.sh -s 80x70 -p center -c nemo-drop -- nemo --class nemo-drop

    # Stashed calculator
    hyprstash.sh -s 400x500 -p right -c calc-drop -- gnome-calculator --class calc-drop

    # Stashed text editor
    hyprstash.sh -s 90x80 -p center -c code-drop -- code --class code-drop

NOTES:
    - The window class (-c) should match the class used in your command
    - Use 'hyprctl clients' to verify window class names
    - Size can be in pixels (800x600) or percentages (50%x40%)
    - Position determines where the window appears on screen

EOF
    exit 0
fi

# Validate required arguments
if [[ -z "$CLASS_NAME" ]]; then
    echo "Error: Window class name is required (-c/--class)"
    echo "Use -h or --help for usage information"
    exit 1
fi

if [[ -z "$COMMAND" ]]; then
    echo "Error: Command is required (after --)"
    echo "Use -h or --help for usage information"
    exit 1
fi

# Parse size (handle both percentage and pixel values)
if [[ "$SIZE" =~ ^([0-9]+)(%?)x([0-9]+)(%?)$ ]]; then
    WIDTH="${BASH_REMATCH[1]}${BASH_REMATCH[2]}"
    HEIGHT="${BASH_REMATCH[3]}${BASH_REMATCH[4]}"
else
    echo "Error: Invalid size format. Use WIDTHxHEIGHT (e.g., 800x600 or 50%x40%)"
    exit 1
fi

# Calculate position based on argument
case "$POSITION" in
    top)
        X_POS="15%"
        Y_POS="5%"
        ;;
    bottom)
        X_POS="15%"
        Y_POS="35%"
        ;;
    left)
        X_POS="5%"
        Y_POS="15%"
        ;;
    right)
        X_POS="25%"
        Y_POS="15%"
        ;;
    center)
        X_POS="25%"
        Y_POS="20%"
        ;;
    *)
        echo "Error: Invalid position. Use: top, bottom, left, right, center"
        exit 1
        ;;
esac

# Get the current workspace
CURRENT_WS=$(hyprctl activeworkspace -j | jq -r '.id')

# Function to check if window exists
window_exists() {
    hyprctl clients -j | jq -e --arg CLASS "$CLASS_NAME" 'any(.[]; .class == $CLASS)' >/dev/null 2>&1
}

# Function to check if window is in special workspace
window_in_special() {
    hyprctl clients -j | jq -e --arg CLASS "$CLASS_NAME" 'any(.[]; .class == $CLASS and .workspace.name == "special:scratchpad")' >/dev/null 2>&1
}

# Function to get window address
get_window_address() {
    hyprctl clients -j | jq -r --arg CLASS "$CLASS_NAME" '.[] | select(.class == $CLASS) | .address'
}

if window_exists; then
    WINDOW_ADDR=$(get_window_address)

    if window_in_special; then
        echo "Bringing $CLASS_NAME to workspace $CURRENT_WS and pinning"
        hyprctl dispatch movetoworkspace "$CURRENT_WS,address:$WINDOW_ADDR"
        hyprctl dispatch pin "address:$WINDOW_ADDR"
        hyprctl dispatch focuswindow "address:$WINDOW_ADDR"
    else
        echo "Unpinning and stashing $CLASS_NAME to special workspace"
        hyprctl dispatch pin "address:$WINDOW_ADDR"  # Unpin (toggle)
        sleep 0.1
        hyprctl dispatch movetoworkspacesilent "$SPECIAL_WS,address:$WINDOW_ADDR"
    fi
else
    echo "Creating new stashed window: $CLASS_NAME"
    echo "Command: $COMMAND"
    echo "Size: ${WIDTH}x${HEIGHT}, Position: $POSITION ($X_POS, $Y_POS)"
    
    hyprctl dispatch exec "[float; move $X_POS $Y_POS; size $WIDTH $HEIGHT] $COMMAND"
    
    sleep 0.5
    if window_exists; then
        WINDOW_ADDR=$(get_window_address)
        hyprctl dispatch pin "address:$WINDOW_ADDR"
        hyprctl dispatch focuswindow "address:$WINDOW_ADDR"
    else
        echo "Warning: Window may not have spawned correctly. Check your command and class name."
    fi
fi
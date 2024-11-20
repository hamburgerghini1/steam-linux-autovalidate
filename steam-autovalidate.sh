#!/bin/bash

# Path to Steam libraryfolders.vdf (with external drive)
LIBRARY_FILE="$HOME/.local/share/Steam/steamapps/libraryfolders.vdf"
EXTERNAL_LIB_PATH="/run/media/games-usb/SteamLibrary/steamapps/"

# Check if libraryfolders.vdf exists
if [[ ! -f "$LIBRARY_FILE" ]]; then
    echo "Error: Steam libraryfolders.vdf not found at $LIBRARY_FILE"
    exit 1
fi

# Function to parse appmanifest files and extract app IDs
get_installed_games() {
    local library_dirs
    mapfile -t library_dirs < <(grep -oP '"path"\s*"\K[^"]+' "$LIBRARY_FILE")

    # Include external Steam library
    library_dirs+=("$EXTERNAL_LIB_PATH")

    local app_ids=()
    for dir in "${library_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            for manifest in "$dir"/appmanifest_*.acf; do
                if [[ -f "$manifest" ]]; then
                    app_ids+=($(basename "$manifest" | grep -oP '\d+'))
                fi
            done
        fi
    done

    echo "${app_ids[@]}"
}

# Main script
installed_games=$(get_installed_games)

if [[ -z "$installed_games" ]]; then
    echo "No installed Steam games found."
    exit 0
fi

echo "Found installed games: ${installed_games[*]}"
echo "Starting validation process..."

for app_id in $installed_games; do
    echo "Validating game with App ID: $app_id"
    steam steam://validate/$app_id
    sleep 5 # Prevent overwhelming Steam with requests
done

echo "Validation process completed for all installed games."

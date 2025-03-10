#!/bin/bash

# Directory to search for .rar files (default: current directory)
SEARCH_DIR="."

# Check if unrar is installed
if ! command -v unrar &> /dev/null; then
    echo "Error: 'unrar' is not installed. Please install it with 'sudo apt install unrar'."
    exit 1
fi

# Find all .rar files in the search directory
rar_files=$(find "$SEARCH_DIR" -type f -name "*.rar")

# Check if any .rar files were found
if [ -z "$rar_files" ]; then
    echo "No .rar files found in $SEARCH_DIR."
    exit 0
fi

# Loop through each .rar file and extract it
for rar_file in $rar_files; do
    # Get the base name of the file (without extension) for the output directory
    base_name=$(basename "$rar_file" .rar)
    output_dir="./$base_name"

    # Create the output directory if it doesn't exist
    mkdir -p "$output_dir"

    echo "Extracting '$rar_file' to '$output_dir'..."
    
    # Attempt to extract the .rar file
    unrar x -y "$rar_file" "$output_dir" 2>/dev/null
    
    # Check the exit status of unrar
    if [ $? -eq 0 ]; then
        echo "Successfully extracted '$rar_file'."
    else
        echo "Failed to extract '$rar_file'. It may be corrupted or password-protected."
        # Optionally, try to repair (if it has a recovery record)
        echo "Attempting to repair '$rar_file'..."
        unrar r "$rar_file" "$output_dir" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "Repair successful. Extracting repaired archive..."
            unrar x -y "$rar_file" "$output_dir" 2>/dev/null
        else
            echo "Repair failed or no recovery record available."
        fi
    fi
done

echo "Extraction process completed."

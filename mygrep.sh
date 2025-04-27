#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: mygrep.sh [-n] [-v] <search_string> <file>"
    echo "  -n   Show line numbers"
    echo "  -v   Invert the match (show lines that do NOT contain the search string)"
    echo "  --help   Show this help message"
    exit 1
}
# Check if --help flag is passed
if [[ "$1" == "--help" ]]; then
    usage
fi

# Initialize flags
show_line_numbers=false
invert_match=false

# Process command-line options
while getopts "nv" opt; do
    case "$opt" in
        n) show_line_numbers=true ;;
        v) invert_match=true ;;
        *) usage ;;
    esac
done

# Shift to get the positional parameters (search_string and file)
shift $((OPTIND - 1))

# Check if there are at least two arguments (search_string and file)
if [ "$#" -lt 2 ]; then
    echo "Error: Missing search string or file."
    usage
fi

# Ensure search_string and file are correctly assigned
search_string="$1"
file="$2"

# Check if the search string is empty
if [ -z "$search_string" ]; then
    echo "Error: Missing search string."
    usage
fi

# Check if the file exists
if [ ! -f "$file" ]; then
    echo "Error: File '$file' does not exist."
    exit 1
fi

# Check if the file is empty
if [ ! -s "$file" ]; then
    echo "Error: File '$file' is empty."
    exit 1
fi

# Convert the search string to lowercase for case-insensitive comparison
search_string_lower=$(echo "$search_string" | tr '[:upper:]' '[:lower:]')

# Initialize line number counter
line_number=0

# Read the file line by line
while IFS= read -r line || [ -n "$line" ]; do
    ((line_number++))

    # Convert the current line to lowercase for case-insensitive comparison
    line_lower=$(echo "$line" | tr '[:upper:]' '[:lower:]')

    # Check if the line matches the search string or not based on the -v flag
    if [[ "$invert_match" == false && "$line_lower" == *"$search_string_lower"* ]] || \
       [[ "$invert_match" == true && "$line_lower" != *"$search_string_lower"* ]]; then

        # If -n is set, print the line number with the matching line
        if [ "$show_line_numbers" == true ]; then
            echo "$line_number: $line"
        else
            echo "$line"
        fi
    fi
done < "$file"

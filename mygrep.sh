#!/bin/bash
usage() {
  	echo "Usage: $0 [-n] [-v] search_string filename"
    echo "Options:"
    echo "  -n  Show line numbers"
    echo "  -v  Invert match (show non-matching lines)"
    echo "  --help Show this help message"
    exit 1
}


show_line_numbers=false
invert_match=false

# Parse options manually
while [[ "$1" == -* ]]; do
    if [[ "$1" == "--help" ]]; then
        usage
    fi

    # Handle combined options like -vn
    optstring="${1:1}"  # Remove leading '-'
    for (( i=0; i<${#optstring}; i++ )); do
        char="${optstring:$i:1}"
        case "$char" in
            n) show_line_numbers=true ;;
            v) invert_match=true ;;
            *) echo "Unknown option: -$char"; usage ;;
        esac
    done
    shift
done

if [ "$#" -lt 2 ]; then
    echo "Error: Missing search pattern or filename."
    usage
fi

search_pattern="$1"
file="$2"

if [ ! -f "$file" ]; then
    echo "Error: File '$file' not found."
    exit 1
fi

search_pattern_lower=$(echo "$search_pattern" | tr '[:upper:]' '[:lower:]')
line_num=0

while IFS= read -r line; do
    ((line_num++))

    line_lower=$(echo "$line" | tr '[:upper:]' '[:lower:]')

    if [[ "$line_lower" =~ $search_pattern_lower ]]; then
        matched=true
    else
        matched=false
    fi

    if $invert_match; then
        if $matched; then
            matched=false
        else
            matched=true
        fi
    fi

    if $matched; then
        if $show_line_numbers; then
            echo "${line_num}:$line"
        else
            echo "$line"
        fi
    fi

done < "$file"

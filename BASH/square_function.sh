#!/bin/bash
square_positive_numbers() {
    local result=()

    for num in "$@"; do
        if (( num > 0 )); then
            result+=( $((num * num)) )
        fi
    done

    echo "${result[@]}"
}

# Example usage:
output=$(square_positive_numbers 2 -3 4 -1 5)
echo "Squared positives: $output"

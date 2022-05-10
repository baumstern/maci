#!/bin/bash

committed_files=$(git ls-tree --name-only -r HEAD)


    while read -r line; do
        file_path=$(echo "$line" | awk '/input/ {print $1}')
        
        if [ ${#file_path} -ge 1 ]; then
            coordinator_input_file_name=$(echo "$file_path" | cut -d '/' -f 2)
            echo "$coordinator_input_file_name"
        fi
    done <<< "$committed_files"

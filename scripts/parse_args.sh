#!/bin/bash

STORAGE_DIR="./storage_dir"
KEEP_COMPRESSED="FALSE"
n_positional=0

while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -k|--keep-compressed)
            KEEP_COMPRESSED="TRUE"
            shift
            ;;
        *)  # only 1 positional argument expected
            if [[ "$1" == "-"* ]]; then
                echo "Unknown argument: $1"
                exit 1
            fi
            STORAGE_DIR="$1"
            n_positional=$((n_positional+1))
            shift # past argument
            ;;
    esac
done

if [[ $n_positional -eq 0 ]]; then
    echo "WARNING: storage dir not defined, using: $STORAGE_DIR"
elif [[ $n_positional -ge 2 ]]; then
    echo "Only one positional argument (storage dir) expected. $n_positional given."
    exit 1
fi

echo "=================================================================="
echo "Arguments:"
echo "------------------------------------------------------------------"
echo "STORAGE DIRECTORY:           $STORAGE_DIR"
echo "KEEP COMPRESSED FILES SAVED: $KEEP_COMPRESSED"
echo "=================================================================="

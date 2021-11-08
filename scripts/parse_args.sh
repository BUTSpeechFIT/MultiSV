#!/bin/bash

STORAGE_DIR="./storage_dir"
KEEP_COMPRESSED="FALSE"
SIMULATE_CV="TRUE"
n_positional=0

while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -k|--keep-compressed)
            KEEP_COMPRESSED="TRUE"
            shift
            ;;
        -c|--no-cross-valid)
            SIMULATE_CV="FALSE"
            shift
            ;;
        -v|--vox2-dir)
            VOX2_DIR="$2"
            shift; shift
            ;;
        -f|--fma-dir)
            FMA_DIR="$2"
            shift; shift
            ;;
        -m|--musan-dir)
            MUSAN_DIR="$2"
            shift; shift
            ;;
        -s|--freesound-but-dir)
            FREESOUND_BUT_DIR="$2"
            shift; shift
            ;;
        -r|--rir-dir)
            RIR_DIR="$2"
            shift; shift
            ;;
        -e|--voices-dir)
            VOICES_DIR="$2"
            shift; shift
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
test -z $VOX2_DIR || \
echo "VOXCELEB 2 DIRECTORY:        $VOX2_DIR"
test -z $FMA_DIR || \
echo "FMA DIRECTORY:               $FMA_DIR"
test -z $MUSAN_DIR || \
echo "MUSAN DIRECTORY:             $MUSAN_DIR"
test -z $FREESOUND_BUT_DIR || \
echo "FREESOUND AND BUT DIRECTORY: $FREESOUND_BUT_DIR"
test -z $RIR_DIR || \
echo "RIR DIRECTORY:               $RIR_DIR"
test -z $VOICES_DIR || \
echo "VOICES DIRECTORY:            $VOICES_DIR"
echo "=================================================================="

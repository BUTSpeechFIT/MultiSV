#!/bin/bash

audio_dir=$1
out_dir=$2

test -z $audio_dir && { echo "No audio directory provided. Stopping."; exit 1; }

if [[ -z $out_dir ]]; then
    echo "No output directory provided. Changes will be done in place."
    out_dir=$audio_dir
else
    mkdir -p $out_dir
fi

echo "INPUT  DIRECTORY: $audio_dir"
echo "OUTPUT DIRECTORY: $out_dir"


for fl in `find $audio_dir -type f \( -iname '*.mp3' \)`; do
    out_file=`echo $fl | sed "s%$audio_dir%$out_dir%"`
    out_file="${out_file%.*}.wav"
    #echo "IN:  $fl"
    #echo "OUT: $out_file"

    mkdir -p `dirname $out_file`
    ffmpeg -loglevel warning -i $fl -acodec pcm_s16le -ac 1 -ar 16000 $out_file
    ret_val=$?
    if [[ $ret_val != 0 ]]; then
        echo "WARNING: conversion failed for: $fl"
    else
        # conversion success
        if [[ $audio_dir == $out_dir ]]; then
            rm -f $fl
        fi
    fi
done

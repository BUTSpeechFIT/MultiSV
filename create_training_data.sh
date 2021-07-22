#!/bin/bash

. scripts/parse_args.sh

storage_dir=$STORAGE_DIR
mkdir -p $storage_dir

function download_and_extract {
    # params: urls, checksum_file, out_dir, extraction method, compressed file name, post-download proc.
    local urls=$1
    local control_md5=$2
    local out_dir=$3
    local extract_method=$4
    local file_name=$5
    local post_download_proc=$6
    echo "urls:               $urls"
    echo "control_md5:        $control_md5"
    echo "out_dir:            $out_dir"
    echo "extract_method:     $extract_method"
    echo "file_name:          $file_name"
    echo "post_download_proc: $post_download_proc"

    # DOWNLOAD
    echo "Downloading: $urls"
    for url in $urls; do
        wget -c -P $storage_dir $url
    done

    # CHECK DOWNLOADED FILES
    echo "Checking downloaded files"
    cd $storage_dir
    md5sum -c $control_md5
    local ret_val=$?
    cd -
    if [[ $ret_val -ne 0 ]]; then
        echo "ERROR: Download failed as checksum of some parts is not correct."
        echo "Return value of md5sum: $ret_val"
        return $ret_val
    fi
    
    # OPTIONAL PROCESSING
    if [[ ! -z $post_download_proc ]]; then
        echo "Post-download processing: $post_download_proc"
        eval $post_download_proc
    fi

    # EXTRACT FILES
    echo "Extracting files"
    mkdir -p $out_dir

    if [[ $extract_method == "zip" ]]; then
        unzip -qn $storage_dir/$file_name -d $out_dir
        ret_val=$?
    elif [[ $extract_method == "tar" ]]; then
        tar --skip-old-files -zxf $storage_dir/$file_name -C $out_dir
        ret_val=$?
    elif [[ $extract_method == "7za" ]]; then
        if command -v 7za &> /dev/null; then
            7za x -o$out_dir $storage_dir/$file_name -aos
            ret_val=$?
        else
            # fall back to simple python decompression (only for zip files)
            ./scripts/simple_unzip.py $storage_dir/$file_name -d $out_dir # standard zip sometimes fails to extract FMA
            ret_val=$?
        fi
    else
        echo "WARNING: Unknown type of an extraction method. Skipping extraction."
        return
    fi

    if [[ $ret_val -ne 0 ]]; then
        echo "ERROR: Extraction of \"${storage_dir}/${file_name}\"" failed.
        return $ret_val
    elif [[ $KEEP_COMPRESSED == "FALSE" ]]; then
        rm $storage_dir/$file_name
    fi
}

# Voxceleb 2 dev
printf "\nACQUIRING VOXCELEB 2 DEV\n"
printf   "========================\n"
download_and_extract "https://thor.robots.ox.ac.uk/~vgg/data/voxceleb/vox1a/vox2_dev_aac_partaa
https://thor.robots.ox.ac.uk/~vgg/data/voxceleb/vox1a/vox2_dev_aac_partab
https://thor.robots.ox.ac.uk/~vgg/data/voxceleb/vox1a/vox2_dev_aac_partac
https://thor.robots.ox.ac.uk/~vgg/data/voxceleb/vox1a/vox2_dev_aac_partad
https://thor.robots.ox.ac.uk/~vgg/data/voxceleb/vox1a/vox2_dev_aac_partae
https://thor.robots.ox.ac.uk/~vgg/data/voxceleb/vox1a/vox2_dev_aac_partaf
https://thor.robots.ox.ac.uk/~vgg/data/voxceleb/vox1a/vox2_dev_aac_partag
https://thor.robots.ox.ac.uk/~vgg/data/voxceleb/vox1a/vox2_dev_aac_partah" \
`pwd`/checksums/vox_md5.txt $storage_dir/voxceleb2 "zip" vox2_dev_aac.zip "test -f $storage_dir/vox2_dev_aac.zip || cat $storage_dir/vox2_dev_aac* > $storage_dir/vox2_dev_aac.zip"

# FMA small
printf "\nACQUIRING FMA SMALL\n"
printf   "===================\n"
download_and_extract "https://os.unil.cloud.switch.ch/fma/fma_small.zip" \
`pwd`/checksums/fma_small_md5.txt $storage_dir/noises_training "7za" fma_small.zip

# MUSAN
printf "\nACQUIRING MUSAN\n"
printf   "===============\n"
download_and_extract "https://www.openslr.org/resources/17/musan.tar.gz" \
`pwd`/checksums/musan_md5.txt $storage_dir/noises_training "tar" musan.tar.gz

# freesound and BUT noises
printf "\nACQUIRING FREESOUND AND BUT NOISES\n"
printf   "==================================\n"
download_and_extract "https://www.fit.vutbr.cz/~imosner/MultiSV/noises_freesound_BUT_training.zip" \
`pwd`/checksums/multisv_noises_freesound_BUT_training_md5.txt $storage_dir/noises_training "zip" noises_freesound_BUT_training.zip

# RIRs
printf "\nACQUIRING RIRs\n"
printf   "==============\n"
download_and_extract "https://www.fit.vutbr.cz/~imosner/MultiSV/rirs_training.zip" \
`pwd`/checksums/multisv_rirs_training_md5.txt $storage_dir/rirs_training "zip" rirs_training.zip

#------------------------------------------------------------------------------#

./scripts/make_wav.sh $storage_dir/noises_training/fma_small

# PERFORM SIMULATION
printf "\nPERFORMING SIMULATION\n"
printf   "=====================\n"

. scripts/select_python.sh
$py_interpreter scripts/simulate_training_data.py \
    --speech_dir="$storage_dir/voxceleb2" \
    --noise_dir="$storage_dir/noises_training" \
    --rir_dir="$storage_dir/rirs_training" \
    --csv="training/metadata/MultiSV_train.csv" \
    --out_dir="$storage_dir/MultiSV"

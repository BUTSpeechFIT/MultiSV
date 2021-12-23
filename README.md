# MultiSV: dataset for far-field multi-channel speaker verification
MultiSV is a corpus designed for training and evaluating text-independent multi-channel speaker verification systems. The training multi-channel data is prepared by simulation on top of clean parts of the Voxceleb dataset. The development and evaluation trials are based on either retransmitted or simulated VOiCES dataset, which we modified to provide multi-channel trials. MultiSV can be used also for experiments with dereverberation, denoising, and speech enhancement.

## Quick start
```bash
conda create -n py39_MultiSV python=3.9
conda activate py39_MultiSV
pip install -r requirements.txt
# TRAINING DATA:
./create_training_data.sh $STORAGE_DIR
# SIMULATED DEVELOPMENT AND EVALUATION DATA:
./create_dev_eval_data.sh --musan-dir $STORAGE_DIR/noises_training --voices-dir $VOICES_DIR $STORAGE_DIR
```
Detailed information about simulation scripts is provided later.
> **Note:** Please note that recordings are processed sequentially during simulation. Parallelization (and hence speedup) can be achieved by splitting CSV files (such as `training/metadata/MultiSV_train.csv`) defining simulation parameters. We will consider native parallelization in the future.

## Usage
### Retransmitted development and evaluation data download
Single and/or multi-channel segments of verification trial pairs are based on the VOiCES dataset. In order to perform an evaluation based on prepared trial lists, it is required to download the VOiCES data first. Please follow instructions at the official [webpage](https://iqtlabs.github.io/voices/downloads/) and download `VOiCES_release.tar.gz`.

Note: we did not automate the download as the corpus is available on AWS which requires AWS Command Line Interface (CLI).

### Training data simulation
If your python installation satisfies the requirements defined in `requirements.txt`, the easiest way to generate simulated training data completely from scratch is by running:
```
./create_training_data.sh STORAGE_DIR
```

We recommend creating a new python environment with the following commands:
```
$ conda create -n py39_MultiSV python=3.9
$ conda activate py39_MultiSV
$ pip install -r requirements.txt
```
Having the environment created, one can follow any of the following alternatives prior to running the `create_training_data.sh` script to correctly utilize it during simulation.
* activate the environment using `conda activate` or `source activate`,
* or add the activation command to `scripts/select_python.sh` (follow the instructions therein),
* or simply add the path of the installed python interpreter to `scripts/select_python.sh` (follow the instructions therein).

The `create_training_data.sh` may be run with various options making use of already downloaded data:
```
./create_training_data.sh [-v VOX2_DIR] [-f FMA_DIR] [-m MUSAN_DIR] [-s FREESOUND_BUT_DIR] [-r RIR_DIR] [-k] [-c] STORAGE_DIR
The following options are allowed. The arguments requiring value must be separated from the value by white space (= sign is not supported).
STORAGE_DIR
	Target directory which will contain downloaded datasets as well as the MultiSV training data upon a successful run of the script.
-v, --vox2-dir
	Path to the directory with Voxceleb 2 audio files (a directory containing dev, test subdirectories, and other content).
-f, --fma-dir
	Path to the directory with FMA small audio files.
-m, --musan-dir
	Path to the directory with MUSAN audio files.
-s, --freesound-but-dir
	Path to the directory with a selection of Freesound.org and BUT-recorded noises.
-r, --rir-dir
	Path to the directory with simulated room impulse responses.
-k, --keep-compressed
	If specified, downloaded compressed files will not be removed from the storage directory after extraction.
-c, --no-cross-valid
	If specified, it prevents the script from creating a cross-validation set.
```

### Development and evaluation data simulation
Preparation of simulated development and evaluation data is similar to the training data simulation procedure (including python environment creation). It is, however, required that the VOiCES corpus is downloaded beforehand. To start the simulation, run the following script:
```
./create_dev_eval_data.sh -e VOICES_DIR [-m MUSAN_DIR] [-s FREESOUND_BUT_DIR] [-r RIR_DIR] [-k] STORAGE_DIR
STORAGE_DIR
	Target directory which will contain downloaded datasets as well as the MultiSV development and evaluation data upon a successful run of the script.
-e, --voices-dir
	Path to the directory with the VOiCES dataset (required).
-m, --musan-dir
	Path to the directory with MUSAN audio files.
-s, --freesound-but-dir
	Path to the directory with a selection of Freesound.org and BUT-recorded noises.
-r, --rir-dir
	Path to the directory with simulated room impulse responses.
-k, --keep-compressed
	If specified, downloaded compressed files will not be removed from the storage directory after extraction.
```

It is recommended to reuse the MUSAN dataset from the training data simulation phase to save space. We also note that Freesound.org and BUT noises (argument `-s`) and room impulse responses (argument `-r`) are different from those used in training data. Therefore, it is not possible to reuse files downloaded by the `create_training_data.sh` script.

## Citation
```
@misc{multisv2021,
      title={MultiSV: Dataset for Far-Field Multi-Channel Speaker Verification}, 
      author={Ladislav Mošner and Oldřich Plchot and Lukáš Burget and Jan Černocký},
      year={2021},
      eprint={2111.06458},
      archivePrefix={arXiv},
      primaryClass={eess.AS}
}
```

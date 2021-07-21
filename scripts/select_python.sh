#!/bin/bash

# This script is supposed to set the variable "py_interpreter" to a correct
# python interpreter. For instance:
# py_interpreter=/path/to/my/python
#
# The interpreter should satisfy the requirements defined in "requirements.txt".
# We recommend using a conda environment. To create the environment, run
# the following commands:
# $ conda create -n py39_MultiSV python=3.9
# $ conda activate py39_MultiSV
# $ pip install -r requirements.txt
#
# Having this environment, this script may, for instance, include the following code:
# conda activate py39_MultiSV
# py_interpreter=python

py_interpreter=python

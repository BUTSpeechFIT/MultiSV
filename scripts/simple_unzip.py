#!/usr/bin/env python3

import os
import argparse
from zipfile import PyZipFile

parser = argparse.ArgumentParser()
parser.add_argument('zip_file', help='File to unzip')
parser.add_argument('-d', '--out_dir', required=False, default='', help='Output directory')
args = parser.parse_args()

if not os.path.exists(args.zip_file):
    print('ERROR in {}: Zipped file does not exist: {}'.format(__file__, args.zip_file))
    exit(1)

if args.out_dir:
    os.makedirs(args.out_dir, exist_ok=True)

try:
    pzf = PyZipFile(args.zip_file)
    print('simple_unzip: extracting {}'.format(args.zip_file))
    pzf.extractall(path=(None if not args.out_dir else args.out_dir))
    pzf.close()
except Exception as e:
    print(e)
    exit(1)

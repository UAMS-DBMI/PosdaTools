#!/usr/bin/env python3
# coding: utf-8

import numpy as np
import pandas as pd
import re
import argparse
import sys

data = None

def parse_args():
    parser = argparse.ArgumentParser(description='some program')
    parser.add_argument('input', help='input file to process')
    parser.add_argument('--out','-o', default="out.csv", help='output file to write to')

    return parser.parse_args()

def apply_dciodvfy_macro(data):
    return None

def main(args):
    data_df = pd.read_csv(args.input)
    data_df['fix'] = pd.NA
    apply_dciodvfy_macro(data_df)
    data_df.to_csv(sys.stdout)

if __name__ == '__main__':
    args = parse_args()
    main(args)

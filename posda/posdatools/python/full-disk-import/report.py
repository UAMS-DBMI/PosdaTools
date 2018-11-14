#!/usr/bin/env python3

import numpy
import json
import os
from collections import defaultdict
from pprint import pprint

import fire

def get_human_readable_size(size, precision=2):
    suffixes=['B','KB','MB','GB','TB']
    suffixIndex = 0
    while size > 1024 and suffixIndex < 4:
        suffixIndex += 1 #increment the index of the suffix
        size = size/1024.0 #apply the division
    return "%.*f%s"%(precision,size,suffixes[suffixIndex])

h = get_human_readable_size

def calc_size(details):
    size = 0
    for i, v in details.items():
        size += v['size']

    return size

def ascii_hist(hist, total):
        values, bins = hist
        total = 1.0 * total
        width = 50
        nmax = values.max()

        for (xi, n) in zip(bins, values):
            bar = '*' * int(n * 1.0 * width / nmax)
            xi = '{0}'.format(get_human_readable_size(xi)).ljust(10)
            print('{0}| {1}'.format(xi, bar))

def generate_report(filename):
    with open(filename) as infile:
        details = json.load(infile)

    size = calc_size(details)
    # generate a numpy array from the sizes
    np = numpy.array([v['size'] for i, v in details.items()])

    print(f"""\
Report:
    Length: {len(np)}
    Total:  {h(size)}
    Min:    {h(np.min())}
    Max:    {h(np.max())}
    Mean:   {h(np.mean())}
    Std:    {h(np.std())}
""")





if __name__ == '__main__':
    fire.Fire(generate_report)

#!/usr/bin/env python3

from subprocess import check_output
import codecs
import struct
import sys


filename = sys.argv[1]

out = check_output(['convert', filename, '-define', 'histogram:unique-colors=true', '-format', '%c', 'histogram:info:-'])

colormap = {}
for line in out.decode('utf8').split('\n'):
    try:
        count, long_color = line.split(':')
        count = count.strip()

        _, color_part = long_color.split('#')
        color, _ = color_part.split(' ')

        colormap[color] = int(count)

    except:
        pass

def hex2rgba(color):
    if len(color) == 6:
        b = codecs.decode(color, "hex")
        r, g, b = struct.unpack("BBB", b)
        return (r, g, b, 255)
    else:
        b = codecs.decode(color, "hex")
        return struct.unpack("BBBB", b)



def compare_colors(color1, color2):
	c1 = hex2rgba(color1)
	c2 = hex2rgba(color2)

	return (c1[0] - c2[0]) + (c1[1] - c2[1]) + (c1[2] - c2[2])	

# distance_map = {}

# for c in sorted(colormap, key=colormap.get, reverse=True)[:10]:
# 	distance_map[c] = compare_colors(c, "000000FF")

# for c in sorted(distance_map, key=distance_map.get, reverse=True):
#     match = c
#     break

# print(match)

import math
max_count = math.log10(max(colormap.values()))

for c in colormap:
  r, g, b, _ = hex2rgba(c)
  # normalized_size = math.log10(colormap[c])/max_count
  normalized_size = math.log10(colormap[c]) + 0.25
  print("{} {} {} {}".format(r, g, b, normalized_size))

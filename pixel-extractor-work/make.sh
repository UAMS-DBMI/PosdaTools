#!/usr/bin/env bash

SERIES=$1
OPS="max min mean or"
TMP=/tmp/pixel_make/$SERIES
INPUT=/tmp/pixel_make/drive/$SERIES

mkdir -p $TMP

for i in $OPS; do
  echo $i
  convert $INPUT/* -evaluate-sequence $i $TMP/$i.png
done

convert $TMP/*.png +append $1.png
#rm -rf $TMP/

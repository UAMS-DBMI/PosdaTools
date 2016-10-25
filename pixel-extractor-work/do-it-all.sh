#!/usr/bin/env bash

SERIES=$1
TMP=/tmp/pixel_make/drive/$SERIES

mkdir -p $TMP

DrivePixelExtractor.pl $SERIES $TMP
./make.sh $SERIES

rm -rf $TMP

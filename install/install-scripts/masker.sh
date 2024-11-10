#!/bin/bash

TEMP_DIR=/tmp/masker

rm -rf $TEMP_DIR
mkdir $TEMP_DIR

curl -k -o $TEMP_DIR/masker.zip https://posda.tools/downloads/masker.zip
cd $TEMP_DIR
unzip ./masker.zip
cd masker-main
pip3.9 install .

# probably should pin to a good version
pip3.9 install --upgrade numpy

rm -rf $TEMP_DIR

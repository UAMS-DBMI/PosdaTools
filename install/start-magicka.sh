#!/bin/bash

POSDA_DIR=/oneposda/posda/posdatools
CONFIG_DIR=/oneposda/install/temp-config

# load the env files that Docker would normally load
for f in $CONFIG_DIR/*.env; do
	export $(grep -v ^# $f)
done

# ensure we can reach the python posda module
export PYTHONPATH=$POSDA_DIR/python
cd $POSDA_DIR
python3 -u $POSDA_DIR/../../lanterna/magicka.py

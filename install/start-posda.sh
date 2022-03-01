#!/bin/bash

POSDA_DIR=/oneposda/posda/posdatools
CONFIG_DIR=/oneposda/install/temp-config

# load the env files that Docker would normally load
for f in $CONFIG_DIR/*.env; do
	export $(grep -v ^# $f)
done

cd $POSDA_DIR

./posda_start.sh

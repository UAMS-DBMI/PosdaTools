#!/bin/bash
#
# Start script for NopperaBo, the daemon that runs Masker.
#

POSDA_DIR=/oneposda/posda/posdatools
CONFIG_DIR=/oneposda/install/configs

# load the env files that Docker would normally load
for f in $CONFIG_DIR/*.env; do
	export $(grep -v ^# $f)
done

# ensure we can reach the python posda module
export PYTHONPATH=$POSDA_DIR/python

SCRIPT=$POSDA_DIR/../../nopperabo/src/nopperabo/nopperabo.py


cd $POSDA_DIR

exec python3.9 -u $SCRIPT \
	--hostname $POSDA_EXTERNAL_HOSTNAME \
	--token $POSDA_API_SYSTEM_TOKEN

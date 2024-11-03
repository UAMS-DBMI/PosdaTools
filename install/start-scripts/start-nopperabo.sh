#!/bin/bash
#
# Start script for NopperaBo, the daemon that runs Masker.
#

cd $(dirname "$0"); # cd to script dir
. load-env.sh

SCRIPT=$ONEPOSDA_LOCATION/nopperabo/src/nopperabo/nopperabo.py

cd $POSDA_DIR

exec $PYTHONBIN -u \
	$SCRIPT \
	--hostname $POSDA_EXTERNAL_HOSTNAME \
	--token $POSDA_API_SYSTEM_TOKEN

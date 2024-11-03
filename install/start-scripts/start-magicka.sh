#!/bin/bash
#
# Start Lanterna Magicka
#

cd $(dirname "$0"); # cd to script dir
. load-env.sh

cd $POSDA_DIR
exec $PYTHONBIN -u $ONEPOSDA_LOCATION/lanterna/magicka.py

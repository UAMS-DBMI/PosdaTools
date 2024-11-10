#!/bin/bash
#
# Start Lanterna Magicka
#

cd $(dirname "$0"); # cd to script dir
. load-env.sh

export PATH=/opt/im/bin:/opt/dcm4che-5.22.1/bin:$PATH

cd $POSDA_DIR
exec $PYTHONBIN -u $ONEPOSDA_LOCATION/lanterna/magicka.py

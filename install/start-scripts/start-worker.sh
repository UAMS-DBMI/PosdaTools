#!/bin/bash
#
# Start Worker Node
#

cd $(dirname "$0"); # cd to script dir
. load-env.sh

export POSDA_WORKER_PRIORITY=$1
#export POSDA_WORKER_NAME=??

cd $POSDA_DIR
exec ./worker_start.sh

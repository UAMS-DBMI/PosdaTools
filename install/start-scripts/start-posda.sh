#!/bin/bash
#
# Start main Posda system
#

cd $(dirname "$0"); # cd to script dir
. load-env.sh

cd $POSDA_DIR
exec ./posda_start.sh

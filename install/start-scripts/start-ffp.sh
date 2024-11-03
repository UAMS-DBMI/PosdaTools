#!/bin/bash
#
# Start FFP
#

cd $(dirname "$0"); # cd to script dir
. load-env.sh

#WorkingDirectory=/home/posda/posdatools/systemd
#ExecStart=/home/posda/posdatools/systemd/run_in_posda_env.sh systemd/start_PosdaFileProcessDaemon.pl
#ExecStop=/home/posda/posdatools/systemd/run_in_posda_env.sh systemd/stop_PosdaFileProcessDaemon.pl

cd $POSDA_ROOT/systemd
#./Posda/bin/FastFileProcessDaemon.pl
#$POSDA_ROOT/systemd/run_in_posda_env.sh systemd/start_PosdaFileProcessDaemon.pl
exec ./run_in_posda_env.sh Posda/bin/FastFileProcessDaemon.pl

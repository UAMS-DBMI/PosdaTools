#!/usr/bin/env bash
#
# This file should be loaded as a bash rc file. Executing it directly
# will not be very useful.
#

function help {
  cat <<EOF
Available commands:

  help      This help.

  start     Start the server, on port $POSDA_PORT (\$POSDA_PORT).
  stop      Stop the server, if running.
  restart   Restart the server.
  log       Display and follow the nohup log.

  stopmine  Stop all servers running under this user.
            Useful if you reloaded the environment and it no longer
            knows the PID of the running server.
  stopall   Stop ALL servers running on this machine. USE WITH CAUTION!

  reconfig  Reload the config file.
  penv      Print a report of the current environment.

  exit      Clear the Posda environment and return to your shell.
            NOTE: This will NOT stop any running servers!

EOF
}

function log {
  echo Tailing the log, Control+C to quit...
  echo
  tail -f $APP_CONTROLLER_ROOT/nohup.out
}

function abort {
  # Abort sourcing of this file, without exiting the user's shell
  kill -INT $$
}

function penv {
  env | grep POSDA_
  echo
}

function reconfig {
  echo "Reconfiguring Posda environment..."
  set -a
  source $APP_CONTROLLER_ROOT/Config/SetEnv $APP_CONTROLLER_STAGE
  set +a
}

function start {
  echo "Starting Posda in the background..."

  rm -f nohup.out
  nohup AppController.pl localhost $POSDA_PORT $APP_CONTROLLER_ROOT/Config/AppConfig &
  # StartServer.sh &
  export POSDA_PID=$!
}

function start_foreground {
  echo "Starting Posda in the foreground..."

  AppController.pl localhost $POSDA_PORT $APP_CONTROLLER_ROOT/Config/AppConfig
}

function stop {
  if [ -z "$POSDA_PID" ]; then
    echo \$POSDA_PID is not set. Are you sure the server is running?
    echo You could try stopmine to kill all servers running as you.
  else
    # the - before the pid indicates the whole process tree should be killed
    kill -9 -$POSDA_PID

    echo Killed server, PID $POSDA_PID
    unset POSDA_PID

  fi
}

function stopmine {
  echo Attempting to kill all running AppControllers owned by you...
  pgrep -f -u $UID -a AppController
  pkill -f -u $UID AppController
}

function stopall {
  echo "Attempting to kill ALL running AppControllers!!!"
  pgrep -f -a AppController
  pkill -f AppController

}

function restart {
  stop
  sleep .1
  start
}

function posda_setup {
  source Config/SetEnv
}

function print_report {
  # print status
  echo "Posda environment configured!"
  echo
  echo
}

function edit {
  vim Config/SetEnv

}

posda_setup
if [ "$1" != "script" ]; then
    clear
    print_report
    penv
    help
fi

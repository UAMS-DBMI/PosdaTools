#{!/usr/bin/env bash

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
  sudo systemctl start posda
}

function start_foreground {
  echo "Starting Posda in the foreground..."

  exec AppController.pl $POSDA_EXTERNAL_HOSTNAME $POSDA_PORT $APP_CONTROLLER_ROOT/Config/AppConfig
}

function stop {
  sudo systemctl stop posda
}

# deprecated
function stopmine {
  echo "This function no longer works. Posda is now controlled via systemd"
}

# deprecated
function stopall {
  echo "This function no longer works. Posda is now controlled via systemd"
}

function restart {
  sudo systemctl restart posda
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

set -o vi

alias vi=vim
alias ls='ls --color'
alias gst="git status"
alias gc="git commit -v"
alias gd="git diff"
alias gdca="git diff --cached"
alias log="sudo journalctl -u posda -f"

export EDITOR=vim
export PS1='\[\033[01m\]POSDA [ \[\033[01;34m\]\u@\h \[\033[00m\]\[\033[01m\]] \[\033[01;32m\]$PWD\[\033[00m\]\n\[\033[01;34m\]$\[\033[00m\] '

posda_setup

export HOME=$POSDA_ROOT

if [ "$1" != "script" ]; then
    clear
    print_report
    penv
    help
fi

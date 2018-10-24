#!/usr/bin/env bash

DB=$(Config.pl database posda_backlog)
PORT=$POSDA_RECEIVE_DAEMON_PORT
SOURCE_ROOT=$POSDA_SUBMISSION_ROOT

echo "Launching Posda Receive Daemon with configuration:"
echo "DB: $DB"
echo "PORT: $PORT"
echo "SOURCE_ROOT: $SOURCE_ROOT"

PosdaReceiveDaemon.pl $DB $PORT $SOURCE_ROOT

#!/usr/bin/env bash
echo "Executing local psql command, connecting to docker db"

export PGHOST=localhost
export PGPORT=5433
export PGUSER=postgres
export PGPASSWORD=example

psql $@

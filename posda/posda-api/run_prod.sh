#!/usr/bin/env bash

export PGUSER=posda
export PGPASSWORD=posda
export PGHOST=tcia-posdadb-rh.ad.uams.edu
unset PGPORT
export WORKERS=1
export TEMP_STORAGE_PATH=temp/
export FILE_STORAGE_PATH=f_storage/

mkdir -p temp/
mkdir -p f_storage/

./main.py

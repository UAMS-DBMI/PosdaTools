#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd $SCRIPT_DIR

TEMP_FILE=$(mktemp)
./dciodvfy_macro.py $@ --out $TEMP_FILE

cat $TEMP_FILE
rm -f $TEMP_FILE

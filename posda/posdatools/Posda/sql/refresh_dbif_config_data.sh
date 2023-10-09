#!/usr/bin/env bash

FILE=posda_dbif_config_data.sql

echo "Prior to refresh:"
wc -l $FILE

echo "\\connect posda_files" > $FILE
pg_dump -x -a -O \
	-n dbif_config \
	-n auth \
	-T queries \
	posda_files >> $FILE

echo "After refresh:"
wc -l $FILE

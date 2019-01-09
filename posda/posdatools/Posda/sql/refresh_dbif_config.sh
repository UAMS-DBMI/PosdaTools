#!/usr/bin/env bash

FILE=posda_dbif_config.sql

echo "Prior to refresh:"
wc -l $FILE

pg_dump -x -a -O \
	-n dbif_config \
	posda_files > $FILE

echo "After refresh:"
wc -l $FILE

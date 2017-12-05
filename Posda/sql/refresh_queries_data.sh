#!/usr/bin/env bash

echo "Prior to refresh:"
wc -l posda_queries_data.sql

pg_dump -x -a -O posda_queries > posda_queries_data.sql

echo "After refresh:"
wc -l posda_queries_data.sql

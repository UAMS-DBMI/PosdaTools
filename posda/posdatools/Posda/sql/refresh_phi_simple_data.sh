#!/usr/bin/env bash

echo "Prior to refresh:"
wc -l posda_phi_simple_data.sql

echo "\\connect posda_phi_simple" > posda_phi_simple_data.sql
pg_dump -x -a -O \
	-t element_seen \
	posda_phi_simple >> posda_phi_simple_data.sql

echo "After refresh:"
wc -l posda_phi_simple_data.sql

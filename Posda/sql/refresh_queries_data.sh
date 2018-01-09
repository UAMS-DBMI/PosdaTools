#!/usr/bin/env bash

echo "Prior to refresh:"
wc -l posda_queries_data.sql

pg_dump -x -a -O \
	-t background_buttons \
	-t chained_query \
	-t chained_query_cols_to_params \
	-t dicom_module_to_posda_table \
	-t dicom_tag_parm_column_table \
	-t popup_buttons \
	-t queries \
	-t query_tabs \
	-t query_tabs_query_tag_filter \
	-t query_tag_filter \
	-t spreadsheet_operation \
	-t tag_preparation \
	posda_queries > posda_queries_data.sql

echo "After refresh:"
wc -l posda_queries_data.sql



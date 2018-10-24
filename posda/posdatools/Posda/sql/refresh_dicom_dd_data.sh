#!/usr/bin/env bash

echo "Prior to refresh:"
wc -l dicom_dd_data.sql

pg_dump -x -a dicom_dd > dicom_dd_data.sql

echo "After refresh:"
wc -l dicom_dd_data.sql

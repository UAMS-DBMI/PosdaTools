#!/usr/bin/env bash

dropdb -e dicom_roots
dropdb -e posda_auth
dropdb -e posda_files
dropdb -e posda_nicknames
dropdb -e posda_queries
dropdb -e private_tag_kb

createdb -e dicom_roots
createdb -e posda_auth
createdb -e posda_files
createdb -e posda_nicknames
createdb -e posda_queries
createdb -e private_tag_kb

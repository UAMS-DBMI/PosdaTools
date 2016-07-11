#!/usr/bin/env bash

echo Creating databases.. this will fail if they arleady exist. Do not be alarmed.
createdb $POSDA_FILES_DB_NAME
if [ $? -eq 0 ]; then
	psql $POSDA_FILES_DB_NAME < $POSDA_ROOT/Posda/sql/dicom_images.sql 
	echo "insert into file_storage_root values (0, '$POSDA_CACHE_ROOT', True)" | psql posda_files
fi	

createdb $POSDA_NICKNAMES_DB_NAME
if [ $? -eq 0 ]; then
	psql $POSDA_NICKNAMES_DB_NAME < $POSDA_ROOT/Posda/sql/Nickname.sql
	psql $POSDA_NICKNAMES_DB_NAME < $POSDA_ROOT/Posda/sql/Nickname-AddFor.sql
fi

createdb $POSDA_APPSTATS_DB_NAME
if [ $? -eq 0 ]; then
	psql $POSDA_APPSTATS_DB_NAME < $POSDA_ROOT/Posda/sql/AppUsageTracker.sql
fi

createdb $POSDA_AUTH_DB_NAME
if [ $? -eq 0 ]; then
	psql $POSDA_AUTH_DB_NAME < $POSDA_ROOT/Posda/sql/posda_auth.sql
	psql $POSDA_AUTH_DB_NAME < $POSDA_ROOT/Posda/sql/posda_auth_setup.sql
fi

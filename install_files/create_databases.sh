#!/usr/bin/env bash
. ../Config/main.env

echo Creating databases.. this will fail if they arleady exist. Do not be alarmed.
createdb posda_files 
if [ $? -eq 0 ]; then
	psql posda_files < $POSDA_ROOT/Posda/sql/dicom_images.sql 
	echo "insert into file_storage_root values (0, '$POSDA_CACHE_ROOT', True)" | psql posda_files
fi	

createdb posda_nicknames
if [ $? -eq 0 ]; then
	psql posda_nicknames < $POSDA_ROOT/Posda/sql/Nickname.sql
	psql posda_nicknames < $POSDA_ROOT/Posda/sql/Nickname-AddFor.sql
fi

createdb app_stats
if [ $? -eq 0 ]; then
	psql app_stats < $POSDA_ROOT/Posda/sql/AppUsageTracker.sql
fi

createdb posda_auth
if [ $? -eq 0 ]; then
	psql posda_auth < $POSDA_ROOT/Posda/sql/posda_auth.sql
	psql posda_auth < $POSDA_ROOT/Posda/sql/posda_auth_setup.sql
fi

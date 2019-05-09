#!/usr/bin/env bash

refresh_db() {
	echo "Refreshing SQL file for $1"	
	pg_dump -x -s -C -O $1 > $1.sql
}

echo "This script will update all the initial db creation sql files."
echo "It assumes all databases have their 'default' names, so if you have"
echo "customized anything, it will likely fail. Also, you probably don't"
echo "want to be doing this... "

echo "PGHOST=$PGHOST"
echo "Press enter to continue, or Control+C to cancel..."
read



refresh_db posda_files
refresh_db dicom_roots
refresh_db file_pt_image_table
refresh_db posda_appstats
refresh_db posda_auth
refresh_db posda_backlog
refresh_db posda_counts
refresh_db posda_files
refresh_db posda_nicknames
refresh_db posda_phi
refresh_db posda_queries
refresh_db posda_simple_phi
refresh_db private_tag_kb
refresh_db public_tag_disposition
refresh_db posda_phi_simple

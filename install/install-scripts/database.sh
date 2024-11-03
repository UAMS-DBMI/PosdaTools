#!/bin/bash
#
# Install, init, start and load the database
# 
# This script can be skipped if this has been done by a DBA or someone else.

if [ -z "$CONFIG_DIR" ]; then 
	echo "Missing install configuration, load CONFIG first!"; 
	exit 1;
fi


yum module enable -y postgresql:13

yum install -y postgresql-server

/usr/bin/postgresql-setup --initdb

systemctl enable --now postgresql

sudo -u postgres createuser -s root

psql postgres < $ONEPOSDA_LOCATION/database/all.sql

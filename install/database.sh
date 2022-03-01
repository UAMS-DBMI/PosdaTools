#!/bin/bash
#
# Install, init, start and load the database
# 
# This script can be skipped if this has been done by a DBA or someone else.


yum module enable -y postgresql:13

yum install -y postgresql-server

/usr/bin/postgresql-setup --initdb

systemctl enable --now postgresql

sudo -u postgres createuser -s root

psql postgres < /oneposda/database/all.sql

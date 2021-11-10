#!/bin/bash
#
# Install, init, start and load the database
# 
# This script can be skipped if this has been done by a DBA or someone else.


# TODO: add a switch here so we always do the right one!

# enabled Software Collections - different on RHEL vs CentOS

# CentOS
yum install -y centos-release-scl

# RHEL 7
#yum-config-manager --enable rhel-server-rhscl-7-rpms

# install postgresql13
yum install -y rh-postgresql13 rh-postgresql13-server

# initialize the database
sudo -u postgres scl enable rh-postgresql13 -- postgresql-setup --initdb

# enable and start
systemctl enable --now rh-postgresql13-postgresql

# add root as a user
sudo -u postgres scl enable rh-postgresql13 -- createuser -s root

# enable in local scope - finally, we can interact normally with the database
source scl_source enable rh-postgresql13

psql postgres < /oneposda/database/all.sql

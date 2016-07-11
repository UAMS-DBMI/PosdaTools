#!/usr/bin/env bash

sudo apt-get update
sudo apt-get install -y postgresql-9.5 postgresql-server-dev-9.5 postgresql-client-9.5
sudo apt-get install -y libmodern-perl-perl libmethod-signatures-simple-perl libdbd-pg-perl libjson-perl libswitch-perl libdata-uuid-perl libtext-diff-perl libterm-readkey-perl

echo "=========================================="
echo "=========================================="
echo "=========================================="
echo

echo "Adding the current user as a postgres superuser"
sudo -u postgres createuser -s $(whoami)

./setup.sh

echo "Everything should be ready to go now!"

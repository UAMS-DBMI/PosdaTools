#!/usr/bin/env bash

echo "This script is intended for Ubuntu 16.04 LTS. "
echo "It may work on older versions of Ubuntu but probably won't on anything else."
echo
echo "WARNING: You should run this script as the user you wish to install Posda for,"
echo "and that user MUST be a member of the sudo group. This script will"
echo "REMOVE the user from the sudo group when it finishes."
echo
echo "If you wish to continue, press enter now. If you have a doubt, press Control+c"

read 

APT="sudo apt-get install -y"
CPAN="sudo cpanm --notest"

sudo apt-get update
# need python2 for building k-base later
$APT build-essential zlib1g-dev libssl-dev python libcairo2-dev
$APT postgresql-9.5 postgresql-server-dev-9.5 postgresql-client-9.5 nginx
$APT libmodern-perl-perl libmethod-signatures-simple-perl libdbd-pg-perl libjson-perl libswitch-perl libdata-uuid-perl libtext-diff-perl libterm-readkey-perl cpanminus libdatetime-perl libnet-ldap-perl


$CPAN REST::Client

echo
echo "=========================================="
echo

echo "Adding the current user as a postgres superuser"
sudo -u postgres createuser -s $(whoami)

./python.sh
./nginx.sh
./node.sh
./posda.sh
./service_files.sh

# echo "Removing this user from the sudo group"
# sudo deluser $(whoami) sudo

# echo "Everything should be ready to go now!"

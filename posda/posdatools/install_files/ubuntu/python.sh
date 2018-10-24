#!/usr/bin/env bash
wget https://code.imphub.org/projects/PT/repos/misc/raw/python/python3.6-ubuntu-16.04.tar.xz
sudo tar xf python3.6-ubuntu-16.04.tar.xz -C /

sudo cp python36_profile.sh /etc/profile.d/python36.sh


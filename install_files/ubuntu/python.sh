#!/usr/bin/env bash
wget https://www.python.org/ftp/python/3.6.1/Python-3.6.1.tar.xz
tar xf Python-3.6.1.tar.xz
cd Python-3.6.1
./configure --prefix=/opt/python36
make
sudo make install
cd ..
sudo rm -rf Python-3.6.1
rm Python-3.6.1.tar.xz

sudo cp python36_profile.sh /etc/profile.d/python36.sh


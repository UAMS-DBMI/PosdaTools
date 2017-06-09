#!/usr/bin/env bash

wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash
echo source ~/.bashrc
echo nvm install v8

echo npm install in quince and k
echo "enabling devtoolset-6 now, manually run above commands"
scl enable devtoolset-6 bash

#!/usr/bin/env bash

git clone https://quasarj@code.imphub.org/scm/pt/quince.git
cd quince/server
sudo /opt/python36/bin/pip3 install -r requirements.txt
cd ..
npm install

cd ..

git clone https://quasarj@code.imphub.org/scm/pt/kaleidoscope.git
cd kaleidoscope/server
sudo /opt/python36/bin/pip3 install -r requirements.txt
cd ..
npm install

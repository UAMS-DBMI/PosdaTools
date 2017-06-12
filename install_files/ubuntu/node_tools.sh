#!/usr/bin/env bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

cd ~/
git clone https://quasarj@code.imphub.org/scm/pt/quince.git
cd quince/server
sudo /opt/python36/bin/pip3 install -r requirements.txt
cd ..
npm install

cd ~/
git clone https://quasarj@code.imphub.org/scm/pt/kaleidoscope.git
cd kaleidoscope/server
sudo /opt/python36/bin/pip3 install -r requirements.txt
cd ..
npm install

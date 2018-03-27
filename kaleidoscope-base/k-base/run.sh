#!/usr/bin/env bash

. /root/.nvm/nvm.sh
cd /k-base

while true; do
	node index.js
	rm -f *.png
done

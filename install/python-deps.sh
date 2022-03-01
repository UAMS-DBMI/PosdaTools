#!/bin/bash

DEPS="
xlsx2csv
mysql-connector
python-box
pydicom
redis
tifffile
Pillow
wheel
"

pip3 install $DEPS
pip3 install -r ../posda/fastapi/app/requirements.txt

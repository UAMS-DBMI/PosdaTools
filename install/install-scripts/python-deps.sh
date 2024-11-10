#!/bin/bash
#
# Install various python deps for different parts of the system
#

if [ -z "$CONFIG_DIR" ]; then
        echo "Missing install configuration, load CONFIG first!";
        exit 1;
fi

DEPS="
xlsx2csv
mysql-connector
python-box
pydicom
redis
tifffile
Pillow
wheel
httpx>=0.27.0
loguru>=0.7.2
jsonargparse[signatures]>=4.32.0
sanic>=24.6.0
"

pip3.9 install $DEPS
pip3.9 install -r $ONEPOSDA_LOCATION/posda/fastapi/app/requirements.txt

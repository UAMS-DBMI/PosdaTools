#!/bin/bash

. /oneposda/install/load-env.sh


API_ROOT=$POSDA_ROOT/../fastapi/app
echo "API_ROOT = $API_ROOT"

cd $API_ROOT

#scl enable rh-python38 -- \
python3 -m uvicorn --workers $API_WORKERS --host 0.0.0.0 --port $API_PORT main:app

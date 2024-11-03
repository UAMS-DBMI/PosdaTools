#!/bin/bash

cd $(dirname "$0"); # cd to script dir

. load-env.sh


API_ROOT=$ONEPOSDA_LOCATION/posda/fastapi/app
echo "API_ROOT = $API_ROOT"

cd $API_ROOT

exec $PYTHONBIN \
	-m uvicorn \
	--workers $API_WORKERS \
	--host 0.0.0.0 \
	--port $API_PORT \
	main:app

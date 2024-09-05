#!/bin/sh

python3 check_db.py
if [ $? -eq 0 ]
then
  exec uvicorn --workers $API_WORKERS --host 0.0.0.0 --port $API_PORT main:app
else
  echo "The database is not available yet, exiting."
  exit 1
fi

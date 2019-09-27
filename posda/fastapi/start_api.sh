#!/bin/sh

uvicorn --workers $API_WORKERS --host 0.0.0.0 --port $API_PORT main:app

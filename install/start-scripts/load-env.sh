#!/bin/bash

# This script will always assume it is loaded
# from it's actual dir

. ../CONFIG

export $(cat $CONFIG_DIR/*.env | grep -v ^#)

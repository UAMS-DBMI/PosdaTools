#!/bin/bash

BASE_DIR=/oneposda/install
CONF_DIR=$BASE_DIR/temp-config

export $(cat $CONF_DIR/*.env | grep -v ^#)
source scl_source enable rh-python38
source scl_source enable rh-postgresql13

#!/bin/bash

if [ -z "$CONFIG_DIR" ]; then
        echo "Missing install configuration, load CONFIG first!";
        exit 1;
fi

cp -r $ONEPOSDA_LOCATION/kaleidoscope/kaleidoscope/dist /kaleidoscope

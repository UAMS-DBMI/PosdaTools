#!/usr/bin/env bash

convert $1 -fill gray -stroke black -draw "rectangle 362,23 512,75" -draw "rectangle 10,23 100,75" $1.d.png

#!/bin/bash

BASE_URL="https://www.dclunie.com/dicom3tools/workinprogress"
OUTPUT_FILENAME=/build/tools.tar.bz2

latest=$(curl -s $BASE_URL/index.html | grep -oP '(?<=<a href=")[^"]*' | grep dicom3tools | sort | tail -n1)

# echo Latest: $latest

curl $BASE_URL/$latest > $OUTPUT_FILENAME

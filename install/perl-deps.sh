#!/bin/bash

DEPS="
Method::Signatures::Simple
K/KE/KEN/xls2csv-1.07.tar.gz
HTTP::Request::StreamingUpload
"

cpanm --notest $DEPS

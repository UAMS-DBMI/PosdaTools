#!/bin/bash

DEPS="
Method::Signatures::Simple
K/KE/KEN/xls2csv-1.07.tar.gz
HTTP::Request::StreamingUpload
Data::UUID
Switch
Text::CSV
Regexp::Common
DateTime
REST::Client
Modern::Perl
List::MoreUtils
Text::Markdown
Redis
"

cpanm --notest $DEPS

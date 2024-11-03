#!/bin/bash
#
# Install required Perl deps using cpanm.
# This script must be run after the system-deps, or
# otherwise after having installed cpanm
#

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

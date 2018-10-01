#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
my $Series = $ARGV[0];
my $FilesToPixDigest;
# $FilesToPixDigest = {
#   <file_id> => <pixel_digest>,
#   ...
# };
my $PixDigestAnalysis;
# $PixDigestAnalysis = {
#   <pixel_digest> => {
#     is_blank => <blank_value> [ if blank ]
#     is_bilevel => {           [ if bilevel ]
#       high_value => {
#         value => <high_value>,
#         count => <num_high_value>
#       },
#       low_value => {
#         value => <low_value>,
#         count => <num_low_value>
#       },
#     },
#   },
#   ...
# };

#!/usr/bin/perl -w
use strict;
use PosdaCuration::ExtractionManagerIf;
my $if = PosdaCuration::ExtractionManagerIf->new(64612, 'bbennett',
  'adfasdyasdf', $0);
my ($collection, $site, $subj) = @ARGV;
$if->DiscardExtraction($collection, $site, $subj);

#!/usr/bin/perl -w
#
use strict;
use DBI;
my $usage = "usage: HideFile.pl <db> <file_id>\n";
unless($#ARGV == 1) { die $usage }
my $dbh = DBI->connect("DBI:Pg:database=$ARGV[0]", "", "");
my $q= <<EOF;
update
  ctp_file
set 
  visibility = 'hidden'
where 
  file_id = ?
EOF
my $p = $dbh->prepare($q) or die "$!";
$p->execute($ARGV[1]) or die $!;
print "OK\n";

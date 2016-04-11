#!/usr/bin/perl -w
#
use strict;
use DBI;
my $usage = "usage: HideFiles.pl <db>\n";
unless($#ARGV == 0) { die $usage }
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
while(my $line = <STDIN>){
  chomp $line;
  $p->execute($line) or die $!;
}
print "OK\n";

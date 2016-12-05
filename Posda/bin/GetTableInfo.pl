#!/usr/bin/perl -w
use strict;
use DBI;
my $dbh = DBI->connect("dbi:Pg:dbname=posda_files");
while(my $line = <STDIN>){
  chomp $line;
  my $table = $line;
  $table =~ s/^\s*//;
  $table =~ s/\s*$//;
  my $q = $dbh->prepare("select count(*) from $table");
  $q->execute;
  while(my $h = $q->fetchrow_hashref){
    print "$h->{count} rows in $table\n";
  }
}

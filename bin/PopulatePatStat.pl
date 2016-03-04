#!/usr/bin/perl -w
use strict;
use DBI;
my $dbh = DBI->connect("DBI:Pg:dbname=posda_files", "", "");
my $ins = $dbh->prepare("insert into patient_import_status(patient_id, patient_import_status) values (?, ?)");
while(my $line = <STDIN>){
  chomp $line;
  my($pat_id, $status) = split(/ /, $line);
  $ins->execute($pat_id, $status);
}

#!/usr/bin/perl -w
use strict;
while(my $line = <STDIN>){
  chomp $line;
  my $table = $line;
  my $cmd = "grep $table Posda/sql/dicom_images.sql";
  my @lines = `$cmd`;
  if($#lines < 0){
    print "definition for table $table not found\n";
  }
}

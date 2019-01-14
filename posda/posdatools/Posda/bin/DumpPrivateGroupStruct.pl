#!/usr/bin/perl -w
use strict;
use Posda::Try;
use Debug;
my $dbg = sub {print @_ };
my $file = $ARGV[0];
my $group = $ARGV[1];
my $try = Posda::Try->new($file);
unless(defined $try->{dataset}) { die "$file not DICOM" }
my $ds = $try->{dataset};
$ds->MapToConvertPvt;
my $gr = hex($group);
if(exists $ds->{$gr}){
  print "Struct for group $gr ($group): ";
  Debug::GenPrint($dbg, $ds->{$gr}, 1);
  print "\n";
} else {
  print "group $gr ($group) not found\n";
}

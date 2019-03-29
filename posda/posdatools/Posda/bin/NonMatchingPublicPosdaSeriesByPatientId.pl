#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
my $patient_id = $ARGV[0];
my $in_public = Query('Series In Public By PatientId');
my $in_posda = Query('Series In Posda By PatientId');
my %InPosda;
$in_posda->RunQuery(sub{
  my($row) = @_;
  $InPosda{$row->[0]} = 1;
}, sub {}, $patient_id);
my %InPublic;
$in_public->RunQuery(sub{
  my($row) = @_;
  $InPublic{$row->[0]} = 1;
}, sub {}, $patient_id);
my %OnlyInPosda;
my %OnlyInPublic;
for my $i(keys %InPosda){
  unless(exists $InPublic{$i}){
    $OnlyInPosda{$i} = 1;
  }
}
for my $i(keys %InPublic){
  unless(exists $InPosda{$i}){
    $OnlyInPublic{$i} = 1;
  }
}
if((keys %OnlyInPosda) > 0){
  print "Only In Posda:\n";
  for my $i (keys %OnlyInPosda){
    print "\t$i\n";
  }
}
if((keys %OnlyInPublic) > 0){
  print "Only In Public\n";
  for my $i (keys %OnlyInPublic){
    print "\t$i\n";
  }
}

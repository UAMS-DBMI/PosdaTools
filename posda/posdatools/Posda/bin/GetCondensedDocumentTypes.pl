#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
my $q = Query("GetFiletypes");
my %CondensedTypes;
$q->RunQuery(sub {
  my($row) = @_;
  my($type, $count) = @$row;
  unless(defined $type) { return }
  if($type eq '') { return }
  my $condensed = CondenseType($type);
  unless(exists $CondensedTypes{$condensed}){ $CondensedTypes{$condensed} = 0 }
  $CondensedTypes{$condensed} += $count;
}, sub {});
for my $type (
  reverse sort {
    $CondensedTypes{$a} <=> $CondensedTypes{$b}
  } keys %CondensedTypes
){
print "$type, $CondensedTypes{$type}\n";
}
sub CondenseType{
  my($type) = @_;
  if($type =~ /PNG image/){
    return "PNG image";
  } elsif($type =~ /XML.*document/){
    return "XML document";
  } elsif($type =~ /Microsoft.*Excel/){
    return "Microsoft Excel";
  } elsif($type =~ /Microsoft.*Word/){
    return "Microsoft Word";
  } elsif($type eq "parsed dicom file"){
    return "Good DICOM";
  } elsif($type =~ "DICOM medical"){
    return "Bad DICOM";
  } elsif($type =~ "PDF document"){
    return "PDF document";
  } elsif($type =~ "ASCII.*text"){
    return "ASCII Text";
  } elsif($type =~ "Unicode.*text"){
    return "Unicode Text";
  } elsif($type =~ "ISO-8859.*text"){
    return "ISO-8859 Text";
  } else {
    return $type;
  }
}

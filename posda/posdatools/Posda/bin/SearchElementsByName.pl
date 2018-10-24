#!/usr/bin/perl -w 
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Posda::DataDict;
use Posda::ElementNames;
use Posda::Dataset;

my $usage = "Usage: $0 <string>";
unless ($#ARGV == 0) {die $usage;}
my $string = $ARGV[0];
if(exists $Posda::ElementNames::NameToSig->{$string}){
  print "\"$string\" is the \"Canonical DICOM name\" for element: " .
   $Posda::ElementNames::NameToSig->{$string} . "\n";
  exit;
}
if(Posda::Dataset->ValidateSig($string)){
  print "$string identifies a DICOM tag:\n";
  my $name = Posda::ElementNames::FromSig($string);
  print "$name\n";
  exit;
}
if(Posda::Dataset->ValidatePattern($string)){
  print "$string identifies a DICOM tag match pattern:\n";
  my $name = Posda::ElementNames::FromPat($string);
  print "$name\n";
  exit;
}
my $dd = Posda::DataDict->new;
if(exists $dd->{SopCl}->{$string}){
  print "\"$string\" is the SOP Class UID for " .
    "$dd->{SopCl}->{$string}->{sopcl_desc}\n";
  exit;
}
if(exists $dd->{XferSyntax}->{$string}){
  print "\"$string\" is the Transfer Syntax UID for " .
    "$dd->{XferSyntax}->{$string}->{name}\n";
  exit;
}
my @matching_elements;
for my $g (keys %{$dd->{Dict}}){
  for my $e (keys %{$dd->{Dict}->{$g}}){
    if($dd->{Dict}->{$g}->{$e}->{Name} =~ /$string/){
      push @matching_elements, $dd->{Dict}->{$g}->{$e};
    }
  }
}
my $me_count = scalar @matching_elements;
if($me_count > 0){
  print "There are are $me_count matching element descriptions:\n";
  for my $m (
    sort {
      $a->{group} cmp $b->{group} ||
      $a->{ele} cmp $b->{ele}
    }
    @matching_elements
  ){
    print "($m->{group},$m->{ele}) $m->{VR} $m->{VM} $m->{Name}\n";
  }
}
my @matching_xfer;
for my $xs (keys %{$dd->{XferSyntax}}){
  if($dd->{XferSyntax}->{$xs}->{name} =~ /$string/){
    push @matching_xfer, [$xs, $dd->{XferSyntax}->{$xs}];
  }
}
my $xf_count = scalar @matching_xfer;
if($xf_count > 0){
  print "There are $xf_count matching transfer syntax names:\n";
  for my $xf (@matching_xfer){
    print "$xf->[0]: $xf->[1]->{name}\n";
  }
}

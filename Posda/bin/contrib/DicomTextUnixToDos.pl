#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/contrib/DicomTextUnixToDos.pl,v $
#$Date: 2011/06/23 15:31:26 $
#$Revision: 1.3 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Cwd;
use strict;
use Posda::Parser;
use Posda::Dataset;

my $usage = "usage: $0 <source file> <destination file>";
unless($#ARGV == 1) {
	die $usage;
}

my $from = $ARGV[0];
my $to = $ARGV[1];
unless(
	$from =~ /^\//
) {
	$from = getcwd."/$from";
}
unless(
	$to =~ /^\//
) {
	$to = getcwd."/$to";
}


Posda::Dataset::InitDD();

my($df, $ds, $size, $xfr_stx, $errors)  = Posda::Dataset::Try($ARGV[0]);
unless($ds) { die "$from didn't parse into a dataset" }
$ds->MapEle(sub{
  my($ele, $sig) = @_;
  if(
    exists $ele->{VR} && (
      $ele->{VR} eq "LT" ||
      $ele->{VR} eq "SH" ||
      $ele->{VR} eq "ST" ||
      $ele->{VR} eq "UT"
    )
  ){
    if(exists $ele->{value} && defined($ele->{value})){
      if(ref($ele->{value}) eq "ARRAY"){
        for my $i (0 .. $#{$ele->{value}}){
          if(defined $ele->{value}->[$i]){
            $ele->{value}->[$i] =~ s/([^\r])\n/"$1\r\n"/ge;
          }
        }
      } else {
        $ele->{value} =~ s/([^\r])\n/"$1\r\n"/ge;
      }
    }
  }
});

$ds->WritePart10($to, $xfr_stx, "DICOM_TEST", undef, undef);

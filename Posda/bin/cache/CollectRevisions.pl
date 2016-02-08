#!/usr/bin/perl -w
#
#Copyright 2015, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Storable;
my $dir = $ARGV[0];
unless(-d $dir) { die "$dir is not a dir" }
opendir DIR, $dir;
my %digests;
while(my $d = readdir(DIR)){
  if($d =~ /^\./) { next }
  unless(-d "$dir/$d"){ next }
  unless(-f "$dir/$d/dicom.pinfo") { next }
  my $dicom_info = Storable::retrieve("$dir/$d/dicom.pinfo");
  for my $dig (keys %{$dicom_info->{FilesByDigest}}){
    $digests{$dig} = 1;
  }
}
for my $dig(keys %digests){
  print "$dig\n";
}

#!/usr/bin/perl -w 
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Dclunie;
use Posda::Validator;
use Posda::Dataset;
use Debug;
my $dbg = sub {print @_};
my $file = $ARGV[0];
my($df, $ds, $size, $xfr_stx, $errors) = Posda::Dataset::Try($file);
unless($ds) { die "$file isn't DICOM" }
my $val = Posda::Validator->new();
#print "Validator: ";
#Debug::GenPrint($dbg, $val, 1);
#print "\n";
my $sopcl = $ds->Get("(0008,0016)");
unless(exists $val->{sopcl_uid}->{$sopcl}) { die "unknown sop_uid: $sopcl" }
my $sop_name = $val->{sopcl_uid}->{$sopcl};
if(exists $val->{iods}->{$sop_name}){
  print "$sop_name has a defined expansion\n";
} else {
  if($sop_name =~ /^(.*)Storage$/){
    $sop_name = $1;
    if(exists $val->{iods}->{$sop_name}){
      print "${sop_name}Storage has no defined expansion\n";
      print "But $sop_name does\n";
    } else {
      die "$sop_name has no defined expansion\n";
    }
  } else {
    die "$sop_name has no defined expansion\n";
  }
}
my @errors;
my $IodExp = $val->ExpandAnIod($val->{iods}->{$sop_name});
$val->SearchElementSpecifications($IodExp, $ds, \@errors);
print "Errors:\n";
for my $i (@errors){
  print "$i\n";
}

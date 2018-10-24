#!/usr/bin/perl -w
use strict;
use Posda::Try;
use Posda::UUID;
use Digest::MD5;
use Debug;
my $from = $ARGV[0];
my $try = Posda::Try->new($from);
unless(exists $try->{dataset}) { die "$from isn't a DICOM file\n" }
my $ds = $try->{dataset};
my $edits = {
  full_ele_pat_substitutions => {
     "(3006,0020)[<0>](3006,0026)" => {
       "PTV2-_RTOG1016" => "PTV2-_RTOG",
       "H&N RTOG-0615" => "H&N RTOG",
       "TRONC_PRV_RTOG" => "TRONC_PRV_RTOG",
       "PTV1-_RTOG1016" => "PTV1-_RTOG",
       "PTV3_RTOG1016" => "PTV3_RTOG",
       "MOELLE_PRV_RTOG1016" => "MOELLE_PRV_RTOG",
       "TISSUS SAINS RTOG1016" => "TISSUS SAINS RTOG",
     },
   },
};
for my $pat (keys %{$edits->{full_ele_pat_substitutions}}){
  for my $v (keys %{$edits->{full_ele_pat_substitutions}->{$pat}}){
    my $s = $edits->{full_ele_pat_substitutions}->{$pat}->{$v};
    my $m = $ds->Search($pat, $v);
    if($m && ref($m) eq "ARRAY" && $#{$m} >= 0){
      for my $ms (@$m){
        my $sig = $ds->DefaultSubstitute($pat, $ms);
        print STDERR "Substitute $s from $v in $sig\n";
        $ds->Insert($sig, $s);
      }
    }
  }
}

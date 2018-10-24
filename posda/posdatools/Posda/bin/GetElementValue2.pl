#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Parser;
use Posda::Dataset;
use Cwd;
use Storable;

Posda::Dataset::InitDD();

my $usage = sub {
  print "usage: $0 <file> <ele_sig> [--plain-text]\n";
  print "Output is Storable frozen by default\n";
  exit(-1);
};

unless($#ARGV >= 1) {
  &$usage();
}

sub GetElementValue {
  my($ds, $ele_sig) = @_;

  my $value = $ds->Get($ele_sig);
  my $type = $Posda::Dataset::DD->get_type_by_sig($ele_sig);
  if(ref($value) eq "ARRAY"){
    if($type eq "text"){
      my $new_value = join("\\", @$value);
      return $new_value;
    } else {
      my $new_value = join("", @$value);
      return $new_value;
    }
  } else {
    return $value;
  }
}

my $file = $ARGV[0]; 
unless($file =~ /^\//) { $file = getcwd."/$file" }

my($df, $ds, $size, $xfr_stx, $errors)  = Posda::Dataset::Try($ARGV[0]);
unless($ds) { die "$file didn't parse into a dataset" }
my $ele_sig = $ARGV[1];

my $results = {};

if($ele_sig =~ /<\d+>/) {  # if this is a sequence, loop over them all
  my $matches = $ds->NewSearch($ele_sig);

  if(ref $matches eq "ARRAY"){
    for my $m (@$matches){
      my $sub_sig = $ele_sig;
      for my $i (0 .. $#{$m}){
        my $mn = "<$i>";
        $sub_sig =~ s/$mn/$m->[$i]/;
      }
      $results->{$sub_sig} = GetElementValue($ds, $sub_sig);
    }
  }
} else {
  $results->{$ele_sig} = GetElementValue($ds, $ele_sig);
}

if ($ARGV[2] eq '--plain-text') {
  for my $k (sort keys %{$results}){
    print "$k: $results->{$k}\n";
  }
} else {
  print Storable::freeze($results);
}

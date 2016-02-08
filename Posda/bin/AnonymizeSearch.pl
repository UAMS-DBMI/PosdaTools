#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Anonymizer;
use Posda::Dataset;
use Posda::Parser;
use File::Find;

Posda::Dataset::InitDD();

unless($#ARGV == 0){ die "usage: $0 <input_dir>" }
my $input_dir = $ARGV[0];

my $hash = {};

my $pass_one_wanted = sub {
  my $f_name = $File::Find::name;
  if(-d $f_name) { return }
  unless(-r $f_name) { return }
  my($df, $ds, $size, $xfr_stx, $errors) = Posda::Dataset::Try($f_name);
  unless(defined $ds){ return }
  my $sop_inst = $ds->ExtractElementBySig("(0008,0018)");
  unless(defined $sop_inst) { return }
  my $add_list = [
     "(300a,0002)",
     "(300a,0003)",
     "(3006,0002)",
     "(3006,0004)",
  ];
  Posda::Anonymizer::history_builder($hash, $ds, $add_list);
};
find({wanted => $pass_one_wanted, follow => 1}, $input_dir);
for my $i (sort keys %{$hash->{sub}}){
  for my $j (keys %{$hash->{sub}->{$i}->{values}}){
    print "map|$i|$hash->{sub}->{$i}->{name}| ";
    print "\"$j\" => \"\"\n";
  }
}
for my $i (sort keys %{$hash->{date}}){
   print "date_map|\"$i\" => \"\"\n";
}

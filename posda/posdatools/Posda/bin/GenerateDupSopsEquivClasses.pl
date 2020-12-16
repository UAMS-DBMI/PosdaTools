#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
my $usage = <<EOF;
Usage:
GenerateDupSopsEquivClasses.pl <sub_process_invocation_id>
or
GenerateDupSopsEquivClasses.pl -h

Uses query ForMakingDupSopsEquivalenceClasses
to generate a list of SOP equivalence classes for a dup_sop_comparison
specified by sub_process_invocation_id

prints on STDOUT:
<equiv_class_desc>|num_sops

EOF

if($#ARGV == 0 && $ARGV[0] eq "-h") { print "$usage\n\n"; exit }
if($#ARGV != 0){ print "Wrong args: $usage\n"; die "$usage\n\n" }
my($subprocess_invocation_id) = @ARGV;
my %Equiv;
my $last_sop_idx;
my $equiv_class;
Query('ForMakingDupSopsEquivalenceClasses')->RunQuery(sub{
  my($row) = @_;
  my($sop_index, $cmp_index, $long_report_file_id) = @$row;
  if(
    defined($last_sop_idx) &&
    $sop_index ne $last_sop_idx
  ){
    $Equiv{$equiv_class}->{$last_sop_idx} = 1;
    $last_sop_idx = $sop_index;
    $equiv_class = $long_report_file_id;
    return;
  }
  if(
    defined($last_sop_idx) &&
    $sop_index eq $last_sop_idx
  ){
    $equiv_class = $equiv_class . "::" . $long_report_file_id;
    return;
  }
  $last_sop_idx = $sop_index;
  $equiv_class = $long_report_file_id;
}, sub{}, $subprocess_invocation_id);
$Equiv{$equiv_class}->{$last_sop_idx} = 1;
my $longest_equiv;
for my $i (keys %Equiv){
  my @foo = split(/::/, $i);
  my $num = @foo;
  unless(defined $longest_equiv) { $longest_equiv = $num }
  if($num > $longest_equiv) { $longest_equiv = $num }
}
print "Longest equiv: $longest_equiv\n";
my $add_equiv = Query('ForInsertingDupSopsEquivalenceClasses');
for my $e (keys %Equiv){
  for my $sop (keys %{$Equiv{$e}}){
    $add_equiv->RunQuery(sub{},sub{}, $e, $subprocess_invocation_id, $sop);
  }
}
for my $e (sort
  {
    keys %{$Equiv{$b}} <=> keys %{$Equiv{$a}} ||
    length($b) <=> length($a)
  }
  keys %Equiv
 ) {
  my $num_sops = keys %{$Equiv{$e}};
  print "$e|$num_sops\n";
}

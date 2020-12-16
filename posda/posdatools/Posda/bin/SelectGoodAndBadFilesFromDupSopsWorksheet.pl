#!/usr/bin/perl -w
use strict;
use File::Temp qw/ tempfile /;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::Try;
use Posda::DiffDicom;
use Digest::MD5;
use FileHandle;
use Storable qw( store retrieve fd_retrieve store_fd );


#use Debug;
#my $dbg = sub { print STDERR @_ };
#my $dbg = sub { print @_ };

my $usage = <<EOF;
Usage:
SelectGoodAndBadFilesFromDupSopsWorksheet.pl <?bkgrnd_id?> <activity_id> <comparison_id> <notify>
or
SelectGoodAndBadFilesFromDupSopsWorksheet.pl -h

Expects lines of the following format on STDIN:
<equiv_class>&<select>

This script uses the query "ForFindingDupSopsEquivalenceClasses" to get a list
of all of the equivalence classes with sop_index, cmp_index, and
from and to file ids.

It uses these results to build the following structure:
\$EquivClasses = {
  <equiv_class> => {
    <sop_index> => [
      <file_id_1>, ... 
    ],
    ...
  },
  ...
}

EOF

if($#ARGV == 0 && $ARGV[0] eq "-h") { print "$usage\n\n"; exit }
if($#ARGV != 3){ print "Wrong args: $usage\n"; die "$usage\n\n" }
my($invoc_id, $act_id, $cmp_id, $notify) = @ARGV;

print "All processing in background\n";
my $back = 
  Posda::BackgroundProcess->new($invoc_id, $notify, $act_id);
$back->Daemonize;

$back->WriteToEmail("script: SelectGoodAndBadFilesFromDupSopsWorksheet.pl\n" .
  "activity_id: $act_id\n" .
  " compare_id: $cmp_id (subprocess_invocation_id of compare step)\n");

$back->SetActivityStatus("Getting Equiv ClassInfo and Building Table");
my %EquivClasses;
Query('ForFindingDupSopsEquivalenceClasses')->RunQuery(sub {
  my($row) = @_;
  my($equiv_class, $sop_index, $cmp_index, $from_file_id, $to_file_id) = @$row;
  unless(exists $EquivClasses{$equiv_class}){
    $EquivClasses{$equiv_class} = {};
  }
  unless(exists $EquivClasses{$equiv_class}->{$sop_index}){
    $EquivClasses{$equiv_class}->{$sop_index} = [];
  }
  if($cmp_index == 1){
    $EquivClasses{$equiv_class}->{$sop_index}->[0] = $from_file_id;
    $EquivClasses{$equiv_class}->{$sop_index}->[1] = $to_file_id;
  } else {
    $EquivClasses{$equiv_class}->{$sop_index}->[$cmp_index] = $to_file_id;
  }
}, sub {}, $cmp_id);
my $num_equiv = keys %EquivClasses;
$back->WriteToEmail("Found $num_equiv equivalence classes\n");
my %FilesToKeep;
my %FilesToDiscard;
while(my $line = <STDIN>){
  chomp $line;
  my($equiv_class,$select) = split(/&/, $line);
  my $good_idx = $select - 1;
  for my $sop (keys %{$EquivClasses{$equiv_class}}){
    $FilesToKeep{$EquivClasses{$equiv_class}->{$sop}->[$good_idx]} = 1;
    for my $i (0 .. $#{$EquivClasses{$equiv_class}->{$sop}}){
      unless($i == $good_idx){
       $FilesToDiscard{$EquivClasses{$equiv_class}->{$sop}->[$i]} = 1;
      }
    }
  }
}
my $num_to_keep = keys %FilesToKeep;
my $num_to_discard = keys %FilesToDiscard;
$back->WriteToEmail("Found:\n" .
  " $num_to_keep files to keep\n". 
  " $num_to_discard files to discard\n");
$back->SetActivityStatus("Preparing Reports");
my $rept_keep = $back->CreateReport("FilesToKeep");
my $rept_discard = $back->CreateReport("FilesToDiscard");
$rept_keep->print("file_id,Files to keep from compare_id $cmp_id\n");
for my $f (keys %FilesToKeep){
  $rept_keep->print("$f\n");
}
$rept_discard->print("file_id,Files to discard from compare_id $cmp_id\n");
for my $f (keys %FilesToDiscard){
  $rept_discard->print("$f\n");
}
$back->Finish("Done");

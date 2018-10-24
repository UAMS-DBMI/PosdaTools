#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Digest::MD5;
use Posda::BackgroundProcess;

my $usage = <<EOF;
DispositionsNeededWorksheet.pl <?bkgrnd_id?> <notify>
or
DispositionsNeededWorksheet.pl -h

The script doesn't expect lines on STDIN:

EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 1){
  die "$usage\n";
}

my ($invoc_id, $notify) = @ARGV;

my $background = Posda::BackgroundProcess->new($invoc_id, $notify);

print "Going straight to background\n";

$background->Daemonize;

my $start_time = `date`;
chomp $start_time;
$background->WriteToEmail("Starting  DispositionsNeededWorksheet.pl at $start_time\n");
$background->WriteToEmail("##### This is a test version of this script #####\n");
open PIPE, "ReconcileTagNames.pl|";
$background->WriteToEmail("Running ReconcileTagNames.pl:\n");
while(my $line = <PIPE>){
  chomp $line;
  $background->WriteToEmail(">>>>$line\n");
}
my $now = `date`;
chomp $now;
$background->WriteToEmail("$now: finished ReconcileTagNames.pl:\n");


my @Rows;
my $get_structs = Query("DistinctDispositionsNeededSimple");
$get_structs->RunQuery(sub {
  my($row) = @_;
  my @copied = @$row;
  push @Rows, \@copied;
}, sub {});
my @cols =  ("id", "vr","tag_name", "disp", "values", "Operation", "why", "notify");
my %ColHeaders = (
  "id" => "id",
#  "element_sig_pattern" => "element_sig_pattern",
  "vr" => "vr",
  "tag_name" => "tag_name",
  "disp" => "disp",
  "values" => "values",
  "Operation" => "Operation",
  "why" => "why",
  "notify" => "notify",
);
my $num_rows = @Rows;
$background->WriteToEmail("$num_rows dispositions needed\n");
my $rpt = $background->CreateReport("Dispositions Needed");
my $vg = Query('ValueSeenByElementSeen');
for my $i (0 .. $#cols){
  $rpt->print("\"$ColHeaders{$cols[$i]}\"");
  if($i == $#cols){
    $rpt->print("\r\n");
  } else {
    $rpt->print(",");
  }
}
my $start_loop = time;
for my $i (0 .. $#Rows){
  my $row = $Rows[$i];
  my %RowInfo;
  $RowInfo{id} = $row->[0];
  $RowInfo{vr} = $row->[2];
  $RowInfo{tag_name} = $row->[3];
  $RowInfo{tag_name} =~ s/"/""/g;
  if($i == 0) {
    $RowInfo{Operation} = "BackgroundUpdatePrivateDisposition";
    $RowInfo{notify} = $notify;
    $RowInfo{why} = "Processing message for subprocess_id $invoc_id";
  }
  my @values;
  $vg->RunQuery(sub {
    my($r) = @_;
    push(@values, $r->[0]);
  }, sub {}, $row->[1]);
  my $val = "";
  for my $i (0 .. $#values){
    $val .= $values[$i];
    unless($i == $#values){
     $val .= "\n";
    }
  }
  $val =~ s/"/""/g;
  $RowInfo{values} = $val;
  for my $i (0 .. $#cols){
    if(defined $cols[$i]){
      $rpt->print("\"$RowInfo{$cols[$i]}\"");
    }
    if($i == $#cols){
      $rpt->print("\r\n");
    } else {
      $rpt->print(",");
    }
  }
}
my $loop_elapsed = time - $start_loop;
$background->WriteToEmail("Loop finished after " .
   "$loop_elapsed seconds\n");
$background->Finish;

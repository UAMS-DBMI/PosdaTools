#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
my $usage = <<EOF;
CorrespondingFilesPosdaPublic.pl <?bkgrnd_id?> <notify>
  <notify> - user to notify

Expects the following list on <STDIN>
  <file_id>

Constructs a spreadsheet with the following columns for all files:
  <sop_instance_uid>
  <posda_path>
  <public_path>

Uses named queries:
   GetSopModalityPath
   GetFilePathPublic
EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 1){
  my $n_args = @ARGV;
  my $mess = "Wrong number of args ($n_args vs 2). Usage:\n$usage\n";
  print $mess;
  die "######################## subprocess failed to start:\n" .
      "$mess\n" .
      "#####################################################\n";
}
my($invoc_id, $notify) = @ARGV;
my @file_ids;
while(my $line = <STDIN>){
  chomp $line;
  $line =~ s/^\s*//;
  $line =~ s/\s*$//;
  push @file_ids, $line;
}
my $num_files = @file_ids;
print "Going to background to process $num_files files\n";

my $back = Posda::BackgroundProcess->new($invoc_id, $notify);
$back->Daemonize;
my $start = time;
my %Hierarchy;
my $q = Query("GetSopModalityPath");
my $q_1 = Query("GetFilePathPublic");
my $i = 0;
$back->WriteToEmail("Starting CorrespondingFilesPosdaPublic\n");
my $rpt = $back->CreateReport("Corresponding paths for files in Posda, Public by posda file_id");
$rpt->print("file_id,posda_path,public_path\n");
for my $file_id (@file_ids){
  $i += 1;
  $q->RunQuery(sub{
    my($row) = @_;
    my($sop_instance_uid, $modality, $posda_path) = @$row;
    my $public_path = "<none>";
    $q_1->RunQuery(sub{
      my($row) = @_;
      $public_path = $row->[0];
    }, sub {}, $sop_instance_uid);
    $rpt->print("$file_id,$posda_path,$public_path\n");
  }, sub {}, $file_id);
}
my $elapsed = time - $start;
$back->Finish("Processed $num_files files in $elapsed seconds");;

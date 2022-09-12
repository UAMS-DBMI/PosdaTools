#!/usr/bin/perl -w
use strict;

use 5.30.0;

use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::Background::PhiScan;

my $usage = <<EOF;
TestBackgroundProcess.pl <bkgrnd_id> <activity_id> <notify>
or
TestBackgroundProcess.pl -h

Expects no lines on STDIN.

EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}
unless($#ARGV == 2){
  die "$usage\n";
}
my ($invoc_id, $act_id, $notify) = @ARGV;

say "some stuff before going to background";

my $background = Posda::BackgroundProcess->new($invoc_id, $notify, $act_id);
$background->Daemonize;

say "some stuff after goign to background";
$background->WriteToEmail("Some stuff in the email\n");
$background->SetActivityStatus("Preparing Reports");

my $rpt1 = $background->CreateReport("Selected Public VR");
$rpt1->print(",,,,,,,,,ProposeEditsTp,$act_id,0,$notify,\"%\"\r\n");

$background->Finish("Completed - Test Script");

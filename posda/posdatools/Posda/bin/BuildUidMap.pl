#!/usr/bin/perl -w
use strict;
use Posda::BackgroundProcess;
use Posda::UUID;

my $usage = <<EOF;
BuildUidMap.pl <id>  <notify>
  id - id of row in subprocess_invocation table created for the
    invocation of the script
  notify - email of party to notify

Expects the following list on <STDIN>
  <unmapped_uid>

EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
if($#ARGV != 1){ print "Wrong args: $usage\n"; die "$usage\n\n" }
my($invoc_id, $notify) = @ARGV;

my $background = Posda::BackgroundProcess->new($invoc_id, $notify);

my $num_lines = 0;
my $map_base = Posda::UUID::GetUUID;
my $ext = 1;
my %UidMapping;
while(my $line = <STDIN>){
  $num_lines += 1;
  chomp $line;
  $UidMapping{$line} = "$map_base.$ext";
  $ext += 1;
}

print "processed $num_lines lines\n" .
  "Forking background process\n";
$background->ForkAndExit;
my $start_text = `date`;
chomp $start_text;
$background->WriteToEmail("Starting at $start_text\n");
my $rpt = $background->CreateReport("UidMapTable");
$rpt->print("unmapped_uid,mapped_uid\n");
for my $unmapped(sort keys %UidMapping){
  $rpt->print("\"$unmapped\",\"$UidMapping{$unmapped}\"\n");
}
my $at_text = `date`;
chomp $at_text;
$background->WriteToEmail("Ending at: $at_text\n");
$background->Finish;

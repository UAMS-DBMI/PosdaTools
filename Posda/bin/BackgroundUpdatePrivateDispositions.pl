#!/usr/bin/perl -w use strict;
use Posda::DB ('Query');
use Posda::BackgroundProcess;
my $usage = <<EOF;
BackgroundUpdatePrivateDispositions.pl <?bkgrnd_id?> <why> <notify>
or
BackgroundUpdatePrivateDispositions.pl -h

expects "<id>&<disp>" on STDIN
EOF
unless($#ARGV == 2) {die $usage};
my @updates;
my($invoc_id, $why, $notify) = @ARGV;
while(my $line = <STDIN>){
  chomp $line;
  my($id, $disp) = split(/\&/, $line);
  push(@updates, [$id, $disp]);
}
my $num_disps = @updates;
print "Going to background to process $num_disps disposition updates\n";
my $back = Posda::BackgroundProcess->new($invoc_id, $notify);
$back->Daemonize;

my $upd = Query("UpdateElementDispositionSimple");
my $rec = Query("RecordElementDispositionChangeSimple");
my $nop = sub { };
for my $update (@updates){
  my($id, $disp) = @$update;
  $back->WriteToEmail("Setting $id to $disp\n");
  $upd->RunQuery($nop, $nop, $disp, $id);
  $rec->RunQuery($nop, $nop, $id, $notify, $why, $disp);
}
$back->Finish;

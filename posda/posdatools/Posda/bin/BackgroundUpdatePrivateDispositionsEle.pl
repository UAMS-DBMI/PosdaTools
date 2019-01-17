#!/usr/bin/perl -w use strict;
use Posda::DB ('Query');
use Posda::BackgroundProcess;
my $usage = <<EOF;
BackgroundUpdatePrivateDispositionsEle.pl <?bkgrnd_id?> <why> <notify>
or
BackgroundUpdatePrivateDispositionsEle.pl -h

expects "<element_sig_pattern>&<disp>" on STDIN
EOF
unless($#ARGV == 2) {die $usage};
my @updates;
my($invoc_id, $why, $notify) = @ARGV;
while(my $line = <STDIN>){
  chomp $line;
  my($ele_sig, $disp) = split(/\&/, $line);
  if($ele_sig =~ /^<(.*)>$/){
    $ele_sig = $1;
  }
  push(@updates, [$ele_sig, $disp]);
}
my $num_disps = @updates;
print "Going to background to process $num_disps disposition updates\n";
my $back = Posda::BackgroundProcess->new($invoc_id, $notify);
$back->Daemonize;

my $get_id = Query('GetElemenSeenIdBySig');
my $upd = Query("UpdateElementDispositionSimple");
my $rec = Query("RecordElementDispositionChangeSimple");
my $nop = sub { };
line:
for my $update (@updates){
  my($ele_sig, $disp) = @$update;
  my $id;
  $back->WriteToEmail("$ele_sig, $disp\n");
  $get_id->RunQuery(sub {
    my($row) = @_;
    $id = $row->[0];
    $back->WriteToEmail("Setting $id to $disp\n");
    $upd->RunQuery($nop, $nop, $disp, $id);
    $rec->RunQuery($nop, $nop, $id, $notify, $why, $disp);
  }, sub {}, $ele_sig);
}
$back->Finish;

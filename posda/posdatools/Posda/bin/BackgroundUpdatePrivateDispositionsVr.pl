#!/usr/bin/perl -w use strict;
use Posda::DB ('Query');
use Posda::BackgroundProcess;
my $usage = <<EOF;
BackgroundUpdatePrivateDispositionsVr.pl <?bkgrnd_id?> <why> <notify>
or
BackgroundUpdatePrivateDispositionsVr.pl -h

expects "<element_sig_pattern>&vr>&<disp>" on STDIN
EOF
unless($#ARGV == 2) {die $usage};
my @updates;
my($invoc_id, $why, $notify) = @ARGV;
while(my $line = <STDIN>){
  chomp $line;
  my($ele_sig, $vr, $disp) = split(/\&/, $line);
  push(@updates, [$ele_sig, $vr, $disp]);
}
my $num_disps = @updates;
print "Going to background to process $num_disps disposition updates\n";
my $back = Posda::BackgroundProcess->new($invoc_id, $notify);
$back->Daemonize;

my $get_id = Query('GetElemenSeenIdBySigVr');
my $upd = Query("UpdateElementDispositionSimple");
my $rec = Query("RecordElementDispositionChangeSimple");
my $nop = sub { };
line:
for my $update (@updates){
  my($ele_sig, $vr, $disp) = @$update;
  $back->WriteToEmail("$ele_sig,$vr,$disp\n");
  my $id;
  $get_id->RunQuery(sub {
    my($row) = @_;
    $id = $row->[0];
    $back->WriteToEmail("Setting $id to $disp\n");
    $upd->RunQuery($nop, $nop, $disp, $id);
    $rec->RunQuery($nop, $nop, $id, $notify, $why, $disp);
  }, sub {}, $ele_sig, $vr);
}
$back->Finish;

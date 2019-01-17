#!/usr/bin/perl -w use strict;
my $usage = <<EOF;
UpdateSimplePrivateDispositionVr.pl <who> <why>
expects "<element_sig_pattern>&<vr>&<disp>" on STDIN
EOF
unless($#ARGV == 1) {die $usage};
my($who, $why) = @ARGV;
use Posda::DB::PosdaFilesQueries;
my $get_id = PosdaDB::Queries->GetQueryInstance("GetElemenSeenIdBySigVr");
my $upd = PosdaDB::Queries->GetQueryInstance("UpdateElementDispositionSimple");
my $rec = PosdaDB::Queries->GetQueryInstance("RecordElementDispositionChangeSimple");
my $nop = sub { };
line:
while(my $line = <STDIN>){
  chomp $line;
  my($ele_sig, $vr,  $new_disp) = split(/\&/, $line);
  my $id;
  $get_id->RunQuery(sub {
    my($row) = @_;
    $id = $row->[0];
  }, sub {}, $ele_sig, $vr);
  unless(defined $id){ next line }
  print "Setting $id to $new_disp\n";
  $upd->RunQuery($nop, $nop, $new_disp, $id);
  $rec->RunQuery($nop, $nop, $id, $who, $why, $new_disp);
}

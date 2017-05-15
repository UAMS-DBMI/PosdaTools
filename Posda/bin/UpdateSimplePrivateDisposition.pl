#!/usr/bin/perl -w use strict;
my $usage = <<EOF;
UpdateSimplePrivateDisposition.pl <who> <why>
expects "<element_seen_id>&<private_disposition>" on STDIN
EOF
unless($#ARGV == 1) {die $usage};
my($who, $why) = @ARGV;
use Posda::DB::PosdaFilesQueries;
my $upd = PosdaDB::Queries->GetQueryInstance("UpdateElementDispositionSimple");
my $rec = PosdaDB::Queries->GetQueryInstance("RecordElementDispositionChangeSimple");
my $nop = sub { };
while(my $line = <STDIN>){
  chomp $line;
  my($id, $new_disp) = split(/\&/, $line);
  $upd->RunQuery($nop, $nop, $new_disp, $id);
  $rec->RunQuery($nop, $nop, $id, $who, $why, $new_disp);
}

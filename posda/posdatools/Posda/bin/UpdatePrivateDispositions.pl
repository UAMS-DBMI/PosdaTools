#!/usr/bin/perl -w
use strict;
my $usage = <<EOF;
UpdateKnowledgeBase.pl <who> <why>
  expects "<element_signature>, <vr>, <disposition>" on STDIN
EOF
unless($#ARGV == 1) {die $usage};
my($who, $why) = @ARGV;
use Posda::DB::PosdaFilesQueries;
my $get = PosdaDB::Queries->GetQueryInstance("GetElementDispositionVR");
my $upd = PosdaDB::Queries->GetQueryInstance("UpdateElementDisposition");
my $rec = PosdaDB::Queries->GetQueryInstance("RecordElementDispositionChange");
my $nop = sub { };
while(my $line = <STDIN>){
  chomp $line;
  my($tag, $vr, $new_disp) = split(/\&/, $line);
  my $sig = $tag;
  $sig =~ s/^-//;
  $sig =~ s/-$//;
  my($sig_id, $old_disp, $old_name);
  $get->RunQuery(sub {
    my($row) = @_;
    $sig_id = $row->[0];
    $old_disp = $row->[3];
    $old_name = $row->[4];
  }, $nop, $sig, $vr);
  unless(defined($sig_id)){
    print "Couldn't find definition for ($sig, $vr)\n";
    next;
  }
  open CHILD, "CalculateNameChainForSig.pl '$sig'|" or die "Can't open child";
  my($xtag, $vrc, $nnc);
  while(my $line = <CHILD>){
    chomp $line;
    ($xtag, $vrc, $nnc) = split /\|/, $line;
  }
  unless(defined $nnc){ 
    print "Couldn't calculate name_chain ($sig, $vr)\n";
    next;
  }
  $upd->RunQuery($nop, $nop, $new_disp, $nnc, $sig, $vr);
  $rec->RunQuery($nop, $nop, $sig_id, $who, $why, $old_disp, 
    $new_disp, $old_name, $nnc);
  print "$sig, $vr changed:\n" .
    "\tdisposition: $old_disp => $new_disp\n" .
    "\tname_chain: $old_name => $nnc\n" .
    "\tby: $who\n" .
    "\tbecause: $why\n";
}

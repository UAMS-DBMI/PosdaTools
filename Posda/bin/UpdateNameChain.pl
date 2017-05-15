#!/usr/bin/perl -w use strict;
use Posda::DB::PosdaFilesQueries;
my $q = PosdaDB::Queries->GetQueryInstance('ListOfElementSignaturesAndVrs');
my $u = PosdaDB::Queries->GetQueryInstance('UpdateNameChain');
my $usage = <<EOF;
UpdateNameChain.pl
EOF
unless($#ARGV == -1) { die $usage }
$q->RunQuery(
  sub {
    my($row) = @_;
    my($sig, $vr, $nc, $count) = @$row;
    unless(defined $nc) {$nc = '<undef>'}
    open CHILD, "CalculateNameChainForSig.pl '$sig'|" or die "Can't open child";
    my($tag, $vrc, $nnc);
    while(my $line = <CHILD>){
      chomp $line;
      ($tag, $vrc, $nnc) = split /\|/, $line;
    }
    unless(defined $nnc) {
      print STDERR "no name chain returned for $sig\n";
      return;
    }
    if($nnc eq $nc) {
      print STDERR "no change for $tag ($nc)\n";
      return;
    }
    print "$tag: $nc => $nnc\n";
    $u->RunQuery(sub {}, sub {},
      $nnc, $sig, $vr)
  },
  sub {},
);

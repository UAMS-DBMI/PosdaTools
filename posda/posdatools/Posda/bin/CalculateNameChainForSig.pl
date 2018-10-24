#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
my $usage = <<EOF;
CalculateNameChainForSig.pl <sig>
EOF
if($#ARGV != 0) { die $usage }
if($ARGV[0] eq '-h') { die $usage }
my $ptdh = PosdaDB::Queries->GetQueryInstance("GetPrivateTagFeaturesBySignature");
sub get_private_info{
  my($tag) = @_;
  my($name,$vr);
  $ptdh->RunQuery(
    sub {
      my($row) = @_;
      $name = $row->[0];
      $vr = $row->[1];
    }, sub {
    },
    $tag
  );
  unless(defined $name) { $name = "<undef>" }
  unless(defined $vr) { $vr = "<undef>" }
  return ($name, $vr);
}
my $tdh = PosdaDB::Queries->GetQueryInstance("GetPublicFeaturesBySignature");
sub get_public_info{
  my($tag) = @_;
  my($name, $vr);
  $tdh->RunQuery(
     sub{
       my($row) = @_;
       $name = $row->[0];
       $vr = $row->[1];
     },
     sub {
     },
     $tag
  );
  unless(defined $name) { $name = "<undef>" }
  unless(defined $vr) { $vr = "<undef>" }
  return ($name, $vr);
}
my $sag = $ARGV[0];
my @sig_comp = split /\[[\d<>]+\]/, $sag;
my $num_comp = @sig_comp;
my $final_vr = "";
my $final_name = "";
for my $i(0 .. $#sig_comp){
  my($dd_name, $dd_vr);
  my $sig = $sig_comp[$i];
  if($sig =~ /,\"/){
    ($dd_name, $dd_vr) = get_private_info($sig);
  } else {
    ($dd_name, $dd_vr) = get_public_info($sig);
  }
  $final_name .= $dd_name;
  $final_vr .= $dd_vr;
  unless($i == $#sig_comp) {
    $final_name .= ":";
    $final_vr .= ":";
  };
}
print "$sag|$final_vr|$final_name\n";

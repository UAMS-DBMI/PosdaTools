#!/usr/bin/perl -w
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use DBI;
use Posda::DB::PosdaFilesQueries;
use Posda::DataDict;
my $dd = Posda::DataDict->new;
use Debug;
my $dbg = sub { print STDERR @_ };
my $help = <<EOF;
Usage: 
  PhiReport.pl <scan_id> 
or
  PhiReport.pl -h
EOF

if($#ARGV < 0 || ($ARGV[0] eq "-h")){
  print $help;
  exit;
}
my $q_inst = PosdaDB::Queries->GetQueryInstance(
  "ValuesWithVrTagAndCountLimited");
my $ptdh = PosdaDB::Queries->GetQueryInstance("GetPrivateTagFeaturesBySignature");
sub get_private_info{
  my($tag) = @_;
  my($name,$vr,$disp);
  $ptdh->RunQuery(
    sub {
      my($row) = @_;
      $name = $row->[0];
      $vr = $row->[1];
      $disp = $row->[2];
    }, sub {
    },
    $tag
  );
  unless(defined $name) { $name = "<undef>" }
  unless(defined $vr) { $vr = "<undef>" }
  unless(defined $disp) { $disp = "<undef>" }
  return ($name, $vr, $disp);
}
my $tdh = PosdaDB::Queries->GetQueryInstance("GetPublicTagDispositionBySignature");
sub get_public_info{
  my($tag) = @_;
  my($name, $vr, $disp);
  $tdh->RunQuery(
     sub{
       my($row) = @_;
       $disp = $row->[0];
     },
     sub {
     },
     $tag
  );
  my $ele = $dd->get_ele_by_sig($tag);
  if(defined($ele) && ref($ele) eq "HASH"){
    $name = $ele->{Name};
    $vr = $ele->{VR};
  }
  unless(defined $name) { $name = "<undef>" }
  unless(defined $vr) { $vr = "<undef>" }
  unless(defined $disp) { $disp = "<undef>" }
  return ($name, $vr, $disp);
}

my $process_row = sub {
  my($row) = @_;
  my $vr = $row->[0];
  my $v = $row->[1];
  if($vr eq 'UI' && $v =~ /^1.3.6.1.4.1.14519.5.2.1/) { return }
  my $sag = $row->[2];
  my $pdisp = $row->[3];
  unless(defined $pdisp) { $pdisp = "<undef>" }
  my $num = $row->[4];
  my @sig_comp = split /\[<\d+>\]/, $sag;
  my $num_comp = @sig_comp;
  my $final_vr = "";
  my $final_name = "";
  my $final_disp = "";
  for my $i(0 .. $#sig_comp){
    my($dd_name, $dd_vr, $dd_disp);
    my $sig = $sig_comp[$i];
    if($sig =~ /,\"/){
      ($dd_name, $dd_vr, $dd_disp) = get_private_info($sig);
    } else {
      ($dd_name, $dd_vr, $dd_disp) = get_public_info($sig);
    }
    $final_name .= $dd_name;
    $final_vr .= $dd_vr;
    $final_disp .= $dd_disp;
    unless($i == $#sig_comp) {
      $final_name .= ":";
      $final_vr .= ":";
      $final_disp .= ":";
    };
  }
  $v =~ s/"/""/g;
  $sag =~ s/"/""/g;
  $v = "<$v>";
  if($sag =~ /^\(\d\d\d\d,\d\d\d\d\)$/){
    $sag = "-$sag-";
  }
  print "\"$vr\",\"$v\",\"$sag\",\"$pdisp"," .
    "\"$final_name\",\"$final_vr\",\"$final_disp\",\"$num\"\n";
};
print '"Vr","Value","Tag","Priv Disp","Name","DD Vr","Disp","# Files"' . "\n";
$q_inst->RunQuery($process_row, sub{}, $ARGV[0]);

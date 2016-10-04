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
my $q_inst = PosdaDB::Queries->GetQueryInstance("ValuesWithVrTagAndCount");
my $db_name = $q_inst->GetSchema;
my $dbh = DBI->connect("dbi:Pg:dbname=$db_name");
unless($dbh) { die "Can't connect to $db_name" }
my $ptdh = DBI->connect("dbi:Pg:dbname=private_tag_kb");
my $get_pt = $ptdh->prepare(
  "select\n" .
  "  pt_consensus_name as name,\n" .
  "  pt_consensus_vr as vr,\n" .
  "  pt_consensus_disposition as disposition\n" .
  "from pt\n" .
  "where pt_signature = ?"
);
sub get_private_info{
  my($tag) = @_;
  $get_pt->execute($tag);
  my($name,$vr,$disp);
  while(my $h = $get_pt->fetchrow_hashref){
    $name = $h->{name};
    $vr = $h->{vr};
    $disp = $h->{disposition};
  }
  unless(defined $name) { $name = "<undef>" }
  unless(defined $vr) { $vr = "<undef>" }
  unless(defined $disp) { $disp = "<undef>" }
  return ($name, $vr, $disp);
}
my $tdh = DBI->connect("dbi:Pg:dbname=public_tag_disposition");
my $get_disp = $tdh->prepare(
  "select\n" .
  "  disposition\n" .
  "from public_tag_disposition\n" .
  "where tag_name = ?"
);
sub get_public_info{
  my($tag) = @_;
  my($name, $vr, $disp);
  my $ele = $dd->get_ele_by_sig($tag);
  if(defined($ele) && ref($ele) eq "HASH"){
    $name = $ele->{Name};
    $vr = $ele->{VR};
  }
  $get_disp->execute($tag);
  while(my $h = $get_disp->fetchrow_hashref){
    $disp = $h->{disposition};
  }
  unless(defined $name) { $name = "<undef>" }
  unless(defined $vr) { $vr = "<undef>" }
  unless(defined $disp) { $disp = "<undef>" }
  return ($name, $vr, $disp);
}
my $process_row = sub {
  my($row) = @_;
  my $vr = $row->{vr};
  my $v = $row->{value};
  my $sag = $row->{element_signature};
  my $num = $row->{num_files};
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
  print "\"$vr\",\"$v\",\"$sag\"," .
    "\"$final_name\",\"$final_vr\",\"$final_disp\",\"$num\"\n";
};
print '"Vr","Value","Tag","Name","DD Vr","Disp","# Files"' . "\n";
$q_inst->Prepare($dbh);
$q_inst->Execute($ARGV[0]);
$q_inst->Rows($process_row);

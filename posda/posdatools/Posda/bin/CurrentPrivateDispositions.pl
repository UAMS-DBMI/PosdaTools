#!/usr/bin/perl -w
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::DB::PosdaFilesQueries;
use Posda::DataDict;
my $dd = Posda::DataDict->new;
use Debug;
my $dbg = sub { print STDERR @_ };
my $help = <<EOF;
Usage: 
  CurrentPrivateDispositions.pl
or
  CurrentPrivateDispositions.pl -h
EOF

if($#ARGV >= 0){
  print $help;
  exit;
}
my $q_inst = PosdaDB::Queries->GetQueryInstance("PrivateTagCountValueList");
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
sub MakeProcessRow{
  my($Info) = @_;
  my $process_row = sub {
    my($row) = @_;
    my $sag = $row->[0];
    my $vr = $row->[1];
    my $v = $row->[2];
    my $disp = $row->[3];
    my $num = $row->[4];
    my @sig_comp = split /\[<\d+>\]/, $sag;
    my $num_comp = @sig_comp;
    my $final_vr = "";
    my $final_name = "";
    my $final_disp = "";
    for my $i(0 .. $#sig_comp){
      my($dd_name, $dd_vr, $dd_disp);
      my $sig = $sig_comp[$i];
      ($dd_name, $dd_vr, $dd_disp) = get_private_info($sig);
      $final_name .= $dd_name;
      $final_vr .= $dd_vr;
      $final_disp .= $dd_disp;
      unless($i == $#sig_comp) {
        $final_name .= ":";
        $final_vr .= ":";
        $final_disp .= ":";
      };
    }
    $Info->{$sag}->{$vr}->{values}->{$v} = 1;
    $Info->{$sag}->{$vr}->{name} = $final_name;
    $Info->{$sag}->{$vr}->{disposition} = $final_disp;
    $Info->{$sag}->{$vr}->{disp} = $disp;
    $Info->{$sag}->{$vr}->{vr} = $final_vr;
  };
  return $process_row;
}
my %Info;
$q_inst->RunQuery(MakeProcessRow(\%Info), sub {});
print '"Tag","VR","Disposition","Name Chain","VR Chain","Disposition Chain"' . "\r\n";
for my $tag (sort keys %Info){
  my $t_print = $tag;
  $t_print =~ s/"/""/g;
  for my $vr (sort keys %{$Info{$tag}}){
    print "\"-$t_print-\",\"$vr\"," .
      "\"$Info{$tag}->{$vr}->{disp}\"," .
      "\"$Info{$tag}->{$vr}->{name}\"," .
      "\"$Info{$tag}->{$vr}->{vr}\"," .
      "\"$Info{$tag}->{$vr}->{disposition}\",\"";
    my @values = sort keys %{$Info{$tag}->{$vr}->{values}};
    my @vprint;
    if($#values <= 9){
      for my $i (0 .. $#values){
        $vprint[$i] = $values[$i];
      }
    } else {
      for my $i (0 .. 4){
        $vprint[$i] = $values[$i];
      }
      $vprint[5] = "----";
      for my $i (0 .. 4){
        my $vi = $#values - $i;
        $vprint[6 + $i] = $values[$vi];
      }
    }
    for my $v (@vprint){
      my $vp = $v;
      $vp =~ s/"/""/g;
      print "$vp\r\n"
    }
    print "\"\r\n";
  }
}

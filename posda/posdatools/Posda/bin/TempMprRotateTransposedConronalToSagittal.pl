#!/usr/bin/perl -w
use strict;
use Posda::BackgroundProcess;
use Posda::File::Import 'insert_file';
use Debug;
my $dbg = sub {
  print STDERR @_;
};
my $usage = <<EOF;
TempMprRotateTransposedConronalToSagittal.pl <?bkgrnd_id?> <activity_id> <notify>
  <activity_id> - activity
  <notify> - user to notify

Expects data on <STDIN>
This script merely uses the data in the spreadsheet report produced by the script;
TempMprTransposeVolume.pl

To create a sagittal volume and produce similar output describing its results

\$SagittalVolume{<x>} = {
  y => <y>,
  z => <z>,
  gray_file => "<dir>/sag_<seq>.gray",
  jpeg_file => "<dir>/sag_<seq>.jpeg",
};

EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 2){
  my $n_args = @ARGV;
  my $mess = "Wrong number of args ($n_args vs 2). Usage:\n$usage\n";
  print $mess;
  die "######################## subprocess failed to start:\n" .
      "$mess\n" .
      "#####################################################\n";
}
my($invoc_id, $activity_id, $notify) = @ARGV;
my %TempMprTransposedCoronalVolume;
my %TempMprTransposedSlice;
line:
while (my $line = <STDIN>){
  chomp $line;
  my($k, $v, $x, $y, $z, $gid, $jid) = split(/&/, $line);
  if($k eq "slice"){
    $TempMprTransposedSlice{$y} = {
      gid => $gid,
      jid => $jid,
    };
    next line;
  }
  if(defined($k) && defined($v)){
    $TempMprTransposedCoronalVolume{$k} = $v;
#    print STDERR "TmpMprTransposedCoronalVolume{$k} = \"$v\"\n";
  } else {
    die "k = $k, v = $v";
  }
}
my @Ys = sort { $b <=> $a } keys %TempMprTransposedSlice;;
my $VolDesc = $TempMprTransposedCoronalVolume{temp_mpr_volume_description};

my $back = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$back->Daemonize;
print STDERR "TempMprTransposedCoronalVolume: ";
Debug::GenPrint($dbg, \%TempMprTransposedCoronalVolume, 1);
print STDERR "\nTempMprTransposedSlice: ";
Debug::GenPrint($dbg, \%TempMprTransposedSlice,1);
print STDERR "\n";
die "just testing";

$back->Finish("Done");

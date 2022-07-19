#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::File::Import 'insert_file';
use Debug;
my $dbg = sub {
  print STDERR @_;
};
my $usage = <<EOF;
TempMprPopulateIsoTropicCoronalFromAxialStack.pl <?bkgrnd_id?> <activity_id> <notify>
  <activity_id> - activity
  <notify> - user to notify

Expects data on <STDIN>
This script merely uses the data in the spreadsheet report produced by the script;
TempMprMakeIsoTropicCoronalFromAxialStack.pl

To create a coronal volume in the temp_mpr_volume and temp_mpr_slice tables

Refer to that script for more information...

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
my %TempMprVolDesc;
my %TempMprSliceDesc;
line:
while (my $line = <STDIN>){
  chomp $line;
  my($k, $v, $x, $y, $z, $gid, $jid) = split(/&/, $line);
  if($k eq "slice"){
    $TempMprSliceDesc{$y} = {
      gid => $gid,
      jid => $jid,
    };
    next line;
  }
  if(defined($k) && defined($v)){
    $TempMprVolDesc{$k} = $v;
    print STDERR "TempMprVolDesc{$k} = \"$v\"\n";
  } else {
    die "k = $k, v = $v";
  }
}
my @Ys = sort { $b <=> $a } keys %TempMprSliceDesc;
my $VolDesc = $TempMprVolDesc{temp_mpr_volume_description};

my $back = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$back->Daemonize;
my $Tt;
Query('GetTimeTag')->RunQuery(sub{
  my($row) = @_;
  $Tt = $row->[0];
}, sub{});
my $desc = "$Tt - " . $VolDesc;

Query('InsertTempMprVolumeExt')->RunQuery(sub{}, sub{},
  $TempMprVolDesc{temp_mpr_volume_type},
  $TempMprVolDesc{temp_mpr_volume_wc},
  $TempMprVolDesc{temp_mpr_volume_ww},
  $TempMprVolDesc{temp_mpr_volume_position_x},
  $TempMprVolDesc{temp_mpr_volume_position_y},
  $TempMprVolDesc{temp_mpr_volume_position_z},
  $TempMprVolDesc{temp_mpr_volume_rows},
  $TempMprVolDesc{temp_mpr_volume_cols},
  $desc,
  $notify,
  $TempMprVolDesc{row_spc},
  $TempMprVolDesc{col_spc}
);
my $VolId;
Query('GetTempMprVolumeId')->RunQuery(sub{
  my($row) = @_;
  $VolId = $row->[0];
}, sub{}, $desc);
unless(defined $VolId) { die "Didn't find a volume" }
$back->WriteToEmail("Created TempMprVolue: $VolId\n" .
  "Description: $desc\n"
);

my $slice_cq = Query('InsertTempMprSlice');
my $i = 0;
for my $y (@Ys){
  $i += 1;
  my $si = $TempMprSliceDesc{$y};
  $slice_cq->RunQuery(sub{}, sub{},
    $VolId, $y, $si->{gid}, $si->{jid});
}
$back->WriteToEmail("Inserted $i rows into temp_mpr_slice for $VolId\n");
$back->Finish("Done");

#!/usr/bin/perl -w
use strict;
use Posda::Try;
use Posda::BackgroundProcess;
use Debug;
my $dbg = sub {print @_};
my $usage = <<EOF;
AdHocSecondaryCaptureConverter.pl <?bkgrnd_id?> <notify> <source_dir> <dest_dir>
Expects input on STDIN:
<pat_code>&<anon_pat_id>&<uid_root>&<pat_sex>

Does the following:
Builds look up table based on <pat_code>
Finds files under <source_dir>, for each:
  - Parses file name into <pat_code>, <study>, <series>, and <img>
  - Sets study_uid = <uid_root>.<study>
  - Sets series_uid = <study_uid>.<series>
  - Sets sop_uid = <series_uid>.<img>
  - Sets series_number = <series>
  - Sets study_id = "Study_<study>"
  - Delete accession number
  - Set patient_name = patient_id = <anon_pat_id>
  - Set birth_date = ""
  - Set sex = <pat_sex>
  - Set Referring Physician's name = "anonymized"
  = Sets Modality = 'SC'
  - Writes the file (SC_<sop>.dcm) into dest_dir
EOF
unless($#ARGV == 3) {die $usage}
if($#ARGV == 0 && $ARGV[0] eq "-h"){ 
  print $usage; exit;
}
my($invoc_id, $notify, $source, $dest) = @ARGV;
unless(-d $source) {
  print "$source is not a directory\n";
  exit;
}
unless(-d $dest) {
  print "$dest is not a directory\n";
  exit;
}
my %Table;
while(my $line = <STDIN>){
  chomp $line;
  my($pat_code,$pat_id,$uid_root,$pat_sex) = split(/&/, $line);
  $Table{$pat_code} = {
    pat_id => $pat_id,
    uid_root => $uid_root,
    pat_sex => $pat_sex
  }
}
my %Conversions;
open FIND, "find $source -type f |" or die "Can't open find";
while(my $line = <FIND>){
  chomp $line;
  my($pat_code, $study, $series, $img) = FileNameParser($line);
  my $uid_root = $Table{$pat_code}->{uid_root};
  my $pat_id = $Table{$pat_code}->{pat_id};
  my $study_uid = "$uid_root.$study";
  my $series_uid = "$uid_root.$study.$series";
  my $sop_uid = "$uid_root.$study.$series.$img";
  my $study_id = "Study_$study";
  my $sex = $Table{$pat_code}->{pat_sex};
  $Conversions{$line} = {
    set => {
      "(0008,0018)" => $sop_uid,
      "(0020,000d)" => $study_uid,
      "(0020,000e)" => $series_uid,
      "(0020,0011)" => $series,
      "(0020,0010)" => $study_id,
      "(0010,0010)" => $pat_id,
      "(0010,0020)" => $pat_id,
      "(0010,0030)" => "",
      "(0010,0040)" => $sex,
      "(0008,0090)" => "anonymized",
      "(0008,0060)" => "OT",
      '(0013,"CTP",10)' => 'RSNA',
      '(0013,"CTP",11)' => 'RSNA',
      '(0013,"CTP",12)' => 'TCIA',
    },
    delete => [
      "(0008,0050)",
    ],
    dest => "$dest/OT_$sop_uid.dcm",
  };
}
my $num_conversions = keys %Conversions;
print "$num_conversions to perform\n";
print "Going to background\n";
my $back = Posda::BackgroundProcess->new($invoc_id, $notify);
$back->Daemonize;
my $start = time;
$back->WriteToEmail("Starting conversion of $num_conversions files\n");
my $rpt = $back->CreateReport("Conversions");
$rpt->print("from_file,to_file\r\n");
my $num_converted = 0;
from:
for my $from (keys %Conversions){
  my $try = Posda::Try->new($from);
  unless(exists $try->{dataset}) {
    $back->WriteToEmail("couldn't open from file ($from)\n");
    next from;
  }
  my $ds = $try->{dataset};
  for my $set (keys %{$Conversions{$from}->{set}}){
    $ds->Insert($set, $Conversions{$from}->{set}->{$set});
  }
  for my $del (@{$Conversions{$from}->{delete}}){
    $ds->Delete($del);
  }
  $ds->WritePart10($Conversions{$from}->{dest}, $try->{xfr_stx},"POSDA");
  $rpt->print("$from,$Conversions{$from}->{dest}\r\n");
  $num_converted += 1;
}
my $elapsed = time - $start;
$back->WriteToEmail("$num_converted files converted in $elapsed seconds\n");
$back->Finish;
exit;

sub FileNameParser{
  my($fn) = @_;
  unless($fn =~ /.*\/([^\/]*)$/) { die "can't make sense of $fn"}
  $fn = $1;
  my($pat, $study, $series, $img);
  if($fn =~ /^([A-Z][A-Z])(\d+)_(\d+)$/){
    $pat = $1;
    my $stser = $2;
    $img = $3;
    if(length($stser) == 6){
      $stser =~ /(...)(...)/;
      $study = $1;
      $series = $2;
    } elsif(length($stser) == 7){
      $stser =~ /(....)(...)/;
      $study = $1;
      $series = $2;
    }
  } elsif($fn =~ /^([A-Z][A-Z])(\d+)$/){
    $img = 1;
    $pat = $1;
    my $stser = $2;
    if(length($stser) == 6){
      $stser =~ /(...)(...)/;
      $study = $1;
      $series = $2;
    } elsif(length($stser) == 7){
      $stser =~ /(....)(...)/;
      $study = $1;
      $series = $2;
    }
  } else {
    die "can't make sense of $fn";
  }
  $series =~ s/^0+//;
  $img =~ s/^0+//;
  return($pat,$series,$study, $img);
}

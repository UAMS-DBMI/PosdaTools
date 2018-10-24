#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Digest::MD5;
use Posda::BackgroundProcess;
use Posda::DB::PosdaFilesQueries;
use Socket;

my $usage = <<EOF;
PublicPosdaCompareLikeCollection.pl <bkgrnd_id> <collection_pat>  <notify>
or
PublicPosdaCompareLikeCollection.pl -h

The script doesn't expect lines on STDIN:
It generates lists of SOP Uids for a collection on both public and posda
and does a compare of the lists.

In test: reports on differences
EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}
unless($#ARGV == 2){ die "$usage\n"; }

my ($invoc_id, $collections, $notify) = @ARGV;
my $get_posda_counts = PosdaDB::Queries->GetQueryInstance(
  "GetPosdaSopsForCompareLikeCollection");
my $get_public_counts = PosdaDB::Queries->GetQueryInstance(
  "GetPublicSopsForCompareLikeCollection");
my %PosdaHierarchy;
my %PosdaSops;
my %PosdaDup1Sops;
my %PosdaDup2Sops;
my %PosdaMultiDupSops;
my %PublicHierarchy;
my %PublicSops;
$get_posda_counts->RunQuery(sub {
    my($row) = @_;
    my $patient_id = $row->[0];
    my $study_uid = $row->[1];
    my $series_uid = $row->[2];
    my $sop_inst = $row->[3];
    my $sop_class = $row->[4];
    my $modality = $row->[5];
    my $dicom_file_type = $row->[6];
    my $file_path = $row->[7];
    my $file_id = $row->[8];
    my $h = {
       pat_id => $patient_id,
       study_uid => $study_uid,
       series_uid => $series_uid,
       sop_inst => $sop_inst,
       sop_class => $sop_class,
       modality => $modality,
       dicom_file_type => $dicom_file_type,
       file_path => $file_path,
       file_id => $file_id,
    };
    if(exists $PosdaSops{$sop_inst}){
      if(exists $PosdaDup1Sops{$sop_inst}){
        $PosdaDup2Sops{$sop_inst} = $h;
      } else {
        $PosdaDup1Sops{$sop_inst} = $h;
      }
    } else {
      $PosdaSops{$sop_inst} = $h;
      $PosdaHierarchy{$patient_id}->{$study_uid}->{$series_uid}
         ->{$sop_inst} = $PosdaSops{$sop_inst};
    }
  }, sub {},
  $ARGV[1]
);
$get_public_counts->RunQuery(sub {
    my($row) = @_;
    my $patient_id = $row->[0];
    my $study_uid = $row->[1];
    my $series_uid = $row->[2];
    my $sop_inst = $row->[3];
    my $sop_class = $row->[4];
    my $modality = $row->[5];
    my $dicom_file_uri = $row->[6];
    $dicom_file_uri =~ s/^.*\/storage/\/nas\/public\/storage/;
    $PublicSops{$sop_inst} = {
       pat_id => $patient_id,
       study_uid => $study_uid,
       series_uid => $series_uid,
       sop_inst => $sop_inst,
       sop_class => $sop_class,
       modality => $modality,
       file_path => $dicom_file_uri,
    };
    $PublicHierarchy{$patient_id}->{$study_uid}->{$series_uid}
       ->{$sop_inst} = $PublicSops{$sop_inst};
  }, sub {},
  $ARGV[1]
);
my %OnlyInPosda;
my %OnlyInPublic;
my %InBoth;
for my $sop (keys %PosdaSops){
  unless(exists $PublicSops{$sop}) { $OnlyInPosda{$sop} = 1 }
  else { $InBoth{$sop} = 1 }
}
for my $sop (keys %PublicSops){
  unless(exists $PosdaSops{$sop}) { $OnlyInPublic{$sop} = 1 }
}
#### Here to generate more report data
my %DifferentBetweenPosdaAndPublic;
my %InPosdaBySeries;
my %InPublicBySeries;
for my $sop (keys %InBoth){
  my $posda_series = $PosdaSops{$sop}->{series_uid};
  my $public_series = $PublicSops{$sop}->{series_uid};
  if($posda_series ne $public_series){
    $DifferentBetweenPosdaAndPublic{$posda_series}->{$public_series}->{$sop}
      = 1;
  } else {
    if(exists $PosdaSops{$sop}) {$InPosdaBySeries{$posda_series}->{$sop} = 1}
    if(exists $PublicSops{$sop}) {$InPublicBySeries{$posda_series}->{$sop} = 1}
  }
}
my %SeriesOnlyInPosda;
my %SeriesOnlyInPublic;
for my $sop (keys %OnlyInPosda){
  my $series = $PosdaSops{$sop}->{series_uid};
  $SeriesOnlyInPosda{$series} = 1;
}
for my $sop (keys %OnlyInPublic){
  my $series = $PublicSops{$sop}->{series_uid};
  $SeriesOnlyInPublic{$series} = 1;
}
my %SeriesSameInPosdaAndPublic;
my %SeriesDifferentInPosdaAndPublic;
series:
for my $series(keys %InPosdaBySeries){
  my $same = 1;
  diff_check:
  for my $sop (keys %{$InPosdaBySeries{$series}}){
    unless(exists $InPublicBySeries{$series}->{$sop}){
      $same = 0;
    }
  }
  for my $sop (keys %{$InPublicBySeries{$series}}){
    unless(exists $InPosdaBySeries{$series}->{$sop}){
      $same = 0;
    }
  }
  if($same){
    $SeriesSameInPosdaAndPublic{$series} = 1;
  } else {
    $SeriesDifferentInPosdaAndPublic{$series} = 1;
  }
}
######
my $total_in_posda = keys %PosdaSops;
my $total_in_public = keys %PublicSops;
my $only_in_posda = keys %OnlyInPosda;
my $only_in_public = keys %OnlyInPublic;
my $dup_sops_in_posda = keys %PosdaDup1Sops;
my $series_only_in_posda = keys %SeriesOnlyInPosda;
my $series_only_in_public = keys %SeriesOnlyInPublic;
my $posda_series_with_different_public_series = 
  keys %DifferentBetweenPosdaAndPublic;
my $series_same_in_both = keys %SeriesSameInPosdaAndPublic;
my $series_different_in_both = keys %SeriesDifferentInPosdaAndPublic;
print "Total in Posda:                $total_in_posda\n" .
      "Total in Public:               $total_in_public\n" .
      "Only in Posda:                 $only_in_posda\n" .
      "Only in Public:                $only_in_public\n" .
      "Dup Sops in Posda:             $dup_sops_in_posda\n" .
      "Series Only in Posda:          $series_only_in_posda\n" .
      "Series Only in Public          $series_only_in_public\n" .
      "In Posda with \n" .
      "  Different Series in Public:  " . 
      "$posda_series_with_different_public_series\n" .
      "Series Same in both:           $series_same_in_both\n" .
      "Series Different  in both:     $series_different_in_both\n\n\n";
my %BySop;
for my $i (keys %OnlyInPosda){
  my $h = $PosdaSops{$i};
  my $sop_desc = $h->{dicom_file_type};
  unless(exists $BySop{$sop_desc}) { $BySop{$sop_desc} = 0 }
  $BySop{$sop_desc} += 1;
}
print "Number of Sops in Posda but not in Public:\n";
for my $sop (keys %BySop){
  print "$BySop{$sop}:   $sop\n";
}
if($posda_series_with_different_public_series > 0){
  print "\n\nSops in Different Series in Posda/Public:\n";
  for my $posda_series (keys %DifferentBetweenPosdaAndPublic){
    for my $public_series (
      keys %{$DifferentBetweenPosdaAndPublic{$posda_series}}
    ){
      my $count = keys
        %{$DifferentBetweenPosdaAndPublic{$posda_series}->{$public_series}};
      print "Posda: $posda_series\n";
      print "Public $public_series\n";
      print "Files: $count\n";
    }
  }
}

my $background = Posda::BackgroundProcess->new($invoc_id, $notify);

print "Entering Background\n";

$background->Daemonize;
my $bk_id = $background->GetBackgroundID;
my $start_time = `date`;
chomp $start_time;
$background->WriteToEmail("Starting Public/Posda Comparison at $start_time\n");
$background->WriteToEmail("BackgroundProcess Id: $bk_id\n");
close STDOUT;
close STDIN;
#####################
#  Columns: Only In Posda|Only In Public|In Posda With Dups In Public|
#     In Public With Dups in Posda|In Both With Different SOPS
my $rpt = $background->CreateReport("Series Difference Summary");
$rpt->print("\"Only In Posda\",\"Only In Public\"," .
  "\"In Posda With Dups In Public\",\"In Public With Dups in Posda\"," .
  "\"In Both With Different SOPS\"\n");
my @OnlyInPosda = keys %SeriesOnlyInPosda;
my @OnlyInPublic = keys %SeriesOnlyInPublic;
my @PosdaDups;
my @PublicDups;
if($posda_series_with_different_public_series > 0){
  for my $posda_series (keys %DifferentBetweenPosdaAndPublic){
    for my $public_series (
      keys %{$DifferentBetweenPosdaAndPublic{$posda_series}}
    ){
      my $count = keys
        %{$DifferentBetweenPosdaAndPublic{$posda_series}->{$public_series}};
      push(@PosdaDups, $posda_series);
      push(@PublicDups, $public_series);
    }
  }
}
my @DiffInBoth = keys %SeriesDifferentInPosdaAndPublic;
while(
  $#OnlyInPosda >= 0 ||
  $#OnlyInPublic >= 0 ||
  $#PosdaDups >= 0 ||
  $#PublicDups >= 0 ||
  $#DiffInBoth >= 0
){
  my $only_posda = shift @OnlyInPosda;
  my $only_public = shift @OnlyInPublic;
  my $posda_dup = shift @PosdaDups;
  my $public_dup = shift @PublicDups;
  my $diff = shift @DiffInBoth;
  $rpt->print("$only_posda,$only_public,$posda_dup,$public_dup,$diff\n");
}
#####################
$background->Finish;

#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Digest::MD5;
use Posda::BackgroundProcess;
use Posda::ActivityInfo;
use Debug;

my $usage = <<EOF;
CompareSopsTpPosdaPublicLikeEq.pl <?bkgrnd_id?> "<collection_like>" "<site>" <activity_id> <notify>
or
CompareSopsTpPosdaPublicLikeEq.pl -h

The script doesn't expect lines on STDIN:

In test: reports on differences
EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}
unless($#ARGV == 4){ die "$usage\n"; }

my ($invoc_id, $collection, $site, $activity_id, $notify) = @ARGV;
sub MapTp{
  my($hash) = @_;
  my %mapped;
  $mapped{pat_id} = $hash->{patient_id};
  $mapped{study_uid} = $hash->{study_instance_uid};
  $mapped{series_uid} = $hash->{series_instance_uid};
  $mapped{sop_inst} = $hash->{sop_instance_uid};
  $mapped{sop_class} = $hash->{sop_class_uid};
  $mapped{modality} = $hash->{modality};
  $mapped{file_path} = $hash->{file_path};
  $mapped{dicom_file_type} = $hash->{dicom_file_type};
  $mapped{file_id} = $hash->{file_id};
  return \%mapped;
}
sub MakeHierarchy{
  my($hash) = @_;
  my $num_sops = keys %$hash;
  if($num_sops <= 0) { return undef }
  my %hier;
  for my $sop (keys %$hash){
    my $rec = $hash->{$sop};
    my $pat_id = $rec->{pat_id};
    my $study_uid = $rec->{study_uid};
    my $series_uid = $rec->{series_uid};
    $hier{$pat_id}->{$study_uid}->{$series_uid}
      ->{$sop} = $rec;
  }
  return \%hier;
}
sub MakeCondensedHierarchy{
  my($hash) = @_;
  my $num_sops = keys %$hash;
  if($num_sops <= 0) { return undef }
  my %hier;
  for my $sop (keys %$hash){
    my $rec = $hash->{$sop};
    my $pat_id = $rec->{pat_id};
    my $study_uid = $rec->{study_uid};
    my $series_uid = $rec->{series_uid};
    $hier{$pat_id}->{studies}->{$study_uid} = 1;
    $hier{$pat_id}->{series}->{$series_uid} = 1;
    $hier{$pat_id}->{sops}->{$sop} = $rec;
  }
  return \%hier;
}
print "script: $0\n";
print "going to background to collect and analyze data\n";
my $back = Posda::BackgroundProcess->new($invoc_id, $notify);
$back->Daemonize;
################### Data To Collect ######################
my $get_posda_counts = Query("GetPosdaSopsForCompareLikeCollectionForSite");
my $get_public_counts = Query("GetPublicSopsForCompareLikeCollection");
my $now = `date`;
chomp $now;
my $start = time;
$back->WriteToEmail("script: $0\n");
$back->WriteToEmail("collecton $collection\n");
$back->WriteToEmail("site $site\n");
$back->WriteToEmail("activity_id $activity_id\n");
$back->WriteToEmail("at: $now\n");
$back->WriteToEmail("by $notify\n\n");
my %PosdaSops;
my %PosdaDup1Sops;
my %PosdaDup2Sops;
my %PosdaMultiDupSops;
my %PublicSops;
my %TpSops;
my %TpDup1Sops;
my %TpDup2Sops;
my %TpMultiDupSops;
my %TpSopsNotInCollection;

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
        if(exists $PosdaDup2Sops{$sop_inst}){
          unless(exists $PosdaMultiDupSops{$sop_inst}){
            $PosdaMultiDupSops{$sop_inst} = [];;
          }
          push @{$PosdaMultiDupSops{$sop_inst}}, $h;
        } else {
          $PosdaDup2Sops{$sop_inst} = $h;
        }
      } else {
        $PosdaDup1Sops{$sop_inst} = $h;
      }
    } else {
      $PosdaSops{$sop_inst} = $h;
    }
  }, sub {},
  $collection, $site
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
  }, sub {},
  $collection
);
my $ActInfo = Posda::ActivityInfo->new($activity_id);
my $tp_id = $ActInfo->LatestTimepoint;
$back->WriteToEmail("activity: $activity_id, tp_id: $tp_id\n");
my $TpFileInfo = $ActInfo->GetFileInfoForTp($tp_id);
file:
for my $file_id (keys %$TpFileInfo){
  my $hash = $TpFileInfo->{$file_id};
  my $mapped = MapTp($hash);
  my $sop_inst = $mapped->{sop_inst};
#  my $coll = $hash->{collection};
#  if($coll ne $collection){
#    $TpSopsNotInCollection{$sop_inst} = $mapped;
#    next file;
#  }
  if(exists $TpSops{$sop_inst}){
    if(exists $TpDup1Sops{$sop_inst}){
      if(exists $TpDup2Sops{$sop_inst}){
        unless(exists $TpMultiDupSops{$sop_inst}){
          $TpMultiDupSops{$sop_inst} = [];
        }
        push @{$TpMultiDupSops{$sop_inst}}, $mapped;
      } else {
        $TpDup2Sops{$sop_inst} = $mapped;
      }
    } else {
      $TpDup1Sops{$sop_inst} = $mapped;
    }
    next file;
  }
  $TpSops{$sop_inst} = $mapped;
}
my $collection_complete = time;
my $collection_time = $collection_complete - $start;
$back->WriteToEmail("collection of data took " .
  "$collection_time seconds\n");
######################################################
my $num_in_public = keys %PublicSops;
$back->WriteToEmail("$num_in_public sops in public\n");
my $num_in_tp = keys %TpSops;
$back->WriteToEmail("$num_in_tp sops in tp\n");
my $num_in_posda = keys %PosdaSops;
$back->WriteToEmail("$num_in_posda sops in posda\n");
#######################################################
# To compute:
my %SopsInPosdaNotInTpOrPublic;
my %SopsInTpAndPublic;
my %SopsInTpAndNotInPublic;
for my $sop(keys %PosdaSops){
  if(
    (!(exists $TpSops{$sop})) &&
    (!(exists $PublicSops{$sop}))
  ){
     $SopsInPosdaNotInTpOrPublic{$sop} = 
       $PosdaSops{$sop};
  }  
}
for my $sop(keys %TpSops){
  if(exists $PublicSops{$sop}){
    $SopsInTpAndPublic{$sop} = $TpSops{$sop};
  } else {
    $SopsInTpAndNotInPublic{$sop} = $TpSops{$sop};
  }
}
my $InPosdaNotInTpOrPublicHierarchy
  = MakeHierarchy(\%SopsInPosdaNotInTpOrPublic);
my $CondensedInPosdaNotInTpOrPublicHierarchy
  = MakeCondensedHierarchy(\%SopsInPosdaNotInTpOrPublic);
my $InTpAndPublicHierarchy
  = MakeHierarchy(\%SopsInTpAndPublic);
my $CondensedInTpAndPublicHierarchy
  = MakeCondensedHierarchy(\%SopsInTpAndPublic);
my $InTpAndNotInPublicHierarchy
  = MakeHierarchy(\%SopsInTpAndNotInPublic);
my $CondensedInTpAndNotInPublicHierarchy
  = MakeCondensedHierarchy(\%SopsInTpAndNotInPublic);
my $analysis_complete = time;
my $analysis_time = $analysis_complete - $collection_complete;
$back->WriteToEmail("Analysis of data took " .
  "$analysis_time seconds\n");

if(defined $InPosdaNotInTpOrPublicHierarchy){
  my $rpt1 = $back->CreateReport("In Posda, Not In Timepoint Or Public");
  PrintHierarchy($rpt1, [
    "Files In Posda, But Not In Timepoint Or Public",
    "",
    ["script", $0],
    ["collection", $collection],
    ["site", $site],
    ["activity_id", $activity_id],
    ["at", $now],
    ["by", $notify],
    "",
  ], $InPosdaNotInTpOrPublicHierarchy);
  my $rpt05 = $back->CreateReport(
    "Condensed In Posda, Not In Timepoint or Public");
  PrintCondensedHierarchy($rpt05, [
    "Condensed Files In Posda, But Not In Timepoint Or Public",
    "",
    ["script", $0],
    ["collection", $collection],
    ["site", $site],
    ["activity_id", $activity_id],
    ["at", $now],
    ["by", $notify],
    "",
  ], $CondensedInPosdaNotInTpOrPublicHierarchy);
} else {
  $back->WriteToEmail("No files In Posda But Not " .
    "In Timepoint Or Public\n");
}

if(defined $InTpAndPublicHierarchy){
  my $rpt2 = $back->CreateReport("In Both Tp And Public");
  PrintHierarchy($rpt2, [
    "Files In Posda, Timepoint And Public",
    "",
    ["script", $0],
    ["collection", $collection],
    ["site", $site],
    ["activity_id", $activity_id],
    ["at", $now],
    ["by", $notify],
    "",
  ], $InTpAndPublicHierarchy);
  my $rpt25 = $back->CreateReport("Condensed In Both Tp And Public");
  PrintCondensedHierarchy($rpt25, [
    "Condensed Files In Posda, Timepoint And Public",
    "",
    ["script", $0],
    ["collection", $collection],
    ["site", $site],
    ["activity_id", $activity_id],
    ["at", $now],
    ["by", $notify],
    "",
  ], $CondensedInTpAndPublicHierarchy);
} else {
  $back->WriteToEmail(
    "No files In Both Tp And Public\n");
}

if(defined $InTpAndNotInPublicHierarchy){
  my $dbg = sub {
    my($text) = @_;
    $back->WriteToEmail($text);
  };
#  $back->WriteToEmail("InTpAndNotInPublicHierarchy: ");
#  Debug::GenPrint($dbg, $InTpAndNotInPublicHierarchy, 1);
#  $back->WriteToEmail("\n");
  my $rpt3 = $back->CreateReport("In Tp And Not In Public");
  PrintHierarchy($rpt3, [
    "Files In Timepoint And Not inPublic",
    "",
    ["script", $0],
    ["collection", $collection],
    ["site", $site],
    ["activity_id", $activity_id],
    ["at", $now],
    ["by", $notify],
    "",
  ], $InTpAndNotInPublicHierarchy);
#  $back->WriteToEmail("CondensedInTpAndNotInPublicHierarchy: ");
#  Debug::GenPrint($dbg, $CondensedInTpAndNotInPublicHierarchy, 1);
#  $back->WriteToEmail("\n");
  my $rpt35 = $back->CreateReport("Condensed In Tp And Not In Public");
  PrintCondensedHierarchy($rpt35, [
    "Condensed Files In Timepoint And Not inPublic",
    "",
    ["script", $0],
    ["collection", $collection],
    ["site", $site],
    ["activity_id", $activity_id],
    ["at", $now],
    ["by", $notify],
    "",
  ], $CondensedInTpAndNotInPublicHierarchy);
} else {
  $back->WriteToEmail(
    "No Files In Timepoint And Not In Public\n");
}

#my %PosdaSops;
#my %PosdaDup1Sops;
#my %PosdaDup2Sops;
#my %PosdaMultiDupSops;
#my %PublicSops;
#my %TpSops;
#my %TpDup1Sops;
#my %TpDup2Sops;
#my %TpMultiDupSops;
#my %TpSopsNotInCollection;

#######################################################
$back->Finish;
sub PrintHierarchy{
  my($rpt, $list, $hier) = @_;
  for my $i (@$list){
    if(ref($i) eq "ARRAY"){
      for my $j (0 ..$#{$i}){
        my $t = $i->[$j];
        $t =~ s/\"/\"\"/g;
        $rpt->print("\"$t\"");
        unless($j == $#{$i}){ $rpt->print(",") }
      }
      $rpt->print("\r\n");
    } else {
      $rpt->print("$i\r\n")
    }
  }
  $rpt->print("pat_id,study_uid,series_uid,num_sops\r\n");
  for my $pat_id (keys %$hier){ 
    for my $study_uid (keys %{$hier->{$pat_id}}){
      for my $series_uid (keys %{$hier->{$pat_id}->{$study_uid}}){
        my $h = $hier->{$pat_id}->{$study_uid}->{$series_uid};
        my $num_sops = "???";
        if(ref($h) eq "HASH"){ $num_sops = keys %$h }
        $rpt->print("$pat_id,$study_uid,$series_uid,$num_sops\r\n");
      }
    }
  }
}
sub PrintCondensedHierarchy{
  my($rpt, $list, $hier) = @_;
  my $dbg;
  for my $i (@$list){
    if(ref($i) eq "ARRAY"){
      for my $j (0 ..$#{$i}){
        my $t = $i->[$j];
        $t =~ s/\"/\"\"/g;
        $rpt->print("\"$t\"");
        unless($j == $#{$i}){ $rpt->print(",") }
      }
      $rpt->print("\r\n");
    } else {
      $rpt->print("$i\r\n")
    }
  }
  $rpt->print("pat_id,num_studies,num_series,num_sops\r\n");
  my @patients = keys %$hier;
  my $num_pats = @patients;
  for my $pat_id (keys %$hier){ 
    my $num_studies = keys %{$hier->{$pat_id}->{studies}};
    my $num_series = keys %{$hier->{$pat_id}->{series}};
    my $num_sops = keys %{$hier->{$pat_id}->{sops}};
    $rpt->print("$pat_id,$num_studies,$num_series,$num_sops\n");
  }
}

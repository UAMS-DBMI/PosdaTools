#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/TciaCuration/bin/AnalyzeExtractedQuarantines.pl,v $
#$Date: 2015/03/13 21:33:51 $
#$Revision: 1.1 $
#
use strict;
use Storable;
use Posda::FileCollectionAnalysis;
my $source_bom = $ARGV[0];
unless(-f $source_bom) { die "No source bom: $source_bom" }
unless($source_bom =~ /^(.*)\/([^\/]+)$/){
  die "can't extract filename from $source_bom";
}
my $bom_dir = $1;
my $consistency_file = "$bom_dir/consistency.pinfo";
my $hierarchy_file = "$bom_dir/hierarchy.pinfo";
my $error_file = "$bom_dir/error.pinfo";
my $bom = Storable::retrieve($source_bom);
my $analysis = Posda::FileCollectionAnalysis->new;
for my $file (keys %{$bom->{FilesToDigest}}){
  my $dig = $bom->{FilesToDigest}->{$file};
  my $f_info = $bom->{FilesByDigest}->{$dig};
  $analysis->Analyze($file, $f_info);
}
$analysis->ConsistencyErrors;
$analysis->ImageNumberErrors;
$analysis->StructureSetLinkages;
$analysis->BuildNewHierarchy;
############### debug only ###############
my $raw_analysis_file = "$bom_dir/FileCollectionAnalysis.pinfo";
Storable::store($analysis, $raw_analysis_file);
##########################################
my $error_info = $analysis->{errors};
my $hierarchy = $analysis->{NewHierarchy};
my $consistency_info = {
  series_consistency => $analysis->{series_consistency},
  study_consistency => $analysis->{study_consistency},
  patient_consistency => $analysis->{patient_consistency},
  seuid_to_index => $analysis->{seuid_to_index},
  seuid_from_index => $analysis->{seuid_from_index},
  stuid_to_index => $analysis->{stuid_to_index},
  stuid_from_index => $analysis->{stuid_from_index},
};
Storable::store($consistency_info, $consistency_file);
Storable::store($hierarchy, $hierarchy_file);
if(ref($error_info) eq "ARRAY" && $#{$error_info} >= 0){
  Storable::store($error_info, $error_file);
}

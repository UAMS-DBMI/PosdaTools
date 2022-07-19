#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::StructFixer;
use Posda::Try;
use Debug;
my $dbg = sub {print @_ };

my $series_instance_uid = $ARGV[0];
my $struct_file_id = $ARGV[1];
my $new_file = $ARGV[2];
my $act_id = $ARGV[3];

my $StructSetFile;
my $Gfp = Query("GetFilePath");
$Gfp->RunQuery(sub{
  my($row) = @_;
  $StructSetFile = $row->[0];
}, sub{}, $struct_file_id);
my %Info;
Query("SeriesReportForStructLinkageTestTp")->RunQuery(sub {
  my($row) = @_;
  my($file_id, $file_name, $sop_instance_uid,
    $sop_class_uid, $study_instance_uid, $series_instance_uid,
    $for_uid, $iop, $ipp) = @$row;
  if(exists $Info{$sop_instance_uid}){
    die "Duplicate sop ($sop_instance_uid) in " .
      "series $series_instance_uid"; 
  }  
  $Info{$sop_instance_uid} =  {
     iop => $iop,
     ipp => $ipp,
     study_uid => $study_instance_uid,
     series_uid => $series_instance_uid,
     sop_class_uid => $sop_class_uid,
     study_instance_uid => $study_instance_uid,
     for_uid => $for_uid,
     file_id => $file_id,
     file => $file_name
  };
}, sub{}, $series_instance_uid);
my $fixer = Posda::StructFixer->new(\%Info);
my $try = Posda::Try->new($StructSetFile);
unless(exists $try->{dataset}){
  die "$StructSetFile didn't parse";
}
my $linked = $fixer->LinkStructSet($try->{dataset});
if($linked) { 
  $try->{dataset}->WritePart10($new_file, $try->{xfr_stx},
    "POSDA", undef, undef);
  print "Linked: $new_file\n";
  for my $i (@{$fixer->{link_record}}){
    print "$i\n";
  }
} else { print "Not linked\n" }
if(exists $fixer->{errors}){
  for my $i (keys %{$fixer->{errors}}){
    print "Error: $i\n";
  }
}

#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
my $usage = <<EOF;
CompareTimepoints.pl <?bkgrnd_id?> <activity_id> <from_timepoint_id> <to_timepoint_id> <notify>
or 
CompareTimepoints.pl -h

Expects no input on STDIN
EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage; exit;
}
unless($#ARGV == 4){
  my $num_args = @ARGV;
  print "Wrong number of args ($num_args vs 5)\n";
  print $usage;
  exit;
}
my($invoc_id, $act_id, $from_tp, $to_tp, $notify) = @ARGV;
print "Going to background to compare time points for activity $act_id\n" ,
  "from:   $from_tp\n" .
  "  to:   $to_tp\n" .
  "notify: $notify\n";
my $back = Posda::BackgroundProcess->new($invoc_id, $notify);
$back->Daemonize;
$back->WriteToEmail("In background to compare time points for activity $act_id\n" ,
  "from:   $from_tp\n" .
  "  to:   $to_tp\n" .
  "notify: $notify\n");
my %AllFiles;
my %FromFiles;
Query("FilesSeriesSopsVisibilityInTimepoint")->RunQuery(sub {
  my($row) = @_;
  my($file_id, $pat_id, $stdy_id, $ser_id, $sop, 
    $coll, $site, $vis, $mod, $type) = @$row;
  unless(defined $vis) { $vis = "<undef>" }
  $AllFiles{$file_id} = {
    patient_id => $pat_id,
    study_instance_uid => $stdy_id,
    series_instance_uid => $ser_id,
    sop_instance_uid => $sop,
    visibility => $vis,
    collection => $coll,
    site => $site,
    modality => $mod,
    type => $type,
  };
  $FromFiles{$file_id} = 1;
},sub{}, $from_tp);
my $num_in_from = keys %FromFiles;
$back->WriteToEmail("$num_in_from files in from timepoint ($from_tp)\n");
my %ToFiles;
Query("FilesSeriesSopsVisibilityInTimepoint")->RunQuery(sub {
  my($row) = @_;
  my($file_id, $pat_id, $stdy_id, $ser_id, $sop,
    $coll, $site,  $vis, $mod, $type) = @$row;
  unless(defined $vis) { $vis = "<undef>" }
  unless(exists $AllFiles{$file_id}){
    $AllFiles{$file_id} = {
      patient_id => $pat_id,
      study_instance_uid => $stdy_id,
      series_instance_uid => $ser_id,
      sop_instance_uid => $sop,
      visibility => $vis,
      collection => $coll,
      site => $site,
      modality => $mod,
      type => $type,
    };
  }
  $ToFiles{$file_id} = 1;
},sub{}, $to_tp);
my $num_in_to = keys %ToFiles;
$back->WriteToEmail("$num_in_to files in to timepoint ($to_tp)\n");
my %FilesOnlyInFrom;
my %FilesOnlyInTo;
my %FilesInBoth;
for my $i (keys %ToFiles){
  if(exists $FromFiles{$i}){
    $FilesInBoth{$i} = 1;
  } else {
    $FilesOnlyInTo{$i} = 1;
  }
}
for my $i (keys %FromFiles){
  unless(exists $ToFiles{$i}){
    $FilesOnlyInFrom{$i} = 1;
  }
}
my $num_in_both = keys %FilesInBoth;
my $num_only_in_from = keys %FilesOnlyInFrom;
my $num_only_in_to = keys %FilesOnlyInTo;
$back->WriteToEmail("$num_in_both files in both\n");
$back->WriteToEmail("$num_only_in_from files only in from\n");
$back->WriteToEmail("$num_only_in_to files only in to\n");
MakeReport($back, "Files In From", \%FromFiles);
MakeReport($back, "Files In To", \%ToFiles);
MakeReport($back, "Files Only In From", \%FilesOnlyInFrom);
MakeReport($back, "Files Only In To", \%FilesOnlyInTo);
MakeReport($back, "Files In Both", \%FilesInBoth);
$back->Finish;
sub MakeReport{
  my($back, $name, $files) = @_;
  my $rpt = $back->CreateReport($name);
  $rpt->print("$name\n");
  $rpt->print("collection,site,patient,num_studies," .
    "num_series,num_type,num_modalities,num_sops," .
    "num_visible,num_hidden\n");
  my %hier;
  for my $f (keys %$files){
    unless(exists $hier{$f}){ $hier{$f} = {} }
    my $info = $AllFiles{$f};
    my $collection = $info->{collection};
    my $site = $info->{site};
    my $pat = $info->{patient_id};
    my $study = $info->{study_instance_uid};
    my $series = $info->{series_instance_uid};
    my $sop = $info->{sop_instance_uid};
    my $vis = $info->{visibility};
    my $mod = $info->{modality};
    my $type = $info->{type};
    unless(exists($hier{$collection})) { $hier{collection} = {} }
    unless(exists($hier{$collection}->{$site})) { $hier{$collection}->{site} = {} }
    unless(exists($hier{$collection}->{$site}->{$pat})) { $hier{$collection}->{$site}->{$pat} = {} }
    my $h1 = $hier{$collection}->{$site}->{$pat};
    unless(exists($h1->{studies})) { $h1->{studies} = {} }
    unless(exists($h1->{series})) { $h1->{series} = {} }
    unless(exists($h1->{sops})) { $h1->{sops} = {} }
    unless(exists($h1->{mod})) { $h1->{mod} = {} }
    unless(exists($h1->{vis})) { $h1->{vis} = {} }
    unless(exists($h1->{type})) { $h1->{type} = {} }
    $h1->{studies}->{$study} = 1;
    $h1->{series}->{$series} = 1;
    $h1->{sops}->{$sop} = 1;
    $h1->{mod}->{$mod} = 1;
    $h1->{type}->{$type} = 1;
    unless(exists $h1->{vis}->{$vis}) { $h1->{vis}->{$vis} = 0 }
    $h1->{vis}->{$vis} += 1;
  }
  for my $col (keys %hier){
    for my $site (keys %{$hier{$col}}){
      for my $pat (keys %{$hier{$col}->{$site}}){
        my $h = $hier{$col}->{$site}->{$pat};
        my $num_studies = keys %{$h->{studies}};
        my $num_series = keys %{$h->{series}};
        my $num_sops = keys %{$h->{sops}};
        my $num_types = keys %{$h->{type}};
        my $num_mods = keys %{$h->{mod}};
        my $num_vis = $h->{vis}->{"<undef>"};
        my $num_hidden = $h->{vis}->{hidden};
        unless(defined $num_vis) { $num_vis = 0 }
        unless(defined $num_hidden) { $num_hidden = 0 }
        $rpt->print("$col,$site,\"$pat\",$num_studies," .
          "$num_series,$num_types,$num_mods,$num_sops," .
          "$num_vis,$num_hidden\n");
      }
    }
  }
}

#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use File::Basename;
use Debug;
my $dbg = sub { print STDERR @_ };

my $usage = <<EOF;
Usage:
BackgroundConvertSeriesInTpToNifti.pl <?bkgrnd_id?> <activity_id> <notify>
  or
BackgroundConvertSeriesInTpToNifti.pl -h

Expects lines on STDIN:
<series_instance_uid>

EOF


if($#ARGV == 0 && $ARGV[0] eq "-h"){ print $usage; exit }

unless($#ARGV == 2) { print $usage; exit }


my($invoc_id, $activity_id, $notify) = @ARGV;

my $num_lines = 0;
my %Series;
while (my $line = <STDIN>){
  chomp $line;
  $Series{$line} = 1;
  $num_lines += 1;
}
my $num_series = keys %Series;
print STDOUT "Read $num_lines from STDIN\nFound $num_series series\n";

my $back = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$back->Daemonize;
my $cache_dir = $ENV{POSDA_CACHE_ROOT};
unless(-d $cache_dir){
  print "Error: Cache dir ($cache_dir) isn't a directory\n";
  exit;
}
unless(-d "$cache_dir/WorkerTemp"){
  mkdir "$cache_dir/WorkerTemp";
}
unless(-d "$cache_dir/WorkerTemp"){
  print "Error: Cache dir ($cache_dir) isn't a directory\n";
  exit;
}

my $dir = "$cache_dir/WorkerTemp/$invoc_id";
if(-d $dir) {
  print "Error: $dir already exists\n";
  exit;
}
unless(mkdir($dir) == 1) {
  print "Error ($!): couldn't mkdir $dir\n";
  exit;
}

my $start = time;
my $count = 0;
my $dicom_to_nifti_conversion_id = CreateDicomToNiftConversionTable($invoc_id, $activity_id);
series:
for my $series (sort {$a cmp $b} keys %Series){
  $count += 1;
  $back->SetActivityStatus("Processing $series ($count of $num_series) in $dir");
  my %FilesInSeries;
  Query('GetFilesInSeriesAndActivity')->RunQuery(sub{
    my($row) = @_;
    my $file_id = $row->[0];
    Query('GetFileInfoForSeriesReportWithType')->RunQuery(sub{
      my($row) = @_;
      $FilesInSeries{$series}->{$row->[0]} = {
        sop_instance_uid => $row->[1],
        series_instance_uid => $row->[2],
        series_date => $row->[3],
        study_instance_uid => $row->[4],
        study_date => $row->[5],
        instance_number => $row->[6],
        patient_id => $row->[7],
        modality => $row->[8],
        dicom_file_type => $row->[9],
        for_uid => $row->[10],
        iop => $row->[11],
        ipp => $row->[12],
        pixel_data_digest => $row->[13],
        pixel_rows => $row->[14],
        pixel_cols => $row->[15],
        pixel_spacing => $row->[16],
        image_type => $row->[17],
      };
    }, sub{}, $file_id)
  }, sub {}, $series, $activity_id);
  my($ListOfFiles, $SelectionNotes, $the_iop, $modality, $dicom_file_type) = SelectFilesFromSeries(\%{$FilesInSeries{$series}});
  unless(ref($ListOfFiles) eq "ARRAY" && $#{$ListOfFiles} >= 0){
    my $nifti_file_from_series_id = CreateNonConversionNiftiFileFromSeriesRow($dicom_to_nifti_conversion_id,
      $series, keys(%{$FilesInSeries{$series}}));
    AddNiftiConversionNotes($nifti_file_from_series_id, $SelectionNotes);
    print STDERR "############\nUnable to select files from series ($series):\n";
    for my $i (@$SelectionNotes){
      print STDERR "\t$i\n";
    }
    next series;
  }
  my $num_selected = @$ListOfFiles;
  my $first_file = $ListOfFiles->[0];
  my $first_ipp = $FilesInSeries{$series}->{$first_file}->{ipp};
  my $last_file = $ListOfFiles->[0];
  my $last_ipp = $FilesInSeries{$series}->{$last_file}->{ipp};
  my $num_in_series = keys %{$FilesInSeries{$series}};
  my $nifti_file_from_series_id = CreateConversionNiftiFileFromSeriesRow(
    $dicom_to_nifti_conversion_id, $series, $num_in_series, $num_selected,
    $modality, $dicom_file_type, $the_iop, $first_ipp, $last_ipp);
  );
  AddNiftiConversionNotes($nifti_file_from_series_id, $SelectionNotes);
  my $series_dir = "$dir/$series";
  unless(mkdir($series_dir)){
    die "Cannot create series dir $series_dir ($!0)";
  }
  my $input_dir = "$series_dir/input";
  unless(mkdir($input_dir)){
    die "Cannot create input dir $input_dir ($!0)";
  }
  my $get_path = Query('GetFilePath');
  print STDERR "############\nFor series $series:\n";
  print STDERR "Selected $num_selected of $num_in_series, modality = $modality, " .
    "dicom_file_type = $dicom_file_type\n";
  for my $i (@$SelectionNotes){
    print STDERR "\t$i\n";
  }
  for my $file_id (@$ListOfFiles){
    my $path;
    $get_path->RunQuery(sub {
      my($row) = @_;
      $path = $row->[0];
    }, sub {}, $file_id);
    if(defined $path){
      my $f_name = "$input_dir/" . 
        sprintf("%05d", $FilesInSeries{$series}->{$file_id}->{instance_number}) .
           ".dcm";
      symlink $path, $f_name;
    }
  }
  my $output_dir = "$series_dir/output";
  unless(mkdir($output_dir)){
    die "Cannot create output dir $output_dir ($!0)";
  }
  my $cmd = "dcm2niix -o $output_dir -a y -m yes $input_dir";
  my @foo = `$cmd`;
  my @warnings;
  my $num_found;
  my $num_converted;
  my $conv_file;
  my $conv_rows;
  my $conv_cols;
  my $conv_slices;
  my $conv_vols;
  my $gantry_tilt_spec;
  my $gantry_tilt_est;
  my $conversion_time;
  my $conversion_core_time;
  for my $line (@foo){
    chomp $line;
    if($line =~ /^Chris/) { next }
    if($line =~ /^Warning: (.*)$/){
      push @warnings, $1;
      next;
    }
    if($line =~ /^Found\s*(\d+)\s*DICOM/){
      $num_found = $1;
      next;
    }
    if($line =~ /^Convert.*DICOM as/){
      my($ig1, $di, $as, $conv_spec);
      ($ig1, $num_converted, $di, $as, $conv_file, $conv_spec) = split(/\s+/, $line);
      if($conv_spec =~ /\((\d+)x(\d+)x(\d+)x(\d+)\)/){
        $conv_rows = $1;
        $conv_cols = $2;
        $conv_slices = $3;
        $conv_vols = $4;
      }
      next;
    }
    if($line =~ /^Gantry Tilt based on 0018,1120 (.*), estimated from slice vector (.*)$/){
      $gantry_tilt_spec = $1;
      $gantry_tilt_est = $2;
      next;
    }
    if($line =~ /^Gantry Tilt Correction is new:/) { next }
    if($line =~ /^Conversion required (.*) seconds \((.*) for core code\)\.$/){
      $conversion_time = $1;
      $conversion_core_time = $2;
      next;
    }
    push @warnings, $line;
    #print STDERR "Unparsable line from dcm2niiX: '$line'\n";
  }
  my $base_file;
  if($conv_file =~ /\/([^\/]+)$/){
    $base_file = $1;
  }
  my $converted_nifti;
  my $converted_json;
  my @other_niftis;
  opendir DIR, $output_dir or die "can't opendir $output_dir ($!)";
  while (my $fn = readdir(DIR)){
    if($fn =~ /^\./) { next };
    if($fn eq "$base_file.nii"){
      $converted_nifti = "$base_file.nii";
    } elsif($fn eq "$base_file.json"){
      $converted_json = "$base_file.json";
    } elsif($fn =~ /\.nii$/){
      push @other_niftis, $fn;
    } else {
      print STDERR "Unrecognized file ($fn) in output directory\n";
    }
  }
  my $nifti_file_id = PutFileAndGetId("$output_dir/$base_file.nii");
  my $json_file_id = PutFileAndGetId("$output_dir/$base_file.json");
  AddDcm2NiftiStuff($nifti_file_from_series_id, $nifti_file_id, $nifti_json_file_id,
    $nifti_base_file_name, $gantry_tilt_spec, $gantry_tilt_est, $conversion_time);
  
  
  print STDERR "dcm2niiX found $num_found and converted ($num_converted) DICOM files " .
    "in $conversion_time ($conversion_core_time core) seconds\n";
  print STDERR "Rows: $conv_rows, Cols: $conv_cols, Slices: $conv_slices, Vols: $conv_vols\n";
  
  if(defined $gantry_tilt_spec){
    print STDERR "Defined Gantry tilt: $gantry_tilt_spec, computed: $gantry_tilt_est\n";
  }
#  if(defined $base_file){
#    print STDERR "Base converted file: $base_file\n";
#  } else {
#    print STDERR "Converted file: $conv_file\n";
#  }
  if(defined($converted_nifti)){
    print STDERR "Converted nifti file: $converted_nifti\n";
  }
  if(defined($converted_json)){
    print STDERR "Converted json  file: $converted_json\n";
  }
  if(@other_niftis > 0){
    for my $i (@other_niftis){
      my $file_id = PutFileAndGetId("$output_dir/$i");
      AddNiftiExtraFile($nifti_file_from_series_id, $file_id, $i);
    }
    print STDERR "Other nifti files produced:\n";
    for my $i (@other_niftis){
      print STDERR "\t$i\n";
    }
  }
  if(@warnings > 0){
    print STDERR "Warnings:\n";
    for my $i (@warnings){
      print STDERR "\t$i\n";
    }
  }
}
$back->Finish("Done after $count series in $dir");
sub SelectFilesFromSeries{
  my($sh) = @_;
  my @good_list;
  my @notes;
  my $modality;
  my $dicom_file_type;
  my %IOP;
  my %Modality;
  my %DicomFileType;
  for my $f (keys %$sh){
    my $si = $sh->{$f};
    my $iop = $si->{iop};
    my $dft = $si->{dicom_file_type};
    my $mod = $si->{modality};
    unless(defined $iop){ $iop = '<undef>' }
    $IOP{$iop}->{$f} = 1;
    $Modality{$mod}->{$f} = 1;
    $DicomFileType{$dft}->{$f} = 1;
  }
  if(keys %Modality != 1){
    my $num_modalities = keys %Modality;
    push @notes, "Series should have only one modality ($num_modalities found);";
    for my $i (keys %Modality){
      my $num_files = keys %{$Modality{$i}};
      push @notes, "$num_files of modality $i";
    }
    push @notes, "Not trying to cope with multiple modalities";
    return [], @notes;
  } else {
    $modality = [keys %Modality]->[0];
  }
  if(keys %DicomFileType != 1){
    my $num_dfts = keys %DicomFileType;
    push @notes, "Series should have only one dicom_file_type ($num_dfts found);";
    for my $i (keys %DicomFileType){
      my $num_dfts = keys %{$DicomFileType{$i}};
      push @notes, "$num_dfts of dicom_file_type $i";
    }
    push @notes, "Not trying to cope with multiple dicom_file_types";
    return [], @notes;
  } else {
    $dicom_file_type = [keys %DicomFileType]->[0];
  }
  my $chosen_iop;
  if(keys %IOP != 1){
    my $sel_iop;
    my $max_num = 0;
    push @notes, "More than one iop in series";
    for my $iop (keys %IOP){
      my $num_files = keys %{$IOP{$iop}};
      push @notes, "iop $iop has $num_files files";
      if($num_files > $max_num){
        $sel_iop = $iop;
        $max_num = $num_files;
      }
    }  
    if(keys %IOP > 2){
      my $num_iops = keys %IOP;
      push @notes, "Not trying to make sense with $num_iops iops";
      return [], \@notes;
    }
    push @notes, "Chosen iop: $sel_iop ($max_num files)";
    $chosen_iop = $sel_iop;
    @good_list = sort
      { $sh->{$a}->{instance_number} <=> $sh->{$b}->{instance_number} }
      keys %{$IOP{$sel_iop}};
    if($sel_iop eq "<undef>"){
      push @notes, "no iop found";
      return \@good_list, \@notes, $sel_iop, $modality, $dicom_file_type;
    }
  } else {
    @good_list = sort
      { $sh->{$a}->{instance_number} <=> $sh->{$b}->{instance_number} }
      keys %$sh;
    my @iops = keys %IOP;
    my $iop = $iops[0];
    push @notes, "iop: $iop";
    if($iop eq "<undef>"){
      push @notes, "no iop found";
      return \@good_list, \@notes, $iop, $modality, $dicom_file_type;
    }
    $chosen_iop = $iop;
  }
  my %SliceSpacings;
  my $prior_ipp;
  my $prior_inst;
  good_f:
  for my $f (@good_list){
    unless(defined $prior_ipp) {
      $prior_ipp = $sh->{$f}->{ipp};
      $prior_inst = $sh->{$f}->{instance_number};
      next good_f;
    }
    my $this_ipp = $sh->{$f}->{ipp};
    my $this_inst = $sh->{$f}->{instance_number};
    my @p_ipp = split(/\\/, $prior_ipp);
    my @ipp = split(/\\/, $this_ipp);
    my $dx = $p_ipp[0] - $ipp[0];
    my $dy = $p_ipp[1] - $ipp[1];
    my $dz = $p_ipp[2] - $ipp[2];
    my $d = sqrt(($dx * $dx) + ($dy * $dy) + ($dz * $dz));
    my $df = sprintf("%7.2f", $d) + 0;
    $SliceSpacings{$df}->{"$prior_inst - $this_inst"} = 1;
    $prior_inst = $this_inst;
    $prior_ipp = $this_ipp;
  }
  if(keys %SliceSpacings > 1){
    push(@notes, "Multiple slice spacings:");
    for my $i (keys %SliceSpacings){
      my $num_spacings = keys %{$SliceSpacings{$i}};
      push(@notes, "\t$i: $num_spacings spacings");
#      for my $j (keys %{$SliceSpacings{$i}}){
#        push(@notes, "\t\t$j");
#      }
    }
  } else {
    my $slice_spacing = [keys %{SliceSpacings}]->[0];
    push @notes, "Slice spacing: $slice_spacing";
  }
  return \@good_list, \@notes, $chosen_iop, $modality, $dicom_file_type;
}

#########################
#  Database update routines....

#my $dicom_to_nifti_conversion_id = CreateDicomToNiftConversionTable($invoc_id, $activity_id);
sub CreateDicomToNiftConversionTable{
  my($invoc_id, $activity_id) = @_;
}

#my $nifi_file_from_series_id = CreateNonConversionNiftiFileFromSeriesRow($dicom_file_to_nifti_conversion_id, $series, $num_files)
sub CreateNonConversionNiftiFileFromSeriesRow{
  my($dicom_ftnc_id, $series, $num_files) = @_;
}

#AddNiftiConversionNotes($dicom_file_to_nifti_conversion_id, $SelectionNotes);
sub AddNiftiConversionNotes{
  my($dicom_ftnc_id, $sel_notes) = @_;
}

#my $nifti_file_from_series_id = CreateConversionNiftiFileFromSeriesRow(
#    $dicom_to_nifti_conversion_id, $series, $num_in_series, $num_selected,
#    $modality, $dicom_file_type, $the_iop, $first_ipp, $last_ipp);
#  );
sub CreateConversionNiftiFileFromSeriesRow{
  my($dtnc_id, $series, $num_in_series, $num_selected, $modality,
     $dicom_file_type, $iop, $first_ipp, $last_ipp) = @_;
}

#AddDcm2NiftiStuff($nifti_file_from_series_id, $nifti_file_id, $nifti_json_file_id,
#    $nifti_base_file_name, $gantry_tilt_spec, $gantry_tilt_est, $conversion_time);
sub AddDcm2NiftiStuff{
  my($nffs_id, $nifti_file_id, $json_file_id, $nifti_base_name, $gt_spec, $gt_est, $cov_time) = @_;
}

#AddNiftiExtraFile($nifti_file_from_series_id, $file_id, $file_name);
sub AddNiftiExtraFile{
  my($nffs_id, $file_id, $json_file_id, $nifti_base_name, $gt_spec, $gt_est, $cov_time) = @_;
}

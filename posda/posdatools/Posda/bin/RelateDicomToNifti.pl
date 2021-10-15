#!/usr/bin/perl -w
use strict;
use Posda::DB qw(Query);
my($tp_id, $nifti_file_id, $series) = @ARGV;
my $row_count = Query('DicomSliceNiftiSliceRowCountByNiftiFileId')
  ->FetchOneHash($nifti_file_id)->{row_count};
if($row_count > 0){
  die "NiftiFile $nifti_file_id is already associated with " .
    "$row_count dicom slices\n";
}
my %FilesInSeries;
Query('GetFilesInSeriesAndActivityTp')->RunQuery(sub{
  my($row) = @_;
  my $file_id = $row->[0];
  Query('GetFileInfoForSeriesReportWithType')->RunQuery(sub{
    my($row) = @_;
    $FilesInSeries{$row->[0]} = {
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
}, sub {}, $series, $tp_id);
my $num_files = keys %FilesInSeries;
my($ListOfFiles, $SelectionNotes, $the_iop, $modality, $dicom_file_type) = 
  SelectFilesFromSeries(\%FilesInSeries);

for my $i (@$SelectionNotes){
#  print "$i\n";
}
my $nifti_path;
Query('GetFilePath')->RunQuery(sub{
  my($row) = @_;
  $nifti_path = $row->[0];
}, sub{}, $nifti_file_id);
$num_files = @$ListOfFiles;

my @NiftiSlices;
open DIG, "GetNiftiSliceDigests.pl $nifti_path|" or die "Can't open GetNiftiSlices";
my $line_count = 0;
while (my $line = <DIG>){
  chomp $line;
  my($v, $slice, $max, $min, $dig, $f_dig) = split /,/, $line;
  if($v eq "vol") { next }
  if($slice != $line_count) { die "wrong slice_no ($slice vs $line_count)" }
  push @NiftiSlices, [$dig, $f_dig];
  $line_count += 1;
}
my $num_slices = @NiftiSlices;
my %DirFlip;
dir_flip_search:
for my $i (0 .. $#{$ListOfFiles}){
  my $file_id = $ListOfFiles->[$i];
  my $f_info = $FilesInSeries{$file_id};
  my $pix_dig = $f_info->{pixel_data_digest};
  my $rev_i = $#{$ListOfFiles} - $i;
  my $n_pix_r_f = $NiftiSlices[$rev_i]->[1];
  if($n_pix_r_f eq $pix_dig){
    $DirFlip{"RF"}->{$i} = 1;
  }
  my $n_pix_r_n = $NiftiSlices[$rev_i]->[0];
  if($n_pix_r_n eq $pix_dig){
    $DirFlip{"RN"}->{$i} = 1;
  }
  my $n_pix_i_f = $NiftiSlices[$i]->[1];
  if($n_pix_i_f eq $pix_dig){
    $DirFlip{"IF"}->{$i} = 1;
  }
  my $n_pix_i_n = $NiftiSlices[$i]->[0];
  if($n_pix_i_n eq $pix_dig){
    $DirFlip{"IN"}->{$i} = 1;
  }
}
my $chosenDirFlip;
for my $i (keys %DirFlip){
  my $num = keys %{$DirFlip{$i}};
  if($num == $num_files){
    if(defined $chosenDirFlip){
      Query('SetMappedToDicomFiles')->RunQuery(sub{}, sub{}, 0, $nifti_file_id);
      die "Can't choose direction and flip ($chosenDirFlip and $i)";
    }
    $chosenDirFlip = $i;
  }
#  print "$i: $num\n";
}
unless(defined $chosenDirFlip){
  print STDERR "Couldn't choose DirFlip:\n" .
    "  num_files: $num_files\n";
  for my $i (keys %DirFlip){
    my $n = keys %{$DirFlip{$i}};
    print "  $i: $n\n";
  }
  Query('SetMappedToDicomFiles')->RunQuery(sub{}, sub{}, 0, $nifti_file_id); 
  die "Can't choose direction and flip (no matching digests??)";
}
#print "Num files $num_files, num_slices: $num_slices, $chosenDirFlip\n";
for my $i (0 .. $#{$ListOfFiles}){
  my $nifti_slice_number = $#{$ListOfFiles} - $i;
  if($chosenDirFlip =~ /^R/){
    $nifti_slice_number = $#{$ListOfFiles} - $i;
  } else {
    $nifti_slice_number = $i;
  }
  my $dicom_file_id = $ListOfFiles->[$i];
  my $pix_digest = $FilesInSeries{$dicom_file_id}->{pixel_data_digest};
  Query('InsertDicomSliceNiftiSlice')->RunQuery(sub{}, sub{},
    $dicom_file_id, $nifti_file_id, $nifti_slice_number, $pix_digest);
#  print "Insert:\n";
#  print "\tdicom_file_id: $dicom_file_id\n";
#  print "\tnifti_file_id: $nifti_file_id\n";
#  print "\tnifti_slice_no: $nifti_slice_number\n";
#  print "\tpixel_data_digest: $pix_digest\n";
}
Query('SetMappedToDicomFiles')->RunQuery(sub{}, sub{}, 1, $nifti_file_id);
exit;
###################################
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
    return [], \@notes;
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
    return [], \@notes;
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
    }
  } else {
    my $slice_spacing = [keys %{SliceSpacings}]->[0];
    push @notes, "Slice spacing: $slice_spacing";
  }
  return \@good_list, \@notes, $chosen_iop, $modality, $dicom_file_type;
}

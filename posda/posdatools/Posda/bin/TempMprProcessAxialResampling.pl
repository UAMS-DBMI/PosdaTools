#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::File::Import 'insert_file';
use File::Temp qw/ tempdir /;
my $usage = <<EOF;
TempMprProcessAxialResampling.pl <?bkgrnd_id?> <activity_id> <temp_mpr_volume_id> <notify>
  <activity_id> - activity
  <temp_mpr_volume_id> - identifies temp_mpr_volume to be resampled
  <notify> - user to notify

Expects the following list on <STDIN>
<i_slice_no>&<slice_offset>&<slice_spacing>

This spreadsheet is normally prepared from a "series report" spreadsheet.

The program first reads the data in the spreadsheet and constructs:
  \$ResampledSlices = {
    <slice_offset> => {
      slice_num => <slice_num>,
      slice_spacing => <slice_spacing>
    },
    ...
  };

It also constructs the following data structure from the specified temp_mpr_volume and its slices:

  \$OriginalSlices = {
    <slice_offset> => {
      gray_file_id => <temp_mpr_gray_file_id>,
      jpeg_file_id => <jpeg_mpr_gray_file_id>,
    },
    ...
  }

When both of these data structures are constructed, the program will validate that the resampling
specified is "proper", i.e:

  - The largest resampled slice location is smaller than the largest original slice location, but
    the distance is less than 1/2 the slice spacing

  - The smallest resampled slice location is larger than the smallest original slice location, but
    the distance is less than 1/2 the slice spacing

If it is then it will create a new temp_mpr_volume:
First it creates a row in temp_mpr_volume:

  temp_mpr_volume_type - copied from original
  temp_mpr_volume_w_c   - copied from original
  temp_mpr_volume_w_w   - copied from original
  temp_mpr_volume_position_x - copied from original
  temp_mpr_volume_position_y - copied from original
  temp_mpr_volume_position_z - largest resampled slice offset
  temp_mpr_volume_rows - copied from original
  temp_mpr_volume_cols -  copied from original
  temp_mpr_volume_description - 
     "<time_tag> - Volume <original_id> resampled to <slice_spacing>"
  temp_mpr_volme_creation_time - now()
  temp_mpr_volume_creator - <notify>


Then for every row in the input, it will do the following:

1) Find the smallest original_slice_offset of which is larger than the slice_offset.
   Call it's file <file_h> and the distance from it to the slice_offset <d_h>.
2) Find the largest original_slice_offset which is smaller than the slice_offset.
   Call it's file <file_l> and the distance from it to the slice_offset <d_l>.
3) Create a "gray" file in /tmp 
4) Open both <file_h>, and <file_l>
5) For each corresponding byte in <file_h> (h_pix[i]) and <file_l> (l_pix[i]),
   compute an interpolated pixel_value (i_pix[i]) as follows:
     i_pix[i] = ((h_pix[i] * d_l) + (l_pix[i] * d_h)) / (d_l + d_h)
   Then convert this to a single 8 bit byte, rounding if necessary, and write it
   to tne new gray file,  This is the interpolated pixel data,
6) Import the file into Posda and retrieve its id
7) Delete the "gray" file in /tmp
8) Use convert to render the file into a jpeg in /tmp
9) Import the file into Posda and retrieve its id
10) Delete the jpeg file in /tmp
11) Create a row in temp_mpr_slice with the following:
   1) temp_mpr_volume_id - the id of the volume (created above)
   2) temp_mpr_slice_offset - <slice_offset>
   3) temp_mpr_gray_file_id - file_id of imported "gray" file
   4) temp_mpr_jpeg_file_id - file_id of imported "jpeg" file

EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 3){
  my $n_args = @ARGV;
  my $mess = "Wrong number of args ($n_args vs 3). Usage:\n$usage\n";
  print $mess;
  die "######################## subprocess failed to start:\n" .
      "$mess\n" .
      "#####################################################\n";
}
my($invoc_id, $activity_id, $orig_vol_id, $notify) = @ARGV;
my $OriginalVolumeData;
Query('GetTempMprVolumeInfo')->RunQuery(sub{
  my($row) = @_;
  my($vol_id, $vol_type, $vol_wc, $vol_ww, $vol_pos_x, $vol_pos_y, $vol_pos_z,
    $rows, $cols, $vol_desc, $create_time, $creator) = @{$row};
  $OriginalVolumeData = {
    temp_mpr_volume_id => $vol_id,
    temp_mpr_volume_type => $vol_type,
    temp_mpr_volume_wc => $vol_wc,
    temp_mpr_volume_ww => $vol_ww,
    temp_mpr_volume_position_x => $vol_pos_x,
    temp_mpr_volume_position_y => $vol_pos_y,
    temp_mpr_volume_position_z => $vol_pos_z,
    temp_mpr_volume_rows => $rows,
    temp_mpr_volume_cols => $cols,
    temp_mpr_volume_description => $vol_desc,
    temp_mpr_volume_creation_time => $create_time,
    temp_mpr_volume_creator => $creator,
  };
},sub{}, $orig_vol_id);
my %OriginalSlices;
Query('GetTempMprSliceInfo')->RunQuery(sub{
  my($row) = @_;
  my($s_offset, $gray_file_id, $jpeg_file_id) = @$row;
  $OriginalSlices{$s_offset} = {
    gray_file_id => $gray_file_id,
    jpeg_file_id => $jpeg_file_id
  };
},sub{}, $orig_vol_id);

my %ResampledSlices;
my $SliceSpacing;
while(my $line = <STDIN>){
  chomp $line;
  $line =~ s/^\s*//;
  $line =~ s/\s*$//;
  my($slice_num, $slice_offset, $slice_spacing) = split(/&/, $line);
  unless(defined $SliceSpacing){
    $SliceSpacing = $slice_spacing;
  }
  unless($slice_spacing == $SliceSpacing){
    die "Slice spacing for resampling is not consistent";
  }
  $ResampledSlices{$slice_offset} = {
    slice_num => $slice_num,
    slice_spacing => $slice_spacing
  };
}
# Do the proper checks...
my @original_slice_offsets = sort {$a <=> $b} keys %OriginalSlices;
my @resampled_slice_offsets = sort {$a <=> $b} keys %ResampledSlices;

my $h_orig = $original_slice_offsets[$#original_slice_offsets];
my $l_orig = $original_slice_offsets[0];

my $h_resamp = $resampled_slice_offsets[$#resampled_slice_offsets];
my $l_resamp = $resampled_slice_offsets[0];

unless($h_orig > $h_resamp) { die "highest resampled is not lower than higest original" }
unless($l_orig < $l_resamp) { die "lowest resampled is not lower than lowest original" }

my $half_spacing = $SliceSpacing / 2;
my $h_dist = abs ($h_orig - $h_resamp);
my $l_dist = abs ($l_orig - $l_resamp);

unless($h_dist < $half_spacing) { die "high spacing is more than half a slice" }
unless($l_dist < $half_spacing) { die "low spacing is more than half a slice" }

my $tmpdir = &tempdir( CLEANUP => 1 );

my $back = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$back->Daemonize;

my $Tt;
Query('GetTimeTag')->RunQuery(sub{
  my($row) = @_;
  $Tt = $row->[0];
}, sub{});
my $desc = "$Tt - Volume $orig_vol_id resampled to $SliceSpacing";
#  $OriginalVolumeData = {
#    temp_mpr_volume_id => $vol_id,
#    temp_mpr_volume_type => $vol_type,
#    temp_mpr_volume_wc => $vol_wc,
#    temp_mpr_volume_ww => $vol_ww,
#    temp_mpr_volume_position_x => $vol_pos_x,
#    temp_mpr_volume_position_y => $vol_pos_y,
#    temp_mpr_volume_position_z => $vol_pos_z,
#    temp_mpr_volume_rows => $rows,
#    temp_mpr_volume_cols => $cols,
#    temp_mpr_volume_description => $vol_desc,
#    temp_mpr_volume_creation_time => $create_time,
#    temp_mpr_volume_creator => $creator,
#  };
Query('InsertTempMprVolume')->RunQuery(sub{}, sub{},
  $OriginalVolumeData->{temp_mpr_volume_type},
  $OriginalVolumeData->{temp_mpr_volume_wc},
  $OriginalVolumeData->{temp_mpr_volume_ww},
  $OriginalVolumeData->{temp_mpr_volume_position_x},
  $OriginalVolumeData->{temp_mpr_volume_position_y},
  $h_resamp,
  $OriginalVolumeData->{temp_mpr_volume_rows},
  $OriginalVolumeData->{temp_mpr_volume_cols},
  $desc,
  $notify
);
my $VolId;
Query('GetTempMprVolumeId')->RunQuery(sub{
  my($row) = @_;
  $VolId = $row->[0];
}, sub{}, $desc);
unless(defined $VolId) { die "Didn't find a volume" }
$back->WriteToEmail("Something appropriate here\n");
$back->WriteToEmail("Resampled temp_mpr_volume_id = $VolId ($desc)\n");

my $slice_cq = Query('InsertTempMprSlice');
my $get_file_path = Query('FilePathByFileId');
my $start = time;
my $num_slices = @resampled_slice_offsets;
my $i = 0;
for my $rso (@resampled_slice_offsets){
  $i += 1;
  $back->SetActivityStatus("Interpolating $i of $num_slices");
  my($ooh, $ool) = GetHighLowOffsets($rso,\%OriginalSlices);
  my $d2l = abs($rso - $ool);
  my $d2h = abs($ooh - $rso);
  my $h_pix_file_id = $OriginalSlices{$ooh}->{gray_file_id};
  my $l_pix_file_id = $OriginalSlices{$ool}->{gray_file_id};
  my $h_pix_file_path;
  $get_file_path->RunQuery(sub{
    my($row) = @_;
    $h_pix_file_path = $row->[0];
  }, sub {}, $h_pix_file_id);
  unless(defined($h_pix_file_path)){
    die "no path found for file_id: $h_pix_file_id";
  }
  my $l_pix_file_path;
  $get_file_path->RunQuery(sub{
    my($row) = @_;
    $l_pix_file_path = $row->[0];
  }, sub {}, $l_pix_file_id);
  unless(defined($l_pix_file_path)){
    die "no path found for file_id: $l_pix_file_id";
  }
  my $i_file_path = "$tmpdir/infile_" . "$i" . "_raw_pix.gray";

  ## do interpolation
  open INTERP, ">$i_file_path" or die "can't open " .
    "$i_file_path for write ($!)";
  open HFILE, "<$h_pix_file_path" or die "can't open " .
    "$h_pix_file_path for read ($!)";
  open LFILE, "<$l_pix_file_path" or die "can't open " .
    "$l_pix_file_path for read ($!)";
  my $at_end = 0;
  interp_loop:
  while (!$at_end){
    my $buff_h;
    my $buff_l;
    my $br_h = sysread HFILE, $buff_h, 1024;
    my $br_l = sysread LFILE, $buff_l, 1024;
    unless($br_h == $br_l){
      die "br_h != br_l";
    }
    if($br_h == 0){
      $at_end = 1;
      next interp_loop;
    }
    my @b_h = unpack("C*", $buff_h);
    my @b_l = unpack("C*", $buff_l);
    my @b_i;
    for my $i (0 .. $#b_h){
      my $b_i = (($b_h[$i] * $d2l) + ($b_l[$i] * $d2h)) / ($d2l + $d2h);
      if ($b_i >= 256) {
        die "interpolated pixel to large ($b_h[$i], $b_l[$i], $b_i)"
      }
      $b_i[$i] = int $b_i;
    }
    my $buff_i = pack("C*", @b_i);
    my $iw_l = syswrite INTERP, $buff_i;
    unless($iw_l == $br_h){
      die "read $br_h, but only wrote $iw_l interpolated";
    }
  }
  close HFILE;
  close LFILE;
  close INTERP;
  
  ## end do interpolation

  my $PixDim = $OriginalVolumeData->{temp_mpr_volume_rows};
  unless($PixDim == $OriginalVolumeData->{temp_mpr_volume_rows}){
    die "Only currently resampling for isotropic pixels...";
  }
  $back->SetActivityStatus("Converting $i of $num_slices to jpeg");
  my $jpeg_name = "$tmpdir/infile__" . "$i" . "_rendered.jpeg"; 
  my $cmd = "convert -endian MSB -size ${PixDim}x${PixDim} " .
    "-depth 8 gray:$i_file_path $jpeg_name";
  open FOO, "$cmd|";
  while(my $line = <FOO>){
    #print "from command: $line";
  }
  close FOO;
  $back->SetActivityStatus("Inserting $i (gray) of $num_slices");
  my $resp = Posda::File::Import::insert_file($i_file_path);
  my($gray_file_id, $jpeg_file_id);
  if($resp->is_error){
    die $resp->message;
  } else {
    $gray_file_id = $resp->file_id;
  }
  unlink $i_file_path;
  $back->SetActivityStatus("Inserting $i (jpeg) of $num_slices");
  $resp = Posda::File::Import::insert_file($jpeg_name);
  if($resp->is_error){
    die $resp->message;
  } else {
    $jpeg_file_id = $resp->file_id;
  }
  unlink $jpeg_name;
  $slice_cq->RunQuery(sub{}, sub{}, $VolId, $rso, $gray_file_id, $jpeg_file_id);
}
my $elapsed = time - $start;
$back->WriteToEmail("Processed $num_slices slices in $elapsed seconds\n");
$back->Finish("Processed $num_slices slices in $elapsed seconds");;

#my($ooh, $ool) = GetHighLowOffsets($rso,\%OriginalSlices);
sub GetHighLowOffsets{
  my($rso, $OriginalSlices) = @_;
  my @offsets = sort { $a <=> $b } keys %$OriginalSlices;
  my $num_offsets = @offsets;
  for my $i (0 .. $num_offsets - 1) {
    my $l = $offsets[$i];
    my $h = $offsets[$i+1];
    if($rso > $l && $rso <= $h){
      return ($l, $h);
    }
  }
  die "Couldn't find slot for offset $rso";
}

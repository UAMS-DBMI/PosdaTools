#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::File::Import 'insert_file';
use File::Temp qw/ tempdir /;
my $usage = <<EOF;
TempMprPopulateInitialAxialVolume.pl <?bkgrnd_id?> <activity_id> <series> <notify>
  <activity_id> - activity
  <comment> - comment to identify temp_mpr_volume
  <notify> - user to notify

Expects the following list on <STDIN>
<file_id>&<pix_rows>&<pix_cols>&<ipp_x>&<ipp_y>&<ipp_z>&<row_spc>&<col_spc>

This spreadsheet is normally prepared from a "series report" spreadsheet.
You should verify that 
  every column is consistent except for <file_id> and <ipp_z>
  neither <file_id> nor <ipp_z> repeat
  pixels are isotropic (i.e. <row_spc> eq <col_spc>
In otherwords, we have DICOM axial series with isotropic pixels.

This script will verify that the specified dicom files meet the requirement
and then it will create a new row in temp_mpr_volume with the following

  temp_mpr_volume_type - "Axial"
  temp_mpr_volume_w_c   - "-81"
  temp_mpr_volume_w_w   - "397"
  temp_mpr_volume_position_x - <ipp_x>
  temp_mpr_volume_position_y - <ipp_y>
  temp_mpr_volume_position_z - largest <ipp_z>
  temp_mpr_volume_rows - <rows>
  temp_mpr_volume_cols - <cols>
  temp_mpr_volume_description - 
     "<time_tag> - Initial Axial Volume for series <series>"
  temp_mpr_volme_creation_time - now()
  temp_mpr_volume_creator - <notify>


Then for every row in the input, it will do the following:

1) Invoke ConvertDicomFileToRenderedRawGrayScale.pl to render the file
   into a "gray" file in /tmp
2) Import the file into Posda and retrieve its id
3) Delete the "gray" file in /tmp
3) Use convert to render the file into a jpeg in /tmp
4) Import the file into Posda and retrieve its id
5) Delete the jpeg file in /tmp
6) Create a row in temp_mpr_slice with the following:
   1) temp_mpr_volume_id - the id of the volume (created above)
   2) temp_mpr_slice_offset - <ipp_z>
   3) temp_mpr_gray_file_id - file_id of imported "gray" file
   4) temp_mpr_jpeg_file_id - file_id of imported "jpeg" file

So it is creating slice in a temp_mpr_volume which can be subsampled,
mpr'ed (i.e. have orthogonal projections made and displayed).
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
my($invoc_id, $activity_id, $series, $notify) = @ARGV;
my $comment = "Initial Axial Volume for series $series";
my $PixDim;
my $PixSpc;
my $IppX;
my $IppY;
my %ZToFile;
my %FileToZ;
while(my $line = <STDIN>){
  chomp $line;
  $line =~ s/^\s*//;
  $line =~ s/\s*$//;
  my($file_id,$rows,$cols,$ipp_x,$ipp_y,$ipp_z,$row_spc,$col_spc) = split(/&/, $line);
  unless(defined($rows) && defined($cols) && $rows == $cols){
    die "rows and columns must be defined and equal";
  }
  unless(defined($PixDim)){
    $PixDim = $rows;
  }
  unless($PixDim == $rows) {
    die "pixel dimensions must be consistent";
  }
  unless(defined($row_spc) && defined($col_spc) && $row_spc == $col_spc){
    die "row_spc and col_spc must be defined and equal";
  }
  unless(defined $PixSpc){
    $PixSpc = $row_spc;
  }
  unless($PixSpc == $row_spc){
    die "pixel spacing must be consistent";
  }
  if(exists $ZToFile{$ipp_z}){
    die "Zvalue $ipp_z repeats";
  }
  $ZToFile{$ipp_z} = $file_id;
  if(exists $FileToZ{$file_id}){
    die "file_id $file_id repeats";
  }
  $FileToZ{$file_id} = $ipp_z;
  unless(defined($IppX)){ $IppX = $ipp_x }
  unless($IppX == $ipp_x) { die "ipp_x must be consistent" }
  unless(defined($IppY)){ $IppY = $ipp_y }
  unless($IppY == $ipp_y) { die "ipp_y must be consistent" }
}
my @Zs = sort {$a <=> $b} keys %ZToFile;
my $MinZ = $Zs[0]; 
my $MaxZ = $Zs[$#Zs]; 
my $num_slices = @Zs;

my $tmpdir = &tempdir( CLEANUP => 1 );
my $back = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$back->Daemonize;
$back->WriteToEmail("TempMprPopulateInitialAxialVolume.pl\n");
$back->WriteToEmail("tmpdir = $tmpdir\n" .
  "$num_slices slices\n" .
  "min z: $MinZ, max z: $MaxZ\n" .
  "pixel dimension: $PixDim\n" .
  "pixel spacing: $PixSpc\n"
);

my $Tt;
Query('GetTimeTag')->RunQuery(sub{
  my($row) = @_;
  $Tt = $row->[0];
}, sub{});
my $desc = "$Tt - $comment";
Query('InsertTempMprVolume')->RunQuery(sub{}, sub{},
  'Axial',
  -81,
  397,
  $IppX,
  $IppY,
  $MaxZ,
  $PixDim,
  $PixDim,
  $desc,
  $notify
);
my $VolId;
Query('GetTempMprVolumeId')->RunQuery(sub{
  my($row) = @_;
  $VolId = $row->[0];
}, sub{}, $desc);
unless(defined $VolId) { die "Didn't find a volume" }
$back->WriteToEmail("temp_mpr_volume_id = $VolId ($desc)\n");

my $slice_cq = Query('InsertTempMprSlice');
my $start = time;
my $i = 0;
for my $z (@Zs){
  $i += 1;
  $back->SetActivityStatus("Processing $i of $num_slices");
  my $file_id = $ZToFile{$z};
  my $f_name = "$tmpdir/file_" . "$file_id" . "_raw_pix.gray";
  my $cmd = "ConvertDicomFileToRenderedRawGrayScale.pl $file_id -81 397 $f_name";
  open FOO, "$cmd|";
  while(my $line = <FOO>){
    #print "from command: $line";
  }
  close FOO;
  my $jpeg_name = "$tmpdir/file_" . "$file_id" . "_rendered.jpeg"; 
  $cmd = "convert -endian MSB -size ${PixDim}x${PixDim} " .
    "-depth 8 gray:$f_name $jpeg_name";
  open FOO, "$cmd|";
  while(my $line = <FOO>){
    #print "from command: $line";
  }
  close FOO;
  my $resp = Posda::File::Import::insert_file($f_name);
  my($gray_file_id, $jpeg_file_id);
  if($resp->is_error){
    die $resp->message;
  } else {
    $gray_file_id = $resp->file_id;
  }
  unlink $f_name;
  $resp = Posda::File::Import::insert_file($jpeg_name);
  if($resp->is_error){
    die $resp->message;
  } else {
    $jpeg_file_id = $resp->file_id;
  }
  unlink $jpeg_name;
  $slice_cq->RunQuery(sub{}, sub{}, $VolId, $z, $gray_file_id, $jpeg_file_id);
}
my $elapsed = time - $start;
$back->WriteToEmail("Processed $num_slices slices in $elapsed seconds\n");
$back->Finish("Processed $num_slices slices in $elapsed seconds");;

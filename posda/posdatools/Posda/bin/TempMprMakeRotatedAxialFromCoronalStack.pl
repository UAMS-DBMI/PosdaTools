#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::File::Import 'insert_file';
use File::Temp qw/ tempdir /;
use Debug;
my $dbg = sub {
  print STDERR @_;
};
my $usage = <<EOF;
TempMprMakeRotatedAxialFromCoronalStack.pl <?bkgrnd_id?> <activity_id> <temp_mpr_volume_id> <notify>
  <activity_id> - activity
  <temp_mpr_volume_id> - identifies temp_mpr_volume to be resampled
  <notify> - user to notify

Expects no data on <STDIN>
It is completely driven by the data in the temp_mpr_volume table and the temp_mpr_slice table for
the supplied temp_mpr_volume_id
This is a follow on, and is similar to TempMprMakeIsoTropicCoronalFromAxialStack.pl, which
makes an (e.g.) 512 Coronal slices with 512 cols and 1024 rows...

So TempMprMakeIsoTropicCoronalFromAxialStack.pl takes a stack of (e.g.) 1024 512x512 slices and turns
it into a stack of (e.g) 1024 512x512 axials.

These axials, however, are rotated 90 degrees from the original axial stack, so that rows point to
posterior and columns point to the left.

This volume will then be reformatted into a Sagittal stack by another script,
TempMprMakeSagittalStackFromRotatedAxial.pl

So, laying out the algorithm:

1) Get the data from the temp_mpr_volume and temp_mpr_slice table for the axial volume and build the
   following structure:
   \$CoronalVolume{<y>} = {
     rows => <rows>,
     cols => <cols>,
     z => <ipp_z>,
     x => <ipp_y>,
     pix_spc => <pix_spc>,
     gray_file_id => <gray_file_id>,
     gray_file_path => <gray_file_path>,
   };
2) Allocate a working directory in /tmp create the following descriptor of the working files in this
   directory:
   \$RotatedAxial->{<ipp_z>} = {
     x => <ipp_x>,
     y => <ipp_y>,
     file_name => "<dir>/cor_<seq>.gray",
     jpeg_file => "<dir>/cor_<seq>.jpeg",
   };

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
my %CoronalVolume;
#   \$CoronalVolume{<y>} = {
#     rows => <rows>,
#     cols => <cols>,
#     z => <ipp_z>,
#     x => <ipp_x>,
#     pix_spc => <pix_spc>,
#     gray_file_id => <gray_file_id>,
#     gray_file_path => <gray_file_path>,
#   };
my($vol_id, $vol_type, $vol_wc, $vol_ww, $vol_pos_x, $vol_pos_y, $vol_pos_z,
  $rows, $cols, $vol_desc, $create_time, $creator, $row_spc, $col_spc);
Query('GetTempMprVolumeInfo')->RunQuery(sub{
  my($row) = @_;
  ($vol_id, $vol_type, $vol_wc, $vol_ww, $vol_pos_x, $vol_pos_y, $vol_pos_z,
    $rows, $cols, $vol_desc, $create_time, $creator, $row_spc, $col_spc) = @{$row};
  }, sub{}, $orig_vol_id
);
print STDERR "Coronal rows: $rows\n";
print STDERR "Coronal cols: $cols\n";
my $get_file_path = Query('FilePathByFileId');
my $Desc = "Coronal $orig_vol_id reformatted to Rotated Axial";
my $tmpdir = &tempdir( CLEANUP => 1 );
Query('GetTempMprSliceInfo')->RunQuery(sub{
  my($row) = @_;
  my($s_offset, $gray_file_id, $jpeg_file_id) = @$row;
  my $gray_file_path;
  $get_file_path->RunQuery(sub{
    my($row) = @_;
    $gray_file_path = $row->[0];
  }, sub{}, $gray_file_id);
  $CoronalVolume{$s_offset} = {
    rows => $rows,
    cols => $cols,
    x => $vol_pos_x,
    z => $vol_pos_z,
    pix_spc => $row_spc,
    gray_file_id => $gray_file_id,
    gray_file_path => $gray_file_path,
  };
},sub{}, $orig_vol_id);


#Get a sorted list of Coronal Y-values
my @CoronalYs = sort {$b <=> $a} keys %CoronalVolume;

my @RotatedAxialZs;
my %RotatedAxial;
#Assuming normal coronal, and all CT's have same geometry - generate list of Axial X-values
#  from first axial
{
  my $y = $CoronalYs[0];
  my $desc = $CoronalVolume{$y};
  my $x = $desc->{x};
  my $z = $desc->{z};
  my $pd = $rows;
  my $ps = $desc->{pix_spc};
  my $fz = $z;
  for my $i (0 .. $pd - 1){
    push @RotatedAxialZs, $z;
    $RotatedAxial{$z} = {
      x => $x,
      y => $y,
      file_name => "$tmpdir/rx_" .  "$i.gray",
      jpeg_name => "$tmpdir/rx_" .  "$i.jpeg",
    };
    $z = $fz - ($ps * ($i + 1));
  }
}

#   $RotatedAxial{<z>} = {
#     x => <ipp_x>,
#     y => <ipp_y>,
#     file_name => "<dir>/cor_<seq>.gray",
#     jpeg_name => "<dir>/cor_<seq>.jpeg",
#     gray_file_id => <gray_file_id>,  # added after file imported into posda
#     jpeg_file_id => <jpeg_file_id>,  # added after file imported into posda
#   };

my $back = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$back->Daemonize;

my $first_coronal_y = $CoronalYs[0];
my $last_coronal_y = $CoronalYs[$#CoronalYs];

$back->WriteToEmail("First coronal y: $first_coronal_y\n" .
"Last coronal y: $last_coronal_y\n");
print STDERR "First coronal y: $first_coronal_y\n" .
"Last coronal y: $last_coronal_y\n";

my $first_rotax_z = $RotatedAxialZs[0];
my $last_rotax_z = $RotatedAxialZs[$#RotatedAxialZs];
my $num_rotax_z = $#RotatedAxialZs;
my $avg_rotax_spacing = ($last_rotax_z - $first_rotax_z)/$num_rotax_z;
$back->WriteToEmail("First rotax x: $first_rotax_z\n" .
  "Last rotax z: $last_rotax_z\n" .
  "Num rotaxs : $num_rotax_z\n" .
  "Avg Spacing: $avg_rotax_spacing\n");
print STDERR "First rotax z: $first_rotax_z\n" .
  "Last rotax z: $last_rotax_z\n" .
  "Num rotaxs : $num_rotax_z\n" .
  "Avg Spacing: $avg_rotax_spacing\n";

my %RotatedAxialVolume = (
  temp_mpr_volume_type => "RotatedAxial",
  temp_mpr_volume_w_c => $vol_wc,
  temp_mpr_volume_w_w => $vol_ww,
  temp_mpr_volume_position_x => $vol_pos_x,
  temp_mpr_volume_position_y => $vol_pos_y,
  temp_mpr_volume_position_z => $vol_pos_z,
  temp_mpr_volume_rows => $rows,
  temp_mpr_volume_cols => $cols,
  temp_mpr_volume_description => $Desc,
  temp_mpr_volume_creator => $notify,
  row_spc => $row_spc,
  col_spc => abs($avg_rotax_spacing)
);

my $abs_avg_spc = abs($avg_rotax_spacing);
$back->WriteToEmail("RotatedAxialVolume:\n" .
  "  temp_mpr_volume_type : \"RotatedAxial\",\n" .
  "  temp_mpr_volume_w_c : $vol_wc\n" .
  "  temp_mpr_volume_w_w : $vol_ww\n" .
  "  temp_mpr_volume_position_x : $vol_pos_x\n" .
  "  temp_mpr_volume_position_y : $vol_pos_y\n" .
  "  temp_mpr_volume_position_z : $vol_pos_z\n" .
  "  temp_mpr_volume_rows : $rows\n" .
  "  temp_mpr_volume_cols : $cols\n" .
  "  temp_mpr_volume_description : $Desc\n" .
  "  temp_mpr_volume_creator : $notify\n" .
  "  row_spc => $row_spc\n" .
  "  col_spc => $abs_avg_spc\n");
print STDERR "RotatedAxialVolume:\n" .
  "  temp_mpr_volume_type : \"RotatedAxial\",\n" .
  "  temp_mpr_volume_w_c : $vol_wc\n" .
  "  temp_mpr_volume_w_w : $vol_ww\n" .
  "  temp_mpr_volume_position_x : $vol_pos_x\n" .
  "  temp_mpr_volume_position_y : $vol_pos_y\n" .
  "  temp_mpr_volume_position_z : $vol_pos_z\n" .
  "  temp_mpr_volume_rows : $rows\n" .
  "  temp_mpr_volume_cols : $cols\n" .
  "  temp_mpr_volume_description : $Desc\n" .
  "  temp_mpr_volume_creator : $notify\n" .
  "  row_spc => $row_spc\n" .
  "  col_spc => $abs_avg_spc\n";


# Here's the loop where we read the Coronals and write the Rotated Axials

#   \$CoronalVolume{<y>} = {
#     rows => <rows>,
#     cols => <cols>,
#     x => <ipp_x>,
#     z => <ipp_z>,
#     pix_spc => <pix_spc>,
#     gray_file_id => <gray_file_id>,
#     gray_file_path => <gray_file_path>,
#   };

#   $RotatedAxial{<z>} = {
#     x => <ipp_x>,
#     y => <ipp_y>,
#     file_name => "<dir>/cor_<seq>.gray",
#     jpeg_name => "<dir>/cor_<seq>.jpeg",
#     gray_file_id => <gray_file_id>,  # added after file imported into posda
#     jpeg_file_id => <jpeg_file_id>,  # added after file imported into posda
#   };

my $start_time = time;
my $i = 0;
my $ny = @CoronalYs;
for my $yi (0 .. $#CoronalYs){
  $i += 1;
  my $y = $CoronalYs[$yi];
  my $cor_info = $CoronalVolume{$y};
  open CORONAL, "<$cor_info->{gray_file_path}" or
    die "can't open $cor_info->{gray_file_path} ($!)";
  my $elapsed = time - $start_time;
  $back->SetActivityStatus("Copying from " .
    "coronal $i (of $ny) $elapsed seconds");
  for my $zi (0 .. $#RotatedAxialZs){
    my $z = $RotatedAxialZs[$zi];
    my $rx_info = $RotatedAxial{$z};
    my $rx_file = $rx_info->{file_name};
    for my $pix (0 .. 511){
      my $pix_buf;
      my $br = read(CORONAL, $pix_buf, 1);
      unless($br == 1) {die "read $br vs 1 at $pix ($zi)" }
      open RX_FILE, ">>$rx_file" or
        die "Can't open >>$rx_file ($!)";
      print RX_FILE $pix_buf;
      close RX_FILE;
    }
#    my $z = $RotatedAxialZs[$zi];
#    my $rx_info = $RotatedAxial{$z};
#    my $rx_file = $rx_info->{file_name};
#    my $elapsed = time - $start_time;
#    $back->SetActivityStatus("Copying row $yi from " .
#      "coronal $i (of $ny) appending to " .
#      "$rx_file ($elapsed sec)");
#    my $buff;
#    my $br = read CORONAL,$buff, $cor_info->{cols};
#    unless($br == $cor_info->{cols}) {
#      die "Read $br vs $cor_info->{cols} reading coronal " .
#        "file $cor_info->{gray_file_id} $cor_info->{grey_file_path}";
#    }
#    open RX_FILE, ">>$rx_file" or
#      die "Can't open >>$rx_file ($!)";
#    print RX_FILE $buff;
#    close RX_FILE;
  }
  close CORONAL;
  my $elapsed = time - $start_time;
  #print STDERR "Finshed Coronal $i after $elapsed seconds\n";
}

$i = 0;
my $num_rx_slices = @RotatedAxialZs;
for my $zi (0 .. $#RotatedAxialZs){
  $i += 1;
  my $z = $RotatedAxialZs[$zi];
  my $rx_slice_info = $RotatedAxial{$z};
  my $gfile = $rx_slice_info->{file_name};
  my $jfile = $rx_slice_info->{jpeg_name};
  my $elapsed = time - $start_time;
  $back->SetActivityStatus("Rendering jpeg $i ($elapsed sec)");
#print "Lets try reading the gray file:\n";
#open GRAY, "<$gfile" or die "Can't open $gfile";
#my $tmp_buf;
#my $bi;
#while (my $br = read GRAY, $tmp_buf, 512){
#  $bi += 1;
#  print "Read $br ($bi)\n";
#  if($br <= 0) { die "done" }
#}

  # render the jpeg--
  my $cmd = "convert -endian MSB -size ${cols}x${cols} -depth 8 gray:$gfile $jfile";
#print "Rendering JPEG:\n" .
#  "gfile: $gfile\n" .
#  "jfile: $jfile\n" .
#  "command: $cmd\n";
#print "Before invoking command\n";
#if(-d $tmpdir){ print "directory $tmpdir is present\n"; } else {print "$tmpdir is gone\n" }
#if(-r $gfile){ print "$gfile is readable\n"; } else {print "$gfile is not readable\n" }
#print `ls -al gfile`;
  open FOO, "$cmd|";
  while(my $line = <FOO>){
    print $line;
  };
  close FOO;
  #-- render the jpeg--

#print "After invoking command\n";
#if(-d $tmpdir){ print "directory $tmpdir is present\n"; } else {print "$tmpdir is gone\n" }
#if(-r $gfile){ print "$gfile is readable\n"; } else {print "$gfile is not readable\n" }
#print `ls -al gfile`;

  unless(-f $jfile) { die "jfile failed to render" }
  $elapsed = time - $start_time;
  my($gray_file_id, $jpeg_file_id);
  $back->SetActivityStatus("Importing gray_file $i ($elapsed sec)");
  my $resp = Posda::File::Import::insert_file($gfile);
  if($resp->is_error){
    die $resp->message;
  } else {
    $rx_slice_info->{gray_file_id} = $resp->file_id;
  }
  unlink $gfile;
  $back->SetActivityStatus("Importing jpeg_file $i ($elapsed sec)");
  $resp = Posda::File::Import::insert_file($jfile);
  if($resp->is_error){
    die $resp->message;
  } else {
    $rx_slice_info->{jpeg_file_id} = $resp->file_id;
  }
  unlink $jfile;
#  print STDERR "$yi - Gray file id: $sag_slice_info->{gray_file_id} " .
#    "Jpeg file id: $sag_slice_info->{jpeg_file_id}\n";
}
my $rpt = $back->CreateReport("ForRotatedAxialVolumeCreation");
$rpt->print("key,value,x,y,z,gray_file_id,jpeg_file_id,Operation\n");
$rpt->print(
"  temp_mpr_volume_type,\"RotatedAxial\",,,,,,TempMprConvertRotatedAxialToSagittal\n"
);
$rpt->print(
"  temp_mpr_volume_w_c,$RotatedAxialVolume{temp_mpr_volume_w_c}\n" .
"  temp_mpr_volume_w_w,$RotatedAxialVolume{temp_mpr_volume_w_w}\n" .
"  temp_mpr_volume_position_x,$RotatedAxialVolume{temp_mpr_volume_position_x}\n" .
"  temp_mpr_volume_position_y,$RotatedAxialVolume{temp_mpr_volume_position_y}\n" .
"  temp_mpr_volume_position_z,$RotatedAxialVolume{temp_mpr_volume_position_z}\n" .
"  temp_mpr_volume_rows,$RotatedAxialVolume{rows}\n" .
"  temp_mpr_volume_cols,$RotatedAxialVolume{cols}\n" .
"  temp_mpr_volume_description,$RotatedAxialVolume{temp_mpr_volume_description}\n" .
"  temp_mpr_volume_description,$Desc\n" .
"  temp_mpr_volume_creator,$notify\n" .
"  row_spc,$row_spc\n" .
"  col_spc,$abs_avg_spc\n"
);
for my $zi (0 .. $#RotatedAxialZs){
  my $z = $RotatedAxialZs[$zi];
  my $ssi = $RotatedAxial{$z};
  $rpt->print("slice,,$ssi->{x},$ssi->{y},$z,$ssi->{gray_file_id},$ssi->{jpeg_file_id}\n");
}
$back->Finish("Done");

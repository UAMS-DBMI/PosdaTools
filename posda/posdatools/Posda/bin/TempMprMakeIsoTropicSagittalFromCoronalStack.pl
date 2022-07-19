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
TempMprMakeIsoTropicSagittalFromCoronalStack.pl <?bkgrnd_id?> <activity_id> <temp_mpr_volume_id> <notify>
  <activity_id> - activity
  <temp_mpr_volume_id> - identifies temp_mpr_volume to be resampled
  <notify> - user to notify

Expects no data on <STDIN>
It is completely driven by the data in the temp_mpr_volume table and the temp_mpr_slice table for
the supplied temp_mpr_volume_id
This is a follow on, and is similar to TempMprMakeIsoTropicCoronalFromAxialStack.pl, which
makes an (e.g.) 512 Coronal slices with 512 cols and 1024 rows...

Generally, based on the following observations:
   - for a collection of 512 (e.g) 512x1024 slices, you will need to construct 512 Sagittal 
     slices with 1024 rows of 512 columns.
   - for the first coronal slice, the first row will be the first row in the first sagittal file,
     the second row will be the first row in the second sagittal file, and so on..
   - for the second coronal slice, the first row will be the second row in the sagittal coronal file,
     the second row will be the second row in the second sagittal file

So, if you could afford to have 512 file handles open at once, you could write a simple loop that 
goes through the coronal in order, and then the rows in each coronal and writes each row to the
sagittal in order.  At the end of the loop(s), you'd have a sagittal volume in the 512 files...

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
   \$sagittal_volume->{<ipp_x>} = {
     z => <ipp_z>,
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
#my $Tt;
#Query('GetTimeTag')->RunQuery(sub{
#  my($row) = @_;
#  $Tt = $row->[0];
#}, sub{});
#my $desc = "$Tt - Coronal $orig_vol_id reformatted to Sagittal";
my $desc = "Coronal $orig_vol_id reformatted to Sagittal";
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

my @SagittalXs;
my %SagittalVolume;
#Assuming normal coronal, and all CT's have same geometry - generate list of sagittal X-values
#  from first axial
{
  my $y = $CoronalYs[0];
  my $desc = $CoronalVolume{$y};
  my $x = $desc->{x};
  my $z = $desc->{z};
  my $pd = $cols;
  my $ps = $desc->{pix_spc};
  for my $i (0 .. $pd - 1){
    push @SagittalXs, $x;
    $SagittalVolume{$x} = {
      z => $z,
      y => $y,
      file_name => "$tmpdir/sag_" .  "$i.gray",
      jpeg_name => "$tmpdir/sag_" .  "$i.jpeg",
    };
    $x = $x + $ps;
  }
}

#   $SagittalVolume{<x>} = {
#     z => <ipp_z>,
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

my $first_sagittal_x = $SagittalXs[0];
my $last_sagittal_x = $SagittalXs[$#SagittalXs];
my $num_sagittal_x = $#SagittalXs;
my $avg_sagittal_spacing = ($last_sagittal_x - $first_sagittal_x)/$num_sagittal_x;
$back->WriteToEmail("First sagittal x: $first_sagittal_x\n" .
  "Last sagittal x: $last_sagittal_x\n" .
  "Num sagittals : $num_sagittal_x\n" .
  "Avg Spacing: $avg_sagittal_spacing\n");
print STDERR "First sagittal x: $first_sagittal_x\n" .
  "Last sagittal x: $last_sagittal_x\n" .
  "Num sagittals : $num_sagittal_x\n" .
  "Avg Spacing: $avg_sagittal_spacing\n";

my %NewSagittalVolume = (
  temp_mpr_volume_type => "Sagittal",
  temp_mpr_volume_w_c => $vol_wc,
  temp_mpr_volume_w_w => $vol_ww,
  temp_mpr_volume_position_x => $vol_pos_x,
  temp_mpr_volume_position_y => $vol_pos_y,
  temp_mpr_volume_position_z => $vol_pos_z,
  temp_mpr_volume_rows => $rows,
  temp_mpr_volume_cols => $cols,
  temp_mpr_volume_description => $desc,
  temp_mpr_volume_creator => $notify,
  row_spc => $row_spc,
  col_spc => abs($avg_sagittal_spacing)
);

my $abs_avg_spc = abs($avg_sagittal_spacing);
$back->WriteToEmail("NewSagittalVolume:\n" .
  "  temp_mpr_volume_type : \"Sagittal\",\n" .
  "  temp_mpr_volume_w_c : $vol_wc\n" .
  "  temp_mpr_volume_w_w : $vol_ww\n" .
  "  temp_mpr_volume_position_x : $vol_pos_x\n" .
  "  temp_mpr_volume_position_y : $vol_pos_y\n" .
  "  temp_mpr_volume_position_z : $vol_pos_z\n" .
  "  temp_mpr_volume_rows : $rows\n" .
  "  temp_mpr_volume_cols : $cols\n" .
  "  temp_mpr_volume_description : $desc\n" .
  "  temp_mpr_volume_creator : $notify\n" .
  "  row_spc => $row_spc\n" .
  "  col_spc => $abs_avg_spc\n");

# Here's the loop where we read the Coronals and write the Sagittals

#   \$CoronalVolume{<y>} = {
#     rows => <rows>,
#     cols => <cols>,
#     x => <ipp_x>,
#     z => <ipp_z>,
#     pix_spc => <pix_spc>,
#     gray_file_id => <gray_file_id>,
#     gray_file_path => <gray_file_path>,
#   };
my $start_time = time;
my $i = 0;
my $ny = @CoronalYs;
for my $yi (0 .. $#CoronalYs){
  $i += 1;
  my $y = $CoronalYs[$yi];
  my $cor_info = $CoronalVolume{$y};
#print STDERR "Coronal gray file: $cor_info->{gray_file_path}\n";
  open CORONAL, "<$cor_info->{gray_file_path}" or
    die "can't open $cor_info->{gray_file_path} ($!)";
  my $cor_buff;
  my $cor_size = $cor_info->{rows} * $cor_info->{cols};
  my $br = read CORONAL,$cor_buff, $cor_size;
  unless($br == $cor_size) {
    die "Read $br vs $cor_size reading coronal " .
      "file $cor_info->{gray_file_id} $cor_info->{grey_file_path}";
  }
  for my $xi (0 .. $#SagittalXs){
    my $x = $SagittalXs[$xi];
    my $sag_info = $SagittalVolume{$x};
    my $sag_file = $sag_info->{file_name};
    my $elapsed = time - $start_time;
    $back->SetActivityStatus("Copying col $xi from " .
      "coronal $i (of $ny) appending to " .
      "$sag_file ($elapsed sec)");
    open SAG_FILE, ">>$sag_file" or
      die "Can't open >>$sag_file ($!)";
    my $buff = ExtractColumn($cor_buff, $xi, 
      $cor_info->{rows}, $cor_info->{columns});
    unless($br == $cor_info->{rows}) {
      die "read $br vs $cor_info->{rows}";
    }
    print SAG_FILE $buff;
    close SAG_FILE;
  }
  close CORONAL;
  my $elapsed = time - $start_time;
  #print STDERR "Finshed Coronal $i after $elapsed seconds\n";
}

sub ExtractColumn{
  my($image, $col_no, $num_rows, $num_cols) = @_;
  my @buff;
  for my $r (0 .. $num_rows - 1){
    my $offset = ($col_no * $num_rows) + $r;
    $buff[$r] = unpack "C", substr($image, $offset, 1);
    return pack "C",@buff;
  }
}

#   $SagittalVolume{<x>} = {
#     z => <ipp_z>,
#     y => <ipp_y>,
#     file_name => "<dir>/cor_<seq>.gray",
#     jpeg_name => "<dir>/cor_<seq>.jpeg",
#     gray_file_id => <gray_file_id>,  # added after file imported into posda
#     jpeg_file_id => <jpeg_file_id>,  # added after file imported into posda
#   };
$i = 0;
my $num_cor_slices = @SagittalXs;
for my $xi (0 .. $#SagittalXs){
  $i += 1;
  my $x = $SagittalXs[$xi];
  my $sag_slice_info = $SagittalVolume{$x};
  my $gfile = $sag_slice_info->{file_name};
  my $jfile = $sag_slice_info->{jpeg_name};
  my $elapsed = time - $start_time;
  $back->SetActivityStatus("Rendering jpeg $i ($elapsed sec)");
  # render the jpeg--
  my $cmd = "convert -endian MSB -size ${rows}x${cols} -depth 8 gray:$gfile $jfile";
  open FOO, "$cmd|";
  while(my $line = <FOO>){
  };
  close FOO;
  #-- render the jpeg--

  unless(-f $jfile) { die "jfile failed to render" }
  $elapsed = time - $start_time;
  my($gray_file_id, $jpeg_file_id);
  $back->SetActivityStatus("Importing gray_file $i ($elapsed sec)");
  my $resp = Posda::File::Import::insert_file($gfile);
  if($resp->is_error){
    die $resp->message;
  } else {
    $sag_slice_info->{gray_file_id} = $resp->file_id;
  }
  unlink $gfile;
  $back->SetActivityStatus("Importing jpeg_file $i ($elapsed sec)");
  $resp = Posda::File::Import::insert_file($jfile);
  if($resp->is_error){
    die $resp->message;
  } else {
    $sag_slice_info->{jpeg_file_id} = $resp->file_id;
  }
  unlink $jfile;
#  print STDERR "$yi - Gray file id: $sag_slice_info->{gray_file_id} " .
#    "Jpeg file id: $sag_slice_info->{jpeg_file_id}\n";
}
my $rpt = $back->CreateReport("ForSagittalVolumeCreation");
$rpt->print("key,value,x,y,z,gray_file_id,jpeg_file_id,Operation\n");
$rpt->print(
"  temp_mpr_volume_type,\"Sagittal\",,,,,,TempMprPopulateIsoTropicSagittalFromCoronalStack\n"
);
$rpt->print(
"  temp_mpr_volume_w_c,$NewSagittalVolume{temp_mpr_volume_w_c}\n" .
"  temp_mpr_volume_w_w,$NewSagittalVolume{temp_mpr_volume_w_w}\n" .
"  temp_mpr_volume_position_x,$NewSagittalVolume{temp_mpr_volume_position_x}\n" .
"  temp_mpr_volume_position_y,$NewSagittalVolume{temp_mpr_volume_position_y}\n" .
"  temp_mpr_volume_position_z,$NewSagittalVolume{temp_mpr_volume_position_z}\n" .
"  temp_mpr_volume_rows,$NewSagittalVolume{rows}\n" .
"  temp_mpr_volume_cols,$NewSagittalVolume{cols}\n" .
"  temp_mpr_volume_description,$NewSagittalVolume{temp_mpr_volume_description}\n" .
"  temp_mpr_volume_description,$desc\n" .
"  temp_mpr_volume_creator,$notify\n" .
"  row_spc,$row_spc\n" .
"  col_spc, $abs_avg_spc\n"
);
for my $xi (0 .. $#SagittalXs){
  my $x = $SagittalXs[$xi];
  my $ssi = $SagittalVolume{$x};
  $rpt->print("slice,,$x,$ssi->{y},$ssi->{z},$ssi->{gray_file_id},$ssi->{jpeg_file_id}\n");
}

$back->Finish("Done");
#my %NewSagittalVolume = (
#  temp_mpr_volume_type => "Sagittal",
#  temp_mpr_volume_w_c => $vol_wc,
#  temp_mpr_volume_w_w => $vol_ww,
#  temp_mpr_volume_position_x => $vol_pos_x,
#  temp_mpr_volume_position_y => $vol_pos_y,
#  temp_mpr_volume_position_z => $vol_pos_z,
#  temp_mpr_volume_rows => $rows,
#  temp_mpr_volume_cols => $cols,
#  temp_mpr_volume_description => $desc,
#  temp_mpr_volume_creator => $notify,
#  row_spc => $row_spc,
#  col_spc => abs($avg_sagittal_spacing)
#);

$back->Finish("Done");

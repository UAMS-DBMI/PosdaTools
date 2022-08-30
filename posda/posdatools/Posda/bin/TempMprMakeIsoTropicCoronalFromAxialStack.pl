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
TempMprMakeIsoTropicCoronalFromAxialStack.pl <?bkgrnd_id?> <activity_id> <temp_mpr_volume_id> <notify>
  <activity_id> - activity
  <temp_mpr_volume_id> - identifies temp_mpr_volume to be resampled
  <notify> - user to notify

Expects no data on <STDIN>
It is completely driven by the data in the temp_mpr_volume table and the temp_mpr_slice table for
the supplied temp_mpr_volume_id

Generally, based on the following observations:
   - for a collection of 1024 (e.g) 512x512 slices, you will need to construct 512 Coronal 
     slices with 1024 rows of 512 columns.
   - for the first axial slice, the first row will be the first row in the first coronal file,
     the second row will be the first row in the second coronal file, and so on..
   - for the second axial slice, the first row will be the second row in the first coronal file,
     the second row will be the second row in the second coronal file

So, if you could afford to have 512 file handles open at once, you could write a simple loop that 
goes through the axial in order, and then the rows in each axial and writes each row to the
coronals in order.  At the end of the loop(s), you'd have a coronal volume in the 512 files...
But I'm not confident that I can keep 512 files open, so I'm going to close the files after
each row is written, and reopen them in append mode for each new row...

This makes this program a little iffy for the following two reasons:
  - How well does append mode work in all of the virtualizations?
  - Where do I keep the coronal files while they are being constructed? (i.e do I have enough disk space?)
  - How much data segment will my program accumulate keeping info about all of these files? Enough to crash?

Bad answers to either of those questions could cause locally catastropic failures.  We'll see...
It can be good to experiment...
I am testing this in a resource poor environment..

So, laying out the algorithm:

1) Get the data from the temp_mpr_volume and temp_mpr_slice table for the axial volume and build the
   following structure:
   \$AxialVolume{<z>} = {
     pix_dim => <rows/cols>,
     x => <ipp_x>,
     y => <ipp_y>,
     pix_spc => <pix_spc>,
     gray_file_id => <gray_file_id>,
     gray_file_path => <gray_file_path>,
   };
2) Allocate a working directory in /tmp create the following descriptor of the working files in this
   directory:
   \$coronal_volume->{<ipp_y>} = {
     z => <ipp_z>,
     x => <ipp_y>,
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
my %AxialVolume;
#   \$AxialVolume{<z>} = {
#     pix_dim => <rows/cols>,
#     x => <ipp_x>,
#     y => <ipp_y>,
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
my $get_file_path = Query('FilePathByFileId');
#my $Tt;
#Query('GetTimeTag')->RunQuery(sub{
#  my($row) = @_;
#  $Tt = $row->[0];
#}, sub{});
#my $desc = "$Tt - Axial $orig_vol_id reformatted to Coronal";
my $desc = "Axial $orig_vol_id reformatted to Coronal";
my $tmpdir = &tempdir( CLEANUP => 1 );
Query('GetTempMprSliceInfo')->RunQuery(sub{
  my($row) = @_;
  my($s_offset, $gray_file_id, $jpeg_file_id) = @$row;
  my $gray_file_path;
  $get_file_path->RunQuery(sub{
    my($row) = @_;
    $gray_file_path = $row->[0];
  }, sub{}, $gray_file_id);
  $AxialVolume{$s_offset} = {
    pix_dim => $rows,
    x => $vol_pos_x,
    y => $vol_pos_y,
    pix_spc => $row_spc,
    gray_file_id => $gray_file_id,
    gray_file_path => $gray_file_path,
  };
},sub{}, $orig_vol_id);


#Get a sorted list of axial Z-values
my @AxialZs = sort {$b <=> $a} keys %AxialVolume;

my @CoronalYs;
my %CoronalVolume;
#Assuming normal axial, and all CT's have same geometry - generate list of coronal Y-values
#  from first axial
{
  my $z = $AxialZs[0];
  my $desc = $AxialVolume{$z};
  my $x = $desc->{x};
  my $y = $desc->{y};
  my $pd = $desc->{pix_dim};
  my $ps = $desc->{pix_spc};
  for my $i (0 .. $pd-1){
    push @CoronalYs, $y;
    $CoronalVolume{$y} = {
      z => $z,
      x => $x,
      file_name => "$tmpdir/cor_" .  "$i.gray",
      jpeg_name => "$tmpdir/cor_" .  "$i.jpeg",
    };
    $y = $y + $ps;
  }
}

#   $CoronalVolume{<y>} = {
#     z => <ipp_z>,
#     x => <ipp_y>,
#     file_name => "<dir>/cor_<seq>.gray",
#     jpeg_name => "<dir>/cor_<seq>.gray",
#     gray_file_id => <gray_file_id>,  # added after file imported into posda
#     jpeg_file_id => <jpeg_file_id>,  # added after file imported into posda
#   };

my $back = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$back->Daemonize;

my $first_coronal_y = $CoronalYs[0];
my $last_coronal_y = $CoronalYs[$#CoronalYs];

$back->WriteToEmail("First coronal y: $first_coronal_y\n" .
"Last coronal y: $last_coronal_y\n");

my $first_axial_z = $AxialZs[0];
my $last_axial_z = $AxialZs[$#AxialZs];
my $num_axial_z = $#AxialZs;
my $avg_axial_spacing = ($last_axial_z - $first_axial_z)/$num_axial_z;
$back->WriteToEmail("First axial z: $first_axial_z\n" .
  "Last axial z: $last_axial_z\n" .
  "Num axials : $num_axial_z\n" .
  "Avg Spacing: $avg_axial_spacing\n");

my %NewCoronalVolume = (
  temp_mpr_volume_type => "Coronal",
  temp_mpr_volume_w_c => $vol_wc,
  temp_mpr_volume_w_w => $vol_ww,
  temp_mpr_volume_position_x => $vol_pos_x,
  temp_mpr_volume_position_y => $first_coronal_y,
  temp_mpr_volume_position_z => $first_axial_z,
  temp_mpr_volume_rows => $num_axial_z,
  temp_mpr_volume_cols => $cols,
  temp_mpr_volume_description => $desc,
  temp_mpr_volume_creator => $notify,
  row_spc => $row_spc,
  col_spc => abs($avg_axial_spacing)
);

my $abs_avg_spc = abs($avg_axial_spacing);
$back->WriteToEmail("NewCoronalVolume:\n" .
  "  temp_mpr_volume_type : \"Coronal\",\n" .
  "  temp_mpr_volume_w_c : $vol_wc\n" .
  "  temp_mpr_volume_w_w : $vol_ww\n" .
  "  temp_mpr_volume_position_x : $vol_pos_x\n" .
  "  temp_mpr_volume_position_y : $first_coronal_y\n" .
  "  temp_mpr_volume_position_z : $first_axial_z\n" .
  "  temp_mpr_volume_rows : $num_axial_z\n" .
  "  temp_mpr_volume_cols : $cols\n" .
  "  temp_mpr_volume_description : $desc\n" .
  "  temp_mpr_volume_creator : $notify\n" .
  "  row_spc => $row_spc\n" .
  "  col_spc => $abs_avg_spc\n");
#print STDERR "NewCoronalVolume: ";
#Debug::GenPrint($dbg, \%NewCoronalVolume, 1);
#print STDERR "\n";
#Debug::GenPrint($dbg, \%CoronalVolume, 1);
#print STDERR "\n";

# Here's the loop where we read the Axials and write the Coronals

#   \$AxialVolume{<z>} = {
#     pix_dim => <rows/cols>,
#     x => <ipp_x>,
#     y => <ipp_y>,
#     pix_spc => <pix_spc>,
#     gray_file_id => <gray_file_id>,
#     gray_file_path => <gray_file_path>,
#   };
my $start_time = time;
my $i = 0;
my $nz = @AxialZs;
for my $zi (0 .. $#AxialZs){
  $i += 1;
  my $z = $AxialZs[$zi];
  my $ax_info = $AxialVolume{$z};
  open AXIAL, "<$ax_info->{gray_file_path}" or 
    die "can't open $ax_info->{gray_file_path} ($!)";
  for my $yi (0 .. $#CoronalYs){
    my $y = $CoronalYs[$yi];
    my $cor_info = $CoronalVolume{$y};
    my $cor_file = $cor_info->{file_name};
    my $elapsed = time - $start_time;
    $back->SetActivityStatus("Copying row $yi from " .
      "axial $i (of $nz) appending to " .
      "$cor_file ($elapsed sec)");
    open COR_FILE, ">>$cor_file" or 
      die "Can't open >>$cor_file ($!)";
    my $buff;
    my $br = read AXIAL, $buff, $ax_info->{pix_dim};
    unless($br == $ax_info->{pix_dim}) {
      die "read $br vs $ax_info->{pix_dim}";
    }
    print COR_FILE $buff;
    close COR_FILE;
  }
  close AXIAL;
  my $elapsed = time - $start_time;
  #print STDERR "Finshed Axial $i after $elapsed seconds\n";
}
#   $CoronalVolume{<y>} = {
#     z => <ipp_z>,
#     x => <ipp_y>,
#     file_name => "<dir>/cor_<seq>.gray",
#     jpeg_name => "<dir>/cor_<seq>.jpeg",
#     gray_file_id => <gray_file_id>,  # added after file imported into posda
#     jpeg_file_id => <jpeg_file_id>,  # added after file imported into posda
#   };
$i = 0;
my $num_cor_slices = @CoronalYs;
for my $yi (0 .. $#CoronalYs){
  $i += 1;
  my $y = $CoronalYs[$yi];
  my $cor_slice_info = $CoronalVolume{$y};
  my $gfile = $cor_slice_info->{file_name};
  my $jfile = $cor_slice_info->{jpeg_name};
  my $elapsed = time - $start_time;
  $back->SetActivityStatus("Rendering jpeg $i ($elapsed sec)");
  # render the jpeg--
  my $cmd = "convert -endian MSB -size ${rows}x${nz} -depth 8 gray:$gfile $jfile";
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
    $cor_slice_info->{gray_file_id} = $resp->file_id;
  }
  unlink $gfile;
  $back->SetActivityStatus("Importing jpeg_file $i ($elapsed sec)");
  $resp = Posda::File::Import::insert_file($jfile);
  if($resp->is_error){
    die $resp->message;
  } else {
    $cor_slice_info->{jpeg_file_id} = $resp->file_id;
  }
  unlink $jfile;
#  print STDERR "$yi - Gray file id: $cor_slice_info->{gray_file_id} " .
    "Jpeg file id: $cor_slice_info->{jpeg_file_id}\n";
}
my $rpt = $back->CreateReport("ForCoronalVolumeCreation");
$rpt->print("key,value,x,y,z,gray_file_id,jpeg_file_id,Operation\n");
$rpt->print(
"  temp_mpr_volume_type,\"Coronal\",,,,,,TempMprPopulateIsoTropicCoronalFromAxialStack\n"
);
$rpt->print(
"  temp_mpr_volume_w_c,$vol_wc\n" .
"  temp_mpr_volume_w_w,$vol_ww\n" .
"  temp_mpr_volume_position_x,$vol_pos_x\n" .
"  temp_mpr_volume_position_y,$first_coronal_y\n" .
"  temp_mpr_volume_position_z,$first_axial_z\n" .
"  temp_mpr_volume_rows,$num_axial_z\n" .
"  temp_mpr_volume_cols,$cols\n" .
"  temp_mpr_volume_description,$desc\n" .
"  temp_mpr_volume_creator,$notify\n" .
"  row_spc,$row_spc\n" .
"  col_spc, $abs_avg_spc\n"
);
for my $yi (0 .. $#CoronalYs){
  my $y = $CoronalYs[$yi];
  my $csi = $CoronalVolume{$y};
  $rpt->print("slice,,$csi->{x},$y,$csi->{z},$csi->{gray_file_id},$csi->{jpeg_file_id}\n");
}

$back->Finish("Done");

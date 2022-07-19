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
TempMprTransposeVolume.pl <?bkgrnd_id?> <activity_id> <temp_mpr_volume_id> <notify>
  <activity_id> - activity
  <temp_mpr_volume_id> - identifies temp_mpr_volume to be resampled
  <notify> - user to notify

Expects no data on <STDIN>
It is completely driven by the data in the temp_mpr_volume table and the temp_mpr_slice table for
the supplied temp_mpr_volume_id
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
#print STDERR "Coronal rows: $rows\n";
#print STDERR "Coronal cols: $cols\n";
my $get_file_path = Query('FilePathByFileId');
my $Desc = "Coronal $orig_vol_id Transposed";
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


my $back = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$back->Daemonize;

my $first_coronal_y = $CoronalYs[0];
my $last_coronal_y = $CoronalYs[$#CoronalYs];

$back->WriteToEmail("First coronal y: $first_coronal_y\n" .
"Last coronal y: $last_coronal_y\n");
#print STDERR "First coronal y: $first_coronal_y\n" .
#"Last coronal y: $last_coronal_y\n";


my %TransposedCoronalVolume = (
  temp_mpr_volume_type => "TransposedCoronal",
  temp_mpr_volume_w_c => $vol_wc,
  temp_mpr_volume_w_w => $vol_ww,
  temp_mpr_volume_position_x => $vol_pos_x,
  temp_mpr_volume_position_y => $vol_pos_y,
  temp_mpr_volume_position_z => $vol_pos_z,
  temp_mpr_volume_rows => $cols,
  temp_mpr_volume_cols => $rows,
  temp_mpr_volume_description => $Desc,
  temp_mpr_volume_creator => $notify,
  row_spc => $row_spc,
  col_spc => $row_spc
);

my $rpt = $back->CreateReport("ForTransposedCoronalVolumeCreation");
$rpt->print("key,value,x,y,z,gray_file_id,jpeg_file_id,Operation\n");
$rpt->print(
"  temp_mpr_volume_type,\"TransposedCoronal\",,,,,,TempMprRotateTransposedConronalToSagittal\n"
);
$rpt->print(
"  temp_mpr_volume_w_c,$TransposedCoronalVolume{temp_mpr_volume_w_c}\n" .
"  temp_mpr_volume_w_w,$TransposedCoronalVolume{temp_mpr_volume_w_w}\n" .
"  temp_mpr_volume_position_x,$TransposedCoronalVolume{temp_mpr_volume_position_x}\n" .
"  temp_mpr_volume_position_y,$TransposedCoronalVolume{temp_mpr_volume_position_y}\n" .
"  temp_mpr_volume_position_z,$TransposedCoronalVolume{temp_mpr_volume_position_z}\n" .
"  temp_mpr_volume_rows,$TransposedCoronalVolume{temp_mpr_volume_rows}\n" .
"  temp_mpr_volume_cols,$TransposedCoronalVolume{temp_mpr_volume_cols}\n" .
"  temp_mpr_volume_description,$TransposedCoronalVolume{temp_mpr_volume_description}\n" .
"  temp_mpr_volume_description,$Desc\n" .
"  temp_mpr_volume_creator,$notify\n" .
"  row_spc,$row_spc\n" .
"  col_spc,$row_spc\n"
);

# Here's the loop where we read the Files, Transpose, Jpeg, Insert and write row

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
  my $gfile = $cor_info->{gray_file_path};
  my $tgfile = "$tmpdir/Trans_$i.gray";
  my $jfile = "$tmpdir/Trans_$i.jpeg";
  my $tgfile_id;
  my $jfile_id;
  my $elapsed = time - $start_time;
  $back->SetActivityStatus("Transposing Gray file  $i ($elapsed sec)");
  my $cmd = "TransposeGrayFile.pl $gfile $rows $cols $tgfile";
#print "Transpose command: $cmd\n";
  open TRANS, "$cmd|" or die "Can't open \"$cmd\" for reading (!$)";
  while(my $line = <TRANS>){
   # print STDERR "$line";
  }
  close TRANS;
  unless(-r $tgfile) { die "transposed file ($tgfile) not readable" }
  $cmd = "convert -endian MSB -size ${rows}x${cols} -depth 8 gray:$tgfile $jfile";
#print "Convert command: $cmd\n";
  open FOO, "$cmd|";
  while(my $line = <FOO>){
    print $line;
  };
  close FOO;
  unless(-r $jfile) { die "jpeg file ($jfile) not readable" }

  $elapsed = time - $start_time;
  $back->SetActivityStatus("Importing transposed_gray_file $i ($elapsed sec)");
  my $resp = Posda::File::Import::insert_file($tgfile);
  if($resp->is_error){
    die $resp->message;
  } else {
    $tgfile_id = $resp->file_id;
  }
  unlink $tgfile;
  $elapsed = time - $start_time;
  $back->SetActivityStatus("Importing jpeg_file $i ($elapsed sec)");
  $resp = Posda::File::Import::insert_file($jfile);
  if($resp->is_error){
    die $resp->message;
  } else {
    $jfile_id = $resp->file_id;
  }
  unlink $jfile;
  $rpt->print("slice,,$vol_pos_x,$y,$vol_pos_z,$tgfile_id,$jfile_id}\n");
}
$back->Finish("Done");

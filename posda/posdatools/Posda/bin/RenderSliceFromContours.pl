#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::FlipRotate;
use File::Temp qw/ tempfile /;
use Debug;
my $dbg = sub { print @_ };

my $usage = <<EOF;
RenderRoiSlicesFromContours.pl <?bkgrnd_id?> <activity_id> <notify>
or
RenderSliceFromContours.pl -h

The script expects lines in the following format on STDIN:
Structure Set File Id: <file_id>
Structure Set File Path: <path>
BEGIN ROI: <roi_num>
BEGIN SLICE: <image_file_id>
Iop: (x,y,z),(x,y,z)
Ipp: (x,y,z)
Pix sp: (r,c)
Rows: <rows>
Cols: <cols>
CONTOUR: (offset,length,num_pts)
...
END SLICE
... (more slices)
END ROI
... (more rois

EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 2){
  die "$usage\n";
}

my ($invoc_id, $activity_id, $notify) = @ARGV;
my $back = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$back->Daemonize;

$back->WriteToEmail(
  "RenderRoiSlicesFromContours.pl $invoc_id $notify $activity_id\n");
my $ss_file_id;
my $ss_file_path;
my %Rois;
my $mode = "search";
my $curr_roi;
my $curr_slice;
my $line_no = 0;
while(my $line = <STDIN>){
  $line_no += 1;
  chomp $line;
  if($mode eq "search"){
    if($line =~ /^Structure Set File Id:\s*(\d+)\s*$/){
      $ss_file_id = $1;
      next;
    }
    if($line =~ /^Structure Set File Path:\s*(.+)\s*$/){
      $ss_file_path = $1;
      next;
    }
    if($line =~/^BEGIN ROI:\s*(.*)\s*$/){
      $curr_roi = $1;
      if(exists $Rois{$curr_roi}){
        die "$curr_roi is duplicated at line $line_no";
      }
      $Rois{$curr_roi} = {};
      $mode = "in_roi";
      next;
    }
    die "Unrecognizable line in mode $mode at line no: $line_no:\n" .
      "\t\" $line\"";
  } elsif ($mode eq "in_roi"){
    if($line =~ /^END ROI/){
      $mode = "search";
      next;
    }
    if($line =~ /^BEGIN SLICE:\s*(\d+)\s*$/){
      $mode = "in_slice";
      $curr_slice = $1;
      if(exists $Rois{$curr_roi}->{$curr_slice}){
        die "$curr_slice slice is duplicated within roi $curr_roi " .
          "at line $line_no";
      }
      $Rois{$curr_roi}->{$curr_slice} = {
        contours => []
      };
    }
  } elsif ($mode eq "in_slice"){
    my $slice_p = $Rois{$curr_roi}->{$curr_slice};
    if($line =~ /^END SLICE/){
      $mode = "in_roi";
    } elsif(
      $line =~
         /^Iop:\s*\(([^,]+),([^,]+),([^\)]+)\),\(([^,]+),([^,]+),([^\)]+)\)\s*$/
    ){
      $slice_p->{iop} = [[$1,$2,$3],[$4,$5,$6]];
    } elsif($line =~ /^Ipp:\s*\(([^,]+),([^,]+),([^\)]+)\)\s*$/){
      $slice_p->{ipp} = [$1,$2,$3];
    } elsif($line =~ /^Pix sp:\s*\(([^,]+),([^\)]+)\)\s*$/){
      $slice_p->{pix_sp} = [$1,$2];
    } elsif($line =~ /^Rows:\s*(.*)\s*$/){
      $slice_p->{rows} = $1;
    } elsif($line =~ /^Cols:\s*(.*)\s*$/){
      $slice_p->{cols} = $1;
    } elsif($line =~ /^CONTOUR:\s*\(([^,]+),([^,]+),([^\)]+)\)\s*$/){
      push @{$slice_p->{contours}}, {
        offset =>$1, length => $2, num_pts => $3
      };
    } else {
      print "Line matched no pattern in $mode\n";
    }
  } else {
    die "unknown mode \"$mode\"";
  }
}
my $data_set_start;
Query('GetDatasetStart')->RunQuery(sub{
  my($row) = @_;
  $data_set_start = $row->[0];
}, sub {}, $ss_file_id);


open STRUCT, "<$ss_file_path" or die "Can't open structure set file";
my $num_rois = keys %Rois;
my $num_tot_slice = 0;
for my $roi(keys %Rois){
  my $ns = keys %{$Rois{$roi}};
  $num_tot_slice += $ns;
}
my $roi_count = 0;
my $total_slices = 0;
for my $i (keys %Rois){
  $roi_count += 1;
  my $num_slices = keys %{$Rois{$i}};
  my $slice_count = 0;
  for my $j (keys %{$Rois{$i}}){
    my $cont_file_path;
    my $slice_file_path;
    my $c_fhs;
    {
      my $t_fhs;
      ($c_fhs, $cont_file_path) = tempfile();
      ($t_fhs, $slice_file_path) = tempfile();
    }
    $slice_count += 1;
    $total_slices += 1;
    $back->SetActivityStatus("Roi $i ($roi_count of $num_rois), ".
      "slice $j ($slice_count of $num_slices) " .
      "tot: $total_slices of $num_tot_slice");
    my $info = $Rois{$i}->{$j};
    my @iop_6;
    $iop_6[0] = $info->{iop}->[0]->[0];
    $iop_6[1] = $info->{iop}->[0]->[1];
    $iop_6[2] = $info->{iop}->[0]->[2];
    $iop_6[3] = $info->{iop}->[1]->[0];
    $iop_6[4] = $info->{iop}->[1]->[1];
    $iop_6[5] = $info->{iop}->[1]->[2];
    my $rows = $info->{rows};
    my $cols = $info->{cols};
    my $ipp = $info->{ipp};
    my $iop = \@iop_6;
    my $pix_sp = $info->{pix_sp};
    my $contours = $info->{contours};
    # Extract 3D contours and convert
    my $num_points = 0;
    my $num_contours = @$contours;
    for my $c (@$contours){
      my $offset = $c->{offset} + $data_set_start;
      my $length = $c->{length};
      my $num_pts = $c->{num_pts};
      $num_points += $num_pts;
      unless(seek STRUCT, $offset, 0){
        die "Can't seek structure to $offset";
      }
      my $text;
      my $len = read STRUCT, $text, $length;
      unless($len == $length){
        die "Read wrong length ($len vs $length)";
      }
      my @nums = split(/\\/, $text);
      my $num_n = @nums;
      unless(($num_n % 3) == 0){
        die "Not an integral number of points ($num_n):\n$text\n";
      }
      my @pts;
      for my $j (0 .. $num_pts - 1){
        $pts[$j] = [$nums[$j * 3], $nums[($j * 3) + 1], $nums[($j * 3)+ 2]];
      }
      my $first = $pts[0];
      my $last = $pts[$#pts];
      unless(
        $first->[0] == $last->[0] &&
        $first->[1] == $last->[1] &&
        $first->[2] == $last->[2]
      ){
        push @pts, $pts[0];
      }
      # Now convert to pixel space and write to cont_file
      print $c_fhs "BEGIN\n";
      my $z_dist = 0;
      for my $pt (@pts){
        my $pix_pt = Posda::FlipRotate::ToPixCoords(
          $iop, $ipp, $rows, $cols, $pix_sp, $pt);
        if($pix_pt->[2] > $z_dist){
          $z_dist = $pix_pt->[2];
        }
        print $c_fhs "$pix_pt->[0],$pix_pt->[1]\n";
      }
      print $c_fhs "END\n";
    }
    close $c_fhs;
    # Create compressed bitmap file
    my $cmd = "cat $cont_file_path | ContourToBitmapPixCoordsOnly.pl " .
     "$rows $cols $slice_file_path";
    open CMD, "$cmd|";
    my($total_ones, $total_zeros, $c_bytes, $c_ratio);
    while(my $line = <CMD>){
      chomp $line;
      if($line =~ /^total ones: (.*)$/){
        $total_ones = $1;
      }elsif($line =~ /^total zeros: (.*)$/){
        $total_zeros = $1;
      }elsif($line =~ /^bytes written: (.*)$/){
        $c_bytes = $1;
      }elsif($line =~ /^compression: (.*)$/){
        $c_ratio = $1;
      }
    }
    my $pbm_path = "$slice_file_path.pbm";
    $cmd = "cat $slice_file_path|CmdCtoPbm.pl rows=$rows cols=$cols >$pbm_path";
    `$cmd`;
    my $png_path = "$slice_file_path.png";
    $cmd = "convert $pbm_path $png_path";
    `$cmd`;
    my $contour_slice_file_id;
    $cmd = "ImportSingleFileIntoPosdaAndReturnId.pl \"$cont_file_path\" " .
      "\"2D contours from SS ROI\"";
    my $res = `$cmd`;
    if($res =~ /File id: (.*)/){
      $contour_slice_file_id = $1;
    };
    my $segmentation_slice_file_id;
    $cmd = "ImportSingleFileIntoPosdaAndReturnId.pl \"$slice_file_path\" " .
      "\"Compressed Bitmap from 2D Contours\"";
    $res = `$cmd`;
    if($res =~ /File id: (.*)/){
      $segmentation_slice_file_id = $1;
    };
    my $png_slice_file_id;
    $cmd = "ImportSingleFileIntoPosdaAndReturnId.pl \"$png_path\" " .
      "\"Png from Compressed Bitmap\"";
    $res = `$cmd`;
    if($res =~ /File id: (.*)/){
      $png_slice_file_id = $1;
    };
    unlink($cont_file_path);
    unlink($slice_file_path);
    unlink($pbm_path);
    unlink($png_path);
    my $existing_row;
    Query('GetStructContoursToSegByRoiAndImageIdAndStructFileId')->RunQuery(sub{
      my($row) = @_;
      $existing_row = $row;
    }, sub {},
      $i,
      $j,
      $ss_file_id
    );
    unless(defined $existing_row){
      Query('InsertStructContoursToSeg')->RunQuery(sub{
      }, sub{},
        $ss_file_id,
        $j,
        $i,
        $rows,
        $cols,
        $num_contours,
        $num_points,
        $total_ones,
        $contour_slice_file_id,
        $segmentation_slice_file_id,
        $png_slice_file_id
      );
    }
  }
}
close STRUCT;

$back->WriteToEmail("Rendered $total_slices in $roi_count rois\n");
$back->Finish("Done: rendered $total_slices in $roi_count rois");

#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
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
      $ss_file_id = $1;
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

print "Parsed struct: ";
Debug::GenPrint($dbg, \%Rois, 1);
print "\n";

$back->Finish("Done");

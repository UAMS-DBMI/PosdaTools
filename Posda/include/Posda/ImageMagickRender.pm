#
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/ImageMagickRender.pm,v $
#$Date: 2012/02/07 13:41:43 $
#$Revision: 1.14 $
#
#Copyright 2011, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::HttpApp::HttpObj;
use Dispatch::Select;
use PipeChildren;
use Posda::Transforms;
package Posda::ImageMagickRender;
use vars qw( @ISA );
@ISA = ( "Posda::HttpObj" );
my $Revision = 'unknown';
if('$Revision: 1.14 $' =~ /^[^:]*:\s([0-9\.]*)\s*\$$/){
  $Revision = $1;
}
sub Revision {
  my($this_or_class) = @_;
  return $Revision;
}
#
# descriptor  = {
#     iop => [ x, y, z] (dicom iop)
#     ipp => [ x, y, z] (dicom ipp)
#     gray_file => <file_name> (pixel data in gray scale UNSIGNED)
#     ds_digest => <ds_dig> (dataset digest of dicom for which gray_file
#                            is pixel data (so we can request the
#                            pixel extractor to extract it if necessary))
#     rows => <rows>,
#     cols => <cols>,
#     temp_dir => <temp_dir>
#     bits_allocated => <bits_allocated>,
#     pix_sp => <pix_sp>,
#     window_width => <window_width>, (corrected for UNSIGNED scaling if CT)
#     window_center => <window_center>, (corrected for UNSIGNED scaling if CT)
#     contours => [
#       <file_name>,
#       <file_name>,
#       ...
#     ],
#     max_contour_dist => <mm>,
#     base_c_file_name => <file_name>,
#     op => <op>
#     op_contours => [
#       <file_name>,
#       <file_name>,
#       ...
#     ],
#     ImageFile => <dest_file_name>,
#     TypeOfRendering => [Mask | Contour | NormalizedContour],
#     OverlayImage => [Y | N],
#   },
#
sub new {
  my($class, $session, $path, $descriptor) = @_;
  my $this = Posda::HttpObj::new($class, $session, $path);
  $this->{revision} = $Revision;
  $this->{descrip} = $descriptor;
  $this->StartRendering;
  return $this;
}
sub ImageFile{
  my($this) = @_;
  if($this->{Status} eq "Rendered"){
    return $this->{ImageFile};
  }
  return undef;
}
sub Status {
  my($this) = @_;
  return($this->{Status});
}
sub StartRendering{
  my($this) = @_;
  $this->{Status} = "StartingRendering";
  $this->{ImageFile} = "$this->{descrip}->{temp_dir}/" .
    "$this->{descrip}->{ds_digest}" .
    "_$this->{descrip}->{TypeOfRendering}.png";
  if(-f $this->{ImageFile}) { unlink $this->{ImageFile}; }
  if(
    $this->{descrip}->{TypeOfRendering} eq "Mask" &&
    $this->{descrip}->{OverlayImage} eq "Y"
  ){
    $this->{Status} = "Image Overlay on Bitmaps not currently supported";
    $this->AutoRefresh;
    return;
  }
  if(
    $this->{descrip}->{OverlayImage} eq "Y" &&
    !(defined $this->{descrip}->{gray_file})
  ){
    $this->{Status} = "Error: No gray file specifed";
    return;
  }
  if(
    $this->{descrip}->{OverlayImage} eq "Y" &&
    !(-f $this->{descrip}->{gray_file})
  ){
    $this->{Awaiting}->{"Grayfile Rendering"} = 1;
    $this->StartGrayFileRendering;
  }
  if($this->{descrip}->{TypeOfRendering} eq "NormalizedContour"){
    $this->{Awaiting}->{"Pipeline"} = 1;
    $this->RenderNormalizedContours;
  }
  if($this->{descrip}->{TypeOfRendering} eq "Mask"){
    $this->{Awaiting}->{"Pipeline"} = 1;
    if($this->{descrip}->{op} eq "none"){
      $this->RenderMask;
    } else {
      $this->RenderOpMask;
    }
  }
  $this->Render;
}
sub StartGrayFileRendering{
  my($this) = @_;
  my $pix_extract = $this->get_obj("FileManager/PixelExtractor");
  if($pix_extract && $pix_extract->can("DumpedImageByDsDigest")){
    $pix_extract->DumpedImageByDsDigest($this->{descrip}->{ds_digest});
    $this->WaitGrayFileRendering;

    return;
  } else {
    print STDERR "no pixel rendering\n";
    $this->{Awaiting}->{"Grayfile Rendering Not Available"} = 1;
  }
}
sub WaitGrayFileRendering{
  my($this) = @_;
  my $waiter = sub {
    my($disp) = @_;
    if(
      $this->{descrip}->{OverlayImage} eq "Y" &&
      !(-f $this->{descrip}->{gray_file})
    ){ 
      $disp->timer(1);
    } else {
      delete($this->{Awaiting}->{"Grayfile Rendering"});
    }
  };
  my $back = Dispatch::Select::Background->new($waiter);
  $back->timer(1);
}
sub RenderNormalizedContours{
  my($this) = @_;
  unless(defined $this->{descrip}->{op}) {$this->{descrip}->{op} = "none"}
  if($this->{descrip}->{op} eq "none"){
    $this->BuildNormalizePipeline;
  } else {
    $this->BuildOpPipeline;
  }
}
sub BuildNormalizePipeline{
  my($this) = @_;
  $this->{PipelineType} = "RenderNormalizedContours";
  $this->{NormalizedBaseName} = 
    "$this->{descrip}->{base_c_file_name}_normalized";
  my $file_list = $this->{descrip}->{contours};
  my $to_cbm = PipeChildren::GetSocketPair;
  my $cbm_status = PipeChildren::GetSocketPair;
  my $cbm_to_bmc = PipeChildren::GetSocketPair;
  my $bmc_status = PipeChildren::GetSocketPair;
  my $cbm_fd_map = {
    in => $to_cbm->{from},
    out => $cbm_to_bmc->{to},
    status => $cbm_status->{to},
  };
  my $bmc_fd_map = {
    in => $cbm_to_bmc->{from},
    status => $bmc_status->{to},
  };
  my $d = $this->{descrip};
  my $cbm_other_args = {
    rows => $d->{rows},
    cols => $d->{cols},
    ulx => $d->{ipp}->[0],
    uly => $d->{ipp}->[1],
    ulz => $d->{ipp}->[2],
    rowdcosx => $d->{iop}->[0],
    rowdcosy => $d->{iop}->[1],
    rowdcosz => $d->{iop}->[2],
    coldcosx => $d->{iop}->[3],
    coldcosy => $d->{iop}->[4],
    coldcosz => $d->{iop}->[5],
    rowspc => $d->{pix_sp}->[0],
    colspc => $d->{pix_sp}->[1],
    ztol => 1,
  };
  my $bmc_other_args = {
    rows => $d->{rows},
    cols => $d->{cols},
    ulx => $d->{ipp}->[0],
    uly => $d->{ipp}->[1],
    ulz => $d->{ipp}->[2],
    rowdcosx => $d->{iop}->[0],
    rowdcosy => $d->{iop}->[1],
    rowdcosz => $d->{iop}->[2],
    coldcosx => $d->{iop}->[3],
    coldcosy => $d->{iop}->[4],
    coldcosz => $d->{iop}->[5],
    rowspc => $d->{pix_sp}->[0],
    colspc => $d->{pix_sp}->[1],
    base_file => $this->{NormalizedBaseName},
  };
  $this->{num_children} = 0;
  my $cbm_pid =
    PipeChildren::Spawn("ContourToBitMap.pl", $cbm_fd_map, $cbm_other_args);
  $this->{num_children} += 1;
  my $to_pbm_pid =
    PipeChildren::Spawn("BitMapToContour.pl", 
      $bmc_fd_map, $bmc_other_args);
  $this->{num_children} += 1;
  Dispatch::Select::Socket->new(
    $this->ChildHarvester($cbm_pid, "ContourToBitMap"),
    $cbm_status->{from}
  )->Add("reader");
  Dispatch::Select::Socket->new(
    $this->ChildHarvester(
       $to_pbm_pid, 
       "BitMapToContour.pl", "CollectContoursFromBitmap"
    ),
    $bmc_status->{from}
  )->Add("reader");
  my $to = $to_cbm->{to};
  for my $i (@$file_list){
    print $to "BEGIN CONTOUR\n";
    open my $cont, "<", "$i" or die "can't open $i";
    while (my $line = <$cont>){
      print $to $line;
    }
    print $to "\nEND CONTOUR\n";
  }
  close $to;
}
#sub BuildOpPipeline{
#  my($this) = @_;
#  if($this->{descrip}->{op} eq "intersect"){
#    $this->BuildIntersectPipeline;
#  } elsif($this->{descrip}->{op} eq "union") {
#    $this->BuildIntersectPipeline;
#  } elsif($this->{descrip}->{op} eq "minus") {
#    $this->BuildIntersectPipeline;
#  }
#}
sub BuildOpPipeline{
  my($this) = @_;
  $this->{NormalizedContours} = [];
  $this->{PipelineType} = "RenderNormalizedContours";
  $this->{NormalizedBaseName} = 
    "$this->{descrip}->{base_c_file_name}_op_contours";
  my $file_list = $this->{descrip}->{contours};
  my $op_file_list = $this->{descrip}->{op_contours};
  my $to_cbm1 = PipeChildren::GetSocketPair;
  my $to_cbm2 = PipeChildren::GetSocketPair;
  my $cbm1_status = PipeChildren::GetSocketPair;
  my $cbm2_status = PipeChildren::GetSocketPair;
  my $cbm1_to_int = PipeChildren::GetSocketPair;
  my $cbm2_to_int = PipeChildren::GetSocketPair;
  my $int_to_bmc = PipeChildren::GetSocketPair;
  my $int_status = PipeChildren::GetSocketPair;
  my $bmc_status = PipeChildren::GetSocketPair;
  my $cbm1_fd_map = {
    in => $to_cbm1->{from},
    out => $cbm1_to_int->{to},
    status => $cbm1_status->{to},
  };
  my $cbm2_fd_map = {
    in => $to_cbm2->{from},
    out => $cbm2_to_int->{to},
    status => $cbm2_status->{to},
  };
  my $int_fd_map = {
    in1 => $cbm1_to_int->{from},
    in2 => $cbm2_to_int->{from},
    out => $int_to_bmc->{to},
    status => $int_status->{to},
  };
  my $bmc_fd_map = {
    in => $int_to_bmc->{from},
    status => $bmc_status->{to},
  };
  my $d = $this->{descrip};
  my $cbm1_other_args = {
    rows => $d->{rows},
    cols => $d->{cols},
    ulx => $d->{ipp}->[0],
    uly => $d->{ipp}->[1],
    ulz => $d->{ipp}->[2],
    rowdcosx => $d->{iop}->[0],
    rowdcosy => $d->{iop}->[1],
    rowdcosz => $d->{iop}->[2],
    coldcosx => $d->{iop}->[3],
    coldcosy => $d->{iop}->[4],
    coldcosz => $d->{iop}->[5],
    rowspc => $d->{pix_sp}->[0],
    colspc => $d->{pix_sp}->[1],
    ztol => 1,
  };
  my $cbm2_other_args = $cbm1_other_args;
  my $op = "CMP";
  if($this->{descrip}->{op} eq "intersect"){
    $op = "AND";
  } elsif($this->{descrip}->{op} eq "union") {
    $op = "OR";
  }
  my $int_other_args = {
    num => ($d->{rows} * $d->{cols}) / 8,
    depth => 2,
    op => $op,
  };
  my $bmc_other_args = {
    rows => $d->{rows},
    cols => $d->{cols},
    ulx => $d->{ipp}->[0],
    uly => $d->{ipp}->[1],
    ulz => $d->{ipp}->[2],
    rowdcosx => $d->{iop}->[0],
    rowdcosy => $d->{iop}->[1],
    rowdcosz => $d->{iop}->[2],
    coldcosx => $d->{iop}->[3],
    coldcosy => $d->{iop}->[4],
    coldcosz => $d->{iop}->[5],
    rowspc => $d->{pix_sp}->[0],
    colspc => $d->{pix_sp}->[1],
    base_file => $this->{NormalizedBaseName},
  };
  $this->{num_children} = 0;
  my $cbm1_pid =
    PipeChildren::Spawn("ContourToBitMap.pl", $cbm1_fd_map, $cbm1_other_args);
  $this->{num_children} += 1;
  my $cbm2_pid =
    PipeChildren::Spawn("ContourToBitMap.pl", $cbm2_fd_map, $cbm2_other_args);
  $this->{num_children} += 1;
  my $int_pid =
    PipeChildren::Spawn("PixManip.pl", $int_fd_map, $int_other_args);
  $this->{num_children} += 1;
  my $to_pbm_pid =
    PipeChildren::Spawn("BitMapToContour.pl", 
      $bmc_fd_map, $bmc_other_args);
  $this->{num_children} += 1;
  Dispatch::Select::Socket->new(
    $this->ChildHarvester($cbm1_pid, "ContourToBitMap1"),
    $cbm1_status->{from}
  )->Add("reader");
  Dispatch::Select::Socket->new(
    $this->ChildHarvester($cbm2_pid, "ContourToBitMap2"),
    $cbm2_status->{from}
  )->Add("reader");
  Dispatch::Select::Socket->new(
    $this->ChildHarvester($int_pid, "IntersectBitMaps"),
    $int_status->{from}
  )->Add("reader");
  Dispatch::Select::Socket->new(
    $this->ChildHarvester(
       $to_pbm_pid, 
       "BitMapToContour", "CollectContoursFromBitmap"
    ),
    $bmc_status->{from}
  )->Add("reader");
  my $to = $to_cbm1->{to};
  for my $i (@$file_list){
    print $to "BEGIN CONTOUR\n";
    open my $cont, "<", "$i" or die "can't open $i";
    while (my $line = <$cont>){
      print $to $line;
    }
    print $to "\nEND CONTOUR\n";
  }
  close $to;
  $to = $to_cbm2->{to};
  for my $i (@$op_file_list){
    print $to "BEGIN CONTOUR\n";
    open my $cont, "<", "$i" or die "can't open $i";
    while (my $line = <$cont>){
      print $to $line;
    }
    print $to "\nEND CONTOUR\n";
  }
  close $to;
}
sub ChildHarvester{
  my($this, $pid, $child_name, $reply_processor) = @_;
  my $reply = "";
  my $processed_reply;
  my $foo = sub {
    my($disp, $sock) = @_;
    my $count = sysread($sock, $reply, 1024, length($reply));
    unless($count){
      $disp->Remove;
      unless($reply =~ /^OK/ || defined($reply_processor)){
        print "Child $child_name ($pid) completed: \"$reply\"\n";
      }
      waitpid $pid, 0;
      if(defined($reply_processor)){
        if($this->can($reply_processor)){
          $processed_reply = $this->$reply_processor($reply);
        } else {
          print STDERR "no method $reply_processor for processing reply\n";
        }
      }
      $this->{num_children}--;
      if($this->{num_children} <= 0){
        delete $this->{num_children};
        $this->PipelineComplete($processed_reply);
      }
    }
  };
}
sub CollectContoursFromBitmap{
  my($this, $reply) = @_;
  my @lines = split(/\n/, $reply);
  $this->{NormalizedContours} = [];
  for my $line(@lines){
    if($line =~ /^ContourFile: (.*)$/){
      push(@{$this->{NormalizedContours}}, $1);
    } elsif ($line =~ /^Finished: (.*)$/){
      my $status = $1;
      unless($status eq "OK") {
        print STDERR "Bad Status ($status) collecting normalized contours\n";
      }
    }
  }
}
sub PipelineComplete{
  my($this, $processed_reply) = @_;
  delete $this->{Awaiting}->{Pipeline};
  $this->Render;
}
sub RenderMask{
  my($this) = @_;
  $this->{PipelineType} = "RenderBitMap";
  my $file_list = $this->{descrip}->{contours};
  my $pbm_file_name = $this->{descrip}->{base_c_file_name} . "_map.pbm";
  my $to_cbm = PipeChildren::GetSocketPair;
  my $cbm_status = PipeChildren::GetSocketPair;
  my $cbm_to_pbm = PipeChildren::GetSocketPair;
  my $pbm_status = PipeChildren::GetSocketPair;
  open(my $pbm_writer, ">", "$pbm_file_name") or die "Can't open $pbm_file_name";
  $this->{bit_map_file} = $pbm_file_name;
  my $cbm_fd_map = {
    in => $to_cbm->{from},
    out => $cbm_to_pbm->{to},
    status => $cbm_status->{to},
  };
  my $to_pbm_fd_map = {
    in => $cbm_to_pbm->{from},
    out => $pbm_writer,
    status => $pbm_status->{to},
  };
  my $d = $this->{descrip};
  my $cbm_other_args = {
    rows => $d->{rows},
    cols => $d->{cols},
#    ulx => $d->{ipp}->[0],
    ulx => 0,
#    uly => $d->{ipp}->[1],
    uly => 0,
#    ulz => $d->{ipp}->[2],
    ulz => 0,
#    rowdcosx => $d->{iop}->[0],
#    rowdcosy => $d->{iop}->[1],
#    rowdcosz => $d->{iop}->[2],
#    coldcosx => $d->{iop}->[3],
#    coldcosy => $d->{iop}->[4],
#    coldcosz => $d->{iop}->[5],
    rowspc => $d->{pix_sp}->[0],
    colspc => $d->{pix_sp}->[1],
#    ztol => 1,
  };
  my $to_pbm_other_args = {
    rows => $d->{rows},
    cols => $d->{cols},
  };
  $this->{num_children} = 0;
  my $cbm_pid =
    PipeChildren::Spawn("NewContourToBitMap.pl", $cbm_fd_map, $cbm_other_args);
  $this->{num_children} += 1;
  my $to_pbm_pid =
    PipeChildren::Spawn("NewToPbm.pl", $to_pbm_fd_map, $to_pbm_other_args);
  $this->{Status} = "AwaitingChildren";
  $this->{num_children} += 1;
  Dispatch::Select::Socket->new(
    $this->ChildHarvester( $cbm_pid, "ContourToBitMap"),
    $cbm_status->{from}
  )->Add("reader");
  Dispatch::Select::Socket->new(
    $this->ChildHarvester($to_pbm_pid, "ToPbm"),
    $pbm_status->{from}
  )->Add("reader");
  my $xfm = Posda::Transforms::NormalizingVolume($d->{iop}, $d->{ipp});
  my $to = $to_cbm->{to};
  for my $i (@$file_list){
    print $to "BEGIN CONTOUR\n";
    open my $cont, "<", "$i" or die "can't open $i";
    line:
    while (my $line = <$cont>){
      my @nums = split(/\\/, $line);
      my $num_nums = @nums;
      unless(($num_nums % 3) == 0){
        print STDERR "$i: line doesn't contain multiple of 3 nums\n";
        next line;
      }
      my @points_2d;
      for my $i (0 .. ($num_nums / 3) - 1){
        my $point_3d = Posda::Transforms::ApplyTransform($xfm, 
          [$nums[$i * 3], $nums[($i * 3)+1], $nums[($i * 3)+2]]);
        push(@points_2d, [$point_3d->[0], $point_3d->[1]]);
#print "($nums[$i * 3], $nums[($i * 3)+1], $nums[($i * 3)+2]) => " .
#  "($point_3d->[0], $point_3d->[1]) ($point_3d->[2])\n";
      }
      for my $i (0 .. $#points_2d){
        print $to "$points_2d[$i]->[0]\\$points_2d[$i]->[1]";
        unless($i == $#points_2d) { print $to "\\" }
      }
#      print $to $line;
    }
    print $to "\nEND CONTOUR\n";
  }
  close $to;
}
sub RenderOpMask{
  my($this) = @_;
  $this->{PipelineType} = "RenderBitMap";
  my $file_list = $this->{descrip}->{contours};
  my $op_file_list = $this->{descrip}->{op_contours};
  my $pbm_file_name = $this->{descrip}->{base_c_file_name} . "_map.pbm";
  my $to_cbm1 = PipeChildren::GetSocketPair;
  my $to_cbm2 = PipeChildren::GetSocketPair;
  my $cbm1_status = PipeChildren::GetSocketPair;
  my $cbm2_status = PipeChildren::GetSocketPair;
  my $cbm1_to_int = PipeChildren::GetSocketPair;
  my $cbm2_to_int = PipeChildren::GetSocketPair;
  my $int_status = PipeChildren::GetSocketPair;
  my $int_to_pbm = PipeChildren::GetSocketPair;
  my $pbm_status = PipeChildren::GetSocketPair;
  open(my $pbm_writer, ">", "$pbm_file_name") or die "Can't open $pbm_file_name";
  $this->{bit_map_file} = $pbm_file_name;
  my $cbm1_fd_map = {
    in => $to_cbm1->{from},
    out => $cbm1_to_int->{to},
    status => $cbm1_status->{to},
  };
  my $cbm2_fd_map = {
    in => $to_cbm2->{from},
    out => $cbm2_to_int->{to},
    status => $cbm2_status->{to},
  };
  my $int_fd_map = {
    in1 => $cbm1_to_int->{from},
    in2 => $cbm2_to_int->{from},
    out => $int_to_pbm->{to},
    status => $int_status->{to},
  };
  my $to_pbm_fd_map = {
    in => $int_to_pbm->{from},
    out => $pbm_writer,
    status => $pbm_status->{to},
  };
  my $d = $this->{descrip};
  my $cbm1_other_args = {
    rows => $d->{rows},
    cols => $d->{cols},
    ulx => $d->{ipp}->[0],
    uly => $d->{ipp}->[1],
    ulz => $d->{ipp}->[2],
    rowdcosx => $d->{iop}->[0],
    rowdcosy => $d->{iop}->[1],
    rowdcosz => $d->{iop}->[2],
    coldcosx => $d->{iop}->[3],
    coldcosy => $d->{iop}->[4],
    coldcosz => $d->{iop}->[5],
    rowspc => $d->{pix_sp}->[0],
    colspc => $d->{pix_sp}->[1],
    ztol => 1,
  };
  my $cbm2_other_args = $cbm1_other_args;
  my $op = "CMP";
  if($this->{descrip}->{op} eq "intersect"){
    $op = "AND";
  } elsif($this->{descrip}->{op} eq "union") {
    $op = "OR";
  }
  my $int_other_args = {
    num => ($d->{rows} * $d->{cols}) / 8,
    depth => 2,
    op => $op,
  };
  my $to_pbm_other_args = {
    rows => $d->{rows},
    cols => $d->{cols},
  };
  $this->{num_children} = 0;
  my $cbm1_pid =
    PipeChildren::Spawn("ContourToBitMap.pl", $cbm1_fd_map, $cbm1_other_args);
  $this->{num_children} += 1;
  my $cbm2_pid =
    PipeChildren::Spawn("ContourToBitMap.pl", $cbm2_fd_map, $cbm2_other_args);
  $this->{num_children} += 1;
  my $int_pid =
    PipeChildren::Spawn("PixManip.pl", $int_fd_map, $int_other_args);
  $this->{num_children} += 1;
  my $to_pbm_pid =
    PipeChildren::Spawn("ToPbm.pl", $to_pbm_fd_map, $to_pbm_other_args);
  $this->{num_children} += 1;
  $this->{Status} = "AwaitingChildren";
  Dispatch::Select::Socket->new(
    $this->ChildHarvester( $cbm1_pid, "ContourToBitMap"),
    $cbm1_status->{from}
  )->Add("reader");
  Dispatch::Select::Socket->new(
    $this->ChildHarvester( $cbm2_pid, "ContourToBitMap"),
    $cbm2_status->{from}
  )->Add("reader");
  Dispatch::Select::Socket->new(
    $this->ChildHarvester( $int_pid, "PixManip"),
    $int_status->{from}
  )->Add("reader");
  Dispatch::Select::Socket->new(
    $this->ChildHarvester($to_pbm_pid, "ToPbm"),
    $pbm_status->{from}
  )->Add("reader");
  my $to = $to_cbm1->{to};
  for my $i (@$file_list){
    print $to "BEGIN CONTOUR\n";
    open my $cont, "<", "$i" or die "can't open $i";
    while (my $line = <$cont>){
      print $to $line;
    }
    print $to "\nEND CONTOUR\n";
  }
  close $to;
  $to = $to_cbm2->{to};
  for my $i (@$op_file_list){
    print $to "BEGIN CONTOUR\n";
    open my $cont, "<", "$i" or die "can't open $i";
    while (my $line = <$cont>){
      print $to $line;
    }
    print $to "\nEND CONTOUR\n";
  }
  close $to;
}
sub Render{
  my($this) = @_;
  my @Awaiting = sort keys %{$this->{Awaiting}};
  if(scalar(@Awaiting)> 0){
    $this->{Status} = "Awaiting the following:<ul>";
    for my $i (@Awaiting){
      $this->{Status} .= "<li>$i</li>";
    }
    $this->{Status} .= "</ul>";
    $this->AutoRefresh;
    return;
  }
  if($this->{descrip}->{TypeOfRendering} eq "Mask"){
    $this->RenderMaskImage;
  } elsif ($this->{descrip}->{TypeOfRendering} eq "Contour"){
    $this->RenderContourImage;
  } elsif ($this->{descrip}->{TypeOfRendering} eq "NormalizedContour"){
    $this->RenderNormalizedContourImage;
  } else {
    $this->{Status} = 
      "Unknown rendering type $this->{descrip}->{TypeOfRendering}";
  }
  $this->AutoRefresh;
}
sub RenderMaskImage{
  my($this) = @_;
  my $cmd = "convert $this->{bit_map_file} $this->{ImageFile}";
   `$cmd`;
  unless(-f $this->{ImageFile}) {
     print STDERR "Failed to render $this->{ImageFile}\n";
  }
  $this->{Status} = "Rendered";
  $this->AutoRefresh;
}
sub RenderContourImage{
  my($this) = @_;
  my($cmd1, $cmd2);
  if($this->{descrip}->{OverlayImage} eq "Y"){
    $cmd1 = $this->ImageRenderingCommand;
  } else {
    $cmd1 = $this->NoImageRenderingCommand;
  }
  $cmd2 = $this->ContourRenderingPart($this->{descrip}->{contours});
  my $cmd = "$cmd1 $cmd2 $this->{ImageFile}";
  $this->{Status} = "Rendering $cmd";
  $this->{pid} = open $this->{fh}, "$cmd|";
  Dispatch::Select::Socket->new($this->Reader, $this->{fh})->Add("reader");
  $this->AutoRefresh;
}
sub RenderNormalizedContourImage{
  my($this) = @_;
  my($cmd1, $cmd2);
  if($this->{descrip}->{OverlayImage} eq "Y"){
    $cmd1 = $this->ImageRenderingCommand;
  } else {
    $cmd1 = $this->NoImageRenderingCommand;
  }
  $cmd2 = $this->ContourRenderingPart($this->{NormalizedContours});
  my $cmd = "$cmd1 $cmd2 $this->{ImageFile}";
  $this->{Status} = "Rendering $cmd";
  $this->{pid} = open $this->{fh}, "$cmd|";
  Dispatch::Select::Socket->new($this->Reader, $this->{fh})->Add("reader");
  $this->AutoRefresh;
}
sub NoImageRenderingCommand{
  my($this) = @_;
  my $cmd;
  if($this->{descrip}->{bits_allocated} == 16){
    $cmd = "convert -size $this->{descrip}->{cols}x$this->{descrip}->{rows}" .
      " xc:white ";
  } else {
    $cmd = "convert -size $this->{descrip}->{cols}x$this->{descrip}->{rows}" .
      " xc:white ";
  }
  return $cmd;
}
sub ImageRenderingCommand{
  my($this) = @_;
  my $cmd;
  if($this->{descrip}->{bits_allocated} == 16){
    my $black = $this->{descrip}->{window_center} - 
      ($this->{descrip}->{window_width} / 2);
    my $white = $this->{descrip}->{window_center} +
      ($this->{descrip}->{window_width} / 2);
    if($black < 0) { $black = 0 }
    my $level = "-level $black,$white";
    $cmd = "convert -endian MSB " .
      "-size $this->{descrip}->{cols}x$this->{descrip}->{rows}" .
      " -depth 16 " .
      "\"$this->{descrip}->{gray_file}\" $level ";
  } else {
    $cmd = "convert -size $this->{descrip}->{cols}x$this->{descrip}->{rows}" .
      " -depth 8 " .
      "\"$this->{descrip}->{gray_file}\" ";
  }
  return $cmd;
}
sub ContourRenderingPart{
  my($this, $contour_files) = @_;
  my $cmd;
  my @ContourFiles = $this->GetContourFileList($contour_files);
  for my $c_file (@ContourFiles){
    $cmd .= "-stroke \"#ff0000\" -draw '\@$c_file' ";
  }
  return $cmd;
}
sub Reader{
  my($this) = @_;
  my $reader = sub {
    my($disp, $sock) = @_;
    if($this->{Abort}){
      delete $this->{pid};
      delete $this->{fh};
      $this->{Status} = "Aborted";
      $disp->Remove;
    }
    my $text;
    my $inp = sysread($sock, $text, 1024);
    if($inp == 0){
      delete $this->{pid};
      delete $this->{fh};
      $disp->Remove;
      $this->{Status} = "Rendered";
      $this->AutoRefresh;
    }
  };
  return $reader;
}
sub GetContourFileList{
  my($this, $contour_files) = @_;
  my $s_f_i = 0;
  my @ContourFiles;
  for my $fn (@{$contour_files}){
    unless(-r $fn) {
      print STDERR "$fn is not readable\n";
      next structure;
    }
    open FOO, "<", "$fn";
    my $string = <FOO>;
    close FOO;
    my $c = [ split /\\/, $string ];
    $s_f_i += 1;
    my $c_file = "$this->{descrip}->{base_c_file_name}_c_$s_f_i";
    open CFILE, ">", "$c_file";
    my $start = Posda::FlipRotate::ToPixCoords($this->{descrip}->{iop},
      $this->{descrip}->{ipp},
      $this->{descrip}->{rows},
      $this->{descrip}->{cols}, 
      $this->{descrip}->{pix_sp},
      [$c->[0], $c->[1], $c->[2]]);
    my $num_eles = @$c;
    my $num_points = int($num_eles/3);
    if($num_points < 3){
      print STDERR "Contour has only $num_points points ($fn)\n";
      next structure;
    }
    my $end;
    for my $pi (0 .. $num_points - 2){
      my $p = $pi * 3;
      my $pf = Posda::FlipRotate::ToPixCoords($this->{descrip}->{iop},
        $this->{descrip}->{ipp},
        $this->{descrip}->{rows},
        $this->{descrip}->{cols},
        $this->{descrip}->{pix_sp},
        [$c->[$p + 0], $c->[$p + 1], $c->[$p + 2]]);
      my $pt = Posda::FlipRotate::ToPixCoords($this->{descrip}->{iop},
        $this->{descrip}->{ipp},
        $this->{descrip}->{rows},
        $this->{descrip}->{cols},
        $this->{descrip}->{pix_sp},
        [$c->[$p + 3], $c->[$p + 4], $c->[$p + 5]]);
      print CFILE "line $pf->[0], $pf->[1] $pt->[0], $pt->[1]\n";
      $end = $pt;
    }
    print CFILE "line $end->[0], $end->[1] $start->[0], $start->[1]\n";
    close CFILE;
    push(@ContourFiles, $c_file);
  }
  return @ContourFiles;
}
sub CleanUpAndDelete{
  my($this) = @_;
  $this->CleanUp;
  $this->DeleteSelf;
}
sub CleanUp{
  my($this) = @_;
  if(defined $this->{ImageFile}){
    if(-f $this->{ImageFile}){ unlink $this->{ImageFile} }
    delete $this->{ImageFile};
  }
  if(
      exists($this->{ContourFiles}) &&
      ref($this->{ContourFiles}) eq "ARRAY" &&
      $#{$this->{ContourFiles}} >= 0
    ){
    for my $file (@{$this->{ContourFiles}}){
      if(-f $file) { unlink $file }
    }
    delete $this->{ContourFiles};
  }
}
1;

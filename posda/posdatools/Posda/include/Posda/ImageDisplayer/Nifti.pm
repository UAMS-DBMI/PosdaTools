#!/usr/bin/perl -w
#
use strict;
package Posda::ImageDisplayer::Nifti;
use Posda::ImageDisplayer;
use Posda::DB qw( Query );
use Dispatch::LineReader;
use VectorMath;
use Storable qw ( store_fd fd_retrieve );
use JSON;
use Debug;
use File::Temp qw/ tempfile /;
my $dbg = sub {print STDERR @_ };
##################################################
#Data Fetched via Ajax (AjaxPosdaGet):
#  ImageLabels
#  ImageUrl
use vars qw( @ISA );
@ISA = ( "Posda::ImageDisplayer" );
sub Init{
  my($self, $params) = @_;
  $self->{params} = $params;
  $self->{ImageLabels} = {
    top_text => "",
    bottom_text => "",
    right_text => "",
    left_text => "",
  };
  $self->{title} =
    "View NIFTI:  File_id: $self->{params}->{file_id}";
  ($self->{rows}, $self->{cols},$self->{bytes}) = 
    $params->{nifti}->RowsColsAndBytes();
  $self->{canvas_width} = $self->{cols} * 2;
  $self->{width} = $self->{canvas_width} + 20;
  $self->{canvas_height} = $self->{rows} * 2;
  $self->{height} = $self->{canvas_height} + 100;
  ($self->{num_slices}, $self->{num_vols}) = 
    $params->{nifti}->NumSlicesAndVols();
  $self->{ToolTypes} = [["Pan/Zoom", "P/Z tool"]];
  $self->{CurrentVolume} = 0;
  $self->{flip} = "n";
  $self->{JpegsInDb} = {};
  $self->InitializeImageList;
  $self->{CurrentUrlIndex} = 0;
  $self->SetImageUrl;
}
sub InitializeImageList{
  my($self)= @_;
  if($self->{flip} eq 'n'){
    Query("NiftiRenderedJpegsForByNiftiFileIdVolNumNormal")->RunQuery(sub{
      my($row) = @_;
      my($slice_num, $jpeg_file_path) = @$row;
      $self->{JpegsInDb}->{$self->{CurrentVolume}}->{$slice_num}->{n} =
        $jpeg_file_path;
    }, sub{}, $self->{params}->{file_id}, $self->{CurrentVolume});
  } else {
    Query("NiftiRenderedJpegsForByNiftiFileIdVolNumFlipped")->RunQuery(sub{
      my($row) = @_;
      my($slice_num, $jpeg_file_path) = @$row;
      $self->{JpegsInDb}->{$self->{CurrentVolume}}->{$slice_num}->{f} =
        $jpeg_file_path;
    }, sub{}, $self->{params}->{file_id}, $self->{CurrentVolume});
  }
  $self->{JpegImageUrls} = [];
  $self->{FileList} = [];
  for my $i (0 .. $self->{num_slices} - 1){
    my $image = "FetchNiftiJpeg?obj_path=$self->{path}&" .
      "file_id=$self->{params}->{file_id}&" .
      "flip=$self->{flip}&" .
      "vol=$self->{CurrentVolume}&slice=$i";
    push @{$self->{JpegImageUrls}}, {
        image => $image,
        url_type => "relative"
      };
    push(@{$self->{FileList}}, { offset => "slice $i" });
  }
};

sub SetImageUrl{
  my($self) = @_;
  $self->{ImageLabels}->{current_index} = $self->{CurrentUrlIndex};
  $self->{ImageUrl} = $self->{JpegImageUrls}->[$self->{CurrentUrlIndex}];
};

sub FetchNiftiJpeg{
  my($self, $http, $dyn) = @_;
  my $nifti_file_id = $dyn->{file_id};
  my $flip = $dyn->{flip};
  my $vol = $dyn->{vol};
  my $slice = $dyn->{slice};
  my $path;
  if(exists $self->{JpegsInDb}->{$vol}->{$slice}->{$flip}){
    $path = $self->{JpegsInDb}->{$vol}->{$slice}->{$flip}
  } else {
  $path = "$self->{params}->{temp_path}/nifti_$nifti_file_id" .
    "_$vol" . "_$slice" . "_$flip.jpeg";
  }
  if(-f $path){
    $self->SendCachedJpeg($http, $dyn, $path);
    return;
  }
  $self->RenderNiftiPixelToJpeg($http, $dyn, 
    $nifti_file_id, $self->{params}->{file_path},
    $flip, $vol, $slice);
} 

sub SendCachedJpeg{
  my($self, $http, $dyn, $jpeg_path) = @_;
  my $content_type = "image/jpeg";
  open my $sock, "cat $jpeg_path|" or die "Can't open " .
    "$jpeg_path for reading ($!)";

  $self->SendContentFromFh($http, $sock, $content_type,
  $self->CreateNotifierClosure("NullNotifier", $dyn));
}

sub RenderNiftiPixelToJpeg{
  my($self, $http, $dyn, $nifti_file_id, $path, $flip, $vol, $slice,
    $when_done) = @_;
  my $cmd = "ExtractNiftiSlice.pl $nifti_file_id $path $vol $slice " .
    "$flip $self->{params}->{temp_path}";
  print STDERR "Command: $cmd\n";
  open SUB, "$cmd|" or die "Can't open $cmd";
  my $jpeg_path;
  while (my $line = <SUB>){
    chomp $line;
    if($line =~ /Jpeg: (.*)$/){
      $jpeg_path = $1;
    }
  }
  close SUB;
  unless(defined $jpeg_path){
    die "Unable to render: $cmd\n";
  }
  my $cmd1 = "ImportSingleFileIntoPosdaAndReturnId.pl $jpeg_path " .
    "\"from $cmd\"";
  open SUB, "$cmd1|" or die "Can't open $cmd1";
  my $jpeg_file_id;
  while(my $line = <SUB>){
    if($line =~ /File id: (\d+)/){
      $jpeg_file_id = $1;
    }
  }
  unless(defined $jpeg_file_id){
    die "Unable to import: $cmd1";
  }
  my $f_stat = ($flip eq "n") ? 0 : 1;
  Query("CreateNiftiJpegSlice")->RunQuery(sub{}, sub{},
    $nifti_file_id, $vol, $slice, $f_stat, $jpeg_file_id);
  my $imported_file_path;
  Query("GetFilePath")->RunQuery(sub{
    my($row) = @_;
    $imported_file_path = $row->[0];
  }, sub{}, $jpeg_file_id);
  unless(defined $imported_file_path){
    die "unable to get path for file $jpeg_file_id";
  }
  $self->{JpegsInDb}->{$vol}->{$slice}->{$flip} = $imported_file_path;
  unlink $jpeg_path;
  $self->SendCachedJpeg($http, $dyn, $imported_file_path);
}

sub VolOptions{
  my($self, $http, $dyn) = @_;
  for my $i (0 .. $self->{num_vols} - 1){
    $http->queue("<option value=\"$i\"");
    if($i == $self->{CurrentVolume}){
      $http->queue(" selected");
    }
    $http->queue(">Vol $i</option>");
  }
}

sub SetVolIndex{
  my($self, $http, $dyn) = @_;
  $self->{CurrentVolume} = $dyn->{value};
  $self->InitializeImageList;
  $self->SetImageUrl;
}

sub FlipOptions{
  my($self, $http, $dyn) = @_;
  for my $i ('f', 'n'){
    $http->queue("<option value=\"$i\"");
    if($i eq $self->{flip}){
      $http->queue(" selected");
    }
    my $stat = ($i eq "n") ? "normal" : "flipped";
    $http->queue(">$stat</option>");
  }
}

sub SetSelectedFlip{
  my($self, $http, $dyn) = @_;
  $self->{flip} = $dyn->{value};
  $self->InitializeImageList;
  $self->SetImageUrl;
}

my $content = <<EOF;
<div style="display: flex; flex-direction: column; align-items: flex-beginning; margin-bottom: 5px" id="div_content">
<div id="div_canvas">
<table border="1" width="100%">
<tr>
<td align="center" colspan="3" id="TopPositionText"`>
</td>
</tr>
<tr>
<td id="LeftPositionText">
</td>
<td align="center" valign="center">
<canvas id="MyCanvas" width="<?dyn="CanvasWidth"?>" height="<?dyn="CanvasHeight"?>"></canvas>
</td>
<td id="RightPositionText">
</td>
</tr>
<tr>
<td align="center" colspan="3" id="BottomPositionText">
</td>
</tr>
</table>
</div>
<div id="div_control_buttons_1" style="display: flex; flex-direction: row; align-items: flex-end; margin-left: 10px">
<div id="ControlButton1" width="10%">
<input type="Button" class="btn btn-default"  onclick="javascript:ResetZoom();" value="reset">
</div>
<div width=10% id="ToolTypeSelector">
<?dyn="ToolTypeSelector"?>
</div>
<div width=10% id="CineSelector">
  <select class="form-control"
    onchange="javascript:SetCineMode(this.options[this.selectedIndex].value);">
    <option value="Cine off" selected="">Cine off</option>
    <option value="Cine +">Cine +</option>
    <option value="Cine -">Cine -</option>
  </select>
</div>
<div id="divPrev" width="10%">&nbsp;<?dyn="PrevButton"?></div>
<div id="divNext" width="10%">&nbsp;<?dyn="NextButton"?></div>
<div id="divOffsetSelector" width="10%">
  <select id="OffsetSelector" class="form-control"
    onchange="javascript:PosdaGetRemoteMethod('SetImageIndex', 'value=' +
      this.options[this.selectedIndex].value,
      function () { UpdateImage(); });">
   <?dyn="OffsetOptions"?>
   </select>
</div>
<div id="divOffsetSelector" width="10%">
  <select id="OffsetSelector" class="form-control"
    onchange="javascript:PosdaGetRemoteMethod('SetVolIndex', 'value=' +
      this.options[this.selectedIndex].value,
      function () { UpdateImage(); });">
   <?dyn="VolOptions"?>
   </select>
</div>
</div>
<div id="div_control_buttons_2" style="display: flex; flex-direction: row; align-items: flex-end; margin-left: 10px">
<div id="flip_selector">
  <select id="FlipSelector" class="form-control"
    onchange="javascript:PosdaGetRemoteMethod('SetSelectedFlip', 'value=' +
      this.options[this.selectedIndex].value,
      function () { UpdateImage(); });">
    <?dyn="FlipOptions"?>
   </select>
</div>
<div id="div_contours_pending">&nbsp;</div>
</div>
</div>
<div style="display: flex; flex-direction: row; align-items: flex-end; margin-left: 10px">
</div>
EOF

sub Content{
  my($self, $http, $dyn) = @_;
  $self->RefreshEngine($http, $dyn, $content);
}
1;

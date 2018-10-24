#!/usr/bin/perl -w
#
use strict;
package Posda::HttpApp::ImageDisp;
use Posda::HttpApp::GenericSubIframe;
use Posda::HttpApp::PrefetchContours;
use Posda::HttpApp::PrefetchImages;
use Posda::HttpApp::PrefetchIsodoses;
use Dispatch::LineReader;
use Storable qw ( store_fd fd_retrieve );
use Debug;
my $dbg = sub {print STDERR @_ };
##################################################
#Methods Invoked from Routing:
#$this->SelectedDoseOptions({
#  calc_method => "Old" | "New" | "Both",
#  dose_dig => <digest of dose file>,
#  dose_file => <path to dose file>,
#  iso_doses => {
#    <n> => {
#      Color => <color>,
#      GyValue => <value>,
#    },
#    ...
#  },
#});
#$this->SelectedImageSet({
#  ds_digest => <image ds digest
#  file => <path to image file>,
#  modality => <modality>,
#  series_uid => <series_uid>,
#  sop => <sop_inst_uid>,
#  z => <z_offset>
#});
#$this->SetNewWL($center, $width);
#$this->SetRoiSelections({
#  <roi_num> => "checked" | "not_checked",
#  ...
#});
#$this->SetStruct($file);
##################################################
#Imports From Above:
#  TempDir
#  StructColors
#  NewStructsToDrawBySop($sop) = {
#    color => <color>,
#    struct => [
#      <3d_contour_file_name>,
#      ...
#    ],
#  };
##################################################
#Data Fetched via Ajax (AjaxPosdaGet):
#  ImageLabels
#  ImageUrl
##################################################
#Methods Invoked via Ajax:
#  GetContoursToRender
#  RetrieveTempFile (indirectly)
##################################################
#Has Children:
#  ImagePrefetcher(Posda::HttpApp::PrefetchImages)
#    Exports:
#      PrefetchStatus(Collection)
#    Imports:
#      GetSelectedImageSet  (see SelectedImageSet above)
#        ret = [
#          {
#            ds_digest => <ds_digest>,
#            file => <file>,
#            modality => <modality>,
#            series_uid => <series_uid>,
#            sop => <sop>,
#            z => <z>,
#          },
#          ...
#        ];
#      PrefetchStatusChange
#  RoiPrefetcher(Posda::HttpApp::PrefetchContours)
#    Exports:
#      PrefetchStatus(Collection)
#    Imports:
#      PrefetchStatusChange
#  IsodosePrefetcher(Posda::HttpApp::PrefetchIsodoses)
#    Exports:
#      PrefetchStatus(Collection)
#    Imports:
#      PrefetchStatusChange
##################################################
use vars qw( @ISA );
@ISA = ( "Posda::HttpApp::GenericIframe", 
  "Posda::HttpApp::GenericJsController" );
sub new {
  my($class, $sess, $path) = @_;
  my $this = Posda::HttpApp::GenericSubIframe->new($sess, $path);
  my $temp_dir = $this->FetchFromAbove("TempDir");
  $this->{temp_dir} = "$temp_dir/ViewImageCache";
  $this->{iso_dir} = "$temp_dir/isodose_files";
  unless(-d $this->{temp_dir}) {
    mkdir $this->{temp_dir};
  }
  bless($this, $class);
  $this->{ImportsFromAbove}->{TempDir} = 1;
  $this->{ImportsFromAbove}->{StructColors} = 1;
  $this->{ImportsFromAbove}->{NewStructsToDrawBySop} = 1;
  $this->{Exports}->{SelectedDoseOptions} = 1;
  $this->{Exports}->{SelectedImageSet} = 1;
  $this->{Exports}->{SetNewWL} = 1;
  $this->{Exports}->{SetRoiSelections} = 1;
  $this->{Exports}->{SetStruct} = 1;
  $this->{Exports}->{RefreshImageDisplay} = 1;
  $this->{ImageUrl} = { url_type => "absolute", image => "/LoadingScreen.png" };
  $this->{ImageLabels} = {
    top_text => "<small>&nbsp;</small>",
    bottom_text => "<small>&nbsp;</small>",
    right_text => "<small>&nbsp;</small>",
    left_text => "<small>&nbsp;</small>",
  };
  return $this;
}
my $header  = <<EOF;
<?dyn="JqueryHeader"?>
<?dyn="JsController"?>
<script language="javascript" type="text/javascript" src="/DicomImageDisp.js">
</script>
EOF
my $content = <<EOF;
<table border="0" width="100%">
<tr>
<td align="center" colspan="3" id="TopPositionText"`>
</td>
</tr>
<tr>
<td id="LeftPositionText">
</td>
<td align="center" valign="center">
<canvas id="MyCanvas" width="512" height="512"></canvas>
</td>
<td id="RightPositionText">
</td>
</tr>
<tr>
<td align="center" colspan="3" id="BottomPositionText">
</td>
</tr>
</table>
<table border="1" width="100%">
<tr>
<td id="ControlButton1" width="10%">
<?dyn="Button" op="FrameReset" caption="reset"?>
</td>
<td id="ControlButton2" width="10%">&nbsp;</td>
<td id="ControlButton3" width="10%">&nbsp;</td>
<td id="ControlButton4" width="10%">&nbsp;</td>
<td id="ControlButton5" width="10%">&nbsp;</td>
<td id="ControlButton6" width="10%">&nbsp;</td>
<td id="ControlButton7" width="10%">&nbsp;</td>
<td id="ControlButton8" width="10%">&nbsp;</td>
<td id="ControlButton9" width="10%">&nbsp;</td>
<td id="ControlButton10" width="10%">&nbsp;</td>
</tr>
</table>
EOF
sub RefreshImageDisplay{
  my($this) = @_;
  Posda::HttpApp::GenericJsController::AutoRefresh($this);
}
sub AutoRefresh{
  my($this) = @_;
  Posda::HttpApp::GenericJsController::AutoRefresh($this);
}
sub FrameReset{
  my($this) = @_;
  Posda::HttpApp::GenericIframe::AutoRefresh($this);
}
sub Content{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn, $content);
}
sub Header{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn, $header);
}
##### Pixel Rendering Stuff
sub SetNewWL{
  my($this, $c, $w) = @_;
  unless($c == $this->{window_center} && $w == $this->{window_width}){
    $this->{window_center} = $c;
    $this->{window_width} = $w;
    $this->PrefetchImages;
    $this->RenderPixels;
    $this->AutoRefresh;
  }
}
sub SideText{
  my($text) = @_;
  my $ret = "";
  my $escaped = 0;
  for my $i (0 .. (length($text)-1)) {
    my $c = substr($text, $i, 1);
    if ($escaped) {
      $ret .= $c;
      if ($c eq ";") {
        $ret .= "<br>";
        $escaped = 0;
      }
    } else {
      $ret .= $c;
      if ($c eq "&") {
        $escaped = 1;
      } else {
        $ret .= "<br>";
      }
    }
  }
  return $ret;
}
sub RenderPixels{
  my($this) = @_;
  unless($this->{SelectedImage}) {
    print STDERR "No Image selected in RenderPixels\n";
    return;
  }
  my($root, $info) = $this->GrayJpegRoot($this->{SelectedImage}->{file});
  my $rows = $info->{"(0028,0010)"};
  my $cols = $info->{"(0028,0011)"};
  my $gray_file_name = "$root.gray";
  my $jpeg_file_name = "$root.jpeg";
  my $img_url = "RetrieveTempFile?obj_path=$this->{path}&" .
    "content_name=$jpeg_file_name";
  if(
    $this->{ImageUrl}->{url_type} ne "session_relative" ||
    $this->{ImageUrl}->{image} ne $img_url
  ){
    $this->{ImageUrl} = {
      url_type => "session_relative", 
      image=> $img_url,
    };
    $this->AutoRefresh;
  }
  unless(-f $jpeg_file_name){
    my $child = $this->child("ImagePrefetcher");
    if($child && $child->can("RequestNotify")){
      $child->RequestNotify($jpeg_file_name,
        $this->CreateNotifierClosure("AutoRefresh"));
    }
  }
}
sub GrayJpegRoot{
  my($this, $file) = @_;
  my $fm = $this->get_obj("FileManager");
  my $fi = $fm->DicomInfo($file);
  unless($this->{window_center}) { $this->{window_center} = 20 }
  unless($this->{window_width}) { $this->{window_width} = 470 }
  return("$this->{temp_dir}/ImageCache/" .
    "$this->{SelectedImage}->{ds_digest}" .
    "_$this->{window_center}" . "_$this->{window_width}",
    $fi);
}
sub PrefetchImages{
  my($this) = @_;
  my $pre_fetcher = $this->child("ImagePrefetcher");
  ########### reset or create...
  if(defined $pre_fetcher){
    $pre_fetcher->Reset($this->{SelectedImage}, 
      $this->{window_center}, $this->{window_width});
  } else{
    Posda::HttpApp::PrefetchImages->new($this->{session}, 
      $this->child_path("ImagePrefetcher"),
      "$this->{temp_dir}/ImageCache",
      $this->{SelectedImage},
      $this->{window_center}, $this->{window_width});
  }
}
sub SelectedImageSet{
  my($this, $img) = @_;
  $this->{SelectedImage} = $img;
  my $fm = $this->get_obj("FileManager");
  my $di = $fm->DicomInfo($img->{file});
  $this->{SelectedImage}->{info} = $di;
  $this->PrefetchImages;
  $this->PrefetchIsodoses;
  $this->RenderPixels;
  my($Left, $Right, $Top, $Bottom);
  unless (defined $di->{modality} && defined $di->{norm_iop}) { return; }
  unless ($di->{modality} eq "CT" || $di->{modality} eq "MR") { return; }
  my @iop = split(/\\/, $di->{norm_iop});
  if ($iop[3] == 0 &&  $iop[5] == 0) {
    if ($iop[4] == 1) {
      $Top = "Anterior";
      $Bottom = "Posterior";
    } elsif ($iop[4] == -1) {
      $Top = "Posterior";
      $Bottom = "Anterior";
    }
  }
  unless (defined $Top) {
    $Top = "";
    $Bottom = "";
   for my $i ([5,"Head","Foot"],
              [3,"Left","Right"],
              [4,"Anterior","Posterior"]) {
     if ($iop[$i->[0]] == 0) { next; }
     my $d = int Math::Trig::rad2deg(Math::Trig::acos($iop[$i->[0]]));
     $Bottom .= $i->[2] . " ($d&deg;) ";
     $d += 180;
     if ($d >= 360) { $d -= 360; }
     if ($d >= 180) { $d -= 180; }
     $Top .= $i->[1] . " ($d&deg;) ";
   }
  }
  if ($iop[1] == 0 &&  $iop[2] == 0) {
    if ($iop[0] == 1) {
      $Left = "Right";
      $Right = "Left";
    } elsif ($iop[0] == -1) {
      $Left = "Left";
      $Right = "Right";
    }
  }
  unless (defined $Left) {
    $Left = "";
    $Right = "";
   for my $i ([2,"Head","Foot"],
              [0,"Left","Right"],
              [1,"Anterior","Posterior"]) {
     if ($iop[$i->[0]] == 0) { next; }
     my $d = int Math::Trig::rad2deg(Math::Trig::acos($iop[$i->[0]]));
     $Right .= $i->[2] . " $d&deg; ";
     $d += 180;
     if ($d >= 360) { $d -= 360; }
     if ($d >= 180) { $d -= 180; }
     $Left .= $i->[1] . " $d&deg; ";
   }
  }

  if (defined $Left) {
    $Left = SideText($Left);
  }
  if (defined $Right) {
    $Right = SideText($Right);
  }
  $this->{ImageLabels} = {
    top_text => "<small>$Top</small>",
    bottom_text => "<small>$Bottom</small>",
    right_text => "<small>$Right</small>",
    left_text => "<small>$Left</small>",
  };
  $this->PrefetchContours;
  $this->AutoRefresh;
}
#######  End of Image Stuff
#######  Begin Contour Stuff
sub SetRoiSelections{
  my($this, $rsel) = @_;
  $this->{RoiSelections} = $rsel;
  $this->AutoRefresh;
}
sub SetStruct{
  my($this, $file) = @_;
  $this->{SelectedStruct} = $file;
  my $fm = $this->get_obj("FileManager");
  $this->{StructInfo} = $fm->DicomInfo($file);
  $this->{StructDsOffset} = $fm->GetDsOffset($file);
  $this->PrefetchContours;
}
sub PrefetchContours{
  my($this) = @_;
  my $pre_fetcher = $this->child("RoiPrefetcher");
  ########### reset or create...
  if(defined $pre_fetcher){
    $pre_fetcher->Reset($this->{SelectedStruct}, $this->{StructInfo},
      $this->{SelectedImage});
  } else{
    Posda::HttpApp::PrefetchContours->new($this->{session}, 
      $this->child_path("RoiPrefetcher"), "$this->{temp_dir}/RoiCache",
      $this->{SelectedStruct}, $this->{StructInfo},
      $this->{SelectedImage});
  }
}
################################################
sub GetContoursToRender{
  my($this, $http, $dyn) = @_;
  $dyn->{ContourConstructionInstructions} = [];
  $dyn->{SelectedSop} = $this->{SelectedImage}->{sop};
  if(
    defined $this->{SelectedImage} &&
    $this->{SelectedImage}->{info}->{norm_iop}
  ){
    my @list_of_contour_files;
    my @list_of_contour_colors;
    if(
      defined($this->{StructInfo}) &&
      defined($this->{StructInfo}->{rois})
    ){
      my $struct_colors = $this->FetchFromAbove("StructColors");
      if(ref($struct_colors) eq "HASH"){
        my $selected_rois = $this->{RoiSelections};
        if(ref($selected_rois) eq "HASH"){
          roi:
          for my $roin (keys %{$this->{StructInfo}->{rois}}){
            unless($selected_rois->{$roin} eq "checked") {
              next roi;
            } 
            my $roi = $this->{StructInfo}->{rois}->{$roin};
            if(defined($roi->{contours}) && ref($roi->{contours}) eq "ARRAY"){
              contour:
              for my $cn (0.. $#{$roi->{contours}}){
                my $c = $roi->{contours}->[$cn];
                unless($c->{type} eq "CLOSED_PLANAR"){
                  next contour;
                }
                unless(defined $c->{ref}){
                  print STDERR "CLOSED_PLANAR " .
                    "Roi{$roin}->{contours}->[$cn] has no image ref\n";
                  next contour;
                }
                unless($c->{ref} eq $dyn->{SelectedSop}){
                  next contour;
                }
                my $cache_file_name = $this->RoiCacheFileName($roin, $cn);
                push @list_of_contour_files, $cache_file_name;
                push @list_of_contour_colors, $struct_colors->{$roin};
              }
            }
          }
          my %uncached_contours;
          my @list_of_existing_contour_files;
          my @list_of_existing_contour_colors;
          for my $in (0 .. $#list_of_contour_files){
            my $f = $list_of_contour_files[$in];
            if(-f $f) { 
              push @list_of_existing_contour_files, $f;
              push @list_of_existing_contour_colors, 
               $list_of_contour_colors[$in];
            } else { $uncached_contours{$f} = 1 }
          }
          if(scalar keys %uncached_contours){
            my $child = $this->child("RoiPrefetcher");
            if($child && $child->can("RequestNotify")){
              $child->RequestNotify(\%uncached_contours,
                $this->CreateNotifierClosure("AutoRefresh"));
            }
          }
          for my $i (0 .. $#list_of_existing_contour_files){
            my $h = {
              type => "2dContour",
              color => $list_of_existing_contour_colors[$i],
              file => $list_of_existing_contour_files[$i],
            };
            push(@{$dyn->{ContourConstructionInstructions}}, $h);
          }
        }
      }
    }
  }
  my $new_rois = $this->FetchFromAbove("NewStructsToDrawBySop",
    $this->{SelectedImage}->{sop});
  if(ref($new_rois) ne "ARRAY"){
    print STDERR "NewStructsToDrawBySop returned non-array: ";
    Debug::GenPrint($dbg, $new_rois, 1);
    print STDERR "\n";
  } else {
    for my $struct (@$new_rois){
      for my $contour (@{$struct->{struct}}){
        my $h = {
          type => '3dContour',
          norm_iop => $this->{SelectedImage}->{info}->{norm_iop},
          norm_x => $this->{SelectedImage}->{info}->{norm_x},
          norm_y => $this->{SelectedImage}->{info}->{norm_y},
          norm_z => $this->{SelectedImage}->{info}->{norm_z},
          pix_sp => $this->{SelectedImage}->{info}->{"(0028,0030)"},
          color => $struct->{color},
          file => $contour,
        };
        push(@{$dyn->{ContourConstructionInstructions}}, $h);
      }
    }
  }
  $this->CacheIsodoseContours($http, $dyn);
  ############### This is all that should be left...
  ############### (except you shouldn't have to process list)
  ############### just stick it directly into dyn...
  my $list = $this->CollectFromAbove(
    "GetDisplayContourConstructionInstructions");
  for my $c (@$list){
    push(@{$dyn->{ContourConstructionInstructions}}, $c);
  }
  $this->SendCachedContours($http, $dyn);
}
sub RoiCacheFileName{
  my($this, $roin, $cn) = @_;
  my $dir = "$this->{temp_dir}/RoiCache";
  unless(-d $dir) { unless(mkdir $dir) { die "can't mkdir $dir}"} }
  my $fn = "$this->{StructInfo}->{dataset_digest}_${roin}_$cn";
  return "$dir/$fn";
}
sub CacheIsodoseContours{
  my($this, $http, $dyn) = @_;
  if(
    $this->{SelectedDoseOptions}->{calc_method} eq "Old" ||
    $this->{SelectedDoseOptions}->{calc_method} eq "Both"
  ){
    push(@{$dyn->{ContourConstructionInstructions}}, 
      $this->GetOldIsodoseInstructions);
  }
  if(
    $this->{SelectedDoseOptions}->{calc_method} eq "New" ||
    $this->{SelectedDoseOptions}->{calc_method} eq "Both"
  ){
    $this->GetNewIsodoseInstructions($http, $dyn);
  }
}
sub SendCachedContours{
  my($this, $http, $dyn) = @_;
  my $file = $this->{temp_dir} . "/ContourInstructions";
  Storable::store $dyn->{ContourConstructionInstructions}, $file;
  open my $sock, "cat $file|ContourConstructor.pl|" or die "Can't open pipe";
  $this->SendContentFromFh($http, $sock, "application/json", 
  $this->CreateNotifierClosure("NewContourSendComplete", $dyn));
}
sub NewContourSendComplete{
  my($this, $dyn) = @_;
  unless($dyn->{SelectedSop} eq $this->{SelectedImage}->{sop}){
    print STDERR "Stale Contours Delivered\n";
    $this->AutoRefresh;
  }
}
sub OldSendCachedContours{
  my($this, $http, $dyn) = @_;
  my($sock, $pid) = $this->ReadWriteChild("ContourConstructor.pl");
  delete $this->{child_pid};
  my $file = $this->{temp_dir} . "/ContourInstructions";
  Storable::store $dyn->{ContourConstructionInstructions}, $file;
  store_fd($dyn->{ContourConstructionInstructions}, $sock);
  $this->SendContentFromFh($http, $sock, "application/json", 
  $this->CreateNotifierClosure("ContourSendComplete", $pid, $dyn));
}
################################################
sub ContourSendComplete{
  my($this, $pid, $dyn) = @_;
  $this->HarvestPid($pid);
  unless($dyn->{SelectedSop} eq $this->{SelectedImage}->{sop}){
    print STDERR "Stale Contours Delivered\n";
    $this->AutoRefresh;
  }
}
sub SelectedDoseOptions{
  my($this, $dose_options) = @_;
  $this->{SelectedDoseOptions} = $dose_options;
  $this->PrefetchIsodoses();
  $this->AutoRefresh;
}
sub PrefetchIsodoses{
  my($this) = @_;
  my $pre_fetcher = $this->child("IsodosePrefetcher");
  ########### reset or create...
  if(defined $pre_fetcher){
    $pre_fetcher->Reset($this->{SelectedDoseOptions},
      $this->{SelectedImage});
  } else{
    Posda::HttpApp::PrefetchIsodoses->new($this->{session}, 
      $this->child_path("IsodosePrefetcher"), "$this->{temp_dir}/IsodoseCache",
      $this->{SelectedDoseOptions},
      $this->{SelectedImage});
  }
}
sub GetNewIsodoseInstructions{
  my($this, $http, $dyn) = @_;
  my $z = $this->{SelectedImage}->{z};
  my $isodoses = $this->{SelectedDoseOptions}->{isodoses};
  my $dose_dig = $this->{SelectedDoseOptions}->{dose_dig};
  my %missing;
  isodose:
  for my $i (keys %$isodoses){
    my $color = $isodoses->{$i}->{Color};
    my $level = sprintf("%05d", 1000 * $isodoses->{$i}->{GyValue});
    my $real_base = "$this->{temp_dir}/IsodoseCache/$dose_dig" . "_$z.iso";
    my $base_file = $real_base . "_$level";
    unless(-f "$base_file" . "_0"){
      $missing{$real_base} = 1;
      next isodose;
    }
    push(@{$dyn->{ContourConstructionInstructions}},
      {
        type => "2dContour",
        color => $color,
        file => "$base_file" . "_0",
      });
    my $j = 1;
    while(-f "$base_file" . "_$j"){
      push(@{$dyn->{ContourConstructionInstructions}},
        {
          type => "2dContour",
          color => $color,
          file => "$base_file" . "_$j",
        });
      $j++;
    }
  }
  if(scalar keys %missing){
    my $child = $this->child("IsodosePrefetcher");
    if($child && $child->can("RequestNotify")){
      $child->RequestNotify(\%missing,
        $this->CreateNotifierClosure("AutoRefresh"));
    } else {
      if($child) {
        print STDERR "No IsodosePrefetcher found\n";
      } else {
        print STDERR "$child->{path} can't RequestNotify\n";
      }
    }
  }
}
sub GetOldIsodoseInstructions{
  my($this) = @_;
  my $inst = {
    type => "IsoDose",
    norm_iop => $this->{SelectedImage}->{info}->{norm_iop},
    norm_x => $this->{SelectedImage}->{info}->{norm_x},
    norm_y => $this->{SelectedImage}->{info}->{norm_y},
    norm_z => $this->{SelectedImage}->{info}->{norm_z},
    rows => $this->{SelectedImage}->{info}->{"(0028,0010)"},
    cols => $this->{SelectedImage}->{info}->{"(0028,0011)"},
    pix_sp => $this->{SelectedImage}->{info}->{"(0028,0030)"},
    list => [],
  };
  if(
    exists($this->{SelectedDoseOptions}->{isodoses}) &&
    ref($this->{SelectedDoseOptions}->{isodoses}) eq "HASH"
  ){
    $this->{SelectedDoseOptions}->{dose_dig} =~ /^(.)(.)/;
    my $dir = "$this->{iso_dir}/$1/$2";
    my $z = $this->{SelectedImage}->{z};
    for my $i (keys %{$this->{SelectedDoseOptions}->{isodoses}}){
      my $color = $this->{SelectedDoseOptions}->{isodoses}->{$i}->{Color};
      my $cgy = sprintf("%d" ,
        $this->{SelectedDoseOptions}->{isodoses}->{$i}->{GyValue} * 100);
      my $file_name = "$dir/$this->{SelectedDoseOptions}->{dose_dig}" .
        "_$z.iso_$cgy";
      if(-f $file_name . "_0"){
        push(@{$inst->{list}}, { color => $color, file => $file_name . "_0" });
      }
      my $j = 1;
      while(-f $file_name . "_$j"){
        push(@{$inst->{list}}, { color => $color, file => $file_name . "_$j" });
        $j++;
      }
    }
  }
  return $inst;
}
1;

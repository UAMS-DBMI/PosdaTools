#!/usr/bin/perl -w
#
use strict;
package Posda::ImageDisplayer::NiftiProjections;
use Posda::ImageDisplayer;
use Posda::DB qw( Query );
use Dispatch::LineReader;
use VectorMath;
use Storable qw ( store_fd fd_retrieve );
use JSON;
use Debug;
use File::Temp qw/ tempfile /;
my $dbg = sub {print STDERR @_ };

use vars qw( @ISA );
@ISA = ( "Posda::ImageDisplayer" );
sub Init{
  my($self, $parms) = @_;
  $self->{params} = $parms;
  $self->{title} =
    "Nifti Projection Viewer: " .
    "Visual Activity id: $self->{params}->{activity_id}";
  $self->Initialize();
  $self->InitializeImageList();
  $self->{CurrentIndexList} = 0;
}

sub Initialize{
  my($self) = @_;
  my $max_rows = 0;
  my $max_cols = 0;
  my %Reviewers;
  my %Statii;
  my $g_jpg = Query('NiftiProjectionsByNiftiFileId');
  $self->{NiftiFiles} = {};
  Query('NiftiFileRenderingsByActvity')->RunQuery(sub{
    my($row) = @_;
    my($nifti_file_id, $jpeg_image_type, $reviewer, $status, $time) = @$row;
    unless($nifti_file_id){
      unless(defined $nifti_file_id){ $nifti_file_id = "<undef>" }
      print STDERR "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n" .
        "Nifti file id = $nifti_file_id\n" .
        "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n";
      return;
    }
    my($rows, $cols);
    if($jpeg_image_type =~ /JPEG .*, (\d+)x(\d+),/){
      $rows = $1;
      $cols = $2;
      if($rows > $max_rows) { $max_rows = $rows }
      if($cols > $max_cols) { $max_cols = $cols }
    }
    unless(defined $reviewer){
      unless(exists $self->{NiftiFiles}->{$nifti_file_id}){
        $self->{NiftiFiles}->{$nifti_file_id} = {};
      }
    }
    if(defined($reviewer)){
      $self->{NiftiFiles}->{$nifti_file_id}->{reviews}->{$reviewer}->{$status}->{$time} = 1;
      $Reviewers{$reviewer} = 1;
      $Statii{$status}->{$nifti_file_id}->{$reviewer}->{$time} = 1;
    }
    $g_jpg->RunQuery(sub{
      my($row) = @_;
      my($proj_type, $jfid,$path) = @$row;
      $self->{NiftiFiles}->{$nifti_file_id}->{$proj_type} = [$jfid, $path];
    }, sub {}, $nifti_file_id);
  }, sub {}, $self->{params}->{activity_id});
  $self->{Reviewers} = \%Reviewers;
  $self->{Statii} = \%Statii;
  $self->{image_width} = $max_cols * 2;
  $self->{image_height} = $max_rows * 2;
  $self->{width} = ($self->{image_width} * 3) + 20;
  $self->{height} = $self->{image_height} + 100;
}

sub InitializeImageList{
  my($self, $http, $dyn) = @_;
  #  He we implement the filter (later)
  unless(defined $self->{FilterType}) { $self->{FilterType} = "Not Reviewed" }
  if($self->{FilterType} eq "All"){
    $self->{ImageList} = [];
    for my $i (sort { $a <=> $b } keys %{$self->{NiftiFiles}}){
      push @{$self->{ImageList}}, $i;
    }
  } elsif ($self->{FilterType} eq "Not Reviewed"){
    $self->{ImageList} = [];
    for my $i (sort {$a <=> $b} keys %{$self->{NiftiFiles}}){
      unless(exists ($self->{NiftiFiles}->{$i}->{reviews})){
        push @{$self->{ImageList}}, $i;
      }
    }
  } elsif ($self->{FilterType} =~ "Not Reviewed by (.*)"){
    my $reviewer = $1;
    $self->{ImageList} = [];
    for my $i (sort {$a <=> $b} keys %{$self->{NiftiFiles}}){
      unless(exists $self->{NiftiFiles}->{$i}->{reviews}->{$reviewer}){
        push @{$self->{ImageList}}, $i;
      }
    }
  } elsif ($self->{FilterType} =~ "Reviewed by (.*)"){
    my $reviewer = $1;
    $self->{ImageList} = [];
    for my $i (sort {$a <=> $b} keys %{$self->{NiftiFiles}}){
      if(exists $self->{NiftiFiles}->{$i}->{reviews}->{$reviewer}){
        push @{$self->{ImageList}}, $i;
      }
    }
  }
  if($self->{CurrentIndexList} > $#{$self->{ImageList}}){
    $self->{CurrentIndexList} = 0;
  }
}

sub FetchProjection{
  my($self, $http, $dyn) = @_;
  my $type = $dyn->{type};
  my $index = $self->{CurrentIndexList};
  my $nifti_file_id = $self->{ImageList}->[$index];
  my $path = $self->{NiftiFiles}->{$nifti_file_id}->{$type}->[1];
  $self->SendCachedJpeg($http, $dyn, $path);
}

sub Skip{
  my($self, $http, $dyn) = @_;
  $self->{CurrentIndexList} += 1;
  if($self->{CurrentIndexList} > $#{$self->{ImageList}}){
    $self->{CurrentIndexList} = 0;
  };
}
sub Good{
  my($self, $http, $dyn) = @_;
  Query('InsertNiftiProjectionReview')->RunQuery(sub{},sub{},
    $self->{ImageList}->[$self->{CurrentIndexList}],
    $self->{params}->{user}, 'Good');
  $self->Initialize();
  $self->InitializeImageList();
}

sub Bad{
  my($self, $http, $dyn) = @_;
  Query('InsertNiftiProjectionReview')->RunQuery(sub{},sub{},
    $self->{ImageList}->[$self->{CurrentIndexList}],
    $self->{params}->{user}, 'Bad');
  $self->Initialize();
  $self->InitializeImageList();
}

sub Index{
  my($self, $http, $dyn) = @_;
  my $index = $self->{CurrentIndexList} + 1;
  $http->queue($index);
}

sub IndexFid{
  my($self, $http, $dyn) = @_;
  $http->queue($self->{ImageList}->[$self->{CurrentIndexList}]);
}

sub NumFiles{
  my($self, $http, $dyn) = @_;
  my $num_files = @{$self->{ImageList}};
  $http->queue($num_files);
}

my $info = <<EOF;
Index: <?dyn="Index"?> of <?dyn="NumFiles"?>; nifti_file_id : <?dyn="Fid"?>
<?dyn="RowsCols"?>
<?dyn="ReviewInfo"?>
EOF
sub Info{
  my($self, $http, $dyn) = @_;
  $self->RefreshEngine($http, $dyn, $info);
}
sub Fid{
  my($self, $http, $dyn) = @_;
  my $fid = $self->{ImageList}->[$self->{CurrentIndexList}];
  $http->queue("$fid");
}
sub RowsCols{
  my($self, $http, $dyn) = @_;
  my $fid = $self->{ImageList}->[$self->{CurrentIndexList}];
  my($rows, $cols, $slices, $vols);
  Query('GetRowsColsSlicesAndVolsByNiftiFileId')->RunQuery(sub{
    my($row) = @_;
    ($rows, $cols, $slices, $vols) = @$row;
  }, sub{}, $fid);
  $http->queue("<br>rows: $rows, cols: $cols, slices: $slices, vols: $vols");
}
sub ReviewInfo{
  my($self, $http, $dyn) = @_;
  my $fid = $self->{ImageList}->[$self->{CurrentIndexList}];
  unless(exists $self->{NiftiFiles}->{$fid}->{reviews}) { return }
  for my $user (keys %{$self->{NiftiFiles}->{$fid}->{reviews}}){
    my $h = $self->{NiftiFiles}->{$fid}->{reviews}->{$user};
    for my $stat (keys %$h){
      my $rev = $h->{$stat};
      for my $time (sort {$a cmp $b} keys %$rev){
         $http->queue("<br>Reviewed by $user: $stat at $time");
       }
    }
  }
}

my $img_exp = <<EOF;
<img src="FetchProjection?obj_path=<?dyn="q_path"?>&type=max&index=<?dyn="IndexFid"?>" alt="max" width="<?dyn="ImageWidth"?>" height="<?dyn="ImageHeight"?>">
<img src="FetchProjection?obj_path=<?dyn="q_path"?>&type=avg&index=<?dyn="IndexFid"?>" alt="avg" width="<?dyn="ImageWidth"?>" height="<?dyn="ImageHeight"?>">
<img src="FetchProjection?obj_path=<?dyn="q_path"?>&type=min&index=<?dyn="IndexFid"?>" alt="min" width="<?dyn="ImageWidth"?>" height="<?dyn="ImageHeight"?>">
EOF
sub DispImage{
  my($self, $http, $dyn) = @_;
  
  if($#{$self->{ImageList}} >= 0){
    my $fid = $self->{ImageList}->[$self->{CurrentIndexList}];
    $self->RefreshEngine($http, $dyn, $img_exp);
  } else {
    $http->queue("No files to show");
  }
}

sub ImageHeight{
  my($self, $http, $dyn) = @_;
  $http->queue($self->{image_height});
}

sub ImageWidth{
  my($self, $http, $dyn) = @_;
  $http->queue($self->{image_width});
}

my $content = <<EOF;
<div id="divImage"
   style="display: flex; flex-direction: row; align-items: flex_beginning; margin-top: 5px; margin-right: 5px; margin-bottom: 5px; margin-left: 5px;">
<?dyn="DispImage"?>
</div>
<div id="divButtons"
   style="display: flex; flex-direction: row; align-items: flex_beginning; margin-top: 5px; margin-right: 5px; margin-bottom: 5px; margin-left: 5px;">
<input type="Button" class="btn btn-default"
   onclick="javascript:PosdaGetRemoteMethod( 'Skip', '',
     function () {
       UpdateDivs([
        ['divImage', 'DispImage'],
        ['divInfo','Info'],
        ['divFilter','FilterTypeSelector']
       ]); 
     }
   );" value="Skip"
>
<input type="Button" class="btn btn-default"
  onclick="javascript:PosdaGetRemoteMethod('Good', '',
    function () {
      UpdateDivs([
        ['divImage', 'DispImage'],
        ['divInfo','Info'],
        ['divFilter','FilterTypeSelector']
      ]); 
    }
  );" value="Good"
>
<input type="Button" class="btn btn-default"
  onclick="javascript:PosdaGetRemoteMethod('Bad', '',
    function () {
      UpdateDivs([
        ['divImage', 'DispImage'],
        ['divInfo','Info'],
        ['divFilter','FilterTypeSelector']
      ]); 
    }
  );" value="Bad"
>
</div>
<div id="divFilter" width="200px">
<?dyn="FilterTypeSelector"?>
</div>
<div id="divInfo">
<?dyn="Info"?>
</div>
EOF

sub FilterTypeSelector{
  my($self, $http, $dyn) = @_;
  $self->RefreshEngine($http, $dyn,
    "<select id=\"FilterTypeSelector\" width=\"200px\" " .
    "onchange=\"javascript:PosdaGetRemoteMethod('SetFilterType', 'value=' +\n" .
    "  this.options[this.selectedIndex].value,\n".
    "  function () {\n" .
    "    UpdateDivs([\n" .
    "      ['divImage', 'DispImage'],\n" .
    "      ['divInfo', 'Info'],\n" .
    "      ['divFilter', 'FilterTypeSelector']\n" .
    "    ]);\n" .
    " });\">" .
    "<?dyn=\"FilterTypeOptions\"?>" .
    "</select>");
}

sub FilterTypeOptions{
  my($self, $http, $dyn) = @_;
  unless(defined $self->{FilterType}){ $self->{FilterType} = "Not Reviewed" }
  my @options = ("All", "Not Reviewed");
  for my $user (keys %{$self->{Reviewers}}){
    push @options, "Reviewed by $user";
    push @options, "Not Reviewed by $user";
  }
  for my $option (@options){
    $http->queue("<option value=\"$option\"");
    if($option eq $self->{FilterType}){
      $http->queue(" selected");
    }
    $http->queue(">$option</option>");
  }
}

sub SetFilterType{
  my($self, $http, $dyn) = @_;
  $self->{FilterType} = $dyn->{value};
  $self->Initialize;
  $self->InitializeImageList;
}

sub Content{
  my($self, $http, $dyn) = @_;
  $self->RefreshEngine($http, $dyn, $content);
}
1;

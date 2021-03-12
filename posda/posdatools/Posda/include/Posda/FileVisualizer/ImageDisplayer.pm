package Posda::FileVisualizer::ImageDisplayer;
use strict;

use Posda::PopupWindow;
use Posda::HttpApp::SimplifiedImageDisp;
use Posda::DB qw( Query );
use Digest::MD5;

use vars qw( @ISA );
@ISA = ("Posda::PopupWindow");

########################################################
## Old Content Skeleton from ItcTools:
my $content = <<EOF;
<table width=100% border="0">  <! Table with 3 columns, 4 rows... >
<tr>  <!------ Top level table row (image display, isodose, image sel)-->
<td>
  <?dyn="iframe" height="605" width="590" child_path="ImageDisp"?>
</td>
</tr>
<tr>   <!-------- Top level table row (ROI Selection, W/L presets)---->
</table>
EOF

########################################################

sub MakeQueuer{ 
  my($http) = @_;
  my $sub = sub {
    my($txt) = @_;
    $http->queue($txt);
  };
  return $sub;
}

sub SpecificInitialize {
  my ($self, $params) = @_;
  $self->{title} = "Image Displayer";
  Posda::HttpApp::SimplifiedImageDisp->new($self->{session},
    $self->child_path("ImageDisp"), $params);
  $self->{params} = $params;
}

sub ContentResponse {
  my ($self, $http, $dyn) = @_;
  $self->RefreshEngine($http, $dyn, $content)
}

sub MenuResponse {
}

1;

package Posda::FileVisualizer::DicomImage;
use strict;

use Posda::PopupWindow;
use Posda::DB qw( Query );
use Digest::MD5;
use ActivityBasedCuration::Quince;


use vars qw( @ISA );
@ISA = ("Posda::FileVisualizer");
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
  $self->{title} = "Dicom Image File Visualizer";
}

sub ContentResponse {
  my ($self, $http, $dyn) = @_;
    $self->DisplayDicomDump($http, $dyn);
}
sub OpenInQuince{
  my ($self, $http, $dyn) = @_;
  bless $self, "ActivityBasedCuration::Quince";
  $self->Initialize({
    type => "file",
    file_id => $self->{params}->{file_id}
  });
}

sub MenuResponse {
  my ($self, $http, $dyn) = @_;
  $self->NotSoSimpleButton($http, {
    op => "ShowDicomDump",
    caption => "ShowDicomDump",
    sync => "Update();"
  });
  $self->NotSoSimpleButton($http, {
    op => "OpenInQuince",
    caption => "Open in Quince",
    sync => "Reload();"
  });
}

1;

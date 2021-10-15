package Posda::FileVisualizer::PNG;

use Posda::FileVisualizer;
use Posda::ImageDisplayer;
use Posda::PopupWindow;
use Debug;

use vars qw( @ISA );
@ISA = ("Posda::FileVisualizer", "Posda::ImageDisplayer");

sub SpecificInitialize {
  my ($self, $params) = @_;
  $self->{title} = "Png File: $self->{file_id}";
  $self->{params} = $params;
}

sub ContentResponse {
  my ($self, $http, $dyn) = @_;
  my $queuer = Posda::FileVisualizer::MakeQueuer($http);
  $http->queue("<pre>Params: ");
  Debug::GenPrint($queuer, $self->{params}, 1);
  $http->queue(";\n");
  $http->queue("</pre>");
  $http->queue("<img src=\"FetchPng?obj_path=$self->{path}&file_id=$self->{file_id}\">");
}

#sub FetchPng{
#  my ($self, $http, $dyn) = @_;
#  print STDERR "In Fetch PNG\n";
#}

sub MenuResponse {
  my ($self, $http, $dyn) = @_;
}

1;

package Posda::SeriesVisualizer;

use Posda::PopupWindow;
use Posda::DB qw( Query );
use Digest::MD5;
use ActivityBasedCuration::Quince;


use vars qw( @ISA );
@ISA = ("Posda::PopupWindow");
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
  $self->{title} = "Generic SeriesVisualizer";
  # Determine temp dir
  $self->{temp_path} = "$self->{LoginTemp}/$self->{session}";
  $self->{params} = $params;
#  Query('GetBasicFileInfo')->RunQuery(sub{
#  }, sub  {}, $self->{file_id};

}

sub ContentResponse {
  my ($self, $http, $dyn) = @_;
  my $queuer = MakeQueuer($http);
  $http->queue("<pre>Params: ");
  Debug::GenPrint($queuer, $self->{params}, 1);
  $http->queue(";\n");
  $http->queue("</pre>");
}

sub OpenInQuince{
  my ($self, $http, $dyn) = @_;
  bless $self, "ActivityBasedCuration::Quince";
  $self->Initialize({
    type => "series",
    series_instance_uid => $self->{params}->{series_instance_uid}
  });
}


sub MenuResponse {
  my ($self, $http, $dyn) = @_;
  $self->NotSoSimpleButton($http, {
     op => "OpenInQuince",
     caption => "Open in Quince",
     sync => "Reload();"
  });
}

1;

package Posda::TestPopup;



use Modern::Perl;

use Posda::Config ('Config','Database');
use Posda::DB 'Query';

use File::Slurp;
use Regexp::Common "URI";

use parent 'Posda::PopupWindow';
use Debug;
sub make_ht_dbg{
  my($http) = @_;
  return sub {
    for my $t (@_){
      $http->queue($t);
    }
  };
}


sub SpecificInitialize {
  my ($self, $params) = @_;
  $self->{title} = 'Popup Params Viewer';
  $self->{params} = $params;
}

sub ContentResponse {
  my ($self, $http, $dyn) = @_;
  $http->queue("<h2>Popup Text Viewer</h2>");
  $http->queue("<p>Params viewer</p>");

  $http->queue("<pre>params: ");
  my $fn = make_ht_dbg($http);
  Debug::GenPrint($fn, $self->{params}, 1);
  $http->queue("</pre>");
}

sub MenuResponse {
  my ($self, $http, $dyn) = @_;
}
1;


package Posda::TestPopup;



use Modern::Perl;
use Method::Signatures::Simple;

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


method SpecificInitialize($params) {
  $self->{title} = 'Popup Params Viewer';
  $self->{params} = $params;
}

method ContentResponse($http, $dyn) {
  $http->queue("<h2>Popup Text Viewer</h2>");
  $http->queue("<p>Params viewer</p>");

  $http->queue("<pre>params: ");
  my $fn = make_ht_dbg($http);
  Debug::GenPrint($fn, $self->{params}, 1);
  $http->queue("</pre>");
}

method MenuResponse($http, $dyn) {
}
1;


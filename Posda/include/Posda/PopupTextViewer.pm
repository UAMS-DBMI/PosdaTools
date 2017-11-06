package Posda::PopupTextViewer;
# 
#

use Modern::Perl;
use Method::Signatures::Simple;

use Posda::Config ('Config','Database');
use Posda::DB 'Query';

use File::Slurp;

use parent 'Posda::PopupWindow';


method SpecificInitialize($params) {
  $self->{title} = 'Popup Text Viewer';

  my $file_id = $params->{file_id};
  $self->{file_id} = $file_id;

  my $results = Query('FilePathByFileId')->FetchOneHash($file_id);
  $self->{filename} = $results->{path};

  my $text = read_file($self->{filename}) ;
  $self->{text} = $text;
}

method ContentResponse($http, $dyn) {
  $http->queue("<h2>Popup Text Viewer</h2>");
  $http->queue("<p>Viewing $self->{file_id} ($self->{filename})</p>");
  $http->queue("<pre>$self->{text}</pre>");
}

method MenuResponse($http, $dyn) {
}

1;

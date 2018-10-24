package DbIf::ShowSubprocessLines;
# 
#

use Modern::Perl;
use Method::Signatures::Simple;

use Posda::Config ('Config','Database');
use Posda::DB 'Query';

use File::Slurp;
use Regexp::Common "URI";

use parent 'Posda::PopupWindow';


method SpecificInitialize($params) {
  $self->{title} = 'Popup Response Line  Viewer';

  my $sub_id = $params->{sub_id};
  $self->{sub_id} = $sub_id;

  my $lq = Query('GetSubprocessLines');
  $self->{lines} = [];
  $lq->RunQuery(sub{
    my($row) = @_;
    push @{$self->{lines}}, $row->[0];
  }, sub {}, $self->{sub_id});
}

method ContentResponse($http, $dyn) {
  $http->queue("<h2>Popup Text Viewer</h2>");
  $http->queue("<p>Viewing response to subprocess invocation:$self->{file_id}</p>");

  $http->queue("<pre>");
  for my $line(@{$self->{lines}}){
    $http->queue("$line\n");
  }
  $http->queue("</pre>");
}

method MenuResponse($http, $dyn) {
  $http->queue(qq{
    <a class="btn btn-primary" 
       href="DownloadTextAsTxt?obj_path=$self->{path}">
       Download Text
    </a>
  });
}
method ScriptButton($http, $dyn){
  my $parent = $self->parent;
  if($parent->can("ScriptButton")){
    $parent->ScriptButton($http, $dyn);
  }
}
method DownloadTextAsTxt($http, $dyn){
  $http->DownloadHeader("text/plain", "Foo.txt");
  for my $line(@{$self->{lines}}){
    $http->queue("$line\n");
  }
}
1;

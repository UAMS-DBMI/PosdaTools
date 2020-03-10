package ActivityBasedCuration::ShowSubprocessLines;
# 
#

use Modern::Perl;

use Posda::Config ('Config','Database');
use Posda::DB 'Query';

use File::Slurp;
use Regexp::Common "URI";

use parent 'Posda::PopupWindow';


sub SpecificInitialize {
  my ($self, $params) = @_;
  $self->{title} = 'Popup Response Line Viewer';

  my $sub_id = $params->{sub_id};
  $self->{sub_id} = $sub_id;

  my $lq = Query('GetSubprocessLines');
  $self->{lines} = [];
  $lq->RunQuery(sub{
    my($row) = @_;
    push @{$self->{lines}}, $row->[0];
  }, sub {}, $self->{sub_id});
}

sub ContentResponse {
  my ($self, $http, $dyn) = @_;
  $http->queue("<h2>Popup Text Viewer</h2>");
  $http->queue("<p>Viewing response to subprocess invocation:$self->{file_id}</p>");

  $http->queue("<pre>");
  for my $line(@{$self->{lines}}){
    $http->queue("$line\n");
  }
  $http->queue("</pre>");
}

sub MenuResponse {
  my ($self, $http, $dyn) = @_;
  $http->queue(qq{
    <a class="btn btn-primary" 
       href="DownloadTextAsTxt?obj_path=$self->{path}">
       Download Text
    </a>
  });
}
sub ScriptButton {
  my ($self, $http, $dyn) = @_;
  my $parent = $self->parent;
  if($parent->can("ScriptButton")){
    $parent->ScriptButton($http, $dyn);
  }
}
sub DownloadTextAsTxt {
  my ($self, $http, $dyn) = @_;
  $http->DownloadHeader("text/plain", "Foo.txt");
  for my $line(@{$self->{lines}}){
    $http->queue("$line\n");
  }
}
1;

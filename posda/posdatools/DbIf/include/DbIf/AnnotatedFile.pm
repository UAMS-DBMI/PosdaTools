package DbIf::AnnotatedFile;
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
  $self->{title} = 'Downloader for Annotated Files';
  $self->{params} = $params
}

method ContentResponse($http, $dyn) {
  $http->queue("<h2>Downloader for Annotated Files</h2>");
  $http->queue("<pre>");
  for my $i (keys %{$self->{params}}){
    $http->queue("$i : $self->{params}->{$i}\n");
  }
  $http->queue("</pre>");
}

method MenuResponse($http, $dyn) {
  $http->queue(qq{
    <a class="btn btn-primary" 
       href="DownloadThisFile?obj_path=$self->{path}">
       Download This File
    </a>
  });
}
method ScriptButton($http, $dyn){
  my $parent = $self->parent;
  if($parent->can("ScriptButton")){
    $parent->ScriptButton($http, $dyn);
  }
}
method DownloadThisFile($http, $dyn){
  my $file_id = $self->{params}->{file_id};
  my $filename;
  Query('GetFilePath')->RunQuery(sub{
    my($row) = @_;
    $filename = $row->[0];
  }, sub {}, $file_id);
  my $fh;
  if(open $fh, $filename) {
    $http->DownloadHeader($self->{params}->{mime_type}, $self->{params}->{targ_name});
    Dispatch::Select::Socket->new(
      $self->SendFile($http),
    $fh)->Add("reader");
  } else {
    print STDERR "Can't open file $filename\n";
  }
}
sub SendFile{
  my($this, $http) = @_;
  my $sub = sub {
    my($disp, $sock) = @_;
    my $buff;
    my $count = sysread($sock, $buff, 10240);
    if($count <= 0){
      $disp->Remove;
      return;
    }
    if($http->ready_out){
      $http->queue($buff);
    } else {
      $disp->Remove("reader");
      my $event = Dispatch::Select::Event->new(
        Dispatch::Select::Background->new(
          $this->WaitHttpReady($disp, $buff, $http)));
      $http->wait_output($event);
    }
  };
  return $sub;
}
sub WaitHttpReady{
  my($this, $disp, $buff, $http) = @_;
  my $sub = sub {
    my($event) = @_;
    $http->queue($buff);
    $disp->Add("reader");
  };
  return $sub;
}
1;

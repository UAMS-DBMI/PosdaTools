package Posda::PopupTextViewer;
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
  $self->{title} = 'Popup Text Viewer';

  my $file_id = $params->{file_id};
  $self->{file_id} = $file_id;
  if(exists $params->{spreadsheet_file_id}){
    $self->{spreadsheet} = 1;
  }

  my $results = Query('FilePathByFileId')->FetchOneHash($file_id);
  $self->{filename} = $results->{path};

  my $text = read_file($self->{filename}) ;
  $self->{text} = $text;
}

sub HeaderResponse{
  my($this, $http, $dyn) = @_;
  return $this->RefreshEngine($http, $dyn,'<center><h1><?dyn="title"?></h1></center>');

}


sub ContentResponse {
  my ($self, $http, $dyn) = @_;
  $http->queue("<h2>Popup Text Viewer</h2>");
  $http->queue("<p>Viewing $self->{file_id} ($self->{filename})</p>");


  my $file_content = $self->{text};

  # Turn any URLs into actual links
  if(exists $self->{spreadsheet}){
     $file_content =~ s/</&lt;/gx;
     $file_content =~ s/>/&gt;/gx;
  } else {
    $file_content =~    s( ($RE{URI}{HTTP}{-scheme => qr<https?>}) )
                  (<a href="$1">$1</a>)gx  ;
  }


  $http->queue("<pre>$file_content</pre>");
}

sub MenuResponse {
  my ($self, $http, $dyn) = @_;
  $http->queue(qq{
    <a class="btn btn-primary" 
       href="DownloadTextAsCsv?obj_path=$self->{path}">
       Download as CSV
    </a><br>
    <a class="btn btn-primary" 
       href="FixBadCsv?obj_path=$self->{path}">
       Download as Fixed Bad CSV (from CTP)
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
sub DownloadTextAsCsv {
  my ($self, $http, $dyn) = @_;
  $http->DownloadHeader("text/csv", "Foo.csv");
  $http->queue($self->{text});
}
sub FixBadCsv {
  my ($self, $http, $dyn) = @_;
  $http->DownloadHeader("text/csv", "Foo.csv");
  my $text_to_fix = $self->{text};
  $text_to_fix =~ s/=\(//g;
  $text_to_fix =~ s/\),/,/g;
  $http->queue($text_to_fix);
}
1;

package DbIf::ShowSr;
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
  $self->{title} = 'DICOM SR Viewer';
  $self->{mode} = 'Text';

  my $raw_path = $params->{dicom_file_uri};
  if($raw_path){
    my $converted_path;
    if($raw_path =~ /(storage.*)$/){
       $self->{converted_path} = "/nas/public/$1";
    }
  } else {
    $raw_path = $params->{file_path};
    $self->{converted_path} = $raw_path;
  }
}

method ContentResponse($http, $dyn) {
  $http->queue("<h2>DICOM SR Viewer ($self->{mode})</h2>");
  $http->queue("<p>File: $self->{converted_path}</p>");

  my $dumper = "DumpSr.pl";
  if($self->{mode} eq "Struct"){
    $dumper = "DumpSrStruct.pl";
  }
  if($self->{mode} eq "DICOM"){
    $dumper = "DumpDicom.pl";
  }
  $http->queue("<pre>");
  open CHILD, "$dumper $self->{converted_path}|";
  while(my $line = <CHILD>){
    $http->queue($line);
  }
  $http->queue("</pre>");
}

method MenuResponse($http, $dyn) {
  $self->NotSoSimpleButton($http, {
     op => "ViewTextSummary",
     caption => "Text",
     sync => "Update();"
  });
  $http->queue("<br>");
  $self->NotSoSimpleButton($http, {
     op => "ViewStruct",
     caption => "Struct",
     sync => "Update();"
  });
  $http->queue("<br>");
  $self->NotSoSimpleButton($http, {
     op => "ViewDicom",
     caption => "DICOM",
     sync => "Update();"
  });

  $http->queue("<br>");
  $http->queue("<hr>");
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
method ViewTextSummary($http, $dyn){
  $self->{mode} = "Text";
}
method ViewStruct($http, $dyn){
  $self->{mode} = "Struct";
}
method ViewDicom($http, $dyn){
  $self->{mode} = "DICOM";
}
method DownloadTextAsTxt($http, $dyn){
  $http->DownloadHeader("text/plain", "Foo.txt");
  my $dumper = "DumpSr.pl";
  if($self->{mode} eq "Struct"){
    $dumper = "DumpSrStruct.pl";
  }
  if($self->{mode} eq "DICOM"){
    $dumper = "DumpDicom.pl";
  }
  open CHILD, "$dumper $self->{converted_path}|";
  while(my $line = <CHILD>){
    $http->queue($line);
  }
}

1;

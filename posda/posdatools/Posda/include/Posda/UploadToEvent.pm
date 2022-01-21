package Posda::UploadToEvent;
# 
#
use strict;

use Posda::Config ('Config','Database');
use Posda::DB 'Query';
use parent 'Posda::PopupWindow';


sub SpecificInitialize {
  my ($self, $params) = @_;
  $self->{title} = 'Upload Data to Timepoint';
  $self->{state} = "Upload";
  $self->{params} = $params;
  $self->{user} = $params->{user};
  $self->{TempDir} = $params->{TempDir};
  $self->{UploadCount} = 0;
  $self->{upload_comment_string} = $params->{upload_comment_string};
  open IMPORTER, "|ImportMultipleTempFilesIntoPosda.pl $self->{upload_comment_string}" or die "Can't open Importer";
}

sub HeaderResponse{
  my($this, $http, $dyn) = @_;
  return $this->RefreshEngine($http, $dyn,'<center><h1><?dyn="title"?></h1></center>');
}

sub ContentResponse {
  my ($self, $http, $dyn) = @_;
  if($self->{state} eq "Upload"){
    return $self->UploadContent($http, $dyn);
  } else {
    return $self->UploadedContent($http, $dyn);
  }
}

sub UploadContent{
  my($self, $http, $dyn) = @_;
  $self->RefreshEngine($http, $dyn, qq{
  <div style="display: flex; flex-direction: column; align-items: flex-beginning;
    margin-left: 10px; margin-bottom: 5px">
  <div id="file_report">
  <?dyn="Files"?>
  </div>
  <div id="load_form">
  <form action="<?dyn="StoreFileUri"?>"
    enctype="multipart/form-data" method="POST" class="dropzone">
  </form>
  </div>
  </div>
  });
}

sub StoreFileUri {
  my ($self, $http, $dyn) = @_;
  $http->queue("StoreFile?obj_path=$self->{path}");
}

sub StoreFile {
  my ($self, $http, $dyn) = @_;
  my $method = $http->{method};
  my $content_type = $http->{header}->{content_type};
  unless($method eq "POST" && $content_type =~ /multipart/){
    print STDERR "No file posted\n";
    return;
  }
  $self->{UploadCount}++;
  my $file = $http->ParseMultipart(
     "$self->{TempDir}/$self->{UploadCount}.upld");
  print STDERR "File uploaded: $file\n";
  print IMPORTER "$file\n";
  $http->queue("<pre>");
  $http->queue("File uploaded into $file\n");
  $http->queue("</pre>");
#  &{$self->UploadDone($http, $dyn)}($file);
}

sub UploadDone{
  my ($self, $http, $dyn) = @_;
  my $sub = sub {
    my($file) = @_;
    $http->queue("<pre>");
    $http->queue("File uploaded into $file\n");
    for my $k (keys %$dyn){
      $http->queue("dyn{$k} = $dyn->{$k}\n");
    }
    for my $k (keys %$http){
      $http->queue("http{$k} = $http->{$k}\n");
    }
    for my $k (keys %{$http->{header}}){
      $http->queue("http{header}->{$k} = $http->{header}->{$k}\n");
    }
    $http->queue("<a href=\"Refresh?obj_path=$self->{path}\">Go back</a>");
    $http->queue("<hr><pre>");
  };
  return $sub;
}

sub Files{
  my($self, $http, $dyn) = @_;
  $http->queue("$self->{UploadCount} files queued for " .
    "upload_event with comment \"$self->{upload_comment_string}\"");
};

sub UpdateStatus{
  my ($self, $http, $dyn) = @_;
}

sub MenuResponse {
  my ($self, $http, $dyn) = @_;
  $self->NotSoSimpleButton($http, {
     op => "UpdateStatus",
     caption => "UpdateStatus",
     sync => "UpdateDiv('file_report', 'Files');",
     class => 'btn btn-default'
  });
}

1;

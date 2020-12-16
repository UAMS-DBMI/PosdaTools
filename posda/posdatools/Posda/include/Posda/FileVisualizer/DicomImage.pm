package Posda::FileVisualizer::DicomImage;

use Posda::PopupWindow;
use Posda::DB qw( Query );
use Digest::MD5;
use ActivityBasedCuration::Quince;


use vars qw( @ISA );
@ISA = ("Posda::FileVisualizer");

sub SpecificInitialize {
  my ($self) = @_;
  $self->{mode} = "show_dicom_dump";
}

sub ContentResponse {
  my ($self, $http, $dyn) = @_;
  if(defined($self->{mode}) && $self->{mode} eq "show_dicom_dump"){
    $http->queue("<h3>Dump of DICOM file $self->{file_id}</h3><pre>");
    open FILE, "<$self->{dicom_dump_file}";
    while(my $line = <FILE>){
      $line =~ s/</&lt/g;
      $line =~ s/>/&gt/g;
      $http->queue($line);
    }
    $http->queue("</pre>");
    return;
  }
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
    type => "file",
    file_id => $self->{params}->{file_id}
  });
}

sub MenuResponse {
  my ($self, $http, $dyn) = @_;
  if($self->{is_dicom_file}){
    $self->NotSoSimpleButton($http, {
       op => "ShowDicomDump",
       caption => "ShowDicomDump",
       sync => "Update();"
    });
    $self->NotSoSimpleButton($http, {
       op => "OpenInQuince",
       caption => "Open in Quince",
       sync => "Reload();"
    });
  }
}

1;

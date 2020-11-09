package Posda::FileVisualizer;

use Modern::Perl;

use Posda::PopupWindow;
use Posda::DB qw( Query );

use Data::Dumper;

use MIME::Base64;


use vars qw( @ISA );
@ISA = ("Posda::PopupWindow");
sub MakeQueuer{ 
  my($http) = @_;
  my $sub = sub {
    my($txt) = @_;
    $http->queue($txt);
  };
  return $sub;
}

sub SpecificInitialize {
  my ($self, $params) = @_;
  $self->{title} = "Generic File Visualizer";
  # Determine temp dir
  $self->{temp_path} = "$self->{LoginTemp}/$self->{session}";
  $self->{params} = $params;
  $self->{file_id} = $params->{file_id};
  if($self->{params}->{file_type} eq "parsed dicom file"){
    $self->{is_dicom_file} = 1;
    $self->{sop_class_name} = $self->{params}->{dicom_file_type};
    $self->{modality} = $self->{params}->{modality};
  } else {
    $self->{is_dicom_file} = 0;
  }
#  Query('GetBasicFileInfo')->RunQuery(sub{
#  }, sub  {}, $self->{file_id};

}

sub ContentResponse {
  my ($self, $http, $dyn) = @_;
  if(defined($self->{mode}) && $self->{mode} eq "show_dump"){
    $http->queue("<h3>Dump of DICOM file $self->{file_id}</h3><pre>");
    open FILE, "<$self->{dump_file}";
    while(my $line = <FILE>){
      $http->queue($line);
    }
    $http->queue("</pre>");
    return;
  }
  my $queuer = MakeQueuer($http);
  $http->queue("<pre>Parms: ");
  Debug::GenPrint($queuer, $self->{params}, 1);
  $http->queue(";\n");
  $http->queue("</pre>");
}

sub ShowDicomDump{
  my ($self, $http, $dyn) = @_;
  unless(exists $self->{dump_file}){
    my $path;
    Query("GetFilePath")->RunQuery(sub{
      my($row) = @_;
      $path = $row->[0];
    }, sub{}, $self->{file_id});
    if(defined $path){
      my $dump_name = "$self->{temp_path}/Dumpfile";
      my $dump_cmd = "DumpDicom.pl \"$path\" >$dump_name";
      open DUMP, "$dump_cmd|";
      while(my $line = <DUMP>){}
      $self->{dump_file} = $dump_name;
    }
  }
  if(defined($self->{dump_file}) && -e $self->{dump_file}){
    $self->{mode} = "show_dump";
  }
}


sub MenuResponse {
  my ($self, $http, $dyn) = @_;
  if($self->{is_dicom_file}){
    $self->NotSoSimpleButton($http, {
       op => "ShowDicomDump",
       caption => "ShowDicomDump",
       sync => "Update();"
    });
  }
}

1;

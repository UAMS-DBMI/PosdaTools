package Posda::FileVisualizer::Nifti;

use Posda::PopupWindow;
use Debug;

use vars qw( @ISA );
@ISA = ("Posda::FileVisualizer");

sub SpecificInitialize {
  my ($self, $params) = @_;
  $self->{title} = "Nifti File: $self->{file_id}";
  $self->{params} = $params;
  $self->{mode} = "show_dicom_dump";
}

sub ContentResponse {
  my ($self, $http, $dyn) = @_;
  my $queuer = Posda::FileVisualizer::MakeQueuer($http);
  $http->queue("<pre>Params: ");
  Debug::GenPrint($queuer, $self->{params}, 1);
  $http->queue(";\n");
  $http->queue("</pre>");
}


sub MenuResponse {
  my ($self, $http, $dyn) = @_;
  $self->NotSoSimpleButton($http, {
     op => "Display",
     caption => "Display",
     sync => "Update();"
  });
}

sub Display{
  my ($self, $http, $dyn) = @_;
  my $class = "Posda::ImageDisplayer::Nifti";
  eval "require $class";
  if($@){
    print STDERR "Class failed to compile\n\t$@\n";
    return;
  }

  unless(exists $self->{sequence_no}){$self->{sequence_no} = 0}
  my $name = "$self->{name}" . "_$self->{sequence_no}";
  $self->{sequence_no} += 1;

  my $child_path = $self->child_path($name);
  my $child_obj = $class->new($self->{session},
                              $child_path, $self->{params});
  $self->StartJsChildWindow($child_obj);
}

1;

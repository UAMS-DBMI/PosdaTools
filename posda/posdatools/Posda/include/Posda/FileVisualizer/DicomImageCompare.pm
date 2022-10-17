package Posda::FileVisualizer::DicomImageCompare;
use strict;

use Posda::PopupWindow;
use Posda::DB qw( Query );
use File::Temp qw/ tempdir /;


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

my $tmpdir;

sub SpecificInitialize {
  my ($self, $params) = @_;
  $self->{title} = "Dicom Image File Comparison Visualizer";
print STDERR "#########\n";
print STDERR "In specific FileVisualizer::DicomImageCompare::SpecificInitialize\n";
print STDERR "params:\n";
for my $k (keys %$params){
  print STDERR "$k = $params->{$k}\n";
}
  $self->{from_file_id} = $params->{from_file};
  $self->{to_file_id} = $params->{to_file};
  $tmpdir = &tempdir( CLEANUP => 1);
#  my $gp = Query('GetFilePath');
#  $gp->RunQuery(sub{
#    my($row) = @_;
#    $self->{FromFilePath} = $row->[0];
#  }, sub{}, $self->{from_file_id});
#  $gp->RunQuery(sub{
#    my($row) = @_;
#    $self->{ToFilePath} = $row->[0];
#  }, sub{}, $self->{to_file_id});
#  unless(-r $self->{ToFilePath}){
#    die
#    "To file for $self->{to_file_id} ($self->{ToFilePath}) is not readable";
#  }
#  unless(-r $self->{FromFilePath}){
#    die
##    "To file for $self->{from_file_id} ($self->{FromFilePath}) is not readable";
#  }
  $self->{ResultsFile} = "$tmpdir/IheDiffs.html";
  my $cmd = "CompareDicomFilesById.pl \"$self->{from_file_id}\" " .
    "\"$self->{to_file_id}\" \"$tmpdir\" \"$self->{ResultsFile}\"";
  print STDERR "#########################\n";
  print STDERR "Tempdir: $tmpdir\n";
  print STDERR "Cmd: $cmd\n";
  open FOO, "$cmd|" or die "Can't open cmd (!$)";
  while(my $line = <FOO>){
    chomp $line;
    print STDERR "Line from cmd: $line\n";
  }
  print STDERR "#########################\n";
}

sub ContentResponse {
  my ($self, $http, $dyn) = @_;
  open FILE, "<$self->{ResultsFile}" or die "Can't open results ($!)";
  while(my $line = <FILE>){
    $http->queue($line);
  }
#  $http->queue("content here");
#  $http->queue("<pre>self:\n");
#  for my $i (keys %{$self}){
#    $http->queue("$i => $self->{$i}\n");
#  }
}



sub MenuResponse {
  my ($self, $http, $dyn) = @_;
#  $http->queue("menu here");
}

1;

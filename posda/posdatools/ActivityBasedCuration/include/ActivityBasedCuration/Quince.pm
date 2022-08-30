package ActivityBasedCuration::Quince; 

use Posda::HttpApp::JsController;
use Dispatch::NamedObject;


use Debug;
my $dbg = sub {print STDERR @_ };

use vars qw( @ISA );
@ISA = ( "Posda::HttpApp::JsController" );


sub new {
  my($class, $sess, $path, $parameters) = @_;

  my $self = Dispatch::NamedObject->new($sess, $path);
  bless $self, $class;
  print STDERR "param = ";
  Debug::GenPrint($dbg, $parameters, 1);
  print STDERR "\n";
  return $self->Initialize($parameters);
}

sub Initialize{
  my($self, $parameters) = @_;
  my $prot = "http:";
  if(exists($ENV{POSDA_SECURE_ONLY}) && $ENV{POSDA_SECURE_ONLY}){
    $prot = "https:";
  }
  my $host_url = $ENV{POSDA_EXTERNAL_HOSTNAME};
  my $base_url;
  if($parameters->{type} eq "file"){
    $base_url = 
      "$prot//$host_url/viewer/file/$parameters->{file_id}";
  } elsif ($parameters->{type} eq "series"){
    $base_url = 
      "$prot//$host_url/viewer/series/$parameters->{series_instance_uid}";
  }
  my $url = $base_url;
  my $expander = "HTTP/1.0 201 Created\n" .
    "Location: $url\n" .
    "Content-Type: text/html\n\n" .
    "<!DOCTYPE html " .
    "PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" " .
    "\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">" .
    "\n<html><head>" .
    "<meta http-equiv=\"refresh\" content=\"0;" .
    "URL=$url\" />" .
    "\n<script>" .
    " CNTLrefresh=window.setTimeout(function(){window.location.href=\"$url\"},1000);" .
    "\n</script>" .
    "</head>\n<body>logged in OK, redirecting...." .
    "\n<a href=\"$url\">$url</a>\n" .
    "<?dyn=\"DeleteMe\"?>" .
    "</body></html>";
  $self->{expander} = $expander;

  $self->{title} = "Quince - Series $parameters->{series_instance_uid}";
  $self->{height} = 1000;
  $self->{width} = 1000;

  $self->{JavascriptRoot} =
    $main::HTTP_APP_CONFIG->{config}->{Environment}->{JavascriptRoot};
  $self->{LoginTemp} = 
    $main::HTTP_APP_CONFIG->{config}->{Environment}->{LoginTemp};

  $self->QueueJsCmd("Update();");
  my $session = $self->get_session;
  $session->{DieOnTimeout} = 1;

  $self->{ExitOnLogout} = 1;
  $self->{Environment}->{ApplicationName} = "PopupApp";

  return $self;
}

sub DeleteMe{
  my($self, $http, $dyn) = @_;
  Dispatch::Select::Background->new($self->MakeDeleter($http, $dyn))->timer(10);
}
sub MakeDeleter{
  my($self, $http, $dyn) = @_;
  my $sub = sub{
    unless($self->{deleted}){
      $self->DeleteSelf;
      $self->{deleted} = 1;
    }
  };
  return $sub;
}

1;

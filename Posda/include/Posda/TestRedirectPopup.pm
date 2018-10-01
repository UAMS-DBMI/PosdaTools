package Posda::TestRedirectPopup; 
use Modern::Perl;
use Method::Signatures::Simple;

use Posda::HttpApp::JsController;
use Dispatch::NamedObject;


use Debug;
my $dbg = sub {print STDERR @_ };

use vars qw( @ISA );
@ISA = ( "Posda::HttpApp::JsController" );


method new($class: $sess, $path, $parameters) {

  my $self = Dispatch::NamedObject->new($sess, $path);
  bless $self, $class;
  print STDERR "param = ";
  Debug::GenPrint($dbg, $parameters, 1);
  print STDERR "\n";


#  "button" => "testr",
#  "dicom_file_type" => "CT Image Storage",
#  "id" => "24",
#  "num_equiv" => "119",
#  "num_series" => "105",
#  "processing_status" => "Reviewed",
#  "review_status" => "Good"

  my $base_url = "http://tcia-posda-rh-1.ad.uams.edu/k/work?";
  $base_url .= "review_status=$parameters->{review_status}&";
  $base_url .= "processing_status=$parameters->{processing_status}&";
  $base_url .= "dicom_file_type=$parameters->{dicom_file_type}&";
  $base_url .= "visual_review_instance_id=$parameters->{id}";
#  my $url = "http://google.com";
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

  $self->{title} = "Test Popup Window";
  $self->{height} = 1000;
  $self->{width} = 1000;
  $self->{menu_width} = 5;
  $self->{content_width} = 5;

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

method DeleteMe($http, $dyn){
  Dispatch::Select::Background->new($self->MakeDeleter($http, $dyn))->timer(10);
}
method MakeDeleter($http, $dyn){
  my $sub = sub{
    unless($self->{deleted}){
      $self->DeleteSelf;
      $self->{deleted} = 1;
    }
  };
  return $sub;
}

1;

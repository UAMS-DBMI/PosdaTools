package Posda::PopupWindow;

use Modern::Perl;

use Posda::HttpApp::JsController;
use Dispatch::NamedObject;

use Posda::HttpApp::DebugWindow;
use Posda::HttpApp::Authenticator;

use Data::Dumper;
use Debug;
my $dbg = sub {print STDERR @_ };

use vars qw( @ISA );
@ISA = ( "Posda::HttpApp::JsController", "Posda::HttpApp::Authenticator" );

my $expander = qq{<?dyn="BaseHeader"?>
  <script type="text/javascript">
  <?dyn="JsController"?>
  <?dyn="JsContent"?>
  </script>
  </head>
  <body>
  <?dyn="Content"?>
</body>
</html>
};

sub new {
  my ($class, $sess, $path, $parameters) = @_;

  my $self = Dispatch::NamedObject->new($sess, $path);
  bless $self, $class;

  $self->{expander} = $expander;

  $self->{title} = "Test Popup Window";
  $self->{height} = 800;
  $self->{width} = 800;
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

  if (not $self->can("SpecificInitialize") or
      not $self->can("ContentResponse") or
      not $self->can("MenuResponse")) {
    die "Posda::PopupWindow must be subclassed, and you must implement " .
        "SpecificInitialize, ContentResponse, and MenuResponse";
  }

  if($self->can("SpecificInitialize")){
    $self->SpecificInitialize($parameters);
  }
  return $self;
}

my $content = qq{
<nav class="navbar navbar-default">
  <div class="container-fluid">
    <div class="navbar-header">
      <a class="navbar-brand" href="#">
        Posda.com
      </a>
    </div>
    <div class="navbar-text">
      <?dyn="title"?>
    </div>
    <div id="login" class="navbar-nav navbar-right">
      Login
    </div>
  </div>
</nav>

  <div class="container-fluid">
    <div class="row">
      <div id="menu" class="col-md-2">
      Menu
      </div>
      <div id="content" class="col-md-10">
      </div>
    </div>
  </div>
};

sub Content {
  my ($self, $http, $dyn) = @_;
  $self->{LaunchParams} = $dyn;
  $self->RefreshEngine($http, $dyn, $content);
}

sub GetJavascriptRoot {
  my ($self) = @_;
  return $self->{JavascriptRoot};
}

sub JsContent {
  my ($self, $http, $dyn) = @_;
  return $self->parent()->JsContent($http, $dyn);
}

###############################################################################
# Override below here
###############################################################################

# sub SpecificInitialize {
#  my ($self) = @_;
#   $self->{Mode} = "Initialized";
#   $self->{menustuff} = "Menu";
# }

# sub ContentResponse {
#  my ($self, $http, $dyn) = @_;
#   $self->NotSoSimpleButtonButton($http, {
#     op => "TestOp",
#     caption => "Button click me",
#   });
#   $http->queue(Dumper($self->{LaunchParams}));
# }

# sub MenuResponse {
#  my ($self, $http, $dyn) = @_;
#   $http->queue($self->{menustuff});
# }

# sub TestOp {
#  my ($self, $http, $dyn) = @_;
#   say STDERR "TestOp called";
#   $self->{menustuff} = "TestOp Called";
# }

1;

package Posda::PopupWindow;

use Modern::Perl;
use Method::Signatures::Simple;

use Posda::HttpApp::JsController;
use Dispatch::NamedObject;

use Posda::HttpApp::DebugWindow;
use Posda::HttpApp::Authenticator;

use Data::Dumper;

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

method new($class: $sess, $path, $parameters) {

  my $self = Dispatch::NamedObject->new($sess, $path);
  bless $self, $class;

  $self->{expander} = $expander;

  $self->{title} = "Test Popup Window";
  $self->{height} = 10;
  $self->{width} = 10;
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
      <div id="menu" class="col-md-1">
      Menu
      </div>
      <div id="content" class="col-md-9">
      </div>
    </div>
  </div>
};

method Content($http, $dyn) {
  $self->{LaunchParams} = $dyn;
  $self->RefreshEngine($http, $dyn, $content);
}

method GetJavascriptRoot() {
  return $self->{JavascriptRoot};
}

method JsContent($http, $dyn) {
  return $self->parent()->JsContent($http, $dyn);
}

###############################################################################
# Override below here
###############################################################################

# method SpecificInitialize() {
#   $self->{Mode} = "Initialized";
#   $self->{menustuff} = "Menu";
# }

# method ContentResponse($http, $dyn) {
#   $self->NotSoSimpleButtonButton($http, {
#     op => "TestOp",
#     caption => "Button click me",
#   });
#   $http->queue(Dumper($self->{LaunchParams}));
# }

# method MenuResponse($http, $dyn) {
#   $http->queue($self->{menustuff});
# }

# method TestOp($http, $dyn) {
#   say STDERR "TestOp called";
#   $self->{menustuff} = "TestOp Called";
# }

1;

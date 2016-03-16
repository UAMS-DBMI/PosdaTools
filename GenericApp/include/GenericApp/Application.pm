#!/usr/bin/perl -w
#
# A simple skeleton application
#
use strict;
package GenericApp::Application;
use Posda::HttpApp::JsController;
use Dispatch::NamedObject;
use Posda::HttpApp::DebugWindow;
use Posda::HttpApp::Authenticator;
use Posda::FileCollectionAnalysis;
use Posda::Nicknames;
use Posda::UUID;
use Dispatch::NamedFileInfoManager;
use Dispatch::LineReader;
use Fcntl qw(:seek);
use File::Path 'remove_tree';
use Digest::MD5;
use JSON;
use Debug;
use Storable;
my $dbg = sub {print STDERR @_ };
use utf8;
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
  <?dyn="Footer"?>
};

my $bad_config = qq{
  <?dyn="BadConfigReport"?>
};

sub new {
  my($class, $sess, $path) = @_;
  my $this = Dispatch::NamedObject->new($sess, $path);
  bless $this, $class;

  if(exists $main::HTTP_APP_CONFIG->{BadJson}){
    $this->{BadConfigFiles} = $main::HTTP_APP_CONFIG->{BadJson};
  }
  $this->{expander} = $expander;
  $this->{Identity} = $main::HTTP_APP_CONFIG->{config}->{Identity};
  $this->{Environment} = $main::HTTP_APP_CONFIG->{config}->{Environment};
  $this->{LoginTempDir} = "$this->{Environment}->{LoginTemp}/$this->{session}";
  unless(mkdir $this->{LoginTempDir}) {
    die "can't mkdir $this->{LoginTempDir}"
  }
  my $width = $this->{Identity}->{width};
  my $height = $this->{Identity}->{height};
  $this->{title} = $this->{Identity}->{Title};
  $this->{height} = $height;
  $this->{width} = $width;
  $this->{menu_width} = 100;
  $this->{content_width} = $this->{width} - $this->{menu_width};
  $this->SetInitialExpertAndDebug("bbennett");
  if($this->CanDebug){
    Posda::HttpApp::DebugWindow->new($sess, "Debug");
  }
  $this->{JavascriptRoot} =
    $main::HTTP_APP_CONFIG->{config}->{Environment}->{JavascriptRoot};
  $this->QueueJsCmd("Update();");
  my $session = $this->get_session;
  $session->{DieOnTimeout} = 1;
  if(
    exists $main::HTTP_APP_SINGLETON->{token} &&
    defined $main::HTTP_APP_SINGLETON->{token}
  ){
    $session->{logged_in} = 1;
    $session->{AuthUser} = $main::HTTP_APP_SINGLETON->{token};
    $session->{real_user} = $main::HTTP_APP_SINGLETON->{token};
    $this->SetUserPrivs($main::HTTP_APP_SINGLETON->{token});
  }
  $this->{ExitOnLogout} = 1;
  $this->{DicomInfoCache} =
    $main::HTTP_APP_CONFIG->{config}->{Environment}->{DicomInfoCache};
  $this->{ExtractionRoot} =
    $main::HTTP_APP_CONFIG->{config}->{Environment}->{ExtractionRoot};
  if($this->can("SpecificInitialize")){
    $this->SpecificInitialize;
  }
  return $this;
}
sub DirLine{
  my($this) = @_;
  my $sub = sub {
    my($line) = @_;
    my($coll, $site, $subj, $dir) = split(/\|/, $line);
    $this->{Collections}->{$coll}->{$site}->{$subj}->{$dir} = 1;
  };
  return $sub;
}
sub DirEnd{
  my($this) = @_;
  my $sub = sub {
    $this->{SelectedCollection} = "none";
    $this->{SelectedSite} = "none";
    $this->{SelectedSubj} = "none";
    $this->{SelectedDir} = "none";
    $this->{Mode} = "Selection";
    $this->AutoRefresh;
  };
  return $sub;
}
sub user{
  my($this, $http, $dyn) = @_;
  $http->queue($this->get_user);
}
my $content = qq{
  <div id="container" style="width:<?dyn="width"?>px">
  <div id="header" style="background-color:#E0E0FF;">
    <table width="100%">
    <tr width="100%">
      <td>
        <?dyn="Logo"?>
      </td>
      <td>
        <h1 style="margin-bottom:0;"><?dyn="title"?></h1>
        User: <?dyn="user"?>
      </td>
      <td valign="top" align="right">
        <div id="login">&lt;login&gt;</div>
      </td>
    </tr>
    </table>
  </div>
  <div id="menu" style="background-color:#F0F0FF;height:<?dyn="height"?>px;width:<?dyn="menu_width"?>px;float:left;">
    &lt;wait&gt;
  </div>
  <div id="content" style="overflow:auto;background-color:#F8F8F8;width:<?dyn="content_width"?>px;float:left;">
    &lt;Content&gt;
  </div>
  <div id="footer" style="background-color:#E8E8FF;clear:both;text-align:center;">
    Posda.com
  </div>
  </div>
};

sub Content{
  my($this, $http, $dyn) = @_;
  if($this->{BadConfigFiles}) {
    return $this->RefreshEngine($http, $dyn, $bad_config);
  }
  $this->RefreshEngine($http, $dyn, $content);
}
sub width{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{width});
}
sub menu_width{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{menu_width});
}
sub content_width{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{content_width});
}
sub height{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{height});
}
sub GetHeight{
  my($this) = @_;
  return $this->{height};
}
sub GetWidth{
  my($this) = @_;
  return $this->{width};
}
sub GetJavascriptRoot{
  my($this) = @_;
  return $this->{JavascriptRoot};
}
sub BadConfigReport{
  my($this, $http, $dyn) = @_;
  for my $i (keys %{$this->{BadConfigFiles}}){
    $http->queue(
      "<tr><td>$i</td><td>$this->{BadConfigFiles}->{$i}</td></tr>");
  }
}
sub Logo{
  my($this, $http, $dyn) = @_;
    my $image = $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoImage};
    my $height = $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoHeight};
    my $width = $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoWidth};
    my $alt = $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoAlt};
    $http->queue("<img src=\"$image\" height=\"$height\" width=\"$width\" " .
      "alt=\"$alt\">");
}
sub JsContent{
  my($this, $http, $dyn) = @_;
  my $js_file = "$this->{JavascriptRoot}/Application.js";
  unless(-f $js_file) { return }
  my $fh;
  open $fh, "<$js_file" or die "can't open $js_file";
  while(my $line = <$fh>) { $http->queue($line) }
}
sub DebugButton{
  my($this, $http, $dyn) = @_;
  if($this->CanDebug){
    $this->RefreshEngine($http, $dyn, qq{
      <span class="btn btn-sm btn-info" 
       onClick="javascript:rt('DebugWindow',
       'Refresh?obj_path=Debug',1600,1200,0);">Debug</span>
    });
  } else {
    print STDERR "Can't debug\n";
  }
}
# above line is generic
#######################################################
# below is app specific

sub SpecificInitialize{
  my($this) = @_;
  $this->{Mode} = "Initialized";
}

sub MenuResponse{
  my($this, $http, $dyn) = @_;
  $this->MakeMenu($http, $dyn,
    [{ 
      type => "host_link",
      condition => 1,
      caption => "Test",
      method => "TestMethod"
    }]
  );
}

sub ContentResponse{
  my($this, $http, $dyn) = @_;
  return $http->queue("content goes here");
}

1;

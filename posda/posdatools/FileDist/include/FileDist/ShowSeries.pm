#!/usr/bin/perl -w
#
use strict;
use Posda::HttpApp::GenericMfWindow;
use Posda::HttpApp::HttpObj;
use Posda::HttpApp::SubController;
use Posda::HttpApp::WindowButtons;
use FileDist::ShowFile;
my $header = <<EOF;
<table style="width:100%" summary="window header">
  <tr>
    <td valign="top" align="left" width="160">
      <?dyn="Logo"?>
    </td>
    <td valign="top">
      <h2>File Distribution Application</h2>
      <h3><?dyn="title"?></h3>
      </td>
    <td valign="top" align="right" width="180" height="120">
<?dyn="iframe" height="0" width="0" style="visibility:hidden;display:none" child_path="Controller"?>
<?dyn="iframe" frameborder="0" height="100%" child_path="WindowButtons"?>
    </td>
  </tr>
</table>
<?dyn="iframe" height="768" child_path="Content"?>
EOF
{
  package FileDist::ShowSeries;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericMfWindow" );
  sub new {
    my($class, $sess, $path, $series, $info, $summary) = @_;
    my $this = Posda::HttpApp::GenericMfWindow->new($sess, $path);
    $this->{title} = "Show $series";
    bless $this, $class;
    $this->{w} = 1024;
    $this->{h} = 700;
    ### Make this a Controller if this is top level app
    Posda::HttpApp::SubController->new($this->{session}, 
      $this->child_path("Controller"));
    ###
    Posda::HttpApp::WindowButtons->new($this->{session},
      $this->child_path("WindowButtons"));
    FileDist::ShowSeries::Content->new($this->{session}, 
      $this->child_path("Content"), $series, $info, $summary);
    ###  If you want Debug capabilities
    Posda::HttpApp::DebugWindow->new($sess, "Debug");
    $this->SetInitialExpertAndDebug;
    ###
    $this->ReOpenFile();
    return $this;
  }
  sub Logo{
    my($this, $http, $dyn) = @_;
    my $image = $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoImage};
    my $height = $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoHeight};
    my $width = $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoWidth};
    my $alt = $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoAlt};
    $http->queue("<img src=\"$image\" height=\"$height\" width=\"$width\" " ,
      "alt=\"$alt\">");
  }
  sub Content {
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn, $header);
  }
  sub DESTROY{
    my($this) = @_;
    $this->delete_descendants();
  }
}
{
  package FileDist::ShowSeries::Content;
  use Posda::HttpApp::GenericIframe;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericIframe" );
  sub new{
    my($class, $sess, $path, $series, $info, $summary) = @_;
    my $this = Posda::HttpApp::GenericIframe->new($sess, $path);
    bless $this, $class;
    $this->{Series} = $series;
    $this->{Info} = $info;
    $this->{Summary} = $summary;
    $this->{ShowFiles} = 0;
    return $this;
  }
  sub Content{
    my($this, $http, $dyn) = @_;
    if($this->{ShowFiles}){
      $this->RefreshEngine($http, $dyn,
        '<?dyn="Button" op="HideFiles" caption="Hide Files"?><br>' .
        'Files:<ul>');
      for my $st (sort keys %{$this->{Summary}}){
        for my $se (sort keys %{$this->{Summary}->{$st}}){
          for my $uid (sort keys %{$this->{Summary}->{$st}->{$se}->{uids}}){
            for my $f (
              sort keys %{$this->{Summary}->{$st}->{$se}->{uids}->{$uid}}
            ){
              if($se eq $this->{Series}){
                $this->RefreshEngine($http, $dyn,
                  '<li>' .
                  '<?dyn="Button" caption="' . $f . '" op="ShowFile" index="' .
                  $f . '"?>' . "$uid $se $st</li>"
                );
              }
            }
          }
        }
      }
      $http->queue("</ul>");
    } else {
      $this->RefreshEngine($http, $dyn, 
        '<?dyn="Button" op="ShowFiles" caption="Show Files"?>');
    }
  }
  sub Series{
    my($this, $http, $dyn) = @_;
    $http->queue("$this->{Series}");
  }
  sub ShowFiles{
    my($this, $http, $dyn) = @_;
    $this->{ShowFiles} = 1;
    $this->AutoRefresh;
  }
  sub HideFiles{
    my($this, $http, $dyn) = @_;
    $this->{ShowFiles} = 0;
    $this->AutoRefresh;
  }
  sub ShowFile{
    my($this, $http, $dyn) = @_;
    my $file = $dyn->{value};
    my $child_name = $this->child_path("Show_$dyn->{value}");
    my $cmp_obj = $this->child($child_name);
    if($cmp_obj) {
      print STDERR "???  already exists ???";
    } else {
      $cmp_obj = FileDist::ShowFile->new($this->{session},
        $child_name, $file);
    }
    $cmp_obj->ReOpenFile;
  }
}
1;

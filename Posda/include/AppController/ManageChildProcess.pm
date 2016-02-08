#!/usr/bin/perl -w
#
use strict;
use POSIX 'strftime';
use Posda::HttpApp::HttpObj;
use Posda::HttpApp::GenericMfWindow;
use Posda::HttpApp::Controller;
use Posda::HttpApp::DebugWindow;
use AppController::Login;
use Debug;
my $dbg = sub {print @_};
{
  package AppController::ManageChildProcess;
  use vars qw( @ISA );
  @ISA = ("Posda::HttpApp::GenericMfWindow");
  my $base_content = <<EOF;
  <table style="width:100%" summary="window header">
    <tr>
      <td valign="top" height="82">
      <?dyn="Logo"?>
      </td>
      <td valign="top" align="left">
      <h2><?dyn="title"?></h2>
      </td>
      <td valign="top" align="right">
  <?dyn="iframe" height="0" width="0" style="visibility:hidden;display:none" child_path="Controller"?>
  <?dyn="iframe" frameborder="0" child_path="WindowButtons"?>
      </td>
      <tr>
  </table>
  <small><?dyn="ControlForm"?></small>
  <?dyn="iframe" height="1024" width="100%" child_path="Content"?>
  <hr>
EOF
#  <?dyn="iframe" height="1024" width="100%" child_path="Content"?>
  sub new{
    my($class, $sess, $path_name, $obj_managed) = @_;
    my $this = Posda::HttpApp::GenericMfWindow->new($sess, $path_name);
    $this->{title} = "Sub-Process Report";
    bless $this, $class;
    $this->{h} = 950;
    $this->{w} = 1024;
    $this->{ManagedObj} = $obj_managed;
    Posda::HttpApp::Controller->new($sess, $this->child_path("Controller"));
    Posda::HttpApp::WindowButtons->new($sess,
      $this->child_path("WindowButtons"), "Close", 0);
    AppController::ManageChildProcess::Content->new(
      $this->{session},$this->child_path("Content"));
    $this->{DisplaySource} = "STDERR";
    $this->{DisplayPosition} = "ToEnd";
    $this->{NumLines} = 50;
    return $this;
  }
  sub Content{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn, $base_content);
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
  sub ControlForm{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn, 
      'Show <?dyn="NoLines"?> Lines <?dyn="DisplayPosition"?> of' .
      ' <?dyn="DisplaySource"?>'
    );
  }
  sub NoLines{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn,
      '<?dyn="InputChangeNoReload" ' .
      ' size="5" ' .
      ' maxlen="5" ' .
      ' field="NumLines"?>');
  }
  sub DisplaySource{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn,
      '<?dyn="SelectNsByValue" op="SetSource"?><?dyn="SourceList"?>' .
      '</select>');
  }
  sub SourceList{
    my($this, $http, $dyn) = @_;
    for my $i ("STDERR", "STDOUT"){
      $http->queue("<option value=\"$i\"");
      if($i eq $this->{DisplaySource}){ $http->queue(" selected") }
      $http->queue(">$i</option>\n");
    }
  }
  sub DisplayPosition{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn,
      '<?dyn="SelectNsByValue" op="SetPosition"?>' .
      '<?dyn="PosList"?></select>');
  }
  sub PosList{
    my($this, $http, $dyn) = @_;
    my %pos = (
      ToEnd => "To End",
      FromBegining => "From Begining",
    );
    for my $i (keys %pos){
      $http->queue("<option value=\"$i\"");
      if($i eq $this->{DisplayPosition}){ $http->queue(" selected") }
      $http->queue(">$pos{$i}</option>\n");
    }
  }
  sub SetPosition{
    my($this, $http, $dyn) = @_;
    $this->{DisplayPosition} = $dyn->{value};
    $this->UpdateContent;
  }
  sub SetSource{
    my($this, $http, $dyn) = @_;
    $this->{DisplaySource} = $dyn->{value};
    $this->UpdateContent;
  }
  sub SetInputReload{
    my($this, $http, $dyn) = @_;
    $this->{$dyn->{field}} = $dyn->{value};
    $this->UpdateContent;
  }
  sub UpdateContent{
    my($this) = @_;
    my $child = $this->child("Content");
    if($child && $child->can("AutoRefresh")){ $child->AutoRefresh }
  }
  sub DESTROY{
    my($this) = @_;
    $this->delete_children();
  }
}
{
  package AppController::ManageChildProcess::Content;
  use vars qw( @ISA );
  @ISA = ("Posda::HttpApp::GenericIframe");
  sub new{
    my($class, $sess, $path) = @_;
    my $this = Posda::HttpApp::GenericIframe::new($class, $sess, $path);
    $this->{ManagedObj} = $this->parent->{ManagedObj};
    $this->{ManagedObj}->{BeingManagedBy} = $this;
    return bless $this, $class;
  }
  sub Content{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn, 
    '<small>pid: <?dyn="pid"?>&nbsp;&nbsp;' .
    'port: <?dyn="port"?>&nbsp;&nbsp;' .
    '<?dyn="user"?>&nbsp;&nbsp;<?dyn="status"?><br />' .
    'cmd: <?dyn="command"?><br /></small><hr>'. 
    '<?dyn="Lines"?><hr>'
    );
  }
  sub pid{
    my($this, $http, $dyn) = @_;
    $http->queue($this->{ManagedObj}->{child_pid});
  }
  sub port{
    my($this, $http, $dyn) = @_;
    $http->queue($this->{ManagedObj}->{TryingSocket});
  }
  sub user {
    my($this, $http, $dyn) = @_;
    $http->queue($this->{ManagedObj}->{AuthUser});
  }
  sub status {
    my($this, $http, $dyn) = @_;
    $http->queue($this->{ManagedObj}->{Status});
  }
  sub command{
    my($this, $http, $dyn) = @_;
    $http->queue($this->{ManagedObj}->{Command});
  }
  sub Lines{
    my($this, $http, $dyn) = @_;
    my $parent = $this->parent;
    my $source = $parent->{DisplaySource};
    my $position = $parent->{DisplayPosition};
    my $lines = $parent->{NumLines};
    my $line_list = $this->{ManagedObj}->{$source};
    my $line_count = $#{$line_list};
    if($line_count < $lines) { $lines = $line_count };
    if($position eq "ToEnd"){
      $http->queue("<small><pre>");
      for my $i (($line_count - $lines) .. $line_count){
        my $line = $line_list->[$i];
        $line =~ s/</&lt;/g;
        $line =~ s/>/&gt;/g;
        $http->queue("$line\n");
      }
      $http->queue("</pre></small>");
    } elsif ($position eq "FromBegining"){
      $http->queue("<small><pre>");
      for my $i (0 .. $line_count){
        my $line = $line_list->[$i];
        $line =~ s/</&lt;/g;
        $line =~ s/>/&gt;/g;
        $http->queue("$line\n");
      }
      $http->queue("</pre></small>");
    }
  };
  sub CleanUp{
    my($this) = @_;
    delete $this->{ManagedObj}->{BeingManagedBy};
    delete $this->{ManagedObj};
  }
  sub DESTROY{
    my($this) = @_;
    print STDERR "Destroying displayer\n";
  }
}
1;

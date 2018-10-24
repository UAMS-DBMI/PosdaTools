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
  package AppController::CheckBOM;
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
  <?dyn="iframe" height="1024" width="100%" child_path="Content"?>
  <hr>
EOF
#  <?dyn="iframe" height="1024" width="100%" child_path="Content"?>
  sub new{
    my($class, $sess, $path_name) = @_;
    my $this = Posda::HttpApp::GenericMfWindow->new($sess, $path_name);
    $this->{title} = "Bill of Materials Report";
    bless $this, $class;
    $this->{h} = 1215;
    $this->{w} = 1024;
    Posda::HttpApp::Controller->new($sess, $this->child_path("Controller"));
    Posda::HttpApp::WindowButtons->new($sess,
      $this->child_path("WindowButtons"), "Close", 0);
    AppController::CheckBOM::Content->new(
      $this->{session},$this->child_path("Content"));
    return $this;
  }
  sub Content{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn, $base_content);
  }
  sub DESTROY{
    my($this) = @_;
    $this->delete_children();
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
}
{
  package AppController::CheckBOM::Content;
  use vars qw( @ISA );
  @ISA = ("Posda::HttpApp::GenericIframe");
  sub new{
    my($class, $sess, $path) = @_;
    my $this = Posda::HttpApp::GenericIframe::new($class, $sess, $path);
    $this->{dir_list} = 
      $main::HTTP_APP_CONFIG->{config}->{Applications}->{BomDirs};
    $this->{num_jobs} = 0;
    $this->RefreshBomCheck;
    return bless $this, $class;
  }
  sub Content{
    my($this, $http, $dyn) = @_;
    if($this->{num_jobs} <= 0){
      $this->RefreshEngine($http, $dyn, '<?dyn="Button" ' .
        'op="RefreshBomCheck" caption="Refresh"?><br>');
    } else {
      $http->queue("<em>In Preparation</em>");
    }
    for my $name (sort keys %{$this->{dir_list}}){
      $http->queue("<hr>$name<br><pre>");
      for my $line(@{$this->{BOM}->{$name}}){
        $http->queue("$line\n");
      }
      $http->queue("</pre>");
    }
  }
  sub RefreshBomCheck{
    my($this, $http, $dyn) = @_;
    unless($this->{num_jobs} <= 0) {
      print STDERR "Lost race in RefreshBomCheck\n";
      return;
    }
    for my $name (keys %{$this->{dir_list}}){
      my $cmd = "CheckBOM.pl \"$this->{dir_list}->{$name}\"";
      open my $fh, "$cmd|" or die "Can't open $cmd";
      Dispatch::Select::Socket->new(
        $this->SocketReader($name),
        $fh)->Add("reader");
    }
    $this->AutoRefresh;
  }
  sub SocketReader{
    my($this, $name) = @_;
    $this->{num_jobs} += 1;
    $this->{BOM}->{$name} = [];
    my $text = "";
    my $foo = sub {
      my($disp, $sock) = @_;
      my $count = sysread($sock, $text, 1024, length($text));
      while($text =~ /^([^\n]*)\n(.*)/s){
        my $line = $1;
        $text = $2;
        push(@{$this->{BOM}->{$name}}, $line);
        $this->AutoRefresh;
      }
      if($count <= 0){
        $disp->Remove;
        $sock->close;
        $this->{num_jobs} -= 1;
      }
    };
    return $foo;
  }
  sub DESTROY{
    my($this) = @_;
    print STDERR "Destroying displayer\n";
  }
}
1;

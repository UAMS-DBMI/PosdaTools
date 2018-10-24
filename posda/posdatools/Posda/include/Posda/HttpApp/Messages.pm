#!/usr/bin/perl -w
#
use strict;
{
  package Posda::HttpApp::Messages;
  use Posda::HttpApp::GenericIframe;
  # always name this object "Messages" so it can be found...
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericIframe" );
  sub new {
    my($class, $sess, $path, $show) = @_;
    my $this = Posda::HttpApp::GenericIframe->new($sess, $path);
    unless (defined $show)
      { $this->{hidden} = 1; } 
    bless $this, $class;
    return $this;
  }
  sub Message{
    my($this, $message) = @_;
    # print "$this->{path}:message: $message.\n";
    push(@{$this->{messages}}, $message);
    $this->AutoRefresh;
  }
  sub Warning{
    my($this, $warning) = @_;
    print STDERR "$this->{path}:warning: $warning.\n";
    push(@{$this->{messages}}, 
      "<font color=\"red\">" . $warning . "</font>");
    $this->AutoRefresh;
  }
  sub ClearMessages{
    my($this) = @_;
    delete $this->{messages};
    $this->AutoRefresh;
  }
  sub Show{
    my($this, $http, $dyn) = @_;
    delete $this->{hidden};
    $this->AutoRefresh;
  }
  sub Hide{
    my($this, $http, $dyn) = @_;
    $this->{hidden} = 1;
    $this->AutoRefresh;
  }
my $before = <<EOF;
<table style="width:100%" summary="Messages">
<tr><td>
EOF
my $after = <<EOF;
</td></tr>
</table>
EOF
my $show = <<EOF;
<?dyn="Button" caption="Show" op="Show"?> messages.<br />
EOF
my $hide = <<EOF;
<?dyn="Button" caption="Hide" op="Hide"?> messages.
&nbsp; 
<?dyn="Button" caption="Clear" op="ClearMessages"?> messages.
<br />
EOF
  sub Content{
    my($this, $http, $dyn) = @_;
    unless (exists $this->{messages}) { return; }
    if (exists $this->{hidden}) {
      $this->RefreshEngine($http, $dyn, $show);
      return
    }
    $http->queue($before);
    $this->RefreshEngine($http, $dyn, $hide);
    for my $i (0 .. $#{$this->{messages}}){
      $http->queue($this->{messages}->[$i] . "<br />");
    }
    $http->queue($after);
  }
}
1;

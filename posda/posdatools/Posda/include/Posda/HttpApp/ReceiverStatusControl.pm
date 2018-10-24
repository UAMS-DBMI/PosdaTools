#!/usr/bin/perl -w
#
use strict;
use Posda::HttpApp::GenericMfWindow;
use Posda::HttpApp::HttpObj;
use Posda::HttpApp::SubController;
use Posda::HttpApp::WindowButtons;
my $header = <<EOF;
<table style="width:100%" summary="window header">
  <tr>
    <td valign="top" align="left" width="160">
      <?dyn="Logo"?>
    </td>
    <td valign="top">
      <h2><?dyn="MainTitle"?></h2>
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
  package Posda::HttpApp::ReceiverStatusControl;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericMfWindow" );
  sub new {
    my($class, $sess, $path) = @_;
    my $this = Posda::HttpApp::GenericMfWindow->new($sess, $path);
    $this->{title} = "Dicom Receiver Status";
    bless $this, $class;
    $this->{w} = 1024;
    $this->{h} = 700;
    Posda::HttpApp::SubController->new($this->{session}, 
      $this->child_path("Controller"));
    Posda::HttpApp::WindowButtons->new($this->{session},
      $this->child_path("WindowButtons"));
    Posda::HttpApp::ReceiverStatusControl::Content->new(
        $this->{session}, $this->child_path("Content"));
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
  sub MainTitle{
    my($this, $http, $dyn) = @_;
    my $main_title = "Posda Dicom Tools";
    if(defined $main::HTTP_APP_CONFIG->{config}->{Identity}->{Title}){
      $main_title = $main::HTTP_APP_CONFIG->{config}->{Identity}->{Title};
    }
    $http->queue($main_title);
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
  package Posda::HttpApp::ReceiverStatusControl::Content;
  use Posda::HttpApp::GenericIframe;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericIframe" );
  sub new{
    my($class, $sess, $path) = @_;
    my $this = Posda::HttpApp::GenericIframe::new($class,$sess, $path);
    $this->{ReceiverConfig} = $main::HTTP_APP_CONFIG->{config}->{DicomReceiver};
    $this->{Receiver} = $main::HTTP_STATIC_OBJS{DicomReceiver};
    if(
      $this->{Receiver} &&
      $this->{Receiver}->can("NotificationRegistration")
    ){ $this->{Receiver}->NotificationRegistration($this->CreateNotifier) }
    return $this;
  }
  sub Content{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn,
      '<small>Status: <?dyn="Status"?><hr><?dyn="AeTitles"?><hr>'.
      '<?dyn="ActiveConnections"?>' .
      "Messages:<pre>\n" .
      '<?dyn="Messages"?></pre></small>'
    );
  }
  sub ActiveConnections{
    my($this, $http, $dyn) = @_;
    my @conns = sort keys %{$this->{Receiver}->{objs}};
    my $count = @conns;
    unless($count) { return }
    $this->RefreshAfter(3);
    $dyn->{conns} = \@conns;
    $this->RefreshEngine($http, $dyn,
      'Active Connections:' .
      '<table border=1><tr><th>Index</th>' .
      '<th>Calling AE</th>' .
      '<th>Called AE</th>' .
      '<th>Connection From</th>' .
      "<th># Proposed PC's</th>" .
      "<th># Accepted PC's</th>" .
      "<th># Files</th>" .
      '</tr>' .
      '<?dyn="ActiveConnectionRows"?>' .
      '</table><hr>'
    );
  }
  sub ActiveConnectionRows{
    my($this, $http, $dyn) = @_;
    for my $con (@{$dyn->{conns}}){
      $dyn->{con} = $con;
      $this->ActiveConnectionRow($http, $dyn);
    }
  }
  sub ActiveConnectionRow{
    my($this, $http, $dyn) = @_;
    my $obj = $this->{Receiver}->{objs}->{$dyn->{con}};
    $http->queue("<tr>");
    $http->queue("<td>$dyn->{con}</td>");
    $http->queue("<td>$obj->{assoc_ac}->{calling}</td>");
    $http->queue("<td>$obj->{assoc_ac}->{called}</td>");
    $http->queue("<td>$obj->{peer_network_addr}</td>");
    my $num_proposed = 
      scalar keys %{$obj->{assoc_rq}->{presentation_contexts}};
    $http->queue("<td>$num_proposed</td>");
    my $num_accepted = 0;
    for my $i (keys %{$obj->{assoc_ac}->{presentation_contexts}}){
      if($obj->{pres_cntx}->{$i}->{accepted}){
        $num_accepted += 1;
      }
    }
    $http->queue("<td>$num_accepted</td>");
    my $num_files = 0;
    if(exists $this->{Receiver}->{ActiveConnections}->{$dyn->{con}}->{files}){
      my $files = 
        $this->{Receiver}->{ActiveConnections}->{$dyn->{con}}->{files};
      for my $i (keys %$files){
        for my $j (keys %{$files->{$i}}){ $num_files += 1 }
      }
    }
    $http->queue("<td>$num_files</td>");
    $http->queue("</tr>");
  }
  sub AeTitles{
    my($this, $http, $dyn) = @_;
    $http->queue('AeTitles:<ul>');
    for my $i (keys %{$this->{ReceiverConfig}->{dicom_aes}}){
      $dyn->{AeTitle} = $i;
      $this->AeTitle($http, $dyn);
    }
    $http->queue('</ul>');
  }
  sub AeTitle{
    my($this, $http, $dyn) = @_;
    my $ae_title = $dyn->{AeTitle};
    $ae_title =~ s/</&lt;/g;
    $ae_title =~ s/>/&gt;/g;
    $http->queue("<li>$ae_title: Accepts from ");
    my $info = $this->{ReceiverConfig}->{dicom_aes}->{$dyn->{AeTitle}};
    my @calling = keys %{$info->{allowed_calling_ae_titles}};
    for my $i (0 .. $#calling){
      $calling[$i] =~ s/</&lt;/g;
      $calling[$i] =~ s/>/&gt;/g;
      $http->queue($calling[$i]);
      unless($i == $#calling) { $http->queue(",&nbsp;") }
    }
    $http->queue("</li>");
  }
  sub Status{
    my($this, $http, $dyn) = @_;
    unless($this->{Receiver}) { $http->queue("No receiver"); return }
    my $port = $this->{Receiver}->{dcm_port};
    my $count = $this->{Receiver}->{connection_count};
    my $active = 0;
    if(exists $this->{Receiver}->{ActiveConnections}){
      $active = scalar keys %{$this->{Receiver}->{ActiveConnections}};
    }
    $http->queue("Active on port $port, $count total connections, " .
      "$active active");
  }
  sub Messages{
    my($this, $http, $dyn) = @_;
    if($this->{messages} && ref($this->{messages}) eq "ARRAY"){
      for my $mess(@{$this->{messages}}){
        $mess =~ s/</&lt;/g;
        $mess =~ s/>/&gt;/g;
        $http->queue("$mess\n");
      }
    }
  }
  sub CreateNotifier{
    my($this) = @_;
    my $sub = sub {
      my($message) = @_;
      #print STDERR "Notify in $this->{path} ($this)\n";
      if($this->{CleaningUp}) { return 0 }
      unless($message eq "Keep Alive"){
        push(@{$this->{messages}}, $message);
        $this->AutoRefresh;
      }
      return 1;
    };
    return $sub;
  }
  sub CleanUp{
    my($this) = @_;
    #print STDERR "Cleaning Up $this->{path} ($this)\n";
    $this->{CleaningUp} = 1;
    delete($this->{Receiver});
    delete($this->{ReceiverConfig});
  }
  sub DESTROY{
    my($this) = @_;
    #print STDERR "Destroying $this->{path} ($this)\n";
  }
}
1;

#!/usr/bin/perl -w
#
use strict;
use Posda::HttpApp::GenericMfWindow;
use Posda::HttpApp::HttpObj;
use Posda::HttpApp::SubController;
use Posda::HttpApp::WindowButtons;
use Posda::DicomHighlighter;
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
  package FileDist::SessionInfo;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericMfWindow" );
  sub new {
    my($class, $sess, $path, $file) = @_;
    my $this = Posda::HttpApp::GenericMfWindow->new($sess, $path);
    $this->{title} = "Show Session: $file";
    bless $this, $class;
    $this->{w} = 1024;
    $this->{h} = 1000;
    ### Make this a Controller if this is top level app
    Posda::HttpApp::SubController->new($this->{session}, 
      $this->child_path("Controller"));
    ###
    Posda::HttpApp::WindowButtons->new($this->{session},
      $this->child_path("WindowButtons"));
    FileDist::SessionInfo::Content->new($this->{session}, 
      $this->child_path("Content"), $file);
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
  package FileDist::SessionInfo::Content;
  use Posda::HttpApp::GenericIframe;
  use Dispatch::LineReader;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericIframe" );
  sub new{
    my($class, $sess, $path, $file) = @_;
    my $this = Posda::HttpApp::GenericIframe->new($sess, $path);
    bless $this, $class;
    $this->{File} = $file;
    $this->{State} = "Parsing";
    Dispatch::LineReader->new_file($file, $this->HandleLine,
      $this->ReaderFinished);
    return $this;
  }
  sub Content{
    my($this, $http, $dyn) = @_;
    if($this->{State} eq "Parsing"){
      $this->RefreshEngine($http, $dyn, 'here');
      return;
    }
    $this->RefreshEngine($http, $dyn, '<small>' .
      '<table border=1><th>id</th><th>Accept</th><th>Abstract Syntax</th>' .
      '<th>Proposed Xfr Syntaxes</th><th>Accepted Xfr Syntax</th></tr>');
      for my $i (sort {$a <=> $b} keys %{$this->{pres_ctx}}){
        $dyn->{index} = $i;
        $this->PresCtxRow($http, $dyn);
      }
      $http->queue('</table>');
  }
  sub PresCtxRow{
    my($this, $http, $dyn) = @_;
    my $i = $dyn->{index};
    my $dd = $Posda::Dataset::DD;
    my $item = $this->{pres_ctx}->{$i};
    my $accepted;
    if($item->{a_xstx}) { $accepted = "Yes" }
    else {
      if($item->{reject} == 1){
        $accepted = "user-rejection";
      } elsif ($item->{reject} == 2){
        $accepted = "no-reason (provider rejection)";
      } elsif ($item->{reject} == 3){
        $accepted = "abstract-syntax-not-supported (provider rejection)";
      } elsif ($item->{reject} == 4){
        $accepted = "transfer-syntaxes-not-supported (provider rejection)";
      }
    }
    my $abs_stx = $dd->GetSopClName($item->{abs_stx});
    my $xfr_stx = "";
    if(exists $item->{a_xstx}){
      $xfr_stx = $dd->GetXferStxName($item->{a_xstx});
    }
    $http->queue("<tr><td>$i</td><td>$accepted</td>" .
      "<td>$abs_stx</td><td>");
    for my $p (0 .. $#{$item->{p_xstx}}){
      my $xfr_stx = $dd->GetXferStxName($item->{p_xstx}->[$p]);
      $http->queue($xfr_stx);
      unless($p == $#{$item->{p_xstx}}) {
        $http->queue("<br/>");
      }
    }
    $http->queue("</td><td>$xfr_stx</td><tr>");
  }
  sub HandleLine{
    my($this) = @_;
    my $sub = sub {
      my($line) = @_;
      my @fields = split(/\|/, $line);
      if($fields[0] eq "proposed_pc"){
        $this->{pres_ctx}->{$fields[1]}->{abs_stx} = $fields[2];
        $this->{pres_ctx}->{$fields[1]}->{p_xstx} = [];
        for my $i (3 .. $#fields) {
          push(@{$this->{pres_ctx}->{$fields[1]}->{p_xstx}}, $fields[$i]);
        }
      }elsif($fields[0] eq "accepted_pc"){
        $this->{pres_ctx}->{$fields[1]}->{a_xstx} = $fields[2];
      }elsif($fields[0] eq "rejected_pc"){
        $this->{pres_ctx}->{$fields[1]}->{reject} = $fields[2];
      }
    };
    return $sub;
  }
  sub ReaderFinished{
    my($this) = @_;
    my $sub = sub {
      $this->{State} = "Done";
      $this->AutoRefresh;
    };
    return $sub;
  }
}
1;

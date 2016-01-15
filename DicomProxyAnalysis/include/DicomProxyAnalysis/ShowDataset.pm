#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/DicomProxyAnalysis/include/DicomProxyAnalysis/ShowDataset.pm,v $
#$Date: 2014/02/19 15:22:58 $
#$Revision: 1.2 $
#
use strict;
use Posda::HttpApp::GenericMfWindow;
use Posda::HttpApp::HttpObj;
use Posda::HttpApp::SubController;
use Posda::HttpApp::WindowButtons;
use Dispatch::LineReader;
#use Dispatch::Acceptor;
my $header = <<EOF;
<table style="width:100%" summary="window header">
  <tr>
    <td valign="top" align="left" width="160">
      <?dyn="Logo"?>
    </td>
    <td valign="top">
      <h2><?dyn="title"?></h2>
      </td>
    <td valign="top" align="right" width="180" height="120">
<?dyn="iframe" height="0" width="0" style="visibility:hidden;display:none" child_path="Controller"?>
<?dyn="iframe" frameborder="0" height="100%" child_path="WindowButtons"?>
    </td>
  </tr>
</table><hr>
<?dyn="iframe" height="350" child_path="Content"?>
<hr>
EOF
{
  package DicomProxyAnalysis::ShowDataset;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericMfWindow" );
  sub new {
    my($class, $sess, $path, $file) = @_;
    my $this = Posda::HttpApp::GenericMfWindow->new($sess, $path);
    $this->{title} = "View Dataset: $file";
    bless $this, $class;
    $this->{w} = 1024;
    $this->{h} = 700;
    Posda::HttpApp::SubController->new($this->{session}, 
      $this->child_path("Controller"));
    Posda::HttpApp::WindowButtons->new($this->{session},
      $this->child_path("WindowButtons"));
    DicomProxyAnalysis::ShowDataset::Content->new(
        $this->{session}, $this->child_path("Content"), $file);
    Posda::HttpApp::DebugWindow->new($sess, "Debug");
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
  sub CleanUp{
    my($this) = @_;
    $this->delete_descendants;
  }
  sub DESTROY{
    my($this) = @_;
  }
}
{
  package DicomProxyAnalysis::ShowDataset::Content;
  use Time::HiRes qw( gettimeofday tv_interval );
  use File::Path qw (remove_tree);
  use Posda::HttpApp::GenericIframe;
  use Storable qw( fd_retrieve );
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericIframe" );
  sub new{
    my($class, $sess, $path, $file) = @_;
    my $this = Posda::HttpApp::GenericIframe->new($sess, $path);
    $this->{dicom_file} = $file;
    $this->{results_file} = "$file.dicom_dump";
    bless $this, $class;
    $this->StartDump;
    return $this;
  }
  sub StartDump{
    my($this) = @_;
    $this->{State} = "dumping";
    my $command = "IheDumpFile.pl \"$this->{dicom_file}\" " .
      "\"$this->{results_file}\"";
    my $pid = open my $fh, "$command|";
    $this->{dump_reader} = Dispatch::LineReader->new_fh($fh,
      $this->CreateNotifierClosure("NoOp"),
      $this->CreateNotifierClosure("DumpComplete", $pid));
  }
  sub DumpComplete{
    my($this, $pid) = @_;
    $this->{State} = "dumped";
    delete $this->{dump_reader};
    $this->AutoRefresh;
  }
  sub Content{
    my($this, $http, $dyn) = @_;
    if($this->{State} eq "dumping"){
      $http->queue("preparing dump");
    } elsif($this->{State} eq "dumped") {
      open my $fh, "<$this->{results_file}" or
        die "can't open $this->{results_file} ($!)";
      while(my $line = <$fh>){
        $http->queue($line);
      }
    } else {
      $http->queue("no state");

    }
  }
}
1;

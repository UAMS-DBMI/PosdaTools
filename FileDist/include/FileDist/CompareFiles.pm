#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/FileDist/include/FileDist/CompareFiles.pm,v $
#$Date: 2013/12/03 14:37:57 $
#$Revision: 1.6 $
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
  package FileDist::CompareFiles;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericMfWindow" );
  sub new {
    my($class, $sess, $path, $from, $to) = @_;
    my $this = Posda::HttpApp::GenericMfWindow->new($sess, $path);
    $this->{title} = "Compare Files";
    bless $this, $class;
    $this->{from} = $from;
    $this->{to} = $to;
    $this->{w} = 1024;
    $this->{h} = 1000;
    ### Make this a Controller if this is top level app
    Posda::HttpApp::SubController->new($this->{session}, 
      $this->child_path("Controller"));
    ###
    Posda::HttpApp::WindowButtons->new($this->{session},
      $this->child_path("WindowButtons"));
    FileDist::CompareFiles::Content->new(
        $this->{session}, $this->child_path("Content"), $from, $to);
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
  package FileDist::CompareFiles::Content;
  use Posda::HttpApp::GenericIframe;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericIframe" );
  sub new{
    my($class, $sess, $path, $from, $to) = @_;
    my $this = Posda::HttpApp::GenericIframe->new($sess, $path);
    bless $this, $class;
    $this->{RoutesAbove}->{TempDir} = 1;
    $this->{from} = $from;
    $this->{to} = $to;
    my $fm = $this->get_obj("FileManager");
    $this->{from_digest} = $fm->FileDigest($from->{file});
    $this->{to_digest} = $fm->FileDigest($to->{file});
    my $temp_dir = $this->FetchFromAbove("TempDir");
    $this->{from_dump_file} = "$temp_dir/$this->{from_digest}.ddump";
    $this->{to_dump_file} = "$temp_dir/$this->{to_digest}.ddump";
    my $dump_cmd_from = "IheDumpFile.pl \"$from->{file}\" " .
      "\"$this->{from_dump_file}\"";
    $this->{dump_cmd_from} = $dump_cmd_from;
    open my $fh1, "$dump_cmd_from|";
    $this->{from_in_progress} = 1;
    Dispatch::Select::Socket->new($this->ADumpComplete("from_in_progress"),
      $fh1)->Add("reader");
    my $dump_cmd_to = "IheDumpFile.pl \"$to->{file}\" " .
      "\"$this->{to_dump_file}\"";
    $this->{dump_cmd_to} = $dump_cmd_to;
    open my $fh2, "$dump_cmd_to|";
    $this->{to_in_progress} = 1;
    Dispatch::Select::Socket->new($this->ADumpComplete("to_in_progress"),
      $fh2)->Add("reader");
  }
  sub ADumpComplete{
    my($this, $prog) = @_;
    my $buff = "";
    my $sub = sub {
      my($disp, $sock) = @_;
      my $len = read($sock, $buff, length($buff));
      if($len <= 0){
        if(length($buff) > 0){
          print STDERR "Errors dumping $this->{from}->{file}: $buff\n";
        }
        $disp->Remove;
        delete $this->{$prog};
        unless(
          exists($this->{from_in_progress}) || exists($this->{to_in_progress})
        ){
          $this->DumpsComplete;
        }
      }
      $this->AutoRefresh;
    };
    return $sub;
  }
  sub DumpsComplete{
    my($this) = @_;
    my $compare_command = 
      "IheCompareFiles.pl " .
      "\"$this->{from_dump_file}\" " .
      "\"$this->{to_dump_file}\"";
    my $pid = open my $fh, "$compare_command|";
    $this->{compare_reader} = Dispatch::LineReader->new_fh($fh,
      $this->CompareLineHandler,
      $this->CreateNotifierClosure("CompareFinished"), $pid);
    return $this;
  }
  sub Content{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn, 
      '<small>From: <?dyn="FromFile"?><br />' .
      'To: <?dyn="ToFile"?></small><hr>' .
      '<pre><small><?dyn="Comparison"?></small></pre>');
  }
  sub FromFile{
    my($this, $http, $dyn) = @_;
    $http->queue("$this->{from}->{file}");
  }
  sub ToFile{
    my($this, $http, $dyn) = @_;
    $http->queue("$this->{to}->{file}");
  }
  sub CompareLineHandler{
    my($this) = @_;
    my $sub = sub {
      my($l) = @_;
      push(@{$this->{compare_lines}}, $l);
    };
    return $sub;
  }
  sub CompareFinished{
    my($this) = @_;
    delete $this->{compare_reader};
    $this->AutoRefresh;
  }
  sub Comparison{
    my($this, $http, $dyn) = @_;
    if(exists $this->{from_in_progress} || exists $this->{to_dump_file}){
      if(exists $this->{from_in_progress}){
        $http->queue("Dumping from file<br/>")
      }
      if(exists $this->{to_in_progress}){
        $http->queue("Dumping to file<br/>")
      }
    }
    if(exists $this->{compare_reader}){
      return $http->queue("Comparison in Progress");
    }
    for my $l (@{$this->{compare_lines}}){ $http->queue("$l\n") }
  }
}
1;

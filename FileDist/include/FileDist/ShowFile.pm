#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/FileDist/include/FileDist/ShowFile.pm,v $
#$Date: 2013/10/10 20:59:58 $
#$Revision: 1.2 $
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
  package FileDist::ShowFile;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericMfWindow" );
  sub new {
    my($class, $sess, $path, $file, $info, $summary) = @_;
    my $this = Posda::HttpApp::GenericMfWindow->new($sess, $path);
    $this->{title} = "Show File: $file";
    bless $this, $class;
    $this->{w} = 1024;
    $this->{h} = 1000;
    ### Make this a Controller if this is top level app
    Posda::HttpApp::SubController->new($this->{session}, 
      $this->child_path("Controller"));
    ###
    Posda::HttpApp::WindowButtons->new($this->{session},
      $this->child_path("WindowButtons"));
    FileDist::ShowFile::Content->new($this->{session}, 
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
  package FileDist::ShowFile::Content;
  use Posda::HttpApp::GenericIframe;
  use Dispatch::LineReader;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericIframe", "Posda::DicomHighlighter" );
  sub new{
    my($class, $sess, $path, $file) = @_;
    my $this = Posda::HttpApp::GenericIframe->new($sess, $path);
    bless $this, $class;
    $this->{ImportsFromAbove}->{GetFilesByFileNickname} = 1;
    $this->{File} = $file;
    $this->{file_paths} = $this->RouteAbove("GetFilesByFileNickname", $file);
    $this->{file_path} = $this->{file_paths}->[0];
    $this->{lines} = [];
    my $dump_command = "IheDumpFile.pl \"$this->{file_path}\"";
    my $pid = open my $fh, "$dump_command|";
    $this->{dump_reader} = Dispatch::LineReader->new_fh($fh, 
      $this->DumpLineHandler, 
      $this->CreateNotifierClosure("DumpFinished"), $pid);
    $this->{ShowDump} = 0;
    my $dciodvfy_command = "dciodvfy \"$this->{file_path}\" 2>&1";
    my $pid1 = open my $fh1, "$dciodvfy_command|";
    $this->{dciodvfy_reader} = Dispatch::LineReader->new_fh($fh1, 
      $this->DciodvfyLineHandler, 
      $this->CreateNotifierClosure("DciodvfyFinished"), $pid1);
    $this->{ShowDciodvfy} = 0;
    my $posda_rt_verify_command = "RuleValidation.pl " .
      "\"$this->{file_path}\" 2>&1";
    my $pid2 = open my $fh2, "$posda_rt_verify_command|";
    $this->{posda_rt_verify_reader} = Dispatch::LineReader->new_fh($fh2, 
      $this->PosdaRtVerifyLineHandler, 
      $this->CreateNotifierClosure("PosdaRtVerifyFinished"), $pid2);
    $this->{ShowPosdaRtVerify} = 0;
    return $this;
  }
  sub Content{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn, 
      '<small>File: <?dyn="File"?><br/>' .
      'Path: <?dyn="FilePath"?><hr>' .
      '<pre><?dyn="Dump"?></pre><hr>'.
      '<pre><?dyn="Dciodvfy"?></pre><hr>' .
      '<pre><?dyn="PosdaRtVerify"?></pre>' .
      '</small>');
  }
  sub Dump{
    my($this, $http, $dyn) = @_;
    if($this->{dump_reader}){
      $http->queue("Dump in progress");
      return;
    }
    if($this->{ShowDump}){
      $this->RefreshEngine($http, $dyn,
      '<?dyn="Button" caption="Hide Dump" op="HideDump"?><br>' .
      '<?dyn="DumpLines"?>')
    } else {
      $this->RefreshEngine($http, $dyn,
      '<?dyn="Button" caption="Show Dump" op="ShowDump"?><br>');
    }
  }
  sub ShowDump{
    my($this, $http, $dyn) = @_;
    $this->{ShowDump} = 1;
    $this->AutoRefresh;
  }
  sub HideDump{
    my($this, $http, $dyn) = @_;
    $this->{ShowDump} = 0;
    $this->AutoRefresh;
  }
  sub Dciodvfy{
    my($this, $http, $dyn) = @_;
    if($this->{dciodvfy_reader}){
      $http->queue("dciodvfy in progress");
      return;
    }
    if($this->{ShowDciodvfy}){
      $this->RefreshEngine($http, $dyn,
      '<?dyn="Button" caption="Hide dciodvfy" op="HideDciodvfy"?><br>' .
      '<?dyn="DciodvfyLines"?>')
    } else {
      $this->RefreshEngine($http, $dyn,
      '<?dyn="Button" caption="Show dciodvfy" op="ShowDciodvfy"?><br>');
    }
  }
  sub ShowDciodvfy{
    my($this, $http, $dyn) = @_;
    $this->{ShowDciodvfy} = 1;
    $this->AutoRefresh;
  }
  sub HideDciodvfy{
    my($this, $http, $dyn) = @_;
    $this->{ShowDciodvfy} = 0;
    $this->AutoRefresh;
  }
  sub PosdaRtVerify{
    my($this, $http, $dyn) = @_;
    if($this->{posda_rt_verify_reader}){
      $http->queue("PosdaRtVerify in progress");
      return;
    }
    if($this->{ShowPosdaRtVerify}){
      $this->RefreshEngine($http, $dyn,
      '<?dyn="Button" caption="Hide PosdaRtVerify" op="HidePosdaRtVerify"?>' .
      '<br><?dyn="PosdaRtVerifyLines"?>')
    } else {
      $this->RefreshEngine($http, $dyn,
      '<?dyn="Button" caption="Show PosdaRtVerify" op="ShowPosdaRtVerify"?>' .
      '<br>');
    }
  }
  sub ShowPosdaRtVerify{
    my($this, $http, $dyn) = @_;
    $this->{ShowPosdaRtVerify} = 1;
    $this->AutoRefresh;
  }
  sub HidePosdaRtVerify{
    my($this, $http, $dyn) = @_;
    $this->{ShowPosdaRtVerify} = 0;
    $this->AutoRefresh;
  }
  sub File{
    my($this, $http, $dyn) = @_;
    $http->queue("$this->{File}");
  }
  sub FilePath{
    my($this, $http, $dyn) = @_;
    $http->queue("$this->{file_path}");
  }
  sub DumpLines{
    my($this, $http, $dyn) = @_;
    for my $l (@{$this->{dump_lines}}){ $http->queue("$l\n")}
  }
  sub DumpLineHandler{
    my($this) = @_;
    my $sub = sub {
      my($line) = @_;
      push @{$this->{dump_lines}}, $line;
    };
    return $sub;
  }
  sub DumpFinished{
    my($this) = @_;
    delete $this->{dump_reader};
    $this->AutoRefresh;
  }
  sub DciodvfyLines{
    my($this, $http, $dyn) = @_;
    for my $l (@{$this->{dciodvfy_lines}}){ $http->queue("$l\n")}
  }
  sub DciodvfyLineHandler{
    my($this) = @_;
    my $sub = sub {
      my($line) = @_;
      $line =~ s/</&lt;/g;
      $line =~ s/>/&gt;/g;
      push @{$this->{dciodvfy_lines}}, $line;
    };
    return $sub;
  }
  sub DciodvfyFinished{
    my($this) = @_;
    delete $this->{dciodvfy_reader};
    $this->AutoRefresh;
  }
  sub PosdaRtVerifyLines{
    my($this, $http, $dyn) = @_;
    for my $l (@{$this->{posda_rt_verify_lines}}){ $http->queue("$l\n")}
  }
  sub PosdaRtVerifyLineHandler{
    my($this) = @_;
    my $sub = sub {
      my($line) = @_;
      $line =~ s/</&lt;/g;
      $line =~ s/>/&gt;/g;
      push @{$this->{posda_rt_verify_lines}}, $line;
    };
    return $sub;
  }
  sub PosdaRtVerifyFinished{
    my($this) = @_;
    delete $this->{posda_rt_verify_reader};
    $this->AutoRefresh;
  }
}
1;

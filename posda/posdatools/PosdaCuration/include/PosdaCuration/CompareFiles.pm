#!/usr/bin/perl -w
#
use strict;
use POSIX 'strftime';
use Posda::HttpApp::HttpObj;
use Posda::HttpApp::WindowButtons;
use Posda::HttpApp::JsController;
use Posda::HttpApp::Authenticator;
use Posda::UUID;
use Debug;
my $dbg = sub { print @_ };
package PosdaCuration::CompareFiles;

use Fcntl;
use Posda::DebugLog 'off';
use Data::Dumper;

use vars qw( @ISA );
@ISA = ("Posda::HttpApp::JsController", "Posda::HttpApp::Authenticator");
my $expander = <<EOF;
<?dyn="BaseHeader"?>
<script type="text/javascript">
<?dyn="JsController"?>
<?dyn="JsContent"?>
</script>
</head>
<body>
<?dyn="Content"?>
<?dyn="Footer"?>
EOF
sub new{
  my($class, $sess, $path,
    $from_file_nn, $from_file, $to_file_nn, $to_file) = @_;
  my $this = Posda::HttpApp::JsController->new($sess, $path);
  $this->{ExitOnLogout} = 1;
  $this->{ImportsFromAbove}->{GetHeight} = 1;
  $this->{ImportsFromAbove}->{GetWidth} = 1;
  $this->{ImportsFromAbove}->{GetJavascriptRoot} = 1;
  $this->{ImportsFromAbove}->{GetLoginTemp} = 1;
  $this->{height} = $this->FetchFromAbove("GetHeight");
  $this->{width} = $this->FetchFromAbove("GetWidth");
  $this->{JavascriptRoot} = $this->FetchFromAbove("GetJavascriptRoot");
  $this->{expander} = $expander;
  $this->{title} = "File Comparator";
  unless(defined $this->{height}) { $this->{height} = 1024 }
  unless(defined $this->{width}) { $this->{width} = 1024 }
  $this->{FromNickname} = $from_file_nn;
  $this->{FromFile} = $from_file;
  $this->{ToNickname} = $to_file_nn;
  $this->{ToFile} = $to_file;
  bless $this, $class;
  DEBUG Dumper($this);
  $this->Initialize;
  return $this;
}
my $content = <<EOF;
<div id="container" style="width:<?dyn="width"?>px">
  <div id="header" style="background-color:#E0E0FF;">
  <table width="100%"><tr width="100%"><td>
    <?dyn="Logo"?>
    </td><td>
      <h1 style="margin-bottom:0;"><?dyn="title"?></h1>
      <p>
         From File: <?dyn="FromFile_nn"?>
      </p>
      <p>
         To File: <?dyn="ToFile_nn"?>
      </p>
    </td><td valign="top" align="right">
      <div id="login">&lt;login&gt;</div>
    </td></tr>
  </table>
</div>
<div id="content" style="background-color:#F8F8F8;width:<?dyn="width"?>px;float:left;">
&lt;Content&gt;</div>
<div id="footer" style="background-color:#E8E8FF;clear:both;text-align:center;">
Posda.com</div>
</div>
EOF
sub Content{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn, $content);
}
sub width{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{width});
}
sub height{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{height});
}
sub Study{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{Descriptor}->{study_pk});
  unless($this->{Descriptor}->{study_desc} eq "<undef>"){
    $http->queue(" ($this->{Descriptor}->{study_desc})");
  }
}
sub FromFile_nn{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{FromNickname});
}
sub FromFile{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{FromFile});
}
sub ToFile_nn{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{ToNickname});
}
sub ToFile{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{ToFile});
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
  my $js_file = "$this->{JavascriptRoot}/CheckSeries.js";
  unless(-f $js_file) { return }
  my $fh; open $fh, "<$js_file" or die "can't open $js_file";
  while(my $line = <$fh>) { $http->queue($line) }
}
sub Initialize{
  my($this) = @_;
  $this->{LoginTemp} = $this->FetchFromAbove("GetLoginTemp");
  $this->AutoRefresh;
  $this->StartDumps;
}
sub StartDumps{
  my($this) = @_;
  my $from = $this->{FromFile};
  my $from_dump_file;
  if($from =~ /^.*\/([^\/]+)$/){
    $from_dump_file = "$this->{LoginTemp}/from_$1.dump";
    if(-f $from_dump_file){ 
      unlink($from_dump_file);
    }
  }
  my $to = $this->{ToFile};
  my $to_dump_file;
  if($to =~ /^.*\/([^\/]+)$/){
    $to_dump_file = "$this->{LoginTemp}/to_$1.dump";
  }
  if(-f $to_dump_file){
    unlink($to_dump_file);
  }
  unless(defined($from_dump_file) && defined($to_dump_file)){
    die "Can't define dump files";
  }
  $this->{FromLineReader} = Dispatch::LineReader->new_cmd(
    "IheDumpFile.pl \"$from\" \"$from_dump_file\"",
    $this->DumpLineHandler("from"),
    $this->ADumpFinished("from"));
  $this->{DumpInProgress}->{from} = 1;
  $this->{FromDumpFile} = $from_dump_file;
  $this->{ToLineReader} = Dispatch::LineReader->new_cmd(
    "IheDumpFile.pl \"$to\" \"$to_dump_file\"",
    $this->DumpLineHandler("to"),
    $this->ADumpFinished("to"));
  $this->{DumpInProgress}->{from} = 1;
  $this->{ToDumpFile} = $to_dump_file;
}
sub Refresher{
  my($this) = @_;
  my $sub = sub {
    my($disp) = @_;
    $this->AutoRefresh;
    $disp->timer(5);
  };
  return $sub;
}
sub DumpLineHandler{
  my($this, $which) = @_;
  my $sub = sub {
    my($line) = @_;
    print STDERR "Error on $which: $line\n";
  };
  return $sub;
}
sub ADumpFinished{
  my($this, $which) = @_;
  my $sub = sub {
    delete $this->{DumpInProgress}->{$which};
    $this->AutoRefresh;
  };
  return $sub;
}
sub ContentResponse{
  my($this, $http, $dyn) = @_;
  my @DumpsInProgress = keys %{$this->{DumpInProgress}};
  if(@DumpsInProgress == 0){
    $http->HtmlHeader;
    $this->{LineReader} = Dispatch::LineReader->new_cmd(
      "IheCompareFiles.pl \"$this->{FromDumpFile}\" \"$this->{ToDumpFile}\"",
      $this->LineHandler($http),
      $this->DumpFinished);
  } else {
    $http->queue("Dump in progress");
  }
}
sub LineHandler{
  my($this, $http) = @_;
  my $sub = sub {
    my($line) = @_;
    $http->queue("$line\n");
  };
  return $sub;
}
sub DumpFinished{
  my($this) = @_;
  my $sub = sub{
    delete $this->{LineReader};
  };
  return $sub;
}
1;

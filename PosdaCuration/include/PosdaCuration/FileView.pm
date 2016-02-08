#!/usr/bin/perl -w
#
use strict;
use POSIX 'strftime';
use Posda::HttpApp::HttpObj;
use Posda::HttpApp::WindowButtons;
use Posda::HttpApp::JsController;
use Posda::UUID;
use Debug;
my $dbg = sub { print @_ };
package PosdaCuration::FileView;
use Fcntl;
use vars qw( @ISA );
@ISA = ("Posda::HttpApp::JsController");
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
  my($class, $sess, $path, $file_nn, $file) = @_;
  my $this = Posda::HttpApp::JsController->new($sess, $path);
  $this->{ImportsFromAbove}->{GetHeight} = 1;
  $this->{ImportsFromAbove}->{GetWidth} = 1;
  $this->{ImportsFromAbove}->{GetJavascriptRoot} = 1;
  $this->{height} = $this->FetchFromAbove("GetHeight");
  $this->{width} = $this->FetchFromAbove("GetWidth");
  $this->{JavascriptRoot} = $this->FetchFromAbove("GetJavascriptRoot");
  $this->{expander} = $expander;
  $this->{title} = "FileDisplayer ";
  unless(defined $this->{height}) { $this->{height} = 1024 }
  unless(defined $this->{width}) { $this->{width} = 1024 }
  $this->{Nickname} = $file_nn;
  $this->{File} = $file;
  bless $this, $class;
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
         File: <?dyn="File_nn"?>&nbsp;&nbsp;(<?dyn="File"?>)
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
sub File_nn{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{Nickname});
}
sub File{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{File});
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
sub LoginResponse{
  my($this, $http, $dyn) = @_;
  $http->queue(
    '<span onClick="javascript:CloseThisWindow();">close' .
    '</span><br><?dyn="DebugButton"?>'
  );
}
sub JsContent{
  my($this, $http, $dyn) = @_;
  my $js_file = "$this->{JavascriptRoot}/CheckSeries.js";
  unless(-f $js_file) { return }
  my $fh; open $fh, "<$js_file" or die "can't open $js_file";
  while(my $line = <$fh>) { $http->queue($line) }
}
sub DebugButton{
  my($this, $http, $dyn) = @_;
  if($this->CanDebug){
    $this->RefreshEngine($http, $dyn,
      '<span onClick="javascript:' .
      "rt('DebugWindow','Refresh?obj_path=Debug'" .
      ',1600,1200,0);">debug</span><br>');
  } else {
    print STDERR "Can't debug\n";
  }
}
sub Initialize{
  my($this) = @_;
  $this->{NickNames} = $this->parent->{NickNames};
  $this->AutoRefresh;
#  Dispatch::Select::Background->new($this->Refresher)->timer(5);
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
sub ContentResponse{
  my($this, $http, $dyn) = @_;
  $http->HtmlHeader;
  $this->{LineReader} = Dispatch::LineReader->new_cmd(
    "IheDumpFile.pl \"$this->{File}\"",
    $this->LineHandler($http),
    $this->DumpFinished);
}
sub LineHandler{
  my($this, $http) = @_;
  my $sub = sub {
    my($line) = @_;
    my($ele_sig, $vrvm, $name, $value) = split(/:/, $line);
    my $vr; my $vm;
    if(defined($vrvm) && $vrvm =~ /^\((..),(.*)\)$/){
      $vr = $1; $vm = $2;
    }
    if(defined($name) && $name eq "Referenced SOP Instance UID"){
      my $extra;
      if($value =~ /^\"(.*)\"$/){
        my $files = $this->{NickNames}->GetFileNicknamesByUid($1);
        if($files){
          if(ref($files) eq "ARRAY"){
            $extra = "(";
            for my $i (0 .. $#{$files}){
              $extra .= $files->[$i];
              unless($i == $#{$files}) { $extra .= ", " }
            }
            $extra .= ")";
          } else {
            $extra = " ($files)";
          }
        }
      }
      $line .= $extra;
    }
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

#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/TciaCuration/include/TciaCuration/CheckDbFiles.pm,v $
#$Date: 2015/05/20 19:57:37 $
#$Revision: 1.1 $
#
use strict;
use POSIX 'strftime';
use Posda::HttpApp::HttpObj;
use Posda::HttpApp::WindowButtons;
use Posda::HttpApp::JsController;
use Dispatch::Select;
use Digest::MD5;
use Debug;
my $dbg = sub { print @_ };
package TciaCuration::CheckDbFiles;
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
  my($class, $sess, $path, $subj, $collection, $site, $studies) = @_;
  my $this = Posda::HttpApp::JsController->new($sess, $path);
  $this->{ImportsFromAbove}->{GetHeight} = 1;
  $this->{ImportsFromAbove}->{GetWidth} = 1;
  $this->{ImportsFromAbove}->{GetJavascriptRoot} = 1;
  $this->{height} = $this->FetchFromAbove("GetHeight");
  $this->{width} = $this->FetchFromAbove("GetWidth");
  $this->{JavascriptRoot} = $this->FetchFromAbove("GetJavascriptRoot");
  $this->{expander} = $expander;
  $this->{title} = "CheckDbFiles";
  unless(defined $this->{height}) { $this->{height} = 1024 }
  unless(defined $this->{width}) { $this->{width} = 1024 }
  bless $this, $class;
  $this->{subject} = $subj,
  $this->{collection} = $collection,
  $this->{site} = $site,
  $this->{studies} = $studies,
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
         Collection: <?dyn="Collection"?><br>
         Site: <?dyn="Site"?><br>
         Subject: <?dyn="Subj"?><br>
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
sub Collection{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{collection});
}
sub Site{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{site});
}
sub Subj{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{subject});
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
  $this->RefreshEngine($http, $dyn,
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
  my @file_list;
  for my $study(keys %{$this->{studies}}){
    my $st_uid = $this->{studies}->{$study}->{uid};
    for my $series (keys %{$this->{studies}->{$study}->{series}}){
      my $s_hash = $this->{studies}->{$study}->{series}->{$series};
      my $s_uid = $s_hash->{uid};
      for my $f (keys %{$s_hash->{files}}){
        my $file = $s_hash->{files}->{$f}->{file};
        my $md5 = $s_hash->{files}->{$f}->{md5};
        my $md5_len = length($md5);
        unless($md5_len == 32){
          my $pad = 32 - $md5_len;
          $md5 = ("0" x $pad) . $md5;
        }
        push(@file_list, {
          study_uid => $st_uid,
          series_uid => $s_uid,
          file => $file,
          db_md5 => $md5,
        });
      }
    }
  }
  $this->{tot_files_to_check} = @file_list;
  $this->{files_to_check} = \@file_list;
  Dispatch::Select::Background->new($this->CheckNextFile)->queue;
}
sub ContentResponse{
  my($this, $http, $dyn) = @_;
  if($#{$this->{files_to_check}} >= 0){
    return $this->CheckingFiles($http, $dyn);
  }
  $http->queue("<small><table border>" .
    "<tr><th>Study</th><th>Series</th><th>File</th>" .
    "<th>Exists</th><th>MD5 Ok</th><th>Matches</th></tr>");
  my %PrintedStudy;
  my %PrintedSeries;
  for my $study (sort keys %{$this->{Result}}){
    for my $series(sort keys %{$this->{Result}->{$study}}){
      for my $file(sort keys %{$this->{Result}->{$study}->{$series}}){
        my $f_info = $this->{Result}->{$study}->{$series}->{$file};
        my $exists = $f_info->{exists};
        $http->queue("<tr><td>");
        unless($PrintedStudy{$study}){
          $http->queue("$study");
          $PrintedStudy{$study} = 1;
        }
        $http->queue("</td><td>");
        unless($PrintedSeries{$series}){
          $http->queue("$series");
          $PrintedSeries{$series} = 1;
        }
        $http->queue("</td><td>$file</td>");
        $http->queue("<td>");
        if($exists eq "YES"){
          $http->queue("YES</td><td>");
          if($f_info->{md5_computed} eq "YES"){
            $http->queue("YES</td><td>$f_info->{md5_matches}</td>");
          } else {
            $http->queue("NO</td><td>-</td>");
          }
        } else {
          $http->queue("NO</td><td>-</td><td>-</td>");
        }
        $http->queue("</tr>");
      }
    }
  }
  $http->queue("</table></small>");
}
sub CheckingFiles{
  my($this, $http, $dyn) = @_;
  my $tot = $this->{tot_files_to_check};
  my $remaining = @{$this->{files_to_check}};
  $http->queue("There are $remaining of $tot files remaining to be checked");
}
sub CheckNextFile{
  my($this) = @_;
  my $sub = sub {
    my($disp) = @_;
    unless($#{$this->{files_to_check}} >= 0){ return }
    my $next = shift(@{$this->{files_to_check}});
    my $study_uid = $next->{study_uid};
    my $series_uid = $next->{series_uid};
    my $file = $next->{file};
    my $db_md5 = $next->{db_md5};
    my $study_nn = $this->{NickNames}->GetEntityNicknameByEntityId(
      "STUDY", $study_uid);
    my $series_nn = $this->{NickNames}->GetEntityNicknameByEntityId(
      "SERIES", $series_uid);
    my $exists;
    if(-f $file) {
      $exists = "YES";
    } else {
      $exists = "NO";
    }
    my $md5_computed = "NO";
    my $md5_error;
    my $md5_matches;
    my $md5;
    if($exists eq "YES"){
      my $ctx = Digest::MD5->new;
      my $fh;
      if(open $fh, "<$file"){
        $ctx->addfile($fh);
        $md5 = $ctx->hexdigest;
        $md5_computed = "YES";
      } else {
        $md5_error = $!;
      }
    }
    $this->{Result}->{$study_nn}->{$series_nn}->{$file} = {
      exists => $exists,
    };
    my $result = $this->{Result}->{$study_nn}->{$series_nn}->{$file};
    if($exists eq "YES"){
      if($md5_computed eq "YES"){
        $result->{md5_computed} = "YES";
        if($md5 eq $db_md5){
          $result->{md5_matches} = "YES";
        } else {
          $result->{md5_matches} = "NO";
        }
      } else {
        $result->{md5_computed} = "NO";
      }
    }
    $disp->timer(0);
    $this->AutoRefresh;
  };
  return $sub;
}
1;

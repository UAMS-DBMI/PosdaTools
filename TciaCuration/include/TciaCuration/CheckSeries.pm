#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/TciaCuration/include/TciaCuration/CheckSeries.pm,v $
#$Date: 2014/11/24 15:35:59 $
#$Revision: 1.2 $
#
use strict;
use POSIX 'strftime';
use Posda::HttpApp::HttpObj;
use Posda::HttpApp::WindowButtons;
use Posda::HttpApp::JsController;
use Posda::BgColor;
use Posda::UUID;
use PipeChildren;
use Dispatch::Http;
use IO::Socket::INET;
use Debug;
my $dbg = sub { print @_ };
package TciaCuration::CheckSeries;
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
  my($class, $sess, $path, $desc) = @_;
  my $this = Posda::HttpApp::JsController->new($sess, $path);
  $this->{expander} = $expander;
  $this->{title} = "Check Series Consistency ";
  $this->{height} = $this->parent->{height};
  $this->{width} = $this->parent->{width};
  $this->{JavascriptRoot} = $this->parent->{JavascriptRoot};
  $this->{Descriptor} = $desc;
  $this->{image_count} = @{$this->{Descriptor}->{files}};
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
         Study: <?dyn="Study"?>&nbsp;&nbsp;
         Series: <?dyn="Series"?>&nbsp;&nbsp
         <?dyn="ImgCount"?> Images
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
sub Series{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{Descriptor}->{series_pk});
  $http->queue(" $this->{Descriptor}->{modality} ");
  unless($this->{Descriptor}->{body_part} eq "<undef>"){
    $http->queue(" ($this->{Descriptor}->{body_part}) ");
  }
  unless($this->{Descriptor}->{series_desc} eq "<undef>"){
    $http->queue(" ($this->{Descriptor}->{series_desc})");
  }
}
sub ImgCount{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{image_count});
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
sub ContentResponse{
  my($this, $http, $dyn) = @_;
  if($this->{Status} eq "CheckingSeries"){
    $this->InProgressReport($http, $dyn);
  } elsif($this->{Status} eq "Finished"){
    $this->FinishedReport($http, $dyn);
  } elsif($this->{Status} eq "ProcessingCommands"){
    $this->CommandReport($http, $dyn);
  } elsif($this->{Status} eq "FinishedCommands"){
    $this->DoneReport($http, $dyn);
  } else {
    $http->queue("Unknown Mode: $this->{Status}");
  }
}
sub InProgressReport{
  my($this, $http, $dyn) = @_;
  my $remaining = @{$this->{not_yet_checked}};
  my $inprocess = keys %{$this->{in_process}};
  $http->queue("Processing Files:<ul><li>$remaining files waiting</li>" .
    "<li>$inprocess files being processed</li></ul>");
}
sub FinishedReport{
  my($this, $http, $dyn) = @_;
  my $inconsistent = $this->{inconsistent_report};
  my $consistent = $this->{consistent_report};
  if(keys %{$inconsistent} > 0){
    $this->InconsistentReport($http, $dyn);
  } else {
    $http->queue("<h3>No inconsistent elements found in series</h3>");
  }
  if(keys %{$consistent} > 0){
    $this->ConsistentReport($http, $dyn);
  } else {
    $http->queue("<h3>No consistent elements found in series</h3>");
  }
}
sub InconsistentReport{
  my($this, $http, $dyn) = @_;
  $http->queue("<table width=\"100%\"><tr>" .
    "<th colspan=\"4\">Inconsistent Elements</th></tr>");
  $this->RefreshEngine($http, $dyn,
    '<tr><th>Name</th><th>Element</th><th>Value</th>' .
    '<th>#files</th><th>' .
    '<?dyn="SimpleButton" op="SplitSeries" caption="split" sync="Update();"?>' .
    '</tr>');
  for my $i (sort { 
      $this->{inconsistent_report}->{$a}->{name}
        cmp
      $this->{inconsistent_report}->{$b}->{name}
    } keys %{$this->{inconsistent_report}}
  ){
    my $name = $this->{inconsistent_report}->{$i}->{name};
    my $valp = $this->{inconsistent_report}->{$i}->{values};
    my $num_values = keys %$valp;
    $http->queue("<tr><td rowspan=\"$num_values\" valign=\"top\">" .
      "$name</td><td rowspan=\"$num_values\" valign=\"top\">$i</td>");
    my @values = keys %$valp;
    for my $j (0 .. $#values){
      $this->{ValueConversion}->{$i} = \@values;
      unless($j == 0){ $http->queue("<tr>") }
      $http->queue("<td>$values[$j]</td>");
      my $num_i = keys %{$valp->{$values[$j]}};
      $http->queue("<td>$num_i</td><td align=\"center\">");
      unless(exists $this->{SelectedEleValues}->{$i}->{$values[$j]}){
        $this->{SelectedEleValues}->{$i}->{$values[$j]} = "false";
      }
      $http->queue(
        $this->CheckBox("SelectedEleValues", $i,
          "SelectEleValue", 
          $this->{SelectedEleValues}->{$i}->{$values[$j]} eq "true",
          "index=$j")
      );
      $http->queue("</td></tr>");
    }
  }
  $http->queue("</table>");
}
sub ConsistentReport{
  my($this, $http, $dyn) = @_;
  $http->queue("<table><tr><th colspan=\"4\">Consistent Elements</th></tr>");
  $http->queue("<tr><th>Name</th><th>Element</th><th>Value</th>" .
    "<th>#files</th></tr>");
  for my $i (sort { 
      $this->{consistent_report}->{$a}->{name}
        cmp
      $this->{consistent_report}->{$b}->{name}
    } keys %{$this->{consistent_report}}
  ){
    my $name = $this->{consistent_report}->{$i}->{name};
    my $valp = $this->{consistent_report}->{$i}->{values};
    for my $j (keys %$valp){
      $http->queue("<tr><td>$name</td><td>$i</td><td>$j</td>");
      my $num_i = keys %{$valp->{$j}};
      $http->queue("<td>$num_i</td></tr>");
    }
  }
  $http->queue("</table>");
}
sub Initialize{
  my($this) = @_;
  $this->{Status} = "CheckingSeries";
  $this->{not_yet_checked} = $this->{Descriptor}->{files};
  $this->{in_process} = {};
  $this->{SeriesElements} = {};
  $this->StartChecking;
}
sub StartChecking{
  my($this) = @_;
  my $waiting = @{$this->{not_yet_checked}};
  my $inprocess = keys %{$this->{in_process}};
  while($waiting > 0 && $inprocess < 10){
    $this->StartOne;
    $waiting = @{$this->{not_yet_checked}};
    $inprocess = keys %{$this->{in_process}};
  }
  if($waiting == 0 && $inprocess == 0){
    $this->SearchFinished;
  }
} 
sub StartOne{
  my($this) = @_;
  my $file = shift(@{$this->{not_yet_checked}});
  if(exists $this->{in_process}->{$file}){
    print STDERR "Duplicate file in list: $file\n";
    return;
  }
  my $lh = $this->CreateLineHandler($file);
  my $eh = $this->CreateEndHandler($file);
  $this->{in_process}->{$file} = 1;
  Dispatch::LineReader->new_cmd("SeriesElements.pl \"$file\"", $lh, $eh);
}
sub CreateLineHandler{
  my($this, $file) = @_;
  my $sub = sub {
    my $line = shift;
    chomp $line;
    my($name, $ele, $value) = split(/\|/, $line);
    $this->{SeriesElements}->{$ele}->{name} = $name;
    $this->{SeriesElements}->{$ele}->{values}->{$value}->{$file} = 1;
  };
  return $sub;
}
sub CreateEndHandler{
  my($this, $file) = @_;
  my $sub = sub {
    delete $this->{in_process}->{$file};
    $this->StartChecking;
    $this->AutoRefresh;
  };
  return $sub;
}
sub SearchFinished{
  my($this) = @_;
  $this->{Status} = "Finished";
  $this->{inconsistent_report} = {};
  $this->{consistent_report} = {};
  for my $e (keys %{$this->{SeriesElements}}){
    my $ele_rep = $this->{SeriesElements}->{$e};
    my $vc = keys %{$ele_rep->{values}};
    if($vc > 1) {
      $this->{inconsistent_report}->{$e} = $ele_rep;
    } else {
      $this->{consistent_report}->{$e} = $ele_rep;
    }
  }
}
sub SelectEleValue{
  my($this, $http, $dyn) = @_;
  $this->{$dyn->{group}}->{$dyn->{value}}
    ->{$this->{ValueConversion}->{$dyn->{value}}->[$dyn->{index}]} = 
    $dyn->{checked};
}
sub SplitSeries{
  my($this, $http, $dyn) = @_;
  my $uid_root = Posda::UUID->GetUUID;
  my $seq = 1;
  my @items;
  for my $i (keys %{$this->{SelectedEleValues}}){
    for my $v (keys %{$this->{SelectedEleValues}->{$i}}){
      if($this->{SelectedEleValues}->{$i}->{$v} eq "true"){
        my $item = {
          new_series_instance_uid => "$uid_root." . $seq++,
          files => [],
        };
        for my $f (keys %{$this->{inconsistent_report}->{$i}->{values}->{$v}}){
          push(@{$item->{files}}, $f);
        }
        push @items, $item;
      }
    }
  }
  unless(@items) { return }
  my @commands;
  for my $item (@items){
    my $file_root = Dispatch::Http::App::Server::RandString;
    my $file_dest = "/mnt/erlbluearc/systems/cipa1-v10/data/roots/http-import" .
      "/temp/Edit-$file_root.md";
    my $move_dest = "/mnt/erlbluearc/systems/cipa1-v10/data/roots/http-import" .
      "/queue/Edit-$file_root.dcm";
    my $new_series_uid = $item->{new_series_instance_uid};
    for my $file (@{$item->{files}}){
      my $cmd = "ChangeDicomElements.pl \"$file\" \"$file_dest\" " .
        "\"(0020,000e)\" \"$new_series_uid\";mv \"$file_dest\" \"$move_dest\"";
      push @commands, $cmd;
    }
  }
  $this->{SeriesSplittingCommands} = \@commands;
  $this->StartCommandProcessing;
}
sub StartCommandProcessing{
  my($this) = @_;
  $this->{Status} = "ProcessingCommands";
  $this->ProcessNextCommand;
}
sub ProcessNextCommand{
  my($this) = @_;
  if(@{$this->{SeriesSplittingCommands}} > 0){
    $this->{CommandBeingProcessed} = shift @{$this->{SeriesSplittingCommands}};
    Dispatch::LineReader->new_cmd($this->{CommandBeingProcessed},
      $this->CommandLineHandler, $this->CommandDone);
  } elsif($this->{CommandBeingProcessed}) {
  } else {
    $this->{Status} = "FinishedCommands";
  }
  $this->AutoRefresh;
}
sub CommandLineHandler{
  my($this) = @_;
  my $sub = sub{
    my($line) = @_;
    print STDERR "$line\n";
  };
  return $sub;
}
sub CommandDone{
  my($this) = @_;
  my $sub = sub{
    my($line) = @_;
    delete $this->{CommandBeingProcessed};
    $this->ProcessNextCommand;
  };
  return $sub;
}
sub CommandReport{
  my($this, $http, $dyn) = @_;
  $http->queue("Processing command: $this->{CommandBeingProcessed}");
}
sub DoneReport{
  my($this, $http, $dyn) = @_;
  $http->queue("Please close");
}
1;

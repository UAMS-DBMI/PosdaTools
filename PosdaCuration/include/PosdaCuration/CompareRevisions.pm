#!/usr/bin/perl -w
#
use strict;
use POSIX 'strftime';
use Posda::HttpApp::HttpObj;
use Posda::HttpApp::WindowButtons;
use Posda::HttpApp::JsController;
use Posda::UUID;
use Storable;
use PosdaCuration::InfoExpander;
use Posda::Nicknames2;
use Debug;
my $dbg = sub { print @_ };
package PosdaCuration::CompareRevisions;
use Data::Dumper;
use Fcntl;
use vars qw( @ISA );
@ISA = ("Posda::HttpApp::JsController", "PosdaCuration::InfoExpander");
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
  my($class, $sess, $path, $from, $to) = @_;
  my $this = Posda::HttpApp::JsController->new($sess, $path);
  $this->{ImportsFromAbove}->{GetHeight} = 1;
  $this->{ImportsFromAbove}->{GetWidth} = 1;
  $this->{ImportsFromAbove}->{GetJavascriptRoot} = 1;
  $this->{ImportsFromAbove}->{GetExtractionRoot} = 1;
  $this->{ImportsFromAbove}->{StartChildDisplayer} = 1;
  $this->{height} = $this->FetchFromAbove("GetHeight");
  $this->{width} = $this->FetchFromAbove("GetWidth");
  $this->{JavascriptRoot} = $this->FetchFromAbove("GetJavascriptRoot");
  $this->{expander} = $expander;
  $this->{title} = "Posda Curation Tools: Compare Revisions";
  unless(defined $this->{height}) { $this->{height} = 1024 }
  unless(defined $this->{width}) { $this->{width} = 1024 }
  if($from < $to){
    $this->{FromRev} = $from;
    $this->{ToRev} = $to;
  } elsif($to < $from){
    $this->{FromRev} = $to;
    $this->{ToRev} = $from;
  } else {
    die "From and To can't be equal";
  }
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
         Collection: <?dyn="Collection"?> Site: <?dyn="Site"?>
         Subject: <?dyn="Subject"?>
         <br> From revision: <?dyn="FromRev"?> to <?dyn="ToRev"?>
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
sub FromRev{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{FromRev});
}
sub ToRev{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{ToRev});
}
sub Collection{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{Collection});
}
sub Site{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{Site});
}
sub Subject{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{Subject});
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
  $this->{NickNames} = Posda::Nicknames->new();
  $this->{ExtractionRoot} = $this->RouteAbove("GetExtractionRoot");
  my $DII = $this->RouteAbove("GetDisplayInfoIn");
  $this->{Collection} = $DII->{Collection};
  $this->{Site} = $DII->{Site};
  $this->{Subject} = $DII->{subj};
  $this->{nn} = Posda::Nicknames2::get($this->{Collection},
                                              $this->{Site},
                                              $this->{Subject});
  $this->{Revisions} = [];
  for my $i ($this->{FromRev} .. $this->{ToRev}){
    my $rev_info = {
      rev_num => $i,
      dir => "$this->{ExtractionRoot}/$this->{Collection}" .
        "/$this->{Site}/$this->{Subject}/revisions/$i",
    };
    $rev_info->{hierarchy} = 
      Storable::retrieve("$rev_info->{dir}/hierarchy.pinfo");
    $rev_info->{link_info} = 
      Storable::retrieve("$rev_info->{dir}/link_info.pinfo");
    my $d_info = 
      Storable::retrieve("$rev_info->{dir}/dicom.pinfo");
    for my $dig (keys %{$d_info->{FilesByDigest}}){
      $this->{FilesByDigest}->{$dig} = $d_info->{FilesByDigest}->{$dig};
    }
    push @{$this->{Revisions}}, $rev_info;
  }
  for my $i (@{$this->{Revisions}}){
    my $studies = $i->{hierarchy}->{$this->{Subject}}->{studies};
    for my $study (keys %{$studies}){
      for my $series (keys %{$studies->{$study}->{series}}){
        for my $f (keys %{$studies->{$study}->{series}->{$series}->{files}}){
          my $f_info = $studies->{$study}->{series}->{$series}->{files}->{$f};
          $this->{FileToDig}->{$f} = $f_info->{digest};
        }
      }
    }
  }
  for my $i (
    keys %{$this->{Revisions}->[0]->{hierarchy}->{$this->{Subject}}->{studies}}
  ){
    my $study = $this->{Revisions}->[0]->{hierarchy}
      ->{$this->{Subject}}->{studies}->{$i};
    my $study_uid = $study->{uid};
    for my $j (keys %{$study->{series}}){
      my $series = $study->{series}->{$j};
      my $series_uid = $series->{uid};
      for my $f (keys %{$series->{files}}){
        my @f_list;
        my $f_info = $series->{files}->{$f};
        push(@f_list, [$f, $f_info->{digest}]);
        my $last_link = $f;
        for my $rev (1 .. $#{$this->{Revisions}}){
          my $next_link = $this->{Revisions}->[$rev]->{link_info}->{$last_link};
          push(@f_list, [ $next_link, $this->{FileToDig}->{$next_link} ]);
          $last_link = $next_link;
        }
        $this->{FileHist}->{$study_uid}->{$series_uid}->{$f} = \@f_list;
      }
    }
  }
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
  $this->RefreshEngine($http, $dyn, qq{
    <p>
      <?dyn="ToggleOpen"?>
    </p>
    <table class="table" style="width: auto">
      <tr>
  });
  for my $i (@{$this->{Revisions}}){
    my $rev_no = $i->{rev_num};
    $http->queue("<th>Revision: $rev_no</th>");
  }
  $http->queue('</tr><tr>');
  for my $i (@{$this->{Revisions}}){
    $http->queue("<td>");
    if(exists $this->{Open}) { 
      $this->ExpandStudyHierarchy($http, $dyn,
        $i->{hierarchy}->{$this->{Subject}}->{studies},
        $this->{nn});
    } else {
      $this->ExpandStudyCounts($http, $dyn,
        $i->{hierarchy}->{$this->{Subject}}->{studies});
    }
    $http->queue("</td>");
  }
  $http->queue('</tr>');
  $this->RefreshEngine($http, $dyn, '</table>');
  $this->ShowOnlyDiffs($http, $dyn);
  $this->ExpandDiffHierarchy($http, $dyn);
}
sub ShowOnlyDiffs{
  my($this, $http, $dyn) = @_;
  my $group = "ShowOnly";
  my $value ="Foo";
  my $checked = exists($this->{ShowOnlyDiffs});
  my $showbox;
  if($checked){
    $showbox = $this->CheckBoxDelegate($group, $value, $checked, {
      op => "ShowOnlyNo",
      sync => "Update();",
    });
  } else {
    $showbox = $this->CheckBoxDelegate($group, $value, $checked, {
      op => "ShowOnlyYes",
      sync => "Update();",
    });
  }
  $this->RefreshEngine($http, $dyn, "<p>$showbox Show Only Diffs</p>");
}
sub ShowOnlyYes{
  my($this, $http, $dyn) = @_;
  print STDERR "In ShowOnlyYes\n";
  delete $this->{SelectedFiles};
  $this->{ShowOnlyDiffs} = 1;
}
sub ShowOnlyNo{
  my($this, $http, $dyn) = @_;
  print STDERR "In ShowOnlyNo\n";
  delete $this->{ShowOnlyDiffs};
}
sub ToggleOpen{
  my($this, $http, $dyn) = @_;
  if(exists $this->{Open}) {
    $this->NotSoSimpleButton($http, {
      caption => "Close",
      op => "Close",
      sync => "Update();",
    });
  } else {
    $this->NotSoSimpleButton($http, {
      caption => "Open",
      op => "Open",
      sync => "Update();",
    });
  }
}
sub Open{
  my($this, $http, $dyn) = @_;
  $this->QueueJsCmd(q{alert("This doesn't seem to work, so it is disabled.")});
  # $this->{Open} = 1;
}
sub Close{
  my($this, $http, $dyn) = @_;
  delete $this->{Open};
}
sub ExpandDiffHierarchy{
  my($this, $http, $dyn) = @_;
  if(exists $this->{ShowOnlyDiffs}) {
    $this->{DispFileHist} = $this->Reduce($this->{FileHist});
  } else {
    $this->{DispFileHist} = $this->{FileHist};
  }
  $http->queue(qq{
    <table class="table" style="width: auto">
      <tr>
        <th>Study</th>
        <th>Series</th>
  });
  for my $i (@{$this->{Revisions}}){
    $http->queue("<th>Revision: $i->{rev_num}</th>");
  }
  $http->queue(qq{
      <th></th>
    </tr>
  });
  for my $study (sort keys %{$this->{DispFileHist}}){
    my $study_nn = $this->{nn}->FromStudy($study);
    my @series = sort keys %{$this->{DispFileHist}->{$study}};
    my $num_rows = (@series) * 3;
    $http->queue(qq{
      <td rowspan="$num_rows" valign="top">$study_nn</td>
    });
    for my $series (@series){
      my $series_nn = $this->{nn}->FromSeries($series);
      $http->queue(qq{<td rowspan="3" valign="top">$series_nn</td>});
      $this->RefreshEngine($http, $dyn, qq{
        <td>
          <?dyn="RevDropDown" study="$study" series="$series" rev="0"?>
        </td>
      });
      for my $r (1 .. $#{$this->{Revisions}}){
        $this->RefreshEngine($http, $dyn, qq{
          <td>
            <?dyn="CorrespondingFile" study="$study" series="$series" rev="$r"?>
          </td>
        });
      }
      $this->RefreshEngine($http, $dyn, qq{
        <td>
        <?dyn="NotSoSimpleButton" op="Compare" study="$study" series="$series" caption="Compare" sync="Update();"?>
        </td>
        </tr>
      });
      for my $r (0 .. $#{$this->{Revisions}}){
        $this->RefreshEngine($http, $dyn, qq{
          <td>
            <?dyn="FromRadio" study="$study" series="$series" rev="$r"?>
          </td>
        });
      }
      $http->queue("<td>from</td></tr>");
      for my $r (0 .. $#{$this->{Revisions}}){
        $this->RefreshEngine($http, $dyn, qq{
          <td>
            <?dyn="ToRadio" study="$study" series="$series" rev="$r"?>
          </td>
        });
      }
      $http->queue("<td>to</td></tr>");
    }
  }
  $http->queue("</table></small>");
}
sub Reduce{
  # Remove all entries that lack changes between revisions
  my($this, $struct) = @_;
  my $new = {};
  if(ref($struct) eq "HASH"){
    for my $i (keys %{$struct}){
      my $ret = $this->Reduce($struct->{$i});
      if(defined $ret) { $new->{$i} = $ret }
    }
    if(keys %$new) { return \%$new }
    return undef;
  } elsif (ref($struct) eq "ARRAY"){
    my %digs;
    for my $i (@$struct){ $digs{$i->[1]} = 1 }
    if(keys %digs > 1) { return $struct }
    return undef;
  } else {
    my $ref = ref($struct);
    unless(defined $ref) { $ref = "<undef>" }
    print STDERR "Reduce called with ref: $ref\n";
    return undef;
  }
}
sub FromRadio{
  my($this, $http, $dyn) = @_;
  my $group = "to_$dyn->{study}_$dyn->{series}";
  my $study = $dyn->{study};
  my $series = $dyn->{series};
  my $rev = $dyn->{rev};
  unless(exists $this->{SelectedFromRadio}->{$study}->{$series}->{$rev}){
    $this->{SelectedFromRadio}->{$study}->{$series}->{$rev} = "false";
  }
  my $checked = 
    $this->{SelectedFromRadio}->{$study}->{$series}->{$rev} eq "true";
  my $parms = {
    study => $study,
    series => $series,
    rev => $rev,
    op => "SetFromRadio",
    sync => "Update();",
  };
  my $rbd = $this->RadioButtonDelegate($group, "", $checked, $parms, "");
  $http->queue($rbd);
}
sub ToRadio{
  my($this, $http, $dyn) = @_;
  my $group = "from_$dyn->{study}_$dyn->{series}";
  my $study = $dyn->{study};
  my $series = $dyn->{series};
  my $rev = $dyn->{rev};
  unless(exists $this->{SelectedToRadio}->{$study}->{$series}->{$rev}){
    $this->{SelectedToRadio}->{$study}->{$series}->{$rev} = "false";
  }
  my $checked = $this->{SelectedToRadio}->{$study}->{$series}->{$rev} eq "true";
  my $parms = {
    study => $study,
    series => $series,
    rev => $rev,
    op => "SetToRadio",
    sync => "Update();",
  };
  my $rbd = $this->RadioButtonDelegate($group, "", $checked, $parms, "");
  $http->queue($rbd);
}
sub SetToRadio{
  my($this, $http, $dyn) = @_;
  my $study = $dyn->{study};
  my $series = $dyn->{series};
  my $rev = $dyn->{rev};
  for my $i (keys %{$this->{SelectedToRadio}->{$study}->{$series}}){
    $this->{SelectedToRadio}->{$study}->{$series}->{$i} = "false";
  }
  $this->{SelectedToRadio}->{$study}->{$series}->{$rev} = $dyn->{checked};
}
sub SetFromRadio{
  my($this, $http, $dyn) = @_;
  my $study = $dyn->{study};
  my $series = $dyn->{series};
  my $rev = $dyn->{rev};
  for my $i (keys %{$this->{SelectedFromRadio}->{$study}->{$series}}){
    $this->{SelectedFromRadio}->{$study}->{$series}->{$i} = "false";
  }
  $this->{SelectedFromRadio}->{$study}->{$series}->{$rev} = $dyn->{checked};
}
sub RevDropDown{
  my($this, $http, $dyn) = @_;
  my $study = $dyn->{study};
  my $series = $dyn->{series};
  my $rev_num = $dyn->{rev};
  my @list = keys %{$this->{DispFileHist}->{$study}->{$series}};
  unless(exists $this->{SelectedFiles}->{$study}->{$series}){
    $this->{SelectedFiles}->{$study}->{$series} = $list[0];
  }
  $this->RefreshEngine($http, $dyn, qq{
    <?dyn="SelectDelegateByValue" op="SelectFile" study="$study" series="$series" sync="Update();"?>
  });
  for my $i (@list){
    my $file = $this->{DispFileHist}->{$study}->{$series}->{$i}->[0]->[0];
    my $dig = $this->{DispFileHist}->{$study}->{$series}->{$i}->[0]->[1];
    my $d_info = $this->{FilesByDigest}->{$dig};

    my $file_nn = $this->{nn}->FromFile($d_info->{sop_inst_uid},
                                    $d_info->{digest},
                                    $d_info->{modality});

    $http->queue("<option value=\"$file\"" .
      ($file eq $this->{SelectedFiles}->{$study}->{$series} ?
         " selected" : "") .
      ">$file_nn</option>");
  }
  $this->RefreshEngine("</select>");
}
sub SelectFile{
  my($this, $http, $dyn) = @_;
  my $study = $dyn->{study};
  my $series = $dyn->{series};
  my $file = $dyn->{value};
  $this->{SelectedFiles}->{$study}->{$series} = $file;
}

sub CorrespondingFile{
  my($this, $http, $dyn) = @_;
  my $study = $dyn->{study};
  my $series = $dyn->{series};
  my $rev_i = $dyn->{rev};
  my $rev_num = $this->{Revisions}->[$dyn->{rev}]->{rev_num};
  my $fi = $this->{SelectedFiles}->{$study}->{$series};
  my $file = $this->{FileHist}->{$study}->{$series}->{$fi}->[$rev_i]->[0];
  my $dig = $this->{FileHist}->{$study}->{$series}->{$fi}->[$rev_i]->[1];
  if (not defined $dig) {
    print "No CorrespondingFile found!\n";
    print "$study $series $fi $rev_i\n";
    # print Dumper($this->{DispFileHist});
    $http->queue("NONE");
    return;
  }
  my $d_info = $this->{FilesByDigest}->{$dig};

  my $file_nn = $this->{nn}->FromFile($d_info->{sop_inst_uid},
                                  $d_info->{digest},
                                  $d_info->{modality});
  $http->queue("$file_nn");
}
sub Compare{
  my($this, $http, $dyn) = @_;
  my $study = $dyn->{study};
  my $series = $dyn->{series};
  my $sel_file = $this->{SelectedFiles}->{$study}->{$series};
  my $dig = $this->{FileToDig}->{$sel_file};
  my $di = $this->{FilesByDigest}->{$dig};
  my $sel_file_nns =
    $this->{NickNames}->GetDicomNicknamesByFile($sel_file, $di);
  my $sel_file_nn = $sel_file_nns->[0];
  my $sel_from_rev;
  for my $sel (keys %{$this->{SelectedFromRadio}->{$study}->{$series}}){
    if($this->{SelectedFromRadio}->{$study}->{$series}->{$sel} eq "true"){
      $sel_from_rev = $sel;
    }
  }
  unless(defined $sel_from_rev){
    print STDERR "no from revision selected\n";
    return;
  }
  my $sel_to_rev;
  for my $sel (keys %{$this->{SelectedToRadio}->{$study}->{$series}}){
    if($this->{SelectedToRadio}->{$study}->{$series}->{$sel} eq "true"){
      $sel_to_rev = $sel;
    }
  }
  unless(defined $sel_to_rev){
    print STDERR "no to revision selected\n";
    return;
  }
  my $from_file_info = $this->{DispFileHist}->{$study}->{$series}->{$sel_file}
    ->[$sel_from_rev];
  my $from_file = $from_file_info->[0];
  my $from_file_dig = $from_file_info->[1];
  my $from_file_i = $this->{FilesByDigest}->{$from_file_dig};
  my $from_file_nns = 
    $this->{NickNames}->GetDicomNicknamesByFile($from_file, $from_file_i);
  my $from_file_nn = $from_file_nns->[0];
  my $to_file_info = $this->{DispFileHist}->{$study}->{$series}->{$sel_file}
    ->[$sel_to_rev];
  my $to_file = $to_file_info->[0];
  my $to_file_dig = $to_file_info->[1];
  my $to_file_i = $this->{FilesByDigest}->{$to_file_dig};
  my $to_file_nns = 
    $this->{NickNames}->GetDicomNicknamesByFile($to_file, $to_file_i);
  my $to_file_nn = $to_file_nns->[0];
  my $child_path = $this->child_path("compare_${from_file_nn}_$to_file_nn");
  my $child_obj = $this->get_obj($child_path);
  unless(defined $child_obj){
    $child_obj = PosdaCuration::CompareFiles->new($this->{session},
      $child_path, $from_file_nn, $from_file, $to_file_nn, $to_file);
    if($child_obj){
      $this->InvokeAbove("StartChildDisplayer", $child_obj);
#      $this->parent->StartJsChildWindow($child_obj);
    } else {
      print STDERR 'PosdaCuration::CompareFiles->new failed!!!' . "\n";
    }
  }
}
1;

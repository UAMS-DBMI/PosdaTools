#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/FileDist/include/FileDist/PhiSearch.pm,v $
#$Date: 2014/10/28 20:33:34 $
#$Revision: 1.13 $
#
use strict;
use Posda::HttpApp::GenericMfWindow;
use Posda::HttpApp::HttpObj;
use Posda::HttpApp::SubController;
use Posda::HttpApp::WindowButtons;
use Posda::Dataset;
use FileDist::ShowFile;
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
  package FileDist::PhiSearch;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericMfWindow" );
  sub new {
    my($class, $sess, $path, $series, $info, $summary) = @_;
    my $this = Posda::HttpApp::GenericMfWindow->new($sess, $path);
    $this->{title} = "Search for PHI";
    bless $this, $class;
    $this->{w} = 1024;
    $this->{h} = 700;
    Posda::HttpApp::SubController->new($this->{session}, 
      $this->child_path("Controller"));
    Posda::HttpApp::WindowButtons->new($this->{session},
      $this->child_path("WindowButtons"));
    FileDist::PhiSearch::Content->new($this->{session}, 
      $this->child_path("Content"), $series, $info, $summary);
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
  package FileDist::PhiSearch::Content;
  use Posda::HttpApp::GenericIframe;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericIframe" );
  sub new{
    my($class, $sess, $path, $series, $info, $summary) = @_;
    my $this = Posda::HttpApp::GenericIframe->new($sess, $path);
    $this->{ImportsFromAbove}->{GetFileList} = 1;
    bless $this, $class;
    my $file_list = $this->FetchFromAbove("GetFileList");
    for my $i (@$file_list) {
      $this->{DicomFiles}->{$i} = 1;
    }
    $this->StartProcessing;
    return $this;
  }

  sub StartProcessing{
    my($this) = @_;
    my $waiting = scalar(keys(%{$this->{DicomFiles}}));
    my $inprocess = scalar(keys(%{$this->{WorkList}}));
    while (($waiting > 0) && ($inprocess < 10)) {
      $this->StartOne;
      $waiting = scalar(keys(%{$this->{DicomFiles}}));
      $inprocess = scalar(keys(%{$this->{WorkList}}));
    }
    if($waiting == 0 && $inprocess == 0){
      my $old_hash = $this->{ByVr};
      $this->{ByVr} = {};
      for my $j (keys %$old_hash) {
        for my $k (keys %{$old_hash->{$j}}){
          my $new_key = $k;
          $new_key =~ s/</&lt;/g;
          $new_key =~ s/>/&gt;/g;
          $this->{ByVr}->{$j}->{$new_key} = $old_hash->{$j}->{$k};
        }
      }
      print STDERR "Reached End\n";
    }
  }

  sub StartOne{
    my($this) = @_;
    my $filename = [keys %{$this->{DicomFiles}}]->[0];
    delete $this->{DicomFiles}->{$filename};
    $this->{WorkList}->{$filename} = 1;
    my $info = $this->get_obj("FileManager")->DicomInfo($filename);
    my $study = $info->{study_uid};
    my $series = $info->{series_uid};
    my $f_nn =
      $this->FetchFromAbove("GetDicomNicknamesByFile", $filename);
    my $st_nn = $this->FetchFromAbove(
      "GetEntityNicknameByEntityId", "Study", $study);
    my $se_nn =
      $this->FetchFromAbove("GetEntityNicknameByEntityId", "Series", $series);
    $this->{StudyToNickName}->{$study} = $st_nn;
    $this->{SeriesToNickName}->{$series} = $se_nn;
    $this->{FileToNickName}->{$filename} = $f_nn->[0];
    my $lh = $this->CreateLineHandler($filename, $study, $series);
    my $eh = $this->CreateEndHandler($filename);
    Dispatch::LineReader->new_cmd("FindUniqueWords.pl $filename", $lh, $eh);
  }

  sub CreateLineHandler{
    my($this, $filename, $study, $series) = @_;
    my $sub = sub{
      my $line = shift;
      chomp $line;
      my ($word, $tag, $vr) = split (/\|/, $line);
      my ($pat, $indices) = Posda::Dataset->MakeMatchPat($tag);
      if(defined($indices) && ref($indices) eq "ARRAY" && $#{$indices} >= 0){
        unless(
          defined $this->{ByVr}->{$vr}->{$word}->{$pat}->
            {$study}->{$series}->{$filename}
        ){
          $this->{ByVr}->{$vr}->{$word}->{$pat}->
            {$study}->{$series}->{$filename} = [];
        }
        push(
          @{$this->{ByVr}->{$vr}->{$word}->{$pat}->
            {$study}->{$series}->{$filename}},
          $indices);
      } else {
        $this->{ByVr}->{$vr}->{$word}->{$pat}->
          {$study}->{$series}->{$filename} = 1;
      }
    };
    return $sub
  }

  sub CreateEndHandler{
    my($this, $filename) = @_;
    my $sub = sub{
      delete $this->{WorkList}->{$filename};
      $this->StartProcessing;
      $this->AutoRefresh;
    };
    return $sub
  }

  sub Content{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn,
      '<hr><?dyn="Description"?>' .
      '<hr><small><pre><?dyn="Results"?></pre></small>'
    );
  }
  sub Description{
    my($this, $http, $dyn) = @_;
    my $waiting = scalar(keys(%{$this->{DicomFiles}}));
    my $in_process = scalar(keys(%{$this->{WorkList}}));
    if($waiting >= 1 || $in_process >= 1){
      $http->queue("Processing files");
    } else {
      $this->VrSelection($http, $dyn);
    }
  }

  sub VrSelection{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn, 
      'Select VR: <?dyn="SelectNsByValue" op="SelectVr"?>');
    unless(defined $this->{SelectedVR}) { $this->{SelectedVR} = "NONE" }
    $http->queue('<option value="NONE"' .
      ($this->{SelectedVR} eq "NONE" ? " selected" : "") .
      '>Selected VR</option>');
    for my $k (sort keys %{$this->{ByVr}}){
      $http->queue("<option value=\"$k\"");
      if($this->{SelectedVR} eq $k){ 
        $http->queue(" selected");
      }
      $http->queue(">$k</option>");
    }
    $http->queue("</select>");
  }

  sub SelectVr{
    my($this, $http, $dyn) = @_;
    $this->{OpenValues} = {};
    $this->{SelectedVR} = $dyn->{value};
    $this->AutoRefresh;
  }
 
  sub Results{
    my($this, $http, $dyn) = @_;
    my $waiting = scalar(keys(%{$this->{DicomFiles}}));
    my $in_process = scalar(keys(%{$this->{WorkList}}));
    if($waiting >= 1 || $in_process >= 1){
      $http->queue("Waiting: $waiting,  In process: $in_process <br>");
    } elsif(
      defined($this->{SelectedVR}) && 
      exists $this->{ByVr}->{$this->{SelectedVR}}
    ) {
      $this->RefreshEngine($http, $dyn,
        "Table of values for VR: $this->{SelectedVR}".
        '<table border="1"><tr>' .
        '<th colspan="2">value</th><th colspan="2">element/pattern</th>' .
        '<th colspan="2">studies</th>' .
        '<th colspan="2">series</th><th>file</th>' .
        '<th>occurances</th>' .
        '<?dyn="ExpandTableRowsValues"?></table>'
      );
    } else {
      $http->queue("No VR Selected");
    }
  }
  
  sub ExpandTableRowsValues{
    my($this, $http, $dyn) = @_;
    for my $v (sort keys %{$this->{ByVr}->{$this->{SelectedVR}}}){
      my $row_count = $this->GetRowCount([],$v);
      $http->queue("\n<tr>");
      $http->queue("<td rowspan=\"$row_count\" valign=\"top\" ".
        "align=\"left\">$v</td>" .
        "<td rowspan=\"$row_count\" valign=\"top\" align=\"right\">");
      if(exists $this->{OpenValues}->{$v}){
        $http->queue("<a onclick=\"" .
        "javascript:ns('CloseValue?obj_path=$this->{path}&value=$v');\">" .
        "-</h>");
      } else {
        $http->queue("<a onclick=\"" .
        "javascript:ns('OpenValue?obj_path=$this->{path}&value=$v');\">" .
        "+</h>");
      }
      $http->queue("</td>");
      if(exists $this->{OpenValues}->{$v}){
        $this->ExpandTableRowsValuesPatterns($http, $dyn, $v);
      } else {
        $this->ShowPatternCountsByValue($http, $dyn, $v);
      }
    }
  }

  sub ExpandTableRowsValuesPatterns{
    my($this, $http, $dyn, $value) = @_;
    my $hash = $this->{ByVr}->{$this->{SelectedVR}}->{$value};
    for my $i (sort keys %$hash){
      my $pat = $i;
      my $q_pat = $i;
      $pat =~ s/</&lt;/g;
      $q_pat =~ s/(\")/"%" . unpack("H2", $1)/eg;
#      $q_pat =~ s/\"/&quot;/g;
      my $row_count = $this->GetRowCount([$value],$i);
      $http->queue("<td rowspan=\"$row_count\" valign=\"top\" " .
        "align=\"left\">" .
        "$pat</td>" .
        "<td rowspan=\"$row_count\" valign=\"top\">" .
        ( exists($this->{OpenValues}->{$value}->{$i}) ?
          "<a onclick=\"" .
          "javascript:ns('ClosePattern?obj_path=$this->{path}&value=$value" .
          "&pattern=$q_pat');\">-</a>"
          :
          "<a onclick=\"" .
          "javascript:ns('OpenPattern?obj_path=$this->{path}&value=$value" .
          "&pattern=$q_pat');\">+</a>"
        ) .
        "</td>"
      );
      if(exists $this->{OpenValues}->{$value}->{$i}){
        $this->ExpandTableRowsValuesPatternsStudies($http, $dyn, $value, $i);
      } else {
        $this->ShowStudyCountsByValuePattern($http, $dyn, $value, $i);
      }
    }
  }

  sub ExpandTableRowsValuesPatternsStudies{
    my($this, $http, $dyn, $value, $pat) = @_;
    my $q_pat = $pat;
    $q_pat =~ s/(\")/"%" . unpack("H2", $1)/eg;
#    $q_pat =~ s/\"/&quote;/g;
    my $hash = $this->{ByVr}->{$this->{SelectedVR}}->{$value}->{$pat};
    for my $i (sort keys %$hash){
      my $row_count = $this->GetRowCount([$value, $pat],$i);
      $http->queue("<td rowspan=\"$row_count\" valign=\"top\" " .
        "align=\"left\">" .
        $this->{StudyToNickName}->{$i} .
        "</td>" .
        "<td rowspan=\"$row_count\" valign=\"top\">" .
        ( exists($this->{OpenValues}->{$value}->{$pat}->{$i}) ?
          "<a onclick=\"" .
          "javascript:ns('CloseStudy?obj_path=$this->{path}&value=$value" .
          "&study=$i" .
          "&pattern=$q_pat');\">-</a>"
          :
          "<a onclick=\"" .
          "javascript:ns('OpenStudy?obj_path=$this->{path}&value=$value" .
          "&study=$i" .
          "&pattern=$q_pat');\">+</a>"
        ) .
        "</td>"
      );
      if(exists $this->{OpenValues}->{$value}->{$pat}->{$i}){
        $this->ExpandTableRowsValuesPatternsStudiesSeries(
          $http, $dyn, $value, $pat, $i);
      } else {
        $this->ShowSeriesCountsByValuePatternStudy(
          $http, $dyn, $value, $pat, $i);
      }
    }
  }

  sub ExpandTableRowsValuesPatternsStudiesSeries{
    my($this, $http, $dyn, $value, $pat, $stud) = @_;
    my $q_pat = $pat;
    $q_pat =~ s/(\")/"%" . unpack("H2", $1)/eg;
    my $hash = $this->{ByVr}->{$this->{SelectedVR}}->{$value}->{$pat}->{$stud};
    for my $i (sort keys %$hash){
      my $row_count = $this->GetRowCount([$value, $pat, $stud],$i);
      $http->queue("<td rowspan=\"$row_count\" valign=\"top\" " .
        "align=\"left\">" .
        $this->{SeriesToNickName}->{$i} .
        "</td>" .
        "<td rowspan=\"$row_count\" valign=\"top\">" .
        ( exists($this->{OpenValues}->{$value}->{$pat}->{$stud}->{$i}) ?
          "<a onclick=\"" .
          "javascript:ns('CloseSeries?obj_path=$this->{path}&value=$value" .
          "&study=$stud" .
          "&series=$i" .
          "&pattern=$q_pat');\">-</a>"
          :
          "<a onclick=\"" .
          "javascript:ns('OpenSeries?obj_path=$this->{path}&value=$value" .
          "&series=$i" .
          "&study=$stud" .
          "&pattern=$q_pat');\">+</a>"
        ) .
        "</td>"
      );
      if(exists $this->{OpenValues}->{$value}->{$pat}->{$stud}->{$i}){
        $this->ExpandTableRowsValuesPatternsStudiesSeriesFiles(
          $http, $dyn, $value, $pat, $stud, $i);
      } else {
        $this->ShowFileCountsByValuePatternStudySeries(
          $http, $dyn, $value, $pat, $stud, $i);
      }
    }
  }

  sub ExpandTableRowsValuesPatternsStudiesSeriesFiles{
    my($this, $http, $dyn, $value, $pat, $stud, $file) = @_;
    my $hash = $this->{ByVr}->
      {$this->{SelectedVR}}->{$value}->{$pat}->{$stud}->{$file};
    for my $i (sort keys %$hash){
      my $row_count = $this->GetRowCount([$value, $pat, $stud, $file],$i);
      $http->queue("<td rowspan=\"$row_count\" valign=\"top\" " .
        "align=\"left\">" .
        $this->{FileToNickName}->{$i} .
        "</td>"
      );
      if(exists $this->{OpenValues}->{$value}->{$pat}->{$stud}->{$i}){
#        $this->ExpandTableRowsValuesPatternsStudiesSeriesFiles(
#          $http, $dyn, $value, $pat, $stud, $i);
      } else {
#        $this->ShowFileCountsByValuePatternStudySeries(
#          $http, $dyn, $value, $pat, $stud, $i);
      }
      $http->queue("</tr>");
    }
  }


  sub ShowPatternCountsByValue{
    my($this, $http, $dyn, $value) = @_;
    my $hash = $this->{ByVr}->{$this->{SelectedVR}}->{$value};
    my $count = scalar keys %$hash;
    $http->queue("<td align=\"center\" colspan=\"2\">$count</td>");
    $this->ShowStudyCountsByValue($http, $dyn, $value);
  }

  sub ShowStudyCountsByValue{
    my($this, $http, $dyn, $value) = @_;
    my $hash = $this->{ByVr}->{$this->{SelectedVR}}->{$value};
    my %studies;
    for my $i (keys %$hash){
      for my $j (keys %{$hash->{$i}}){
        $studies{$j} = 1;
      }
    }
    my $count = scalar keys %studies;
    my $tot_studies = scalar keys %{$this->{StudyToNickName}};
    $http->queue(
      "<td align=\"center\" colspan=\"2\">$count of $tot_studies</td>");
    $this->ShowSeriesCountsByValue($http, $dyn, $value);
  }
  sub ShowSeriesCountsByValue{
    my($this, $http, $dyn, $value) = @_;
    my $hash = $this->{ByVr}->{$this->{SelectedVR}}->{$value};
    my %series;
    for my $i (keys %$hash){
      for my $j (keys %{$hash->{$i}}){
        for my $k (keys %{$hash->{$i}->{$j}}){
          $series{$k} = 1;
        }
      }
    }
    my $count = scalar keys %series;
    my $tot_series = scalar keys %{$this->{SeriesToNickName}};
    $http->queue(
      "<td align=\"center\" colspan=\"2\">$count of $tot_series</td>");
    $this->ShowFileCountsByValue($http, $dyn, $value);
  }
  
  sub ShowFileCountsByValue{
    my($this, $http, $dyn, $value) = @_;
    my $hash = $this->{ByVr}->{$this->{SelectedVR}}->{$value};
    my %files;
    for my $i (keys %$hash){
      for my $j (keys %{$hash->{$i}}){
        for my $k (keys %{$hash->{$i}->{$j}}){
          for my $m (keys %{$hash->{$i}->{$j}->{$k}}){
            $files{$m} = 1;
          }
        }
      }
    }
    my $count = scalar keys %files;
    my $tot_files = scalar keys %{$this->{FileToNickName}};
    $http->queue(
      "<td align=\"center\">$count of $tot_files</td>");
    $http->queue("<td align=\"center\">-</td>");
    $http->queue("</tr>");
  }

  sub ShowSeriesCountsByValuePatternStudy{
    my($this, $http, $dyn, $value, $pat, $study) = @_;
    my $hash = $this->{ByVr}->{$this->{SelectedVR}}->{$value}->{$pat}->{$study};
    my %series;
    for my $i (keys %$hash){
      $series{$i} = 1;
    }
    my $count = scalar keys %series;
    my $tot_series = scalar keys %{$this->{SeriesToNickName}};
    $http->queue(
      "<td align=\"center\" colspan=\"2\">$count of $tot_series</td>");
    $this->ShowFileCountsByValuePatternStudy($http, $dyn, $value, $pat, $study);
  }

  sub ShowFileCountsByValuePatternStudySeries{
    my($this, $http, $dyn, $value, $pat, $study, $series) = @_;
    my $hash = $this->{ByVr}->{$this->{SelectedVR}}->
      {$value}->{$pat}->{$study}->{$series};
    my %files;
    for my $i (keys %$hash){
      $files{$i} = 1;
    }
    my $count = scalar keys %files;
    my $tot_files = scalar keys %{$this->{FileToNickName}};
    $http->queue(
      "<td align=\"center\">$count of $tot_files</td>");
    $http->queue("<td align=\"center\">-</td>");
    $http->queue("</tr>");
  }

  sub ShowFileCountsByValuePatternStudy{
    my($this, $http, $dyn, $value, $pat, $study) = @_;
    my $hash = $this->{ByVr}->{$this->{SelectedVR}}->{$value}->{$pat}->{$study};
    my %files;
    for my $i (keys %$hash){
      for my $j (keys %{$hash->{$i}}){
        $files{$j} = 1;
      }
    }
    my $count = scalar keys %files;
    my $tot_files = scalar keys %{$this->{FileToNickName}};
    $http->queue(
      "<td align=\"center\">$count of $tot_files</td>");
    $http->queue("<td align=\"center\">-</td>");
    $http->queue("</tr>");
  }

  sub ShowStudyCountsByValuePattern{
    my($this, $http, $dyn, $value, $pat) = @_;
    my $hash = $this->{ByVr}->{$this->{SelectedVR}}->{$value}->{$pat};
    my %studies;
    for my $i (keys %$hash){
      $studies{$i} = 1;
    }
    my $count = scalar keys %studies;
    my $tot_studies = scalar keys %{$this->{StudyToNickName}};
    $http->queue(
      "<td align=\"center\" colspan=\"2\">$count of $tot_studies</td>");
    $this->ShowSeriesCountsByValuePattern($http, $dyn, $value, $pat);
  }

  sub ShowSeriesCountsByValuePattern{
    my($this, $http, $dyn, $value, $pat) = @_;
    my $hash = $this->{ByVr}->{$this->{SelectedVR}}->{$value}->{$pat};
    my %series;
    for my $i (keys %$hash){
      for my $j (keys %{$hash->{$i}}){
        $series{$j} = 1;
      }
    }
    my $count = scalar keys %series;
    my $tot_series = scalar keys %{$this->{SeriesToNickName}};
    $http->queue(
      "<td align=\"center\" colspan=\"2\">$count of $tot_series</td>");
    $this->ShowFileCountsByValuePattern($http, $dyn, $value, $pat);
  }

  sub ShowFileCountsByValuePattern{
    my($this, $http, $dyn, $value, $pat) = @_;
    my $hash = $this->{ByVr}->{$this->{SelectedVR}}->{$value}->{$pat};
    my %files;
    for my $i (keys %$hash){
      for my $j (keys %{$hash->{$i}}){
        for my $k (keys %{$hash->{$i}->{$j}}){
          $files{$k} = 1;
        }
      }
    }
    my $count = scalar keys %files;
    my $tot_files = scalar keys %{$this->{FileToNickName}};
    $http->queue(
      "<td align=\"center\">$count of $tot_files</td>");
    $http->queue("<td align=\"center\">-</td>");
    $http->queue("</tr>");
  }

  sub OpenValue{
    my($this, $http, $dyn) = @_;
    $this->{OpenValues}->{$dyn->{value}} = {};
    $this->AutoRefresh;
  }

  sub CloseValue{
    my($this, $http, $dyn) = @_;
    delete $this->{OpenValues}->{$dyn->{value}};
    $this->AutoRefresh;
  }

  sub OpenPattern{
    my($this, $http, $dyn) = @_;
    $this->{OpenValues}->{$dyn->{value}}->{$dyn->{pattern}} = {};
    $this->AutoRefresh;
  }

  sub ClosePattern{
    my($this, $http, $dyn) = @_;
    delete $this->{OpenValues}->{$dyn->{value}}->{$dyn->{pattern}};
    $this->AutoRefresh;
  }

  sub OpenStudy{
    my($this, $http, $dyn) = @_;
print STDERR "OpenStudy: ";
for my $i (keys %$dyn){
print STDERR "\tdyn{$i} = $dyn->{$i}\n";
};
    $this->{OpenValues}->{$dyn->{value}}->{$dyn->{pattern}}->{$dyn->{study}} =
      {};
    $this->AutoRefresh;
  }

  sub CloseStudy{
    my($this, $http, $dyn) = @_;
    delete 
      $this->{OpenValues}->{$dyn->{value}}->{$dyn->{pattern}}->{$dyn->{study}};
    $this->AutoRefresh;
  }

  sub OpenSeries{
    my($this, $http, $dyn) = @_;
    $this->{OpenValues}->
      {$dyn->{value}}->{$dyn->{pattern}}->{$dyn->{study}}->{$dyn->{series}} =
      {};
    $this->AutoRefresh;
  }

  sub CloseSeries{
    my($this, $http, $dyn) = @_;
    delete 
      $this->{OpenValues}->
        {$dyn->{value}}->{$dyn->{pattern}}->{$dyn->{study}}->{$dyn->{series}};
    $this->AutoRefresh;
  }

  sub GetRowCount{
    my($this, $l, $v) = @_;
    my $hash = $this->{ByVr}->{$this->{SelectedVR}};
    my $sel_hash = $this->{OpenValues};
    for my $i (@$l){
      unless(exists $sel_hash->{$i}) { return 1 }
      $hash = $hash->{$i};
      $sel_hash = $sel_hash->{$i};
    }
    if(ref($sel_hash) eq "HASH" && exists $sel_hash->{$v}) {
      my @keys = keys %{$hash->{$v}};
      my $new_l = [];
      for my $i (@$l){ push @$new_l, $i }
      push @$new_l, $v;
      my $sum = 0;
      for my $j (keys %{$hash->{$v}}){
        my $count = $this->GetRowCount($new_l, $j);
        $sum += $this->GetRowCount($new_l, $j);
      }
      return $sum;
    } else { return 1 }
  }

}
1;

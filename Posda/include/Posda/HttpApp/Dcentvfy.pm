#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/HttpApp/Dcentvfy.pm,v $
#$Date: 2013/09/05 15:21:56 $
#$Revision: 1.1 $
#
use strict;
use Posda::HttpApp::GenericMfWindow;
use Posda::HttpApp::HttpObj;
use Posda::HttpApp::SubController;
use Posda::HttpApp::WindowButtons;
use Dispatch::LineReader;

use Debug;
my $dbg = sub {print STDERR @_};

my $header = <<EOF;
<table style="width:100%" summary="window header">
  <tr>
    <td valign="top" align="left" width="160">
      <?dyn="Logo"?>
    </td>
    <td valign="top">
      <h2><?dyn="title"?></h2>
     <small>
      Select Study and/or Series: 
        <?dyn="SelectNsByValue" op="SelectStudySeries"?>
      <?dyn="StudySeriesDropDown"?></select>
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
  package Posda::HttpApp::Dcentvfy;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericMfWindow" );
  sub new {
    my($class, $sess, $path) = @_;
    my $this = Posda::HttpApp::GenericMfWindow->new($sess, $path);
    $this->{title} = "Dcentvfy Invocaton Tool";
    bless $this, $class;
    $this->{w} = 1024;
    $this->{h} = 700;
    Posda::HttpApp::SubController->new($this->{session}, 
      $this->child_path("Controller"));
    Posda::HttpApp::WindowButtons->new($this->{session},
      $this->child_path("WindowButtons"));
    Posda::HttpApp::Dcentvfy::Content->new(
        $this->{session}, $this->child_path("Content"));
    Posda::HttpApp::DebugWindow->new($sess, "Debug");
    $this->SetInitialExpertAndDebug;
    $this->ReOpenFile();
    $this->{ImportsFromAbove}->{IAmDicomSummary} = 1;
    $this->{ImportsFromAbove}->{IAmSeriesNickNames} = 1;
    $this->{ImportsFromAbove}->{TempDir} = 1;
    $this->{ImportsFromAbove}->{DcentvfySelectionChanged} = 1;
    $this->{RoutesBelow}->{GetDcentvfyDescription} = 1;
    $this->{RoutesBelow}->{GetDcentvfyFileList} = 1;
    $this->{RoutesBelow}->{GetDcentvfySelection} = 1;
    $this->{RoutesBelow}->{DcentvfySelectionChanged} = 1;
    $this->{Exports}->{GetDcentvfyDescription} = 1;
    $this->{Exports}->{GetDcentvfyFileList} = 1;
    $this->{Exports}->{GetDcentvfySelection} = 1;
    $this->{Selection} = "-- All Selected --";
    $this->InitSeriesInfo;
    return $this;
  }
  sub InitSeriesInfo{
    my($this) = @_;
    my $dicom_sum = $this->FetchFromAbove("IAmDicomSummary");
    my $ser_nick = $this->FetchFromAbove("IAmSeriesNicknames");
    my $st_nick = $this->FetchFromAbove("IAmStudyNicknames");
    my $fm = $this->get_obj("FileManager");
    my $series_info = $dicom_sum->{SeriesInfo};
    my $studies = $dicom_sum->{Studies};
    my $sop_files = $dicom_sum->{processed_files}->{by_sop};
    for my $series (keys %$series_info){
      my $nickname = $ser_nick->GetNickname($series);
      $this->{SeriesInfo}->{$series} = {
        modality => $series_info->{$series}->{modality},
        patient_id => $series_info->{$series}->{patient_id},
        nickname => $nickname,
        files => [],
        errors => [],
      };
      for my $st (keys %$studies){
        if(exists $studies->{$st}->{$series}){
          $this->{Studies}->{$st}->{nickname} = $st_nick->GetNickname($st);
          $this->{Studies}->{$st}->{series}->{$series} = 1;
          $this->{SeriesInfo}->{$series}->{study} = $st_nick->GetNickname($st);
          for my $sop (keys %{$studies->{$st}->{$series}}){
            my @list = keys %{$sop_files->{$sop}};
            if($#list > 0 ){
              push(@{$this->{SeriesInfo}->{$series}->{errors}},
                "Error: more than one file for sop $sop"
              );
            }
            if($#list < 0) {
              push(@{$this->{SeriesInfo}->{$series}->{errors}},
                "Error: no file for sop $sop"
              );
            }
            for my $i (@list){
              push(@{$this->{SeriesInfo}->{$series}->{files}}, $i);
            }
          }
        }
      }
    }
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
  sub StudySeriesDropDown{
    my($this, $http, $dyn) = @_;
    $http->queue("<option value=\"-- All Selected --\"" .
      ($this->{Selection} eq "-- All Selected --" ? " selected" : "") .
      ">-- All Selected --</option>"
    );
    for my $st (
      sort
      { 
        $this->{Studies}->{$a}->{nickname} 
          cmp 
        $this->{Studies}->{$b}->{nickname}
      }
      keys %{$this->{Studies}}
    ){
      $http->queue("<option value=\"$st\"" .
        ($this->{Selection} eq $st ? " selected" : "") .
        ">$this->{Studies}->{$st}->{nickname}</option>");
    }
    for my $ser (
      sort
      {
            $this->{SeriesInfo}->{$a}->{study}
          cmp
            $this->{SeriesInfo}->{$b}->{study}
        or
            $this->{SeriesInfo}->{$a}->{nickname}
          cmp
            $this->{SeriesInfo}->{$b}->{nickname}
      }
      keys %{$this->{SeriesInfo}}
    ){
      my $desc = "$this->{SeriesInfo}->{$ser}->{study}:" .
        "$this->{SeriesInfo}->{$ser}->{nickname}:&nbsp;&nbsp;";
      my @modalities = keys %{$this->{SeriesInfo}->{$ser}->{modality}};
      for my $mi (0 .. $#modalities){
        my $modality = $modalities[$mi];
        my $count = $this->{SeriesInfo}->{$ser}->{modality}->{$modality};
        $desc .= "$count $modality";
        unless($mi == $#modalities) { $desc .= ";&nbsp" }
      }
      $http->queue("<option value=\"$ser\"" .
        ($this->{Selection} eq $ser ? " selected" : "") .
        ">$desc</option>");
    }
  }
  sub SelectStudySeries{
    my($this, $http, $dyn) = @_;
    $this->{Selection} = $dyn->{value};
    $this->NotifyUp("DcentvfySelectionChanged");
  }
  sub GetDcentvfyDescription{
    my($this) = @_;
    if($this->{Selection} eq "-- All Selected --"){
      my $num_studies = scalar keys %{$this->{Studies}};
      my $num_series = scalar keys %{$this->{SeriesInfo}};
      my %mod_count;
      for my $ser (keys %{$this->{SeriesInfo}}){
        for my $mod (keys %{$this->{SeriesInfo}->{$ser}->{modality}}){
          unless($mod_count{$mod}) { $mod_count{$mod} = 0 }
          $mod_count{$mod} += $this->{SeriesInfo}->{$ser}->{modality}->{$mod};
        }
      }
      my $desc = "<small>Description<ul>" .
        "<li>$num_studies studies</li><li>$num_series series</li>";
      for my $mod (keys %mod_count){
        $desc .= "<li>$mod_count{$mod} $mod</li>";
      }
      return "$desc</ul></small>";
    } elsif(exists $this->{Studies}->{$this->{Selection}}){
      my $num_studies = 1;
      my $num_series = 
        scalar keys %{$this->{Studies}->{$this->{Selection}}->{series}};
      my $desc = "<small>Description<ul>" .
        "<li>$num_studies studies</li><li>$num_series series</li>";
      my %mod_count;
      for my $ser (
        keys %{$this->{Studies}->{$this->{Selection}}->{series}}
      ){
        for my $mod (keys %{$this->{SeriesInfo}->{$ser}->{modality}}){
          unless($mod_count{$mod}) { $mod_count{$mod} = 0 }
          $mod_count{$mod} += $this->{SeriesInfo}->{$ser}->{modality}->{$mod};
        }
      }
      for my $mod (keys %mod_count){
        $desc .= "<li>$mod_count{$mod} $mod</li>";
      }
      return "$desc</ul></small>";
    } elsif(exists $this->{SeriesInfo}->{$this->{Selection}}){
      my $num_studies = 1;
      my $num_series = 1;
      my $desc = "<small>Description<ul>" .
        "<li>$num_studies studies</li><li>$num_series series</li>";
      my %mod_count;
      for my $mod (
        keys %{$this->{SeriesInfo}->{$this->{Selection}}->{modality}}
      ){
        unless($mod_count{$mod}) { $mod_count{$mod} = 0 }
        $mod_count{$mod} += 
          $this->{SeriesInfo}->{$this->{Selection}}->{modality}->{$mod};
      }
      for my $mod (keys %mod_count){
        $desc .= "<li>$mod_count{$mod} $mod</li>";
      }
      return "$desc</ul></small>";
    } else {
      return "Unknown selection: $this->{Selection}";
    }
  }
  sub GetDcentvfySelection{
    my($this) = @_;
    return $this->{Selection};
  }
  sub GetDcentvfyFileList{
    my($this) = @_;
    my %files;
    if($this->{Selection} eq "-- All Selected --"){
      for my $ser (keys %{$this->{SeriesInfo}}){
        for my $f (@{$this->{SeriesInfo}->{$ser}->{files}}){
          $files{$f} = 1;
        }
      }
    } elsif (exists $this->{Studies}->{$this->{Selection}}){
      for my $ser (keys %{$this->{Studies}->{$this->{Selection}}->{series}}){
        for my $f (@{$this->{SeriesInfo}->{$ser}->{files}}){
          $files{$f} = 1;
        }
      }
    } elsif (exists $this->{SeriesInfo}->{$this->{Selection}}){
      for my $f (@{$this->{SeriesInfo}->{$this->{Selection}}->{files}}){
        $files{$f} = 1;
      }
    }
    return [ keys %files];
  }
}
{
  package Posda::HttpApp::Dcentvfy::Content;
  use Posda::HttpApp::GenericIframe;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericIframe" );
  sub new{
    my($class, $sess, $path) = @_;
    my $this = Posda::HttpApp::GenericIframe->new($sess, $path);
    $this->{Exports}->{DcentvfySelectionChanged} = 1;
    $this->{ImportsFromAbove}->{GetDcentvfyDescription} = 1;
    $this->{ImportsFromAbove}->{GetDcentvfySelection} = 1;
    $this->{ImportsFromAbove}->{GetDcentvfyFileList} = 1;
    bless $this, $class;
    $this->{Selection} = "none";
    $this->{Sequence} = 0;
    $this->{TempDir} = $this->FetchFromAbove("TempDir");
    return $this;
  }
  sub Content{
    my($this, $http, $dyn) = @_;
    my $select = $this->FetchFromAbove("GetDcentvfySelection");
    if($this->{Selection} ne $select){
      $this->{Selection} = $select;
      $this->StartDcentvfy;
    }
    $this->RefreshEngine($http, $dyn, 
      '<hr><?dyn="Description"?>' .
      '<hr><small><pre><?dyn="Results"?></pre></small>'
    );
  }
  sub Description{
    my($this, $http, $dyn) = @_;
    $http->queue($this->FetchFromAbove("GetDcentvfyDescription"));
  }
  sub Results{
    my($this, $http, $dyn) = @_;
    if(exists $this->{ResultsReader}){
      $http->queue("dcentvfy running<hr>");
    } else {
      $http->queue("dcentvfy finished<hr>");
    }
    for my $i (@{$this->{ResultsLines}}){
      $i =~ s/</&lt;/g;
      $i =~ s/>/&gt;/g;
      $http->queue("$i\n");
    }
  }
  sub DcentvfySelectionChanged{
    my($this) = @_;
    $this->AutoRefresh;
  }
  sub StartDcentvfy{
    my($this) = @_;
    $this->AutoRefresh;
    if($this->{ResultsReader}){
      if($this->{ResultsReader}->can("Abort")){
        $this->{ResultsReader}->Abort;
      } else {
        $this->{State} = "Error";
        $this->{Error} = "ResultsReader which can't Abort???";
        return;
      }
      delete $this->{ResultsReader};
      delete $this->{Results};
    }
    $this->{FileList} = $this->FetchFromAbove("GetDcentvfyFileList");
    $this->{State} = "Processing";
    $this->{ResultsLines} = [];
    $this->{Sequence} += 1;
    my $file_list_file = "$this->{TempDir}/file_list_$this->{Sequence}";
    open my $fh, ">$file_list_file" or die "Can't open $file_list_file";
    for my $f (@{$this->{FileList}}){
      print $fh "$f\n";
    }
    close $fh;
    $this->{ResultsReader} = Dispatch::LineReader->new_cmd(
      "dcentvfy -f $file_list_file 2>&1",
      $this->HandleDcentvfyLine,
      $this->CreateNotifierClosure("CommandFinished")
    );
  }
  sub HandleDcentvfyLine{
    my($this) = @_;
    my $sub = sub {
      my($line) = @_;
      push(@{$this->{ResultsLines}}, $line);
      $this->AutoRefresh;
    };
    return $sub;
  }
  sub CommandFinished{
    my($this) = @_;
    $this->{State} = "ResultsAvailable";
    delete $this->{ResultsReader};
    $this->AutoRefresh;
  }
}
1;

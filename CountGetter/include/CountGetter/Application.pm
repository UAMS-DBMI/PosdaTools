#!/usr/bin/perl -w
use strict;
package CountGetter::Application;
use Time::Piece;
use Posda::HttpApp::JsController;
use Dispatch::NamedObject;
use Posda::HttpApp::DebugWindow;
use Posda::HttpApp::Authenticator;
use Posda::FileCollectionAnalysis;
use Posda::Nicknames;
use Posda::UUID;
use Posda::DebugLog 'on';
use Posda::DataDict;
use Dispatch::NamedFileInfoManager;
use Dispatch::LineReader;
use Fcntl qw(:seek);
use File::Path 'remove_tree';
use Digest::MD5;
use JSON;
use Debug;
use Storable;
my $dbg = sub {print STDERR @_ };
use utf8;
use vars qw( @ISA );
@ISA = ( "Posda::HttpApp::JsController", "Posda::HttpApp::Authenticator" );

my $expander = q{<?dyn="BaseHeader"?>
  <script type="text/javascript">
  <?dyn="JsController"?>
  <?dyn="JsContent"?>
  </script>
  <link rel="stylesheet" href="/jquery-ui-1.11.4/jquery-ui.css">
  <script src="/jquery-ui-1.11.4/jquery-ui.min.js"></script>
  </head>
  <body>
  <?dyn="Content"?>
  <?dyn="Footer"?>
};
my $bad_config = qq{
  <?dyn="BadConfigReport"?>
};
sub new {
  my($class, $sess, $path) = @_;
  my $this = Dispatch::NamedObject->new($sess, $path);
  $this->{title} = "Posda Curation Tools";
  bless $this, $class;

  $this->{FoundFiles} = [];
  $this->{DataDict} = Posda::DataDict->new();

  if(exists $main::HTTP_APP_CONFIG->{BadJson}){
    $this->{BadConfigFiles} = $main::HTTP_APP_CONFIG->{BadJson};
  }
  $this->{expander} = $expander;
  $this->{Identity} = $main::HTTP_APP_CONFIG->{config}->{Identity};
  $this->{Environment} = $main::HTTP_APP_CONFIG->{config}->{Environment};
  $this->{LoginTempDir} = "$this->{Environment}->{LoginTemp}/$this->{session}";
  unless(mkdir $this->{LoginTempDir}) {
    die "can't mkdir $this->{LoginTempDir}"
  }
  my $width = $this->{Identity}->{width};
  my $height = $this->{Identity}->{height};
  $this->{title} = $this->{Identity}->{Title};
  $this->{height} = $height;
  $this->{width} = $width;
  $this->{menu_width} = 100;
  $this->{content_width} = $this->{width} - $this->{menu_width};
  # TODO:  This needs to be moved to a config file!
  $this->SetInitialExpertAndDebug("quasar");
  if($this->CanDebug){
    Posda::HttpApp::DebugWindow->new($sess, "Debug");
  }
  $this->{JavascriptRoot} =
    $main::HTTP_APP_CONFIG->{config}->{Environment}->{JavascriptRoot};
  $this->QueueJsCmd("Update();");
  my $session = $this->get_session;
  $session->{DieOnTimeout} = 1;
  if(
    exists $main::HTTP_APP_SINGLETON->{token} &&
    defined $main::HTTP_APP_SINGLETON->{token}
  ){
    $session->{logged_in} = 1;
    $session->{AuthUser} = $main::HTTP_APP_SINGLETON->{token};
    $session->{real_user} = $main::HTTP_APP_SINGLETON->{token};
    $this->SetUserPrivs($main::HTTP_APP_SINGLETON->{token});
  }
  $this->{ExitOnLogout} = 1;
  $this->{DicomInfoCache} =
    $main::HTTP_APP_CONFIG->{config}->{Environment}->{DicomInfoCache};
  $this->{ExtractionRoot} =
    $main::HTTP_APP_CONFIG->{config}->{Environment}->{ExtractionRoot};
  # TODO: This script is used by two apps now.. maybe we should move it to 
  # Posda/bin ?
  my $cmd = 
    "ScanSubmissionDirectories.pl $this->{Environment}->{SubmissionRoot}";
  Dispatch::LineReader->new_cmd($cmd, $this->DirLine, $this->DirEnd);
  $this->{Mode} = "ScanningDir";
  return $this;
}
sub DirLine{
  my($this) = @_;
  my $sub = sub {
    my($line) = @_;
    my($coll, $site, $subj, $dir) = split(/\|/, $line);
    $this->{Collections}->{$coll}->{$site}->{$subj}->{$dir} = 1;
  };
  return $sub;
}
sub DirEnd{
  my($this) = @_;
  my $sub = sub {
    $this->{SelectedCollection} = "none";
    $this->{SelectedSite} = "none";
    $this->{SelectedSubj} = "none";
    $this->{SelectedDir} = "none";
    $this->{Mode} = "Selection";
    $this->AutoRefresh;
  };
  return $sub;
}
sub user{
  my($this, $http, $dyn) = @_;
  $http->queue($this->get_user);
}
my $content = qq{
  <div id="container" style="width:<?dyn="width"?>px">
  <div id="header" style="background-color:#E0E0FF;">
    <table width="100%">
      <tr width="100%">
        <td><?dyn="Logo"?></td>
        <td>
          <h1 style="margin-bottom:0;"><?dyn="title"?></h1>
          User: <?dyn="user"?>
        </td>
        <td valign="top" align="right">
          <div id="login">&lt;login&gt;</div>
        </td>
      </tr>
    </table>
  </div>
  <div id="menu" style="background-color:#F0F0FF;height:<?dyn="height"?>px;width:<?dyn="menu_width"?>px;float:left;">
  &lt;wait&gt;
  </div>
  <div id="content" style="overflow:auto;background-color:#F8F8F8;width:<?dyn="content_width"?>px;float:left;">
  &lt;Content&gt;</div>
  <div id="footer" style="background-color:#E8E8FF;clear:both;text-align:center;">
  Posda.com</div>

  </div>
};
sub Content{
  my($this, $http, $dyn) = @_;
  if($this->{BadConfigFiles}) {
    return $this->RefreshEngine($http, $dyn, $bad_config);
  }
  $this->RefreshEngine($http, $dyn, $content);
}
sub width{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{width});
}
sub menu_width{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{menu_width});
}
sub content_width{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{content_width});
}
sub height{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{height});
}
sub GetHeight{
  my($this) = @_;
  return $this->{height};
}
sub GetWidth{
  my($this) = @_;
  return $this->{width};
}
sub GetJavascriptRoot{
  my($this) = @_;
  return $this->{JavascriptRoot};
}
sub BadConfigReport{
  my($this, $http, $dyn) = @_;
  for my $i (keys %{$this->{BadConfigFiles}}){
    $http->queue(
      "<tr><td>$i</td><td>$this->{BadConfigFiles}->{$i}</td></tr>");
  }
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
  my $js_file = "$this->{JavascriptRoot}/Application.js";
  unless(-f $js_file) { return }
  my $fh;
  open $fh, "<$js_file" or die "can't open $js_file";
  while(my $line = <$fh>) { $http->queue($line) }
}
sub DebugButton{
  my($this, $http, $dyn) = @_;
  if($this->CanDebug){
    $this->RefreshEngine($http, $dyn, qq{
      <span class="btn btn-sm btn-info" 
       onClick="javascript:rt('DebugWindow',
       'Refresh?obj_path=Debug',1600,1200,0);">Debug</span>
    });
  } else {
    print STDERR "Can't debug\n";
  }
}

sub MenuResponse{
  my($this, $http, $dyn) = @_;

  if($this->{Mode} eq "ScanningDir"){
    return $http->queue("busy");
  } else {
    $this->MakeMenu($http, $dyn,
      [
        { type => "host_link_sync",
          condition => 1,
          style => "large",
          caption => "New Scan",
          method => "NewScan",
          sync => "Update();",
        },
      ]
    );
  }
}

sub NewScan{
  my($this, $http, $dyn) = @_;
  # Reset the scan and move back to the Selection screen

  $this->{Mode} = "Selection";
  $this->{FoundFiles} = [];

  $this->AutoRefresh;
}

sub ContentResponse{
  my($this, $http, $dyn) = @_;
  DEBUG "ContentResponse called";
  if($this->{Mode} eq "ScanningDir"){
    return $http->queue("busy");
  }
  if($this->{Mode} eq "Selection"){
    $this->RefreshEngine($http, $dyn, qq{
      <div class="form-group">
        <label>Select a Collection</label>
        <?dyn="CollectionDropDown"?>
      </div>
      <?dyn="SummarizeSelection"?>
    });
    return;
  }

  if($this->{Mode} eq "ProcessingDirectories"){
    my $to_process = @{$this->{DirList}};
    my $processed = @{$this->{DirectoriesProcessed}};
    my $in_process = keys %{$this->{DirectoriesInProcess}};
    my $files_found = scalar @{$this->{FoundFiles}};
    $http->queue(qq{
      <h3>Scanning Directories for files with DICOM Meta Headers</h3> 
      <table class="table" style="width: 45%">
      <tr>
        <td>Waiting directories:</td>
        <td>$to_process</td>
      </tr>
      <tr> 
        <td>Processed directories:</td>
        <td>$processed</td>
      </tr> 
        <td>Directories in process:</td>
        <td>$in_process</td>
      </tr> 
        <td>DICOM files found:</td>
        <td align="left">$files_found</td>
      </tr> 
      </table>
    });
    return;
  }

  if($this->{Mode} eq "ProcessingComplete"){
    # TODO: Should the Download button just be in the menu bar?
    #
    # Note: The download link is a link rather than a SimpleButton, 
    # because we want to avoid doing an AJAX call, but a direct call!
    $this->RefreshEngine($http, $dyn, qq{
      <h3>Files Found</h3> 
      <a class="btn btn-sm btn-primary" href="DownloadCSV?obj_path=$this->{path}\">Download CSV</a>
      <table class="table" style="width: 65%">
      <tr>
          <th>Subject</th> 
          <th>File Type</th>
          <th>Number Files</th>
      </tr>
    });
    # build list of all subjects and their counts
    # Subject, File Type, File Count (distinct sop uid)

    $this->{SubjectList} = {};

    for my $file (@{$this->{FoundFiles}}) {
      my $subj = $file->{subject};
      my $ftype = $file->{abs_stx};
      my $sop_inst = $file->{sop_inst};

      if (not defined $this->{SubjectList}->{$subj}) {
        $this->{SubjectList}->{$subj} = {};
      }

      # Collect the distinct list of sop instances
      # if (not defined $this->{SubjectList}->{$subj}->{$ftype}) {
      #   $this->{SubjectList}->{$subj}->{$ftype} = {};
      # }
      $this->{SubjectList}->{$subj}->{$ftype}->{$sop_inst} = 1;
    }

    for my $subject (sort keys %{$this->{SubjectList}}) {
      $http->queue("<tr><td colspan='3'>$subject</td></tr>");

      for my $ftype (keys %{$this->{SubjectList}->{$subject}}) {
        my $name = $this->{DataDict}->GetSopClName($ftype);
        my $count = keys %{$this->{SubjectList}->{$subject}->{$ftype}};
        $http->queue(qq{
          <tr>
            <td></td>
            <td>$name</td>
            <td>$count</td>
          </tr>
        });
      }
    }
    $http->queue('</table>');
    return;
  }
}
sub DownloadCSV{
  my($this, $http, $dyn) = @_;
  DEBUG "Generating CSV";
  $http->DownloadHeader("text/csv", "CountGetter.csv");

  $http->queue("Subject,File Type,Count\n");

  for my $subject (sort keys %{$this->{SubjectList}}) {
    for my $ftype (sort keys %{$this->{SubjectList}->{$subject}}) {
      my $name = $this->{DataDict}->GetSopClName($ftype);
      my $count = keys %{$this->{SubjectList}->{$subject}->{$ftype}};

      $http->queue("$subject,$name,$count\n");
    }
  }
}

sub CollectionDropDown{
  my($this, $http, $dyn) = @_;
  $this->SelectDelegateByValue($http, {
    op => "SelectCollection",
    sync => "Update();",
  });
  my @collections = sort keys %{$this->{Collections}};
  for my $col ("none", @collections){
    $http->queue("<option value=\"$col\"" .
      ($col eq $this->{SelectedCollection} ? " selected" : "") .
      ">$col</option>");
  }
  $http->queue("</select>");
  if($this->{SelectedCollection} ne "none"){
    $this->SiteDropDown($http, $dyn);
  }
}
sub SelectCollection{
  my($this, $http, $dyn) = @_;
  if(
    $dyn->{value} eq "none" ||
    (
      $dyn->{value} ne $this->{SelectedCollection} &&
      $this->{SelectedCollection} ne "none"
    )
  ){
    $this->{SelectedSite} = "none";
    $this->{SelectedSubj} = "none";
    $this->{SelectedDir} = "none";
  }
  $this->{SelectedCollection} = $dyn->{value};
}
sub SiteDropDown{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn, 
  ' Select Site: <?dyn="SelectDelegateByValue" ' .
  'op="SelectSite" ' .
  'sync="Update();"?>');
  my @sites = sort keys %{$this->{Collections}->{$this->{SelectedCollection}}};
  for my $site ("none", @sites){
    $http->queue("<option value=\"$site\"" .
      ($site eq $this->{SelectedSite} ? " selected" : "") .
      ">$site</option>");
  }
  $http->queue("</select>");
  if($this->{SelectedSite} ne "none"){
    $this->SubjDropDown($http, $dyn);
  }
}
sub SelectSite{
  my($this, $http, $dyn) = @_;
  if(
    $dyn->{value} eq "none" ||
    (
      $dyn->{value} ne $this->{SelectedSite} &&
      $this->{SelectedSite} ne "none"
    )
  ){
    $this->{SelectedSubj} = "none";
    $this->{SelectedDir} = "none";
  }
  $this->{SelectedSite} = $dyn->{value};
}
sub SubjDropDown{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn, 
  ' Select Subject: <?dyn="SelectDelegateByValue" ' .
  'op="SelectSubj" ' .
  'sync="Update();"?>');
  my @subjs = sort keys 
    %{
      $this->{Collections}->{$this->{SelectedCollection}}
        ->{$this->{SelectedSite}}
    };
  for my $subj ("none", @subjs){
    $http->queue("<option value=\"$subj\"" .
      ($subj eq $this->{SelectedSubj} ? " selected" : "") .
      ">$subj</option>");
  }
  $http->queue("</select>");
  if($this->{SelectedSubj} ne "none"){
    $this->DirDropDown($http, $dyn);
  }
}
sub SelectSubj{
  my($this, $http, $dyn) = @_;
  if(
    $dyn->{value} eq "none" ||
    (
      $dyn->{value} ne $this->{SelectedSubj} &&
      $this->{SelectedSubj} ne "none"
    )
  ){
    $this->{SelectedDir} = "none";
  }
  $this->{SelectedSubj} = $dyn->{value};
}
sub DirDropDown{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn, 
  ' Select Directory: <?dyn="SelectDelegateByValue" ' .
  'op="SelectDir" ' .
  'sync="Update();"?>');
  my @dirs = sort keys 
    %{
      $this->{Collections}->{$this->{SelectedCollection}}
        ->{$this->{SelectedSite}}->{$this->{SelectedSubj}}
    };
  for my $dir ("none", @dirs){
    $http->queue("<option value=\"$dir\"" .
      ($dir eq $this->{SelectedDir} ? " selected" : "") .
      ">$dir</option>");
  }
  $http->queue("</select>");
}
sub SelectDir{
  my($this, $http, $dyn) = @_;
  $this->{SelectedDir} = $dyn->{value};
}

sub SummarizeSelection{
  my($this, $http, $dyn) = @_;
  my $num_colls = 0;
  my $num_sites = 0;
  my $num_subj = 0;
  my $num_dirs = 0;
  my @colls;
  my @all_dirs;
  if($this->{SelectedCollection} eq "none"){
    @colls = keys %{$this->{Collections}};
  } else {
    push @colls, $this->{SelectedCollection};
  }
  for my $coll (@colls){
    $num_colls += 1;
    my @sites;
    if($this->{SelectedSite} eq "none"){
      @sites = keys %{$this->{Collections}->{$coll}};
    } else {
      push @sites, $this->{SelectedSite};
    }
    for my $site (@sites){
      $num_sites += 1;
      my @subjs;
      if($this->{SelectedSubj} eq "none"){
        @subjs = keys %{$this->{Collections}->{$coll}->{$site}};
      } else {
        push @subjs, $this->{SelectedSubj};
      }
      for my $subj (@subjs){
        $num_subj += 1;
        my @dirs;
        if($this->{SelectedDir} eq "none"){
          @dirs = keys %{$this->{Collections}->{$coll}->{$site}->{$subj}};
        } else {
          push @dirs, $this->{SelectedDir};
        }
        for my $dir (@dirs){
          $num_dirs += 1;
          push @all_dirs, "$this->{Environment}->{SubmissionRoot}/$dir";
        }
      }
    }
  }
  $this->{DirList} = \@all_dirs;
  $this->RefreshEngine($http, $dyn, qq{
    <p>Current Selection:<p>
    <table class="table" style="width: 65%">
        <tr> 
            <th>Num dirs</th>
            <th>Num Subjects</th>
            <th>Num Sites</th> 
            <th>Num Collections</th>
        </tr>
        <tr> 
            <td>$num_dirs</td>
            <td>$num_subj</td> 
            <td>$num_sites</td>
            <td>$num_colls</td>
        </tr>
    </table> 

    <div class="row">
    <div class="panel panel-default" style="width: 25%">
      <div class="panel-heading">Limit by date range</div>
      <div class="panel-body">
      <label for="startdate">Start Date:</label>
      <?dyn="EntryBox" op="StartDateChange" name="startdate" default="$this->{SelectedStartDate}" class="datepicker form-control"?>
      <label for="enddate">End Date:</label>
      <?dyn="EntryBox" op="EndDateChange" name="enddate" default="$this->{SelectedEndDate}" class="datepicker form-control"?>
      </div>
    </div>
    </div>

    <?dyn="NotSoSimpleButton" op="AddDirectoriesForAnalysis" caption="Count These Directories" sync="Update();" class="btn btn-primary"?>
  });
}

sub StartDateChange {
  my($this, $http, $dyn) = @_;
  $this->{SelectedStartDate} = $dyn->{value};
  $this->UpdateDateRange();

}
sub EndDateChange {
  my($this, $http, $dyn) = @_;
  $this->{SelectedEndDate} = $dyn->{value};
  $this->UpdateDateRange();
}
sub UpdateDateRange {
  my($this) = @_;
  my $start = Time::Piece->strptime($this->{SelectedStartDate}, "%m/%d/%Y");
  my $end = Time::Piece->strptime($this->{SelectedEndDate}, "%m/%d/%Y");

  $this->{SearchDateRange} = [$start->epoch, $end->epoch];
}

sub AddDirectoriesForAnalysis{
  my($this, $http, $dyn) = @_;
  $this->{DirectoriesProcessed} = [];
  $this->{DirectoriesInProcess} = {};
  $this->{Mode} = "ProcessingDirectories";
  $this->CrankNextDirectory;
}

sub CrankNextDirectory{
  my($this) = @_;
  my $to_process = @{$this->{DirList}};
  my $processed = @{$this->{DirectoriesProcessed}};
  my $in_process = keys %{$this->{DirectoriesInProcess}};
  while( $to_process > 0 && $in_process < 5){
    my $next = shift(@{$this->{DirList}});
    $this->{DirectoriesInProcess}->{$next} = 1;
    $to_process = @{$this->{DirList}};
    $processed = @{$this->{DirectoriesProcessed}};
    $in_process = keys %{$this->{DirectoriesInProcess}};
    Dispatch::LineReader->new_cmd("CollectMetaHeaders.pl \"$next\"",
      $this->CollectMetaHeaderLine($next),
      $this->EndMetaHeaderLines($next));
  }
  if($to_process == 0 && $in_process == 0){
    $this->{Mode} = "ProcessingComplete";
    $this->{PresentationContexts} = [];
    $this->{PresentationContextCounts} = [];
    for my $as (keys %{$this->{SopClass}}){
      for my $xs (keys %{$this->{SopClass}->{$as}}){
        DEBUG "xs is: $xs";
        push @{$this->{PresentationContexts}}, [$as, [$xs]];
        push @{$this->{PresentationContextCounts}}, 
          $this->{SopClass}->{$as}->{$xs};
      }
    }
  }
  $this->AutoRefresh;
}

sub CollectMetaHeaderLine{
  my($this, $next) = @_;
  my $file = "No file yet";
  my $subject = "No subject yet";
  my $offset = "No offset yet";
  my $length = "No length yet";
  my $sop_class = "No sop_class yet";
  my $sop_inst = "No sop_inst yet";
  my $xfr_stx = "No xfr_stx yet";
  my $sub = sub {
    my($line) = @_;
    if($line =~ /^File:\s*(.*)$/){
      $file = $1;
    # TODO: Can this be done without the extra variable?
      my @bits = split('/', $file);
      $subject = $bits[-2];
    } elsif($line =~ /^offset:\s*(.*)$/){
      $offset = $1
    } elsif($line =~ /length:\s*(.*)$/){
      $length = $1
    } elsif($line =~ /sop_class:\s*(.*)$/){
      $sop_class = $1
    } elsif($line =~ /sop_inst:\s*(.*)$/){
      $sop_inst = $1
    } elsif($line =~ /xfr_stx:\s*(.*)$/){
      $xfr_stx = $1
    } elsif($line =~ /^####/){
      my @stats = stat($file);
      my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
       $atime,$mtime,$ctime,$blksize,$blocks) = @stats;

      my ($start, $end) = @{$this->{SearchDateRange}};
      if (($start == 0 or $ctime >= $start) and 
          ($end == 0 or $ctime <= $end)) {
        push(@{$this->{FoundFiles}}, {
          file => $file,
          subject => $subject,
          xfr_stx => $xfr_stx,
          abs_stx => $sop_class,
          sop_inst => $sop_inst,
          dataset_offset => $offset,
          dataset_size => $length,
          stat => \@stats,
        });

        if(exists $this->{QTest}->{$sop_class}->{$xfr_stx}){
          $this->{QTest}->{$sop_class}->{$xfr_stx} += 1;
        } else {
          $this->{QTest}->{$sop_class}->{$xfr_stx} = 1;
        }
        if(exists $this->{SopClass}->{$sop_class}->{$xfr_stx}){
          $this->{SopClass}->{$sop_class}->{$xfr_stx} += 1;
        } else {
          $this->{SopClass}->{$sop_class}->{$xfr_stx} = 1;
        }
      }
      $file = "No file yet";
      $offset = "No offset yet";
      $length = "No length yet";
      $sop_class = "No sop_class yet";
      $sop_inst = "No sop_inst yet";
      $xfr_stx = "No xfr_stx yet";
    }
  };
  return $sub;
}

sub EndMetaHeaderLines{
  my($this, $next) = @_;
  my $sub = sub {
    delete $this->{DirectoriesInProcess}->{$next};
    push(@{$this->{DirectoriesProcessed}}, $next);
    $this->CrankNextDirectory;
  };
  return $sub;
}

1;

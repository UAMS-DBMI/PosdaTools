#!/usr/bin/perl -w
#
use strict;
use Posda::HttpApp::GenericIframe;
use FileDist::DirectorySummarizer;
use FileDist::PhiSearch;
use FileDist::StructLinkVal;
package FileDist::ViewDirectory;
use vars qw( @ISA );
@ISA = ( "Posda::HttpApp::GenericIframe", "FileDist::DirectorySummarizer" );
sub new{
  my($class, $sess, $path) = @_;
  my $this = Posda::HttpApp::GenericIframe->new($sess, $path);
  bless $this, $class;
  $this->{State} = "Initial";
  return $this;
}
my $initial_content = <<EOF;
<h3>View a directory</h3>
<?dyn="Button" op="ChooseDirectory" caption="Choose Directory"?>
EOF
my $choosing_content = <<EOF;
Choose in progress
EOF
my $analyzing_content = <<EOF;
<h3>View a directory</h3>
<small>Initializing directory (<?dyn="Dir"?>):</small><hr />
<?dyn="InitStatus"?>
</small>
EOF
my $displaying_content = <<EOF;
<h3>View a directory</h3>
<?dyn="Button" op="Reset" caption="Choose Different Directory"?>
Directory: <?dyn="Dir"?><br/>
<?dyn="Button" op="PhiSearch" caption="Search for PHI"?>
<?dyn="Button" op="ValidateSSLinkages" caption="Validate Struct Linkages"?>
<hr>
<?dyn="StudySeriesImageSelections"?>
EOF
my $unknown_content = <<EOF;
EOF
sub Content{
  my($this, $http, $dyn) = @_;
  if($this->{State} eq "Initial"){
    $this->RefreshEngine($http, $dyn, $initial_content);
  } elsif($this->{State} eq "Choosing"){
    $this->RefreshEngine($http, $dyn, $choosing_content);
  } elsif($this->{State} eq "Analyzing"){
    $this->RefreshEngine($http, $dyn, $analyzing_content);
  } elsif($this->{State} eq "Displaying"){
    $this->RefreshEngine($http, $dyn, $displaying_content);
  } else {
    $this->RefreshEngine($http, $dyn, $unknown_content);
  }
  $this->{phi_count} = 1;
  $this->{ssv_count} = 1;
}
sub Reset{
  my($this) = @_;
  if($this->{Analyzer}) {
    $this->{Analyzer}->Abort;
    delete $this->{Analyzer};
    delete $this->{Directory};
  }
  $this->ClearSummary;
  $this->{State} = "Initial";
  $this->AutoRefresh;
}
sub AutoRefresh{
  my($this) = @_;
  $this->parent->AutoRefresh;
}
sub Dir{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{Directory});
}
sub ChooseDirectory{
  my($this, $http, $dyn) = @_;
  my $child_name = $this->child_path("DirectorySelector");
  my $sel_obj = $this->child($child_name);
  if($sel_obj) {
    print STDERR "??? DirectorySelector already exists ???";
  } else {
    $sel_obj = FileDist::DirectorySelector->new($this->{session},
      $child_name, $this->DirCallback);
  }
  $sel_obj->ReOpenFile;
}
sub DirCallback{
  my($this) = @_;
  my $sub = sub {
    my($dir) = @_;
    unless(-d $dir) { return $this->Reset }
    $this->{Directory} = $dir;
    $this->{Analyzer} = 
      FileDist::DirectoryAnalyzer->new($dir,
          $this->get_obj("FileManager"),
          $this->AnalyzeComplete
      );
    $this->{State} = "Analyzing";
    $this->AutoRefresh;
  };
  return $sub;
}
sub AnalyzeComplete{
  my($this) = @_;
  my $sub = sub {
    $this->{State} = "Displaying";
    $this->InitSummary;
    $this->AutoRefresh;
  };
  return $sub;
}
sub InitStatus{
  my($this, $http, $dyn) = @_;
  my $da = $this->{Analyzer};
  $http->queue("<small>Analyzing Dicom files in directory (" .
    "$this->{Directory}):<br />");
  if($da->InitializingState($http, $dyn)){
    $this->RefreshAfter(1);
  }
}
sub PhiSearch{
  my($this, $http, $dyn) = @_;
  my $child_name = $this->child_path("Phi_search_$this->{phi_count}");
  $this->{phi_count} += 1;
  my $phi_obj = $this->child($child_name);
  if($phi_obj) {
    print STDERR "??? already exists ????\n"
  } else {
    $phi_obj = FileDist::PhiSearch->new($this->{session}, 
      $child_name, "", $this->{DicomInfo},
      $this->{Summary});
    $phi_obj->ReOpenFile;
  }
}
sub ValidateSSLinkages{
  my($this, $http, $dyn) = @_;
  my $child_name = $this->child_path("SS_Val_$this->{ssv_count}");
  $this->{ssv_count} += 1;
  my $ssv_obj = $this->child($child_name);
  if($ssv_obj) {
    print STDERR "??? already exists ????\n"
  } else {
    $ssv_obj = FileDist::StructLinkVal->new($this->{session},
      $child_name, "", $this->{DicomInfo},
      $this->{Summary});
    $ssv_obj->ReOpenFile;
  }
}
1;

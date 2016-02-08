#!/usr/bin/perl -w
#
use strict;
use Posda::HttpApp::GenericMfWindow;
use Posda::HttpApp::HttpObj;
use Posda::HttpApp::SubController;
use Posda::HttpApp::WindowButtons;
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
  package FileDist::EditDestinationCreator;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericMfWindow" );
  sub new {
    my($class, $sess, $path, $callback, $from_directory) = @_;
    my $this = Posda::HttpApp::GenericMfWindow->new($sess, $path);
    $this->{title} = "Create Dicom Edit Destination";
    bless $this, $class;
    $this->{w} = 900;
    $this->{h} = 600;
    Posda::HttpApp::SubController->new($this->{session}, 
      $this->child_path("Controller"));
    Posda::HttpApp::WindowButtons->new($this->{session},
      $this->child_path("WindowButtons"));
    FileDist::EditDestinationCreator::Content->new(
        $this->{session}, $this->child_path("Content"), $callback);
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
  package FileDist::EditDestinationCreator::Content;
  use File::Path qw (remove_tree);
  use Posda::HttpApp::GenericIframe;
  use Storable qw( fd_retrieve );
  $Storable::interwork_56_64bit = 1;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericIframe" );
  sub new{
    my($class, $sess, $path, $callback, $from_directory) = @_;
    my $this = Posda::HttpApp::GenericIframe->new($sess, $path);
    $this->{from_directory} = $from_directory;
    bless $this, $class;
    $this->{Exports}->{ExportModeChanged} = 1;
    $this->{callback} = $callback;
    my $env_config = $main::HTTP_APP_CONFIG->{config}->{Environment};
    $this->AutoRefresh;
    return $this;
  }
  sub ExpertModeChanged{
    my($this) = @_;
    $this->AutoRefresh;
  }
  sub Content{
    my($this, $http, $dyn) = @_;
    my $user = $this->get_user;
    my @participant_list = sort keys
      %{$main::HTTP_APP_CONFIG->{config}
        ->{Capabilities}->{$user}->{ParticipantAccess}};
    $this->{temp_root} = 
      $main::HTTP_APP_CONFIG->{config}->{Environment}->{TempDataRoot};
    $dyn->{participant_list} = \@participant_list;
    $this->RefreshEngine($http, $dyn,
      'Select a Participant: ' .
      '<?dyn="SelectNsByValue" op="SelectParticipant"?>' .
      '<?dyn="DropDown"?></select>' . 
      '<?dyn="Category"?>');
  }
  sub DropDown{
    my($this, $http, $dyn) = @_;
    unless(exists $this->{SelectedParticipant}){
      $this->{SelectedParticipant} = "-- select --";
    }
    for my $i ("-- select --", @{$dyn->{participant_list}}){
      $http->queue("<option value=\"$i\"" .
        ($this->{SelectedParticipant} eq $i ? " selected" : "") .
        ">$i</option>");
    }
  }
  sub SelectParticipant{
    my($this, $http, $dyn) = @_;
    my $participant = $dyn->{value};
    $this->{SelectedParticipant} = $participant;
    unless(-d $this->{temp_root}){
      my $count = mkdir $this->{temp_root};
      unless($count == 1){
        print STDERR "mkdir of $this->{temp_root} returned $count\n";
      }
      unless(-d $this->{temp_root}) { die "can't makdir $this->{temp_root}" }
    }
    my $parc_dir = "$this->{temp_root}/$participant";
    unless(-d $parc_dir){
      my $count = mkdir $parc_dir;
      unless($count == 1){
        print STDERR "mkdir of $parc_dir returned $count\n";
      }
      unless(-d $parc_dir) { die "can't makdir $parc_dir" }
    }
    $this->{parc_dir} = $parc_dir;
    $this->AutoRefresh;
  }
  sub Category{
    my($this, $http, $dyn) = @_;
    unless(defined $this->{parc_dir}) { return }
    opendir(DIR, $this->{parc_dir});
    my @cats;
    while (my $f = readdir(DIR)){
      if($f =~ /^\./){ next }
      unless(-d "$this->{parc_dir}/$f"){ next }
      push @cats, $f;
    }
    $dyn->{categories} = \@cats;
    if(scalar @cats){
      $this->RefreshEngine($http, $dyn,
        ' Select a category: ' .
        '<?dyn="SelectNsByValue" op="SelectCategory"?>' .
        '<?dyn="CatDropDown"?></select>, or ' .
        '<?dyn="Button" op="EnterNewCategory" caption="Enter new category"?>' .
        ': <?dyn="InputChangeNoReload" field="NewCategory"?>'
      );
    } else {
      $this->RefreshEngine($http, $dyn,
        '<?dyn="Button" op="EnterNewCategory" caption="Enter new category"?>' .
        ': <?dyn="InputChangeNoReload" field="NewCategory"?>'
      );
    }
  }
  sub CatDropDown{
    my($this, $http, $dyn) = @_;
    unless(exists $this->{SelectedCategory}){
      $this->{SelectedCategory} = "-- select --";
    }
    for my $i ("-- select --", @{$dyn->{categories}}){
      $http->queue("<option value=\"$i\"" .
        ($this->{SelectedCategory} eq $i ? " selected" : "") .
        ">$i</option>");
    }
  }
  sub SelectCategory{
    my($this, $http, $dyn) = @_;
    my $cat = $dyn->{value};
    my $root_dir = "$this->{parc_dir}/$cat";
    unless(-d $root_dir) { die "$root_dir doesn't exist" }
    $this->ReturnDirectory($root_dir);
  }
  sub EnterNewCategory{
    my($this, $http, $dyn) = @_;
    my $root_dir = "$this->{parc_dir}/$this->{NewCategory}";
    unless(-d $root_dir){
      my $count = mkdir $root_dir;
      unless($count == 1){
        print STDERR "mkdir of $root_dir returned $count\n";
      }
      unless(-d $root_dir) { die "can't makdir $root_dir" }
    }
    $this->ReturnDirectory($root_dir);
  }
  sub ReturnDirectory{
    my($this, $root_dir) = @_;
    my $now_dir = $this->now_dir;
    my $directory = "$root_dir/$now_dir";;
    my $inc = 0;
    while(-d "$directory"){
      $inc += 1;
      $directory = "$root_dir/$now_dir.$inc";
    }
    unless(-d $directory){
      my $count = mkdir $directory;
      unless($count == 1){
        print STDERR "mkdir of $directory returned $count\n";
      }
      unless(-d $directory) { die "can't makdir $directory" }
    }
    my $dir_desc = {
      directory => $directory,
      user => $this->get_user,
      source => $this->{from_directory},
      start_edit_time => time,
    };
    &{$this->{callback}}($dir_desc);
    delete $this->{callback};
    $this->CloseWindow;
  }
  sub CleanUp{
    my($this) = @_;
    print STDERR "Cleanup called $this->{path}\n";
  }
  sub DESTROY{
    my($this) = @_;
    print STDERR "Destroying $this->{path}\n";
  }
}
1;

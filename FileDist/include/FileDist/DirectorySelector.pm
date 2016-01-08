#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/FileDist/include/FileDist/DirectorySelector.pm,v $
#$Date: 2015/03/06 13:46:50 $
#$Revision: 1.14 $
#
use strict;
use Posda::HttpApp::GenericMfWindow;
use Posda::HttpApp::HttpObj;
use Posda::HttpApp::SubController;
use Posda::HttpApp::WindowButtons;
use FileDist::SessionInfo;
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
  package FileDist::DirectorySelector;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericMfWindow" );
  sub new {
    my($class, $sess, $path, $callback) = @_;
    my $this = Posda::HttpApp::GenericMfWindow->new($sess, $path);
    $this->{title} = "Directory Selection";
    bless $this, $class;
    $this->{w} = 900;
    $this->{h} = 600;
    Posda::HttpApp::SubController->new($this->{session}, 
      $this->child_path("Controller"));
    Posda::HttpApp::WindowButtons->new($this->{session},
      $this->child_path("WindowButtons"));
    FileDist::DirectorySelector::Content->new(
        $this->{session}, $this->child_path("Content"), $callback);
    $this->ReOpenFile();
    $this->{seq} = 1;
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
  package FileDist::DirectorySelector::Content;
  use File::Path qw (remove_tree);
  use Posda::HttpApp::GenericIframe;
  use Storable qw( fd_retrieve );
  $Storable::interwork_56_64bit = 1;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericIframe" );
  sub new{
    my($class, $sess, $path, $callback) = @_;
    my $this = Posda::HttpApp::GenericIframe->new($sess, $path);
    bless $this, $class;
    $this->{Exports}->{ExportModeChanged} = 1;
    $this->{callback} = $callback;
    my $env_config = $main::HTTP_APP_CONFIG->{config}->{Environment};
    $this->{DirectoryTypes} = {
      "Received Dicom Data" => $env_config->{ReceiverDataRoot},
      "Dicom Test Data" => $env_config->{TestDataRoot},
      "Anonymized Participant Test Data" => $env_config->{ParticipantDataRoot},
      "Participant Results Data" => $env_config->{ParticipantResultsRoot},
      "Participant Temp Data" => $env_config->{TempDataRoot},
    };
    $this->{SelectedDirectoryType} = "-- select --";
    $this->AutoRefresh;
    return $this;
  }
  sub ExpertModeChanged{
    my($this) = @_;
    $this->AutoRefresh;
  }
  sub Reset{
    my($this, $http, $dyn) = @_;
    $this->{SelectedDirectoryType} = "-- select --";
    $this->AutoRefresh;
  }
  sub Content{
    my($this, $http, $dyn) = @_;
    if($this->{SelectedDirectoryType} eq "-- select --"){
      return $this->SelectDirectoryType($http, $dyn);
    } else {
      $this->RefreshEngine($http, $dyn,
        "<small>Selected Directory Type: $this->{SelectedDirectoryType}<br>" .
        "Selected Directory: $this->{SelectedDirectory}</small><br>" .
        '<?dyn="Button" caption="Reset" op="Reset"?><hr>');
    }
    if($this->{SelectedDirectoryType} eq "Received Dicom Data"){
      $this->ReceivedDicomData($http, $dyn);
    } elsif(
      $this->{SelectedDirectoryType} eq "Anonymized Participant Test Data"
    ){
      $this->AnonymizedData($http, $dyn);
    } elsif($this->{SelectedDirectoryType} eq "Participant Results Data"){
      $this->ParticipantResultsData($http, $dyn);
    } elsif($this->{SelectedDirectoryType} eq "Dicom Test Data"){
      $this->DicomTestData($http, $dyn);
    } elsif($this->{SelectedDirectoryType} eq "Participant Temp Data"){
      $this->ParticipantTempData($http, $dyn);
    } else {
      $http->queue("Unknown Directory Type: $this->{SelectedDirectoryType}");
    }
  }
  sub SelectDirectoryType{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn,
      'Select Directory Type: ' .
      '<?dyn="SelectNsByValue" op="SelectDirType"?><?dyn="DirTypeDropDown"?>' .
      '</select>'
    );
  }
  sub DirTypeDropDown{
    my($this, $http, $dyn) = @_;
    for my $i (
      "-- select --", "Received Dicom Data", "Anonymized Participant Test Data",
      "Participant Results Data", "Dicom Test Data", "Participant Temp Data",
    ){
      $http->queue("<option value=\"$i\"" .
        ($this->{SelectedDirectoryType} eq $i ? " selected" : "") .
        ">$i</option>");
    }
  }
  sub SelectDirType{
    my($this, $http, $dyn) = @_;
    $this->{SelectedDirectoryType} = $dyn->{value};
    $this->{SelectedDirectory} = $this->{DirectoryTypes}->{$dyn->{value}};
    $this->AutoRefresh;
  }
  #############################
  #  Received Dicom Data Directories
  #############################
  sub ReceivedDicomData{
    my($this, $http, $dyn) = @_;
    my @called_list;
    if(-d $this->{SelectedDirectory}) {
      $this->RefreshEngine($http, $dyn, 
        '<?dyn="CalledAe"?>' .
        '<?dyn="CallingAe"?>' .
        '<?dyn="AssociationId"?>');
    } else {
      $this->RefreshEngine($http, $dyn,
        "Error: $this->{SelectedDirectory} doesn't exist");
    }
  }
  sub CalledAe{
    my($this, $http, $dyn) = @_;
    opendir DIR, "$this->{SelectedDirectory}";
    my @called_aes;
    while(my $d = readdir(DIR)){
      unless(-d "$this->{SelectedDirectory}/$d"){ next }
      if($d =~ /^\./) { next }
      push(@called_aes, $d);
    }
    closedir DIR;
    $this->RefreshEngine($http, $dyn, 'Selected Called AE Title: ' .
      '<?dyn="SelectNsByValue" op="SelectCalledAe"?>');
    unless(defined($this->{SelectedCalledAeTitle}) &&
      -d "$this->{SelectedDirectory}/$this->{SelectedCalledAeTitle}"
    ){  $this->{SelectedCalledAeTitle} = $called_aes[0] }
    for my $ae (@called_aes){
      $http->queue("<option value=\"$ae\"" .
        ($ae eq $this->{SelectedCalledAeTitle} ? " selected" : "") .
        ">$ae</option>");
    }
    $http->queue("</select>");
  }
  sub SelectCalledAe{
    my($this, $http, $dyn) = @_;
    $this->{SelectedCalledAeTitle} = $dyn->{value};
    $this->AutoRefresh;
  }
  sub CallingAe{
    my($this, $http, $dyn) = @_;
    delete $this->{CombineDirs};
    my $wd = "$this->{SelectedDirectory}/$this->{SelectedCalledAeTitle}";
    unless(-d $wd){ return }
    opendir DIR, $wd;
    my @calling_aes;
    while(my $d = readdir(DIR)){
      unless(-d "$wd/$d"){ next }
      if($d =~ /^\./) { next }
      push(@calling_aes, $d);
    }
    closedir DIR;
    $this->RefreshEngine($http, $dyn, 'Select Calling AE Title: ' .
      '<?dyn="SelectNsByValue" op="SelectCallingAe"?>');
    unless(defined($this->{SelectedCallingAeTitle}) &&
      -d "$wd/$this->{SelectedCallingAeTitle}"
    ){  $this->{SelectedCallingAeTitle} = $calling_aes[0] }
    for my $ae (@calling_aes){
      $http->queue("<option value=\"$ae\"" .
        ($ae eq $this->{SelectedCallingAeTitle} ? " selected" : "") .
        ">$ae</option>");
    }
    $http->queue("</select>");
  }
  sub SelectCallingAe{
    my($this, $http, $dyn) = @_;
    $this->{SelectedCallingAeTitle} = $dyn->{value};
    $this->AutoRefresh;
  }
  sub AssociationId{
    my($this, $http, $dyn) = @_;
    my $wd = "$this->{SelectedDirectory}/$this->{SelectedCalledAeTitle}/" .
      $this->{SelectedCallingAeTitle};
    unless(-d $wd){ return }
    my @dirs;
    opendir DIR, $wd;
    while(my $d = readdir(DIR)){
      unless(-d "$wd/$d"){ next }
      if($d =~ /^\./) { next }
      my($ip, $yr, $mo, $da, $hr, $min, $sec, $seq);
      if($d =~ /^(.*)-(....)-(..)-(..)_(..)_(..)_(..)$/){
        $ip = $1;
        $yr = $2;
        $mo = $3;
        $da = $4;
        $hr = $5;
        $min = $6;
        $sec = $7;
        $seq = 0;
      } elsif($d =~ /(.*)-(....)-(..)-(..)_(..)_(..)_(..)_(.*)$/){
        $ip = $1;
        $yr = $2;
        $mo = $3;
        $da = $4;
        $hr = $5;
        $min = $6;
        $sec = $7;
        $seq = $8;
      } else { next }
      my $session_info_file = "$wd/$d/Session.info";
      unless(-f $session_info_file) { $session_info_file = "---" }
      push(@dirs, {
        date => "$yr-$mo-$da",
        tm => "$hr:$min:$sec.$seq",
        ip_addr => $ip,
        dir => "$wd/$d",
        session_info => $session_info_file,
      });
    }
    $this->RefreshEngine($http, $dyn, 
      '<table border="1"><tr><th>Date</th><th>time</th>' .
      '<th>From ip address</th><th>info</th><th>op</th>' .
      '<th><?dyn="Button" op="CombineAssociations" ' .
      'caption="Combine"?></th>' .
      '</tr>');
    for my $i (
      sort {
        $b->{date} cmp $a->{date} ||
        $b->{tm} cmp $a->{tm}
      }
      @dirs
    ){
      unless(exists $this->{CombineDirs}->{$i->{dir}}){
        $this->{CombineDirs}->{$i->{dir}} = "not_checked";
      }
      $http->queue("<tr><td>$i->{date}</td><td>$i->{tm}</td>" .
        "<td>$i->{ip_addr}</td><td>");
      if(-f $i->{session_info}){
        $dyn->{session_info_file} = $i->{session_info};
        $dyn->{op} = "SelectSession";
        $dyn->{caption} = "Select";
        $dyn->{index} = $i->{dir};
        $this->RefreshEngine($http, $dyn,
          '<?dyn="SessionInfo"?></td><td><?dyn="Button"?>');
        $dyn->{op} = "ShowSessionInfo";
        $dyn->{caption} = "Info";
        $dyn->{index} = $i->{dir};
        $this->RefreshEngine($http, $dyn,
          '<?dyn="Button"?>');
        $dyn->{caption} = "Delete";
        $dyn->{op} = "DeleteSessionDir";
        $this->RefreshEngine($http, $dyn,
          '<?dyn="Button"?></td><td align="center">' .
          '<?dyn="CheckBoxNs" name="CombineDirs"' .
          ' op="SetCheckBoxValue" ' .
          ' index="' . $i->{dir} . '"?>');
      } else { $http->queue("----</td><td>----</td>") }
      $http->queue("</tr>");
    }
    $http->queue("</table>");
  }
  sub ShowSessionInfo {
    my($this, $http, $dyn) = @_;
    my $dir = $dyn->{index};
    my $file = "$dir/Session.info";
    my $child_name = "session_info_$this->{seq}";
    $this->{seq} += 1;
    FileDist::SessionInfo->new(
        $this->{session}, $this->child_path($child_name), $file);
  }
  sub SelectSession{
    my($this, $http, $dyn) = @_;
    &{$this->{callback}}($dyn->{index});
    delete $this->{callback};
    $this->CloseWindow;
    print STDERR "Selecting Directory: $dyn->{index}\n";
  }
  sub DeleteSessionDir{
    my($this, $http, $dyn) = @_;
    print STDERR "Deleting Directory: $dyn->{index}\n";
    remove_tree($dyn->{index});
    $this->AutoRefresh;
  }
  sub SessionInfo{
    my($this, $http, $dyn) = @_;
    open my $fh, "RetrieveSessionInfo.pl $dyn->{session_info_file}|";
    my $data;
    eval {
      $data = fd_retrieve($fh);
    };
    if($@) {
      $http->queue("<small>error $@ getting info</small>");
      return;
    };
    if($data->{error}){
      $http->queue("<small> error $data->{error} getting info</small>");
    } else {
      my $xfr_info = "";
      if(exists $data->{termination_status}){
        $xfr_info .= "Status: $data->{termination_status}<br>";
      }
      if(
        exists($data->{xfr_stx_counts}) && 
        ref($data->{xfr_stx_counts}) eq "HASH"
      ){
        for my $xfs (keys %{$data->{xfr_stx_counts}}){
           my $dd = $Posda::Dataset::DD;
           my $xfs_name = $dd->GetXferStxName($xfs);
           $xfr_info .= "$xfs_name: " .
             $data->{xfr_stx_counts}->{$xfs} . "<br />";
        }
      }
      $http->queue("<small>$xfr_info". "$data->{info}</small>");
    }
  }
  sub CombineAssociations{
    my($this) = @_;
    my @combine_dirs;
    for my $d (keys %{$this->{CombineDirs}}){
      if($this->{CombineDirs}->{$d} eq "checked"){ push @combine_dirs, $d }
    }
    my $num_dirs = @combine_dirs;
    if($num_dirs <= 1){
      print STDERR "Need more than one Dir to combine\n";
      return;
    }
    print STDERR "Combining Directories:\n";
    for my $i (@combine_dirs) {
      print STDERR "\t$i\n";
    }
    my $wd = "$this->{SelectedDirectory}/$this->{SelectedCalledAeTitle}/" .
      $this->{SelectedCallingAeTitle};
    my $new_dir = "$wd/combined-" . $this->now_dir;
    unless(mkdir($new_dir) == 1){
      print STDERR "Problem making new directory: $new_dir\n";
      return;
    }
    print STDERR "New Directory: $new_dir\n";
    my $session_info = {
      start => time,
      host => "combine",
      num_dirs => $num_dirs,
      files => [],
    };
    dir:
    for my $od (@combine_dirs) {
      unless(-f "$od/Session.info") { next dir }
      my $fh;
      unless(open $fh, "<$od/Session.info"){
        print STDERR "Can't open $od/Session.info\n";
        next file;
      }
      line:
      while(my $line = <$fh>){
        chomp $line;
        my @fields = split(/\|/, $line);
        unless($fields[0] eq "file"){ next line }
        my $sc = $fields[1];
        my $uid = $fields[2];
        my $xf = $fields[3];
        my $old_file = $fields[4];
        unless($old_file =~ /^(.*)\/([^\/]+)$/){
          print STDERR "Non matching file: $old_file\n";
          next line;
        }
        my $fname = $2;
        my $new_file = "$new_dir/$fname";
        if(link $old_file, $new_file){
          push(@{$session_info->{files}}, {
            sop_class => $sc,
            sop_uid => $uid,
            xfr_stx => $xf,
            file_name => $new_file,
          });
        } else {
          print STDERR "Unable to link $old_file, $new_file\n";
        }
      }
      close $fh;
      print STDERR "Deleting Directory: $od\n";
      remove_tree($od);
    }
    open my $fh, ">$new_dir/Session.info";
    print $fh "start time => $session_info->{start}\n";
    print $fh "host => $session_info->{host}\n";
    print $fh "number of combined dirs => $session_info->{num_dirs}\n";
    for my $f (@{$session_info->{files}}){
      print $fh "file|$f->{sop_class}|$f->{sop_uid}|" .
        "$f->{xfr_stx}|$f->{file_name}\n";
    }
    close $fh;
    $this->AutoRefresh;
  }
  #############################
  #  Anonymized Participant Data Directories
  #############################
  sub AnonymizedData{
    my($this, $http, $dyn) = @_;
    opendir DIR, $this->{SelectedDirectory} or 
      die "Can't opendir $this->{SelectedDirectory}";
    item:
    while(my $f = readdir(DIR)){
      if($f =~ /^\./) { next item }
      unless(-d "$this->{SelectedDirectory}/$f") { next item }
      unless($f =~ /^(....)(..)(.)(..)(.*)$/) { 
        print STDERR "non-matching Anonymized Data dir: $f\n";
        next item;
      }
      my $profile = $1;
      my $yr = "20$2";
      my $yc = $2;
      my $event_type = $3;
      my $test_id = $4;
      my $participant = $5;
      my $dataset = "$profile$yc$event_type$test_id";
      $this->{AnonymizedSelections}->{$dataset}->{$participant} = 1;
    }
    closedir DIR;
    unless(
      defined $this->{SelectedDataset} && 
      exists $this->{AnonymizedSelections}->{$this->{SelectedDataset}}
    ){  $this->{SelectedDataset} = "-- select --" }
    $this->RefreshEngine($http, $dyn, 
      'Select Datset Type: ' .
      '<?dyn="SelectNsByValue" op="SelectDataset"?><?dyn="DatasetDropDown"?>' .
      '</select>'
    );
    if(
      defined $this->{SelectedDataset} && 
      exists $this->{AnonymizedSelections}->{$this->{SelectedDataset}}
    ){
      unless(
        defined $this->{SelectedParticipant} && 
        exists $this->{AnonymizedSelections}->{$this->{SelectedDataset}}
          ->{$this->{SelectedParticipant}}
      ){  $this->{SelectedParticipant} = "-- select --" }
      $dyn->{DropDownList} = 
        $this->{AnonymizedSelections}->{$this->{SelectedDataset}};
      $this->RefreshEngine($http, $dyn, 
        'Select Participant: ' .
        '<?dyn="SelectNsByValue" op="SelectPartic"?><?dyn="ParticDropDown"?>' .
        '</select>'
      );
    }
  }
  sub DatasetDropDown{
    my($this, $http, $dyn) = @_;
    for my $i (
      "-- select --", sort keys %{$this->{AnonymizedSelections}}
    ){
      $http->queue("<option value=\"$i\"" .
        ($this->{SelectedDataset} eq $i ? " selected" : "") .
        ">$i</option>");
    }
  }
  sub SelectDataset{
    my($this, $http, $dyn) = @_;
    $this->{SelectedDataset} = $dyn->{value};
    $this->AutoRefresh;
  }
  sub ParticDropDown{
    my($this, $http, $dyn) = @_;
    for my $i (
      "-- select --",
      sort keys %{$dyn->{DropDownList}}
    ){
      $http->queue("<option value=\"$i\"" .
        ($this->{SelectedParticipant} eq $i ? " selected" : "") .
        ">$i</option>");
    }
  }
  sub SelectPartic{
    my($this, $http, $dyn) = @_;
    $this->{SelectedParticipant} = $dyn->{value};
    my $directory = "$this->{SelectedDirectory}/$this->{SelectedDataset}" .
      "$this->{SelectedParticipant}";
    &{$this->{callback}}($directory);
    delete $this->{callback};
    $this->CloseWindow;
  }
  #############################
  #  Participant Results Directories
  #############################
  sub ParticipantResultsData{
    my($this, $http, $dyn) = @_;
  }
  #############################
  #  Dicom Test Data Directories
  #############################
  sub DicomTestData{
    my($this, $http, $dyn) = @_;
    my @datasets;
    opendir DIR, "$this->{SelectedDirectory}";
    while(my $f = readdir(DIR)){
      if($f =~ /^\./) {next}
      unless(-d "$this->{SelectedDirectory}/$f") { next }
      push(@datasets, $f);
    }
    closedir DIR;
    $dyn->{dataset_list} = [ sort @datasets ];
    $this->RefreshEngine($http, $dyn,
      'Select an initial dataset: ' .
      '<?dyn="SelectNsByValue" op="SelectOrigDataset"?>' .
      '<?dyn="OrigDropDown"?></select>');
  }
  sub OrigDropDown{
    my($this, $http, $dyn) = @_;
    unless(exists $this->{SelectedOrigDataset}){
      $this->{SelectedOrigDataset} = "-- select --";
    }
    for my $i ("-- select --", @{$dyn->{dataset_list}}){
      $http->queue("<option value=\"$i\"" .
        ($this->{SelectedOrigDataset} eq $i ? " selected" : "") .
        ">$i</option>");
    }
  }
  sub SelectOrigDataset{
    my($this, $http, $dyn) = @_;
    $this->{SelectedOrigDataset} = $dyn->{value};
    my $directory = "$this->{SelectedDirectory}/$this->{SelectedOrigDataset}";
    &{$this->{callback}}($directory);
    delete $this->{callback};
    $this->CloseWindow;
  }
  #############################
  # Participant Temp Directories 
  #############################
  sub ParticipantTempData{
    my($this, $http, $dyn) = @_;
    my %sub_dirs;
    my @sub_dirs;
    opendir DIR, $this->{SelectedDirectory};
    while (my $sd = readdir(DIR)){
      if($sd =~ /^\./) { next }
      unless(-d "$this->{SelectedDirectory}/$sd"){ next }
      push(@sub_dirs, $sd);
      $sub_dirs{$sd} = 1;
    }
    closedir DIR;
    unless(scalar @sub_dirs){
      return $http->queue("No participants have temp directories");
    }
    unless(
      $this->{SelectedParticipant} &&
      exists $sub_dirs{$this->{SelectedParticipant}}
    ){ $this->{SelectedParticipant} = $sub_dirs[0] }
    $this->InitTempDirList;
    $dyn->{DropDownList} = \%sub_dirs;
    $this->RefreshEngine($http, $dyn, 
      'Choose Participant: ' .
      '<?dyn="SelectNsByValue" op="SelectParticTemp"?>' .
      '<?dyn="ParticDropDown"?></select>' .
      '<?dyn="CategoryList"?>'
    );
  }
  sub SelectParticTemp{
    my($this, $http, $dyn) = @_;
    $this->{SelectedParticipant} = $dyn->{value};
    $this->AutoRefresh;
  }
  sub CategoryList{
    my($this, $http, $dyn) = @_;
    my $parc_dir = "$this->{SelectedDirectory}/$this->{SelectedParticipant}";
    unless(-d $parc_dir) {
      print STDERR "WTF??? Thought I'd already checked this dir: $parc_dir\n";
      return $http->queue("Internal Error");
    }
    opendir DIR, $parc_dir;
    my %sub_dirs;
    my @sub_dirs;
    while (my $sd = readdir(DIR)){
      if($sd =~ /^\./) { next }
      unless(-d "$parc_dir/$sd"){ next }
      push(@sub_dirs, $sd);
      $sub_dirs{$sd} = 1;
    }
    closedir DIR;
    unless(scalar @sub_dirs){
      return $http->queue("Participant $this->{SelectedParticipant} has " .
        "no defined edit categories");
    }
    unless(
      $this->{SelectedCategory} && exists $sub_dirs{$this->{SelectedCategory}}
    ){ $this->{SelectedCategory} = $sub_dirs[0] }

    $this->InitTempDirList;
    $dyn->{DropDownList} = \%sub_dirs;
    $this->RefreshEngine($http, $dyn, 
      'Choose Category: ' .
      '<?dyn="SelectNsByValue" op="SelectCategory"?>' .
      '<?dyn="CatDropDown"?></select>' .
      '<hr>'.
      '<?dyn="TempDirList"?>'
    );
  }
  sub SelectCategory{
    my($this, $http, $dyn) = @_;
    $this->{SelectedCategory} = $dyn->{value};
    $this->AutoRefresh;
  }
  sub CatDropDown{
    my($this, $http, $dyn) = @_;
    for my $i (
      "-- select --",
      sort keys %{$dyn->{DropDownList}}
    ){
      $http->queue("<option value=\"$i\"" .
        ($this->{SelectedCategory} eq $i ? " selected" : "") .
        ">$i</option>");
    }
  }
  sub TempDirList{
    my($this, $http, $dyn) = @_;
    my $num_temp_dirs = @{$this->{TempDirList}};
    if($num_temp_dirs <= 0){
      return $http->queue("No temp dirs");
    }
    $http->queue("<table border><tr>" .
      "<th>i</th><th>Date</th><th>Time</th><th>User</th><th>Description</th>" .
      "</tr>");
    for my $i (0 .. $#{$this->{TempDirList}}){
      $dyn->{td_i} = $i;
      $this->TempDirRow($http, $dyn);
    }
    $http->queue("</table>");
  }
  sub TempDirRow{
    my($this, $http, $dyn) = @_;
    $http->queue("<tr>");
    my $d = $this->{TempDirList}->[$dyn->{td_i}];
    $http->queue("<td>$dyn->{td_i}</td>");
    $http->queue("<td>$d->{date}</td>");
    $http->queue("<td>$d->{time}</td>");
    $http->queue("<td>$d->{info}->{user}</td>");
    $http->queue("<td>$d->{info}->{Description}</td><td>");
    $this->RefreshEngine($http, $dyn,
      '<?dyn="Button" op="SelectThisTempDir" caption="Select" ' .
    ' index="' . $dyn->{td_i} . '"?>');
    $http->queue("</td></tr>");
  }
  sub InitTempDirList{
    my($this) = @_;
    $this->{TempDirList} = [];
    my $dir = "$this->{SelectedDirectory}/" .
      "$this->{SelectedParticipant}/$this->{SelectedCategory}";
    my @dir_list;
    opendir DIR, $dir;
    while (my $sd = readdir(DIR)){
      if($sd =~ /^\./) { next }
      unless(-d "$dir/$sd"){ next }
      push(@dir_list, $sd);
    }
    for my $temp_dir (sort @dir_list){
      unless($temp_dir =~ /^(....)-(..)-(..)_(..)_(..)_(..)$/) { next }
      my $yr = $1;
      my $mo = $2;
      my $da = $3;
      my $hr = $4;
      my $min = $5;
      my $sec = $6;
      my $date = "$yr-$mo-$da";
      my $time = "$hr:$min:$sec";
      my $path = "$dir/$temp_dir";
      my $info_file = "$path/Edit.Results";
if(-f $info_file) {
  print STDERR "About open info file: $info_file\n";
} else {
  print STDERR "About to die opening non-existent info file: $info_file\n";
}
      my $edit_info;
      if(open my $fh, "<$info_file"){
        $edit_info = fd_retrieve($fh);
      }
      push(@{$this->{TempDirList}}, {
        date => $date,
        time => $time,
        info => $edit_info,
        path => $path
      });
    }
  }
  sub SelectThisTempDir{
    my($this, $http, $dyn) = @_;
    my $descrip = $this->{TempDirList}->[$dyn->{index}];
    my $directory = $descrip->{path};
    &{$this->{callback}}($directory);
    delete $this->{callback};
    $this->CloseWindow;
  }
  sub DESTROY{
    my($this) = @_;
    print STDERR "Destroying $this->{path}\n";
  }
}
1;

#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/FileDist/include/FileDist/Anonymizer.pm,v $
#$Date: 2014/05/14 16:03:54 $
#$Revision: 1.12 $
#
use strict;
use Posda::HttpApp::GenericIframe;
use FileDist::DirectoryAnalyzer;
use FileDist::UidCollector;
use Posda::UUID;
use Posda::DataDict;
use Debug;
my $dbg = sub { print STDERR @_ };
package FileDist::Anonymizer;
use Storable qw( store_fd fd_retrieve );
use vars qw( @ISA );
@ISA = ( "Posda::HttpApp::GenericIframe", "FileDist::UidCollector" );
sub new{
  my($class, $sess, $path) = @_;
  my $this = Posda::HttpApp::GenericIframe->new($sess, $path);
  bless $this, $class;
  $this->{title} = "Anonymizer";
  $this->{Datasets} = [];
  $this->{TestDataDir} =
    $main::HTTP_APP_CONFIG->{config}->{Environment}->{TestDataRoot};
  opendir DIR, $this->{TestDataDir} or die "Can't opendir $this->{TestDataDir}";
  while(my $f = readdir(DIR)){
    if($f =~ /^\./) { next }
    unless(-d "$this->{TestDataDir}/$f") { next }
    push(@{$this->{Datasets}}, $f);
  }
  $this->{Datasets} = [sort @{$this->{Datasets}}];
  $this->{SelectedParticipant} = undef;
  $this->{parallel_count} = 2;
  if(
    exists $main::HTTP_APP_CONFIG->{config}
      ->{Environment}->{AnonymizeParallelism}
  ){
    $this->{parallel_count} = $main::HTTP_APP_CONFIG->{config}
      ->{Environment}->{AnonymizeParallelism};
  }
#### Comment next line out - for debug only
  $this->{Config} = $main::HTTP_APP_CONFIG;
####
  $this->{PatientId} = undef;
  $this->{PatientName} = undef;
  return $this;
}
my $content = <<EOF;
<small>Select a starting Dataset: 
<?dyn="SelectNsByValue" op="SelectDs"?><?dyn="DsDropdown"?>
</select></small>
<hr>
<?dyn="MoreContent"?>
EOF
sub AutoRefresh{
  my($this) = @_;
  $this->parent->AutoRefresh;
}
sub Content{
  my($this, $http, $dyn) = @_;
  if(exists $this->{TransactionInProgress}){
    return $this->TransactionStatus($http, $dyn);
  }
  unless(defined $this->{SelectedDataset}){
    $this->OpenSelectedDataset($this->{Datasets}->[0]);
  }
  $this->RefreshEngine($http, $dyn, $content);
}
sub OpenSelectedDataset{
  my($this, $ds) = @_;
  $this->{SelectedDataset} = $ds;
  my $dir = "$this->{TestDataDir}/$ds";
  if(defined $this->{DirAnalyzer}){
    if($this->{DirAnalyzer}->{DirectoryManager}->{dir} eq $dir){ return }
    print STDERR "Aborting old DirAnalyzer\n";
    $this->{DirAnalyzer}->Abort;
  }
  $this->{DirAnalyzer} = 
    FileDist::DirectoryAnalyzer->new($dir, $this->get_obj("FileManager"));
  $this->AutoRefresh;
}
sub DsDropdown{
  my($this, $http, $dyn) = @_;
  for my $ds (@{$this->{Datasets}}){
    $http->queue("<option value=\"$ds\"");
    if($ds eq $this->{SelectedDataset}) { $http->queue(" selected") }
    $http->queue(">$ds</option>");
  }
}
sub SelectDs{
  my($this, $http, $dyn) = @_;
  $this->OpenSelectedDataset($dyn->{value});
}
sub MoreContent{
  my($this, $http, $dyn) = @_;
  if(
    $this->{DirAnalyzer} &&
    (
      !defined($this->{DirAnalyzer}->{DirectoryManager}->{state}) ||
      $this->{DirAnalyzer}->{DirectoryManager}->{state} ne "Initialized"
    )
  ){
    return $this->InitializingState($http, $dyn);
  }
  $this->AnonymizationSelection($http, $dyn);
}
sub InitializingState{
  my($this, $http, $dyn) = @_;
  my $da = $this->{DirAnalyzer};
  $http->queue("<small>Analyzing Dicom files in $this->{SelectedDataset}:" .
    "</small><ul>");
  if($da->InitializingState($http, $dyn)){
    $this->RefreshAfter(1);
  }
}
sub AnonymizationSelection{
  my($this, $http, $dyn) = @_;
  $this->ParticipantSelection($http, $dyn);
  unless(defined $this->{SelectedParticipant}){ return }
  $this->AnonymizationParameters($http, $dyn);
}
sub ParticipantSelection{
  my($this, $http, $dyn) = @_;
  my $user = $this->get_user;
  my $participants = [ sort keys 
   %{$main::HTTP_APP_CONFIG->{config}->{Capabilities}->
      {$user}->{ParticipantAccess}} ];
  unless($#{$participants} >= 0){
    $http->queue("User $user is not authorized to anonymize for any " .
      "participant");
    return;
  }
  $dyn->{participants} = $participants;
  $this->RefreshEngine($http, $dyn,
    '<small>Select participant for whom to prepare Anonymized Data: ' .
    '<?dyn="SelectNsByValue" op="SelectParticipant"?>' .
    '<?dyn="ParticipantDropdown"?></select><hr>');
}
sub ParticipantDropdown{
  my($this, $http, $dyn) = @_;
  $http->queue('<option name="-- select participant --"' .
    (defined($this->{SelectedParticipant}) ? '>' : ' selected>') .
    "-- select participant --</option>");
  for my $i (@{$dyn->{participants}}){
    $http->queue("<option name=\"$i\"" .
    (($this->{SelectedParticipant} eq $i) ? ' selected>' : '>') .
    "$i</option>");
  }
}
sub SelectParticipant{
  my($this, $http, $dyn) = @_;
  if($dyn->{value} eq "-- select participant --"){
    $this->{SelectedParticipant} = undef;
    delete $this->{SelectedParticipantInfo};
  } else {
    $this->{SelectedParticipant} = $dyn->{value};
    $this->{SelectedParticipantInfo} = $main::HTTP_APP_CONFIG->{config}
      ->{Participants}->{Participants}->{$dyn->{value}};
  }
  $this->{PatientId} = undef;
  $this->{PatientName} = undef;
  $this->{AdditionalId} = undef;
  $this->AutoRefresh;
}
sub AnonymizationParameters{
  my($this, $http, $dyn) = @_;
  unless($this->{PatientId}){
    unless($this->{SelectedDataset}) { return }
    unless($this->{SelectedDataset} =~ /^(....)(..)(.)(..)xx$/){ return }
    my $profile = $1;
    my $yc = $2;
    my $test_type = $3;
    my $test_num = $4;
    my $vendor_name = $this->{SelectedParticipantInfo}->{VendorName};
    my $vendor_code = $this->{SelectedParticipantInfo}->{VendorCode};
    my $patient_id = $profile . "$yc$test_type$test_num" . "$vendor_code" .
      ($this->{AdditionalId} ? "_$this->{AdditionalId}" : "");
    my $patient_name = "$patient_id^$vendor_name"; 
    my $anon_dir = 
      $main::HTTP_APP_CONFIG->{config}->{Environment}->{ParticipantDataRoot} .
      "/$patient_id";
    if(-d $anon_dir){
      return $this->AlreadyAnonymized($http, $dyn);
    }
    $this->{AnonymizationParameters} = {
      patient_name => $patient_name,
      patient_id => $patient_id,
      dir => $anon_dir,
    };
    $http->queue("Vendor name: $vendor_name<br>" .
      "Vendor code: $vendor_code<br>" .
      "Profile: $profile<br>" .
      "Test_num: $test_num<br>" .
      "Directory: $anon_dir<br>" .
      "New Patient Name: $patient_name<br>" .
      "New Patient Id: $patient_id");
    $this->CollectUids($this->{DirAnalyzer}->{DirectoryManager}->{Processed});
    $this->AnonymizeButton($http, $dyn);
  }
}
sub AnonymizeButton{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn,
  '<br><?dyn="Button" caption="Create Anonymized Dataset" ' .
  'op="DoAnonymization"?>');
}
sub AlreadyAnonymized{
  my($this, $http, $dyn) = @_;
  $http->queue("AlreadyAnonymized");
}
sub DoAnonymization{
  my($this, $http, $dyn) = @_;
  $this->{AnonymizationConfig} = {};
  my $new_uid_root = Posda::UUID::GetUUID;
  my $seq = 0;
  for my $u (keys %{$this->{CollectedUids}}){
    $this->{AnonymizationConfig}->{uid_substitutions}->{$u} = "$new_uid_root." .
      $seq++;
  }
  $this->{AnonymizationConfig}->{short_ele_replacements}->{"(0010,0010)"} =
    $this->{AnonymizationParameters}->{patient_name};
  $this->{AnonymizationConfig}->{short_ele_replacements}->{"(0010,0020)"} =
    $this->{AnonymizationParameters}->{patient_id};
  $this->{AnonCmds} = [];
  file:
  for my $f (keys %{$this->{DirAnalyzer}->{DirectoryManager}->{Processed}}){
    my $cmd = {
      from_file => $f,
    };
    for my $i (keys %{$this->{AnonymizationConfig}}){
      $cmd->{$i} = $this->{AnonymizationConfig}->{$i};
    }
    my $fi = $this->{DirAnalyzer}->{FM}->DicomInfo($f);
    my $modality = $fi->{modality};
    my $sop = $fi->{sop_inst_uid};
    my $sop_c = $fi->{sop_class_uid};
    my $prefix = Posda::DataDict::GetSopClassPrefix($sop_c);
    unless(exists $this->{AnonymizationConfig}->{uid_substitutions}->{$sop}){
      print STDERR "unknown sop for $f ($sop)\n";
      next file;
    }
    my $new_sop = $this->{AnonymizationConfig}->{uid_substitutions}->{$sop};
    $cmd->{to_file} = $this->{AnonymizationParameters}->{dir} .
      "/$prefix" ."_$new_sop.dcm";
    push @{$this->{AnonCmds}}, $cmd;
  }
  if(-d $this->{AnonymizationParameters}->{dir}){
    print STDERR "Error: $this->{AnonymizationParameters}->{dir} " .
      "already exists!!\n";
  } else {
    my $count = mkdir $this->{AnonymizationParameters}->{dir};
    unless($count == 1) {
      print STDERR "Error: unable to mkdir " .
        "$this->{AnonymizationParameters}->{dir} ($!)\n";
    }
    unless(-d $this->{AnonymizationParameters}->{dir}) {
      die "No anonymization dir: $this->{AnonymizationParameters}->{dir}";
    }
  }
  $this->StartAnonymizationTransaction;
}
###########################
# Transaction Processing
###########################
sub StartAnonymizationTransaction{
  my($this) = @_;
  $this->{TransactionInProgress} = 1;
  $this->{OperationsInProgress} = 0;
  $this->CrankTransactions;
  $this->AutoRefresh;
}
sub TransactionStatus{
  my($this, $http, $dyn) = @_;
  my $pending_count = scalar @{$this->{AnonCmds}};
  $http->queue(
    "Number of operations in progress: $this->{OperationsInProgress}<br>" .
    "Number of operations pending: $pending_count<br>"
  );
  $this->RefreshAfter(1);
}
sub CrankTransactions{
  my($this) = @_;
  my $pending_count = scalar @{$this->{AnonCmds}};
  if($pending_count == 0 && $this->{OperationsInProgress} == 0){
    return $this->TransactionComplete;
  }
  if(
    $this->{OperationsInProgress} < $this->{parallel_count} && 
    $pending_count > 0
  ){
#    $this->StartAnonymizationOperation;
    $this->StartAnonymizationOperation;
    $this->CrankTransactions;
  }
}
sub TransactionComplete{
  my($this) = @_;
  delete $this->{TransactionInProgress};
  $this->AutoRefresh;
}
sub StartAnonymizationOperation{
  my($this) = @_;
  unless(scalar(@{$this->{AnonCmds}}) > 0) { return }
  my $op = shift(@{$this->{AnonCmds}});
  $this->SerializedSubProcess($op, "SubProcessEditor.pl",
    $this->AnonResult($op));
}
sub AnonResult{
  my($this, $op) = @_;
  my $fm = $this->get_obj("FileManager");
  $this->{OpInProgress}->{$op->{to_file}} = 1;
  $this->{OperationsInProgress} += 1;
  my $sub = sub {
    my($status, $result) = @_;
    if($status eq "Failed"){
      $result->{op} = $op;
      $this->{OpFailed}->{$op->{to_file}} = $result;
    } else {
      $this->{OpSucceeded}->{$op->{to_file}} = $result;
      $fm->QueueFile($op->{to_file}, 3);
    }
    delete $this->{OpInProgress}->{$op->{to_file}};
    $this->{OperationsInProgress} -= 1;
    $this->CrankTransactions;
  };
  return $sub;
}
#sub StartAnonymizationOperation{
#  my($this) = @_;
#  unless(scalar(@{$this->{AnonCmds}}) > 0) { return }
#  my $op = shift(@{$this->{AnonCmds}});
#  my($fh, $pid) = $this->ReadWriteChild("SubProcessEditor.pl");
#  store_fd($op, $fh); 
#  Dispatch::Select::Socket->new($this->AnonResult($op, $pid), $fh)->Add(
#    "reader");
#}
#sub AnonResult{
#  my($this, $op, $pid) = @_;
#  my $fm = $this->get_obj("FileManager");
#  $this->{OpInProgress}->{$op->{to_file}} = 1;
#  $this->{OperationsInProgress} += 1;
#  my $sub = sub{
#    my($disp, $sock) = @_;
#    my $result;
#    eval{
#      $result = fd_retrieve($sock);
#    };
#    if($@) {
#      $this->{OpFailed}->{$op->{to_file}} = { op => $op, mess => $@ };
#    } else {
#      $this->{OpSucceeded}->{$op->{to_file}} = $result;
#    }
#    $disp->Remove;
#    waitpid $pid, 0;
#    delete $this->{OpInProgress}->{$op->{to_file}};
#    $this->{OperationsInProgress} -= 1;
#    $fm->QueueFile($op->{to_file}, 3);
#    $this->CrankTransactions;
#  };
#  return $sub;
#}
1;

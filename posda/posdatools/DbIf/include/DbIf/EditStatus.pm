package DbIf::EditStatus;
# 
#

use Modern::Perl;

use Posda::Config ('Config','Database');
use Posda::DB 'QueryAsync', 'Query';

use Regexp::Common "URI";

use parent 'Posda::PopupStatus';


sub SpecificInitialize {
  my ($self, $params) = @_;
  $self->{title} = 'Edit Status';
  $self->{count} = 0;
  $self->StartTimer;
  $self->{params} = $params;
  $self->{subprocess_invocation_id} = $params->{id};
  $self->StartQuery(
    "ActivityStuffMoreBySubprocessInvocationId",
    [$self->{subprocess_invocation_id}]);
  $self->StartQuery(
    "GetEditStatusByEditId",
    [$self->{subprocess_invocation_id}]);
  $self->StartQuery(
    "ToFilesFilesImportedByEditId",
    [$self->{subprocess_invocation_id}]);
  $self->SemiSerializedSubProcess(
    "FindRunningBackgroundSubprocesses.pl|CsvStreamToPerlStruct.pl",
    $self->LoadScriptOutput("running_subprocesses"));
}

sub StartTimer {
  my ($self) = @_;
  $self->{backgrounder} = Dispatch::Select::Background->new($self->TimeIncrementor);
  $self->{backgrounder}->timer(10);
  
}
sub TimeIncrementor {
  my ($self) = @_;
  my $sub = sub{
    unless(exists $self->{backgrounder}) { return }
    $self->{count} += 10;
    $self->{backgrounder}->timer(10);
    $self->AutoRefresh;
  }
}

sub MenuResponse {
  my ($self, $http, $dyn) = @_;
  $http->queue("<small>run time: $self->{count}</small>");
}
sub ScriptButton {
  my ($self, $http, $dyn) = @_;
  my $parent = $self->parent;
  if($parent->can("ScriptButton")){
    $parent->ScriptButton($http, $dyn);
  }
}

sub InitializedResponse {
  my ($self, $http, $dyn) = @_;
  my $edit_status = $self->{query_results}->{GetEditStatusByEditId}->[0]->[6];
  my $files_to_edit = $self->{query_results}->{GetEditStatusByEditId}->[0]->[3];
  my $files_changed = $self->{query_results}->{GetEditStatusByEditId}->[0]->[4];
  my $files_not_changed = $self->{query_results}->{GetEditStatusByEditId}->[0]->[5];
  my $es = $self->{query_results}->{ActivityStuffMoreBySubprocessInvocationId}->[0];
  my $has_email = 0;
  for my $i (0 .. $#{$self->{query_results}->{ActivityStuffMoreBySubprocessInvocationId}}){
    my $foo = $self->{query_results}->{ActivityStuffMoreBySubprocessInvocationId}->[$i];
    if($foo->[5] eq "Email"){
      $es = $foo;
      $has_email = 1;
    }
  }
  my $edit_started = $es->[7];
  my $edit_ended = $es->[9];
  my $edit_by = $es->[10];
  my $notified = $es->[11];
  my $edit_invocation = $es->[14];
  $edit_invocation =~ s/<\?bkgrnd_id\?>/$self->{subprocess_invocation_id}/g;
  my $files_imported = $self->{query_results}->{ToFilesFilesImportedByEditId}->[0]->[0];
  my($user_inbox_content_id, $activity_id);
  if($has_email){
     $user_inbox_content_id = $es->[2];
     $activity_id = $es->[6];
  }
  $http->queue("The edit was started by $edit_by at $edit_started.\n<br>" .
    "The command was:<pre>\n$edit_invocation.\n</pre>" .
    "$files_to_edit files were edited: $files_changed changed, $files_not_changed didn't.\n<br>" .
    "Current edit status is \"$edit_status\".<br>");
   if($user_inbox_content_id){
     $http->queue("A notification of completion of edit (content_id $user_inbox_content_id) was sent to $notified\n<br>");
     if($activity_id) {
       $http->queue("This notification is stored on the timeline of activity $activity_id.\n<br>");
     }
   }
   $http->queue("<br>$files_imported files have been imported.\n<br>");
   my $running = $self->{script_results}->{running_subprocesses}->{rows};
   my($imp_id, $bkgrnd_id, $pid, $import_command, $import_started, $import_for);
   command:
   for my $i (1 .. $#{$running}){
     $import_command = $running->[$i]->[3];
     if(($import_command =~ /ImportEdit/) && ($import_command =~ $self->{subprocess_invocation_id})){
       $imp_id = $running->[$i]->[0];
       $bkgrnd_id = $running->[$i]->[1];
       $pid = $running->[$i]->[2];
       $import_started = $running->[$i]->[4];
       $import_for = $running->[$i]->[5];
       last command;
     }
   }
   if($imp_id and $import_for ne "Stale"){
     $import_command =~ s/<\?bkgrnd_id\?>/$imp_id/g;
     $http->queue("The import appears to be running.\n<br>" .
       "It has subprocess_invocation_id: $imp_id,\n<br>" .
       "And background_subprocess_id: $bkgrnd_id,\n<br>" .
       "And pid: $pid.\n<br>" .
       "And command:<pre>$import_command\n</pre>" .
       "It was started at $import_started and has been running for $import_for.\n<br>");
     my $percent = sprintf("%2.2f", ($files_imported / $files_to_edit) * 100);
     $http->queue("It is $percent percent complete\n<br>");
     my $projected_end;
     Query("ProjectCompletion")->RunQuery(sub{
       my($row) = @_;
       $projected_end = $row->[0];
     }, sub {}, $import_started, $files_imported, $files_to_edit, $files_imported);
     $http->queue("And has a projected completion of $projected_end\n<br>");
   } else {
     $http->queue("There is no ImportEdits running for $self->{subprocess_invocation_id}.\n<br>");
   }
}

1;

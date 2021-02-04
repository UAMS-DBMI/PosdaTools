package Posda::NewerProcessPopup;
#use Modern::Perl;

use Posda::PopupWindow;
use Posda::PopupImageViewer;
use Posda::Config ('Config','Database');
use Posda::DB 'Query';
use Posda::DB::PosdaFilesQueries;
use Posda::File::Import 'insert_file';

use File::Temp 'tempfile';

use DBI;
use URI;
use HTML::Entities;
use Debug;
my $dbg = sub {print STDERR @_};

use MIME::Base64;

use Redis;
use constant REDIS_HOST => 'redis:6379';

my $redis = undef;
my $work_id;

sub ConnectToRedis {
  unless($redis) {
    $redis = Redis->new(server => REDIS_HOST);
  }
}

sub QuitRedis {
  if ($redis) {
    $redis->quit;
  }
  $redis = undef;
}

use vars qw( @ISA );
@ISA = ("Posda::PopupWindow");

my $db_handle;

#params = {
#  bindings => {
#    <variable_name> => <value>,
#    ...
#  },
#  current_settings =>{
#    activity_id => <activity_id>,
#    activity_timepoint_id => <activity_timepoint_id>,
#    notify => <notify>,
#  },
#  prior_ss_args => {
#    <variable_name> => <value>,
#  },
#  columns => {
#     <column_name>,
#      ...
#  },
#  command => {
#    can_chain => 1|0|undef,
#    command_line => <unsubstituted_command_line>,
#    operation_name => <operation_name>,
#    args => [
#      <extracted_from cmd_line>,
#      ...
#    ],
#    input_line_format => <unsubstituted_input_line_format>,
#    fields => [
#      <extracted_from_cmd_line>,
#    ],
#    operation_type => background_process|legacy,
#  },
#  notify => <curent_user>,
#  rows => [
#    {
#      <column_name> => <value>
#      ...
#    },
#    ...
#  ]
#};
#
sub SpecificInitialize{
  my($self,$params) = @_;
  $self->{title} = "Process Operation Popup";
  $self->{args} = {};
  $self->{meta_args} = {};
  $self->{params} = $params;
  for my $arg (@{$self->{params}->{command}->{args}}){
    if(exists $self->{params}->{prior_ss_args}->{$arg}){ #if prior_ss_arg, use it
      $self->{args}->{$arg}  = ["from spreadsheet", $self->{params}->{prior_ss_args}->{$arg}];
    } elsif (exists $self->{params}->{current_settings}->{$arg}){ #elsif current_setting, use it
      $self->{args}->{$arg}  = ["from current_settings",  $self->{params}->{current_settings}->{$arg}],
    } elsif (exists $self->{bindings}->{$arg}) { #elsif binding, set it
      $self->{args}->{$arg}  = ["from bindings",  $self->{params}->{bindings}->{$arg}],
    } else {
      $self->{args}->{$arg}  = ["not present",  ""],
    }
  }
  my $cmd = $self->{params}->{command}->{command_line};
  if($cmd =~ /^([^\s]*)\s/){
    $prog = $1;
    my $effective_prog;
    open FOO, "which $prog|";
    while(my $line = <FOO>){ $effective_prog .= $line };
    chomp $effective_prog;
    $self->{EffectiveProg} = $effective_prog;
  }
  $self->SetDefaultInput;
  $self->{mode} = "initial";
}

sub SetDefaultInput{
  my($self) = @_;
  $self->{InputLines} = [];
  for my $row (@{$self->{params}->{rows}}){
    my $line = $self->{params}->{command}->{input_line_format};
    for my $col (@{$self->{params}->{command}->{fields}}){
      $line =~ s/<$col>/$row->{$col}/g;
    }
    push @{$self->{InputLines}}, $line;
  }
}

sub ContentResponse {
  my($self, $http, $dyn) = @_;
  if($self->{mode} eq "initial"){
  $self->RefreshEngine($http, $dyn,
    '<div style="display: flex; flex-direction: column; align-items: flex-beginning; margin-bottom: 5px">' .
    '<div id="div_ProcessSummary">' .
    '<?dyn="DrawProcessSummary"?>' .
    '</div>' .
    '<div id="div_ParameterForm">' .
    '<?dyn="DrawParameterForm"?>' .
    '</div>' .
    '<div id="div_RenderedCommandLine">' .
    '<?dyn="DrawRenderedCommandLine"?>' .
    '</div>' .
    '<div id="div_RenderedInputData">' .
    '<?dyn="DrawRenderedInputData"?>' .
    '</div>' .
    '</div>');
  } elsif($self->{mode} eq "waiting"){
    $self->WaitingForResponse($http, $dyn);
  } elsif($self->{mode} eq "response_available"){
    $self->SubProcessResponded($http, $dyn);
  } else {
    $http->queue("Unknown mode: $self->{mode}");
  }
}

sub DrawProcessSummary{
  my($self, $http, $dyn) = @_;
  $http->queue("Operation: $self->{params}->{command}->{operation_name}<br>");
  my $cmd = $self->{params}->{command}->{command_line};
  my $encoded_command = encode_entities($cmd);
  $http->queue("Command: $encoded_command<br>");
  my $inp = $self->{params}->{command}->{input_line_format};
  my $encoded_inp = encode_entities($inp);
  if ($encoded_inp){
    $http->queue("Input line format: $encoded_inp");
  }
  my $warn = Query("IsThisOperationOutdated")
               ->FetchOneHash($self->{params}->{command}->{operation_name})
               ->{outdated};
  if ($warn){
    $http->queue("<br><strong>**This operation is outdated. Speak to an administrator.**</strong><br>");
  }
}

sub DrawParameterForm{
  my($self, $http, $dyn) = @_;
  $http->queue("<hr>Parameters:<ul>");
  for my $p (sort keys %{$self->{args}}){
    $http->queue("<li>$p : ");
    $self->NewEntryBox($http, {
      name => "Arg_$p",
      op => "SetArg",
      index => $p,
      value => $self->{args}->{$p}->[1],
      id => "ent_arg_$p",
    }, "UpdateDiv('div_RenderedCommandLine', 'DrawRenderedCommandLine')");
    $http->queue("</li>");
  }
  $http->queue("</ul>");
}

sub SetArg{
  my($self, $http, $dyn) = @_;
#print STDERR "In SetArg:\n";
#for my $i (keys %$dyn){
#  print STDERR "  dyn{$i} = '$dyn->{$i}'\n";
#}
  if($self->{args}->{$dyn->{index}}->[1] ne $dyn->{value}){
    $self->{args}->{$dyn->{index}} = ["entered", $dyn->{value}];
  }
}

sub DrawRenderedCommandLine{
  my($self, $http, $dyn) = @_;
  my $expanded_command = $self->{params}->{command}->{command_line};
  for my $p (keys %{$self->{args}}){
    $expanded_command =~ s/<$p>/$self->{args}->{$p}->[1]/;
  }
  $self->{ExpandedCommand} = $expanded_command;
  my $encoded_command = encode_entities($self->{ExpandedCommand});
  if($self->{EffectiveProg} ne ""){
    $http->queue("<hr>Expanded Command:<pre>$encoded_command</pre>");
  } else {
    $http->queue("<hr>Expanded Command (not found):<pre>$encoded_command</pre>");
  }
}

sub DrawRenderedInputData{
  my($self, $http, $dyn) = @_;
  my $num_lines = @{$self->{InputLines}};
  $http->queue("<hr>$num_lines lines to supply as input:\n<pre>");
  if($num_lines < 20){
    for my $line (@{$self->{InputLines}}){
      $http->queue("$line\n");
    }
  } else {
    my $lines = @{$self->{InputLines}};
    for my $i (0 .. 9){
      $http->queue("$self->{InputLines}->[$i]\n");
    }
    $http->queue("... (only first and last 10 lines shown)\n");
    for my $i ($lines - 10 .. $lines - 1){
      $http->queue("$self->{InputLines}->[$i]\n");
    }
  }
  $http->queue("</pre>");
}

sub Cancel{
  my($self, $http, $dyn) = @_;
  $http->queue("OK");
}


sub MenuResponse{
  my($self, $http, $dyn) = @_;
  $http->queue(
    '<div style="display: flex; flex-direction: column; align-items: flex-beginning; margin-bottom: 5px">');
  if($self->{mode} eq "initial"){
    if($self->{EffectiveProg} ne ""){
      $self->DelegateButton($http, {
        op => "StartSubprocess",
        caption => "Start",
        sync => "Update();",
        css_class => "btn btn-success",
      });
    } else {
      $http->queue("Program not found");
    }
    $self->DelegateButton($http, {
      op => "Cancel",
      caption => "Cancel",
      sync => "CloseThisWindow();",
    });
    $self->NotSoSimpleButton($http, {
      op => "OpHelp",
      caption => "Help",
      cmd => $self->{params}->{command}->{operation_name},
      sync => "Update();",
    });
  } elsif($self->{mode} eq "waiting") {
    $http->queue("waiting");
  } elsif($self->{mode} eq "response_available") {
    $self->DelegateButton($http, {
      op => "Done",
      caption => "Cancel",
      sync => "CloseThisWindow();",
    });
  } else {
    $http->queue("Unknown mode: $self->{mode}");
  }
  $http->queue("</div>");
}

sub StartSubprocess{
  my ($self, $http, $dyn) = @_;
  my $id = $self->{table}->{query}->{invoked_id};
  my $btn_name = $self->{button_name};
  my $operation_name = $self->{params}->{command}->{operation_name};;
  my $command_line = $self->{ExpandedCommand};
  my $invoking_user = $self->get_user;
  my $spreadsheet_f_id;

  #Did this operation come from a spreasheet?
  if ($self->{params}->{invocation}->{type} eq "UploadedUnnamedSpreadsheet" || $self->{params}->{invocation}->{type} eq "UploadedNamedSpreadsheet"){

    # it came from a spreadsheet, so associate it with that one
    $spreadsheet_f_id = $self->{params}->{invocation}->{file_id};

  }else{
    # it came from a button, so we create a spreasheet to be able to rerun the process or create worker nodes

    #create spreadsheet
    my ($fh,$tempfilename) = tempfile();

    #column row
    for my $felds (@{$self->{params}->{command}->{fields}}) {
      print $fh "$felds,";
    }
    print $fh  "Operation,";
    for my $argKey (sort keys %{$self->{args}}){
      print $fh "$argKey,";
    }
    #data rows
    my $line1 = 0;
    for $datalines (@{$self->{InputLines}}) {
      print $fh "\n$datalines,";
      if ($line1 == 0){
        $line1 = 1;
        print $fh "$self->{params}->{command}->{operation_name},";
        for my $argValue (sort keys %{$self->{args}}){
          print $fh "$self->{args}->{$argValue}->[1],";
        }
      }
    }
    #data row when there are no input lines
    if ($#{$self->{InputLines}} == -1){
      print $fh "\n";
      for my $felds (@{$self->{params}->{command}->{fields}}) {
        print $fh ",";
      }
      print $fh "$self->{params}->{command}->{operation_name},";
      for my $argValue (sort keys %{$self->{args}}){
        print $fh "$self->{args}->{$argValue}->[1],";
      }
    }
    close $fh;

    #call API to import
    my $resp = Posda::File::Import::insert_file($tempfilename);
    if ($resp->is_error){
        die $resp->error;
    }else{
      $spreadsheet_f_id =  $resp->file_id;
    }
    unlink $tempfilename;
  }

  #save to spreadsheet uploaded
  my $spreadsheet_table_id = PosdaDB::Queries::record_spreadsheet_upload(1, $invoking_user, $spreadsheet_f_id, ($#{$self->{InputLines}}+1));

  #save to subprocess invocation
  my $new_id = Query("CreateSubprocessInvocationButton")
               ->FetchOneHash($id, $btn_name, $command_line, $spreadsheet_table_id,
                              $invoking_user, $operation_name)
               ->{subprocess_invocation_id};

  unless($new_id) {
    die "Couldn't create row in subprocess_invocation";
  }

  # save input file for worker nodes
  my ($fht,$tempinputdata) = tempfile();
  for $datalines (@{$self->{InputLines}}) {
    print $fht "$datalines\n";
  }
  close $fht;

  #call API to import
  my $resp = Posda::File::Import::insert_file($tempinputdata);
  if ($resp->is_error){
      die $resp->error;
  }else{
    $worker_input_file_id =  $resp->file_id;
  }
  unlink $tempinputdata;

  # add to the work table for worker nodes
  $work_id = Query("CreateNewWork")
                ->FetchOneHash($new_id,$worker_input_file_id)
                ->{work_id};


  ConnectToRedis();
  unless($redis){
    die "Couldn't connect to redis";
  }
  my $priority = Query("OperationPriority")
               ->FetchOneHash($self->{params}->{command}->{operation_name})
               ->{worker_priority};
  $redis->lpush("work_queue_$priority", $work_id);
  QuitRedis();



  my $cmd_to_invoke = $self->{ExpandedCommand};
  $cmd_to_invoke =~ s/<\?bkgrnd_id\?>/$new_id/eg;
#  print STDERR "###########################\n";
#  print STDERR "NewCommandToInvoke: $cmd_to_invoke\n";
#  print STDERR "###########################\n";
# Dispatch::LineReaderWriter->write_and_read_all(
#   $cmd_to_invoke,
#   $self->{InputLines},
#   $self->WhenCommandFinishes($new_id)
# );
#  print STDERR "Started Line reader\n";
  $self->{mode} = "waiting";
}

sub WhenCommandFinishes{
  my($self,$subprocess_invocation_id) = @_;
  my $sub = sub {
    my($results, $pid) = @_;
    $self->{Results} = $results;
    my $q = Query("AddPidToSubprocessInvocation");
    $q->RunQuery(sub{}, sub{}, $pid, $subprocess_invocation_id);
    my $q1 = Query("CreateSubprocessLine");
    my $line_no = 0;
    for my $line (@$results){
      $line_no += 1;
      $q1->RunQuery(sub {}, sub {},
        $subprocess_invocation_id,
        $line_no,
        $line
      );
    }
    $self->{mode} = "response_available";
    if($self->can("AutoRefresh")){
      $self->AutoRefresh;
    }
  };
  return $sub;
}

sub WaitingForResponse{
  my($self,$http, $dyn) = @_;
  $http->queue("<p>Successfully queued background process with worker $work_id.</p>");
  my $q = Query("GetWorkerQueueLength");
  my $qlen = $q->FetchOneHash();
  $http->queue("<p>There are $qlen->{qlength} items ahead in the worker queue.</p>");
  # my $q = Query("GetWorkerCompleteStatus");
  # my $w_info = $q->FetchOneHash($work_id);
  # $http->queue("<p>Worker $work_id's log information can be found in files: $w_info->{stdout_file_id} , $w_info->{stderr_file_id}./p>");
  $self->DelegateButton($http, {
    op => "Close",
    caption => "Close",
    sync => "CloseThisWindow();",
  });
}

sub SubProcessResponded{
  my($self,$http, $dyn) = @_;
  $http->queue("<p>Subprocess response:</p><pre>");
  for my $i (@{$self->{Results}}){
    $http->queue("$i\n");
  }
}
sub OpHelp {
  my ($self, $http, $dyn) = @_;

  my $details = [ $dyn->{cmd} ];


  my $child_path = $self->child_path("PopupHelp_$dyn->{cmd}");
  my $child_obj = ActivityBasedCuration::PopupHelp->new($self->{session},
                                              $child_path, $details);
  $self->parent->StartJsChildWindow($child_obj);
}

1;

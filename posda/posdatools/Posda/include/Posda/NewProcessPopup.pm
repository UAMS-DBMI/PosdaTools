package Posda::NewProcessPopup;
#use Modern::Perl;
#use Method::Signatures::Simple;

use Posda::PopupWindow;
use Posda::PopupImageViewer;
use Posda::Config ('Config','Database');
use Posda::DB 'Query';

use DBI;
use URI;
use HTML::Entities;
use Debug;
my $dbg = sub {print STDERR @_};

use MIME::Base64;


use vars qw( @ISA );
@ISA = ("Posda::PopupWindow");

my $db_handle;

#params = {
#  activity_id => <current_activity_id>,
#  activity_timepoint_id => <latest_activity_timepoint_id>,
#  bindings => {
#    <variable_name> => <value>,
#    ...
#  },
#  col_conv => {
#     <col_name> => <col_index>,
#      ...
#  },
#  command => {
#    can_chain => 1|0|undef,
#    cmdline => <unsubstituted_command_line>,
#    operation_name => <operation_name>,
#    parms => [
#      <extracted_from cmd_line>,
#      ...
#    ],
#    pipe_parms => <input_line_format>,
#    pipe_parmlist => [
#      <extracted_from_cmd_line>,
#    ],
#    type => background_process|legacy,
#  },
#  notify => <curent_user>,
#  rows => [
#    [
#      <col_[0]>,
#      ...
#    ],
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
  for my $arg (@{$self->{params}->{command}->{parms}}){
    if($arg =~ /^\?.*\?$/){
      $self->{meta_args}->{$arg} = 1;
    } else {
      $self->{args}->{$arg} = 1;
    }
  }
  $self->{mode} = "initial";
  $self->SetDefaultArgs;
  if(
    exists($self->{params}->{rows}) &&
    exists($self->{params}->{command}->{pipe_parms})
  ){
    $self->SetDefaultInput;
  }
}

sub SetDefaultInput{
  my($self) = @_;
  $self->{InputLines} = [];
  for my $row (@{$self->{params}->{rows}}){
    my $line = $self->{params}->{command}->{pipe_parms};
    for my $col (@{$self->{params}->{command}->{pipe_parmlist}}){
      my $col_indx = $self->{params}->{col_conv}->{$col};
      $line =~ s/<$col>/$row->[$col_indx]/g;
    }
    push @{$self->{InputLines}}, $line;
  }
}

sub SetDefaultArgs{
  my($self) = @_;
  for my $i (keys %{$self->{args}}){
    if(exists $self->{params}->{$i}){
      $self->{args}->{$i} = $self->{params}->{$i};
    } elsif(exists ($self->{params}->{bindings}->{$i})){
      $self->{args}->{$i} = $self->{params}->{bindings}->{$i};
    } else {
      $self->{args}->{$i} = "no_default";
    }
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
    $self->SubprocessResponded($http, $dyn);
  } else {
    $http->queue("Unknown mode: $self->{mode}");
  }
}

sub DrawProcessSummary{
  my($self, $http, $dyn) = @_;
  $http->queue("Operation: $self->{params}->{command}->{operation_name}<br>");
  my $cmd = $self->{params}->{command}->{cmdline};
  my $encoded_command = encode_entities($cmd);
  $http->queue("Command: $encoded_command<br>");
  my $inp = $self->{params}->{command}->{pipe_parms};
  my $encoded_inp = encode_entities($inp);
  $http->queue("Input line format: $encoded_inp");
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
      value => $self->{args}->{$p},
      id => "ent_arg_$p",
    }, "UpdateDiv('div_RenderedCommandLine', 'DrawRenderedCommandLine')");
    $http->queue("</li>");
  }
  $http->queue("</ul>");
}

sub SetArg{
  my($self, $http, $dyn) = @_;
  $self->{args}->{$dyn->{index}} = $dyn->{value};
}

sub DrawRenderedCommandLine{
  my($self, $http, $dyn) = @_;
  my $expanded_command = $self->{params}->{command}->{cmdline};
  for my $p (keys %{$self->{args}}){
    $expanded_command =~ s/<$p>/$self->{args}->{$p}/;
  }
  $self->{ExpandedCommand} = $expanded_command;
  my $encoded_command = encode_entities($self->{ExpandedCommand});
  $http->queue("<hr>Expanded Command:<pre>$encoded_command</pre>");
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
    $self->DelegateButton($http, {
      op => "StartSubprocess",
      caption => "Start",
      sync => "Update();",
    });
    $self->DelegateButton($http, {
      op => "Cancel",
      caption => "Cancel",
      sync => "CloseThisWindow();",
    });
    $self->NotSoSimpleButton($http, {
      op => "Help",
      caption => "Help",
      cmd => $self->{operation_name},
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

  my $new_id = Query("CreateSubprocessInvocationButton")
               ->FetchOneHash($id, $btn_name, $command_line,
                              $invoking_user, $operation_name)
               ->{subprocess_invocation_id};

  unless($new_id) {
    die "Couldn't create row in subprocess_invocation";
  }
  my $cmd_to_invoke = $self->{ExpandedCommand};
  $cmd_to_invoke =~ s/<\?bkgrnd_id\?>/$new_id/eg;
  print STDERR "###########################\n";
  print STDERR "NewCommandToInvoke: $cmd_to_invoke\n";
  print STDERR "###########################\n";
  Dispatch::LineReaderWriter->write_and_read_all(
    $cmd_to_invoke,
    $self->{InputLines},
    $self->WhenCommandFinishes($new_id)
  );
  print STDERR "Started Line reader\n";
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
    $self->{mode} = "response_complete";
    if($self->can("AutoRefresh")){
      $self->AutoRefresh;
    }
  };
  return $sub;
}

sub WaitingForResponse{
  my($self,$http, $dyn) = @_;
  $http->queue("<p>Waiting on sub_process</p>");
}

sub SubProcessResponded{
  my($self,$http, $dyn) = @_;
  $http->queue("<p>Subprocess response:</p><pre>");
  for my $i (@{$self->{Results}}){
    $http->queue("$i\n");
  }
  $http->queue("</pre>");
}
1;

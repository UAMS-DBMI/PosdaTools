package Posda::OperationPopup;
use Modern::Perl;

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

#params: {
#  "activity_id" => <activity_id>,
#  "activity_timepoint_id" => <latest_activity_timepoint_id>,
#  "bindings" => {
#    <variable_name> => <binding>,
#    ...
#  },
#  "col_conv" => {
#    <name_of_col>" => <index_of_col>,
#    ...
#  },
#  "command" => {
#    "can_chain" => "",
#    "cmdline" => "CreateActivityTimepointFromSeriesList.pl   "" ",
#    "operation_name" => "CreateActivityTimepointFromSeriesList",
#    "parms" => [
#      "?bkgrnd_id?",
#      "activity_id",
#      "comment",
#      "notify"
#    ],
#   "pipe_parmlist" => [
#      "series_instance_uid"
#    ],
#    "pipe_parms" => "",
#    "type" => "background_process"
#  },
#  "notify" => "bbennett",
#  "rows" => [
#    [
#      <value col 1>,
#      <value col 2>,
#      ...
#    ],
#    ...
#  ]
#}

#

sub SpecificInitialize {
  my ($self, $params) = @_;
  my $button_name = $params->{button};
#print STDERR "Parms: ";
#Debug::GenPrint($dbg, $params, 1);
#print STDERR "\n";
#print STDERR "Self ";
#Debug::GenPrint($dbg, $self, 1);
#print STDERR "\n";
  for my $i (keys %{$params}){
    unless($i eq "button"){
      $self->{default_param}->{$i} = $params->{$i};
    }
  }
  $self->{button_name} = $button_name;
  $self->{title} = "Process Button: $button_name";
  # Determine temp dir
  $self->{temp_path} = "$self->{LoginTemp}/$self->{session}";

  $self->{table} = $params->{table};
  my $q1 = Query("GetPopupDefinition");
  $q1->RunQuery($self->ProcessQuery, sub {}, $button_name);
  $self->GetParams;
  $self->GetColumns;
  $self->MakeRowHashArray;
  $self->MakeLineList;
  unless(defined $self->{ParamValues}->{notify}){
    $self->{ParamValues}->{notify} = $self->get_user;
  }
}
sub GetParams {
  my ($self) = @_;
  my $start = $self->{command_line};
  my @Parms;
  my @MetaParms;
  while($start =~ /^[^<]*<([^>]+)>(.*)$/){
    my $parm = $1;
    $start = $2;
    if($parm =~ /^\?(.*)\?$/){
      push @MetaParms, $1;
    } else {
      push @Parms, $parm;
      if(exists $self->{default_param}->{$parm}){
        $self->{ParamValues}->{$parm} = $self->{default_param}->{$parm};
      }
    }
  }
  $self->{Params} = \@Parms;
  $self->{MetaParams} = \@MetaParms;
}
sub GetColumns {
  my ($self) = @_;
  my $start = $self->{input_line_format};
  $self->{Columns} = [];
  while($start =~ /^[^<]*<([^>]+)>(.*)$/){
    push @{$self->{Columns}}, $1;
    $start = $2;
  }
}
sub MakeRowHashArray {
  my ($self) = @_;
  my $cols = $self->{table}->{query}->{columns};
  my $raw_rows;
  if(
    exists $self->{default_param}->{filter_mode} &&
    $self->{default_param}->{filter_mode} eq "filtered"
  ){
    $raw_rows = $self->{table}->{filtered_rows};
  } else {
    $raw_rows = $self->{table}->{rows};
  }
  my @RowHashes;
  for my $row (@$raw_rows){
    my %h;
    for my $i (0 .. $#{$cols}){
      $h{$cols->[$i]} = $row->[$i];
    }
    push @RowHashes, \%h;
  }
  $self->{RowHashArray} = \@RowHashes;
}
sub MakeLineList {
  my ($self) = @_;
  my $format = $self->{input_line_format};
  my $columns = $self->{Columns};
  my @Lines;
  for my $row (@{$self->{RowHashArray}}){
    my $line = $format;
    for my $col (@$columns){
      $line =~ s/<$col>/$row->{$col}/eg;
    }
    push @Lines, $line;
  }
  $self->{LineList} = \@Lines;
}
sub ProcessQuery {
  my ($self) = @_;
  my $sub = sub {
    my($row) = @_;
    $self->{command_line} = $row->[0];
    $self->{input_line_format} = $row->[1];
    $self->{operation_name} = $row->[2];
    $self->{operation_type} = $row->[3];
    $self->{help_info} = [
      $row->[2],
      $row->[0],
      $row->[3],
      $row->[1],
      $row->[4]
    ]
  };
  return $sub;
}

sub Help {
  my ($self, $http, $dyn) = @_;
  my $child_path = $self->child_path("PopupHelp_$self->{operation_name}");
  my $details = $self->{help_info};
  my $child_obj = DbIf::PopupHelp->new($self->{session},
    $child_path, $details);
  $self->StartJsChildWindow($child_obj);
}

sub ContentResponse {
  my ($self, $http, $dyn) = @_;
  if($self->{operation_type} ne "background_process"){
    $self->BadOperationType($http, $dyn);
  } else {
    unless(exists $self->{ContentResponseMode}){
      $self->{ContentResponseMode} = "InitialBackgroundContentResponse";
    }
    my $meth = $self->{ContentResponseMode};
    if($self->can($meth)){
      $self->$meth($http, $dyn);
    } else {
      $http->queue("Unknown Mode: $self->{ContentResponseMode}");
    }
  }
}

sub InitialBackgroundContentResponse {
  my ($self, $http, $dyn) = @_;
  $http->queue("Mode: $self->{ContentResponseMode}");
  $http->queue("<p>Enter Parameters Below:</p><table class=\"table\">");
  for my $p (0 .. $#{$self->{Params}}){
    $http->queue(qq{ <tr>
      <td align="right" valign="top"><strong>$self->{Params}->[$p]</strong>
      </td><td>
     });
     $self->LinkedDelegateEntryBox($http, {
       length => 30,
       index => $self->{Params}->[$p],
       linked => "ParamValues",
     });
     $http->queue(qq{ </td></tr> });
  }
  $http->queue("</table>");
  $self->DelegateButton($http, {
    op => "SetExpandMode",
    caption => "Expand",
    sync => "Update();",
  });
  $self->DelegateButton($http, {
    op => "Cancel",
    caption => "Cancel",
    sync => "CloseThisWindow();",
  });
}

sub Cancel {
  my ($self, $http,$dyn) = @_; $http->queue("OK")}

sub SetExpandMode {
  my ($self, $http, $dyn) = @_;
  my $command_line = $self->{command_line};
  for my $p (@{$self->{Params}}){
    $command_line =~ s/<$p>/$self->{ParamValues}->{$p}/eg;
  }
  $self->{ExpandedCommand} = $command_line;
  $self->{ContentResponseMode} = "ExpandedBackgroundContentResponse";
}

sub ClearExpandMode {
  my ($self, $http, $dyn) = @_;
  $self->{ContentResponseMode} = "InitialBackgroundContentResponse";
}

sub ExpandedBackgroundContentResponse {
  my ($self, $http, $dyn) = @_;
  my $lines = $self->{LineList};
  my $num_lines = @$lines;
  $http->queue("Command: $self->{operation_name} ");
  $self->NotSoSimpleButton($http, {
    op => "Help",
    caption => "H",
    cmd => $self->{operation_name},
    sync => "Update();",
  });
  my $encoded_command = encode_entities($self->{ExpandedCommand});
  $http->queue("<br>Expanded Command:<pre>$encoded_command</pre>");
  $http->queue("<br>Parameters<ul>");
  for my $p (@{$self->{Params}}){
     $http->queue("<li>$p : $self->{ParamValues}->{$p}</li>\n");
  }
  $http->queue("<ul><hr>$num_lines lines to supply as input:\n<pre>");
  if($num_lines < 20){
    for my $line (@{$self->{LineList}}){
      $http->queue("$line\n");
    }
  } else {
    my $lines = @{$self->{LineList}};
    for my $i (0 .. 9){
      $http->queue("$self->{LineList}->[$i]\n");
    }
    $http->queue("... (only first and last 10 lines shown)\n");
    for my $i ($lines - 10 .. $lines - 1){
      $http->queue("$self->{LineList}->[$i]\n");
    }
  }
  $http->queue("</pre>");
  $self->DelegateButton($http, {
    op => "ClearExpandMode",
    caption => "Change Parameters",
    sync => "Update();",
  });
  $self->DelegateButton($http, {
    op => "StartSubprocess",
    caption => "Start Subprocess",
    sync => "Update();",
  });
  $self->DelegateButton($http, {
    op => "Cancel",
    caption => "Cancel",
    sync => "CloseThisWindow();",
  });
}

sub BadOperationType {
  my ($self, $http, $dyn) = @_;
  $http->queue("Bad operation type: $self->{operation_type}");
}

sub MenuResponse {
  my ($self, $http, $dyn) = @_;
}

sub StartSubprocess {
  my ($self, $http, $dyn) = @_;
  my $id = $self->{table}->{query}->{invoked_id};
  my $btn_name = $self->{button_name};
  my $command_line = $self->{ExpandedCommand};
  my $invoking_user = $self->get_user;

  my $new_id = Query("CreateSubprocessInvocationButton")
               ->FetchOneHash($id, $btn_name, $command_line,
                              $invoking_user, $btn_name)
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
    $self->{LineList},
    $self->WhenCommandFinishes($new_id)
  );
  print STDERR "Started Line reader\n";
  $self->{ContentResponseMode} = "WaitingForResponse";
}

sub WhenCommandFinishes {
  my ($self, $subprocess_invocation_id) = @_;
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
    $self->{ContentResponseMode} = "SubProcessResponded";
    if($self->can("AutoRefresh")){
      $self->AutoRefresh;
    }
  };
  return $sub;
}

sub WaitingForResponse {
  my ($self, $http, $dyn) = @_;
  $http->queue("<p>Waiting on sub_process</p>");
}

sub SubProcessResponded {
  my ($self, $http, $dyn) = @_;
  $http->queue("<p>Subprocess response:</p><pre>");
  for my $i (@{$self->{Results}}){
    $http->queue("$i\n");
  }
  $http->queue("</pre>");
}
1;

package Posda::ProcessPopup; 
use Modern::Perl;
use Method::Signatures::Simple;

use Posda::PopupWindow;
use Posda::PopupImageViewer;
use Posda::Config ('Config','Database');

use Posda::DB::PosdaFilesQueries;

use Data::Dumper;
use DBI;
use URI;
use HTML::Entities;

use MIME::Base64;


use vars qw( @ISA );
@ISA = ("Posda::PopupWindow");

my $db_handle;

method SpecificInitialize($params) {
  my $button_name = $params->{button};
  $self->{button_name} = $button_name;
  $self->{title} = "Process Button: $button_name";
  # Determine temp dir
  $self->{temp_path} = "$self->{LoginTemp}/$self->{session}";

  $self->{table} = $params->{table};
  my $q1 = PosdaDB::Queries->GetQueryInstance(
    "GetPopupDefinition"
  );
  $q1->RunQuery($self->ProcessQuery, sub {}, $button_name);
  $self->GetParams;
  $self->GetColumns;
  $self->MakeRowHashArray;
  $self->MakeLineList;
}
method GetParams{
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
    }
  }
  $self->{Params} = \@Parms;
  $self->{MetaParams} = \@MetaParms;
}
method GetColumns{
  my $start = $self->{input_line_format};
  $self->{Columns} = [];
  while($start =~ /^[^<]*<([^>]+)>(.*)$/){
    push @{$self->{Columns}}, $1;
    $start = $2;
  }
}
method MakeRowHashArray{
  my $cols = $self->{table}->{query}->{columns};
  my $raw_rows = $self->{table}->{rows};
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
method MakeLineList{
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
method ProcessQuery{
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

method Help($http, $dyn){
  my $child_path = $self->child_path("PopupHelp_$self->{operation_name}");
  my $details = $self->{help_info};
  my $child_obj = DbIf::PopupHelp->new($self->{session}, 
    $child_path, $details);
  $self->StartJsChildWindow($child_obj);
}

method ContentResponse($http, $dyn) {
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

method InitialBackgroundContentResponse($http, $dyn){
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

method Cancel($http,$dyn) { $http->queue("OK")}

method SetExpandMode($http, $dyn){
  my $command_line = $self->{command_line};
  for my $p (@{$self->{Params}}){
    $command_line =~ s/<$p>/$self->{ParamValues}->{$p}/eg;
  }
  $self->{ExpandedCommand} = $command_line;
  $self->{ContentResponseMode} = "ExpandedBackgroundContentResponse";
}

method ClearExpandMode($http, $dyn){
  $self->{ContentResponseMode} = "InitialBackgroundContentResponse";
}

method ExpandedBackgroundContentResponse($http, $dyn){
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

method BadOperationType($http, $dyn){
  $http->queue("Bad operation type: $self->{operation_type}");
}

method MenuResponse($http, $dyn) {
}

method StartSubprocess($http, $dyn){
  my $q = PosdaDB::Queries->GetQueryInstance(
    "CreateSubprocessInvocationButton");
  my $q1 = PosdaDB::Queries->GetQueryInstance(
    "GetSubProcessInvocationId");
  my $id = $self->{table}->{query}->{invoked_id};
  my $btn_name = $self->{button_name};
  my $command_line = $self->{ExpandedCommand};
  my $invoking_user = $self->get_user;
  $q->RunQuery(sub {}, sub {},
    $id, $btn_name, $command_line, $invoking_user);
  my $new_id;
  $q1->RunQuery(
    sub{my($row) = @_; $new_id = $row->[0];},
    sub {});
  unless($new_id) {
    die "Couldn't create row in subprocess_invocation";
  }
  my $cmd_to_invoke = $self->{ExpandedCommand};
  $cmd_to_invoke =~ s/<\?bkgrnd_id\?>/$new_id/eg;
#  print STDERR "###########################\n";
#  print STDERR "NewCommandToInvoke: $cmd_to_invoke\n";
#  print STDERR "###########################\n";
  Dispatch::LineReaderWriter->write_and_read_all(
    $cmd_to_invoke,
    $self->{LineList},
    $self->WhenCommandFinishes($new_id)
  );
  $self->{ContentResponseMode} = "WaitingForResponse";
}

method WhenCommandFinishes($subprocess_invocation_id){
  my $sub = sub {
    my($results, $pid) = @_;
    $self->{Results} = $results;
    my $q = PosdaDB::Queries->GetQueryInstance(
    "AddPidToSubprocessInvocation");
    $q->RunQuery(sub{}, sub{}, $pid, $subprocess_invocation_id);
    my $q1 = PosdaDB::Queries->GetQueryInstance(
    "CreateSubprocessLine");
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
  };
  return $sub;
}

method WaitingForResponse($http, $dyn){
  $http->queue("<p>Waiting on sub_process</p>");
}

method SubProcessResponded($http, $dyn){
  $http->queue("<p>Subprocess response:</p><pre>");
  for my $i (@{$self->{Results}}){
    $http->queue("$i\n");
  }
  $http->queue("</pre>");
}
1;

package Posda::Subprocess;
#
# A class for spawning Background Subprocesses
#

use Modern::Perl;
use Posda::DB::PosdaFilesQueries;
use Dispatch::LineReaderWriter;
use Posda::DebugLog;

use Data::Dumper;

# Ways to begin a subprocess:
# - from a spreadsheet (DbIf)
# - from a button (ProcessPopup)
# - from code (such as after a drag-and-drop event)
#
# sub example {
#   my $subprocess = Posda::Subprocess->new("TestOperation");
#   $subprocess->set_params($param_map);
#   $subprocess->execute($stdin, $spreadsheet_uploaded_id, $done_callback);

#   $subprocess->execute_from_dbif(
#     $stdin, $spreadsheet_uploaded_id, $query_invoked_by_dbif_id, $done_callback
#   );

#   $subprocess->execute_from_button(
#     $stdin, $spreadsheet_uploaded_id, $query_invoked_by_dbif_id, $done_callback
#   );

# }

sub new {
  my ($class, $name) = @_;
  return bless {
    name => $name,
    user => 'nobody',
    stdin => [],
  }, $class;
}

sub execute_from_dbif {
  my ($self, $user,
      $spreadsheet_uploaded_id,
      $query_invoked_by_dbif_id,
      $done_callback ) = @_;
  $self->set_options({
    user => $user,
    from_spreadsheet => 1,
    from_button => 0,
    query_invoked_by_dbif_id => $query_invoked_by_dbif_id,
    spreadsheet_uploaded_id => $spreadsheet_uploaded_id,
    button_name => undef
  });
  $self->execute($done_callback);
}

# Fill in default values for a button-based execution
sub execute_from_button {
  my ($self, $user, $button_name, $done_callback) = @_;
  $self->set_options({
    user => $user,
    from_spreadsheet => 0,
    from_button => 1,
    query_invoked_by_dbif_id => undef,
    button_name => $button_name
  });
  $self->execute($done_callback);
}

sub new_from_spreadsheet_op {
  my ($class, $name) = @_;
  my $self = $class->new($name);
  my $commands = get_command_hash();
  $self->set_commandline($commands->{$name}->{cmdline});
  DEBUG "Commands: ", Dumper($commands);

  if (not defined $self->{cmdline}) {
    die "$name does not seem to be a spreadsheet op?";
  }

  return $self;
}

sub set_options {
  my ($self, $option_hash) = @_;
  my $oh = $option_hash;

  if (defined $oh->{user}) {
    $self->{user} = $oh->{user};
  }

  if (defined $oh->{from_spreadsheet}) {
    $self->{from_spreadsheet} = $oh->{from_spreadsheet};
  }

  if (defined $oh->{from_button}) {
    $self->{from_button} = $oh->{from_button};
  }

  if (defined $oh->{query_invoked_by_dbif_id}) {
    $self->{query_invoked_by_dbif_id} = $oh->{query_invoked_by_dbif_id};
  }

  if (defined $oh->{spreadsheet_uploaded_id}) {
    $self->{spreadsheet_uploaded_id} = $oh->{spreadsheet_uploaded_id};
  }

  if (defined $oh->{button_name}) {
    $self->{button_name} = $oh->{button_name};
  }

}

sub set_commandline {
  my ($self, $commandline) = @_;
  $self->{cmdline} = $commandline;
}

sub set_params {
  my ($self, $param_hash) = @_;
  DEBUG "called";
  my $final = $self->{cmdline};

  if (not defined $final) {
    die "Missing commandline";
  }

  DEBUG "final is: ", Dumper($final);

  map {
    my $new_value = $param_hash->{$_};
    $final =~ s/<$_>/$new_value/g;
  } keys %$param_hash;

  $self->{cmdline} = $final;
}

sub set_stdin {
  my ($self, $stdin) = @_;
  $self->{stdin} = $stdin;
}

sub set_params_old {
  my ($self, $command, $colmap, $row) = @_;
  if (not defined $command) {
    return undef
  }

  # build the final line
  my $final = $command->{cmdline};
  map {
    my $parm = $_;
    if (not $parm =~ /\?/) {
      my $index_of_parm = $colmap->{$parm};
      my $new_value = $row->[$index_of_parm];

      $final =~ s/<$parm>/$new_value/g;
    }
  } @{$command->{parms}};

  return $final;
}

# TODO: adjust this name
sub get_command_hash {
  # Build the command list from database
  my $commands = {};
  map {
    my ($name, $cmdline, $type, $input_line, $tags) = @$_;

    $commands->{$name} = { cmdline => $cmdline,
                           parms => [$cmdline =~ /<([^<>]+)>/g],
                           operation_name => $name              };
    if (defined $input_line) {
      $commands->{$name}->{pipe_parms} = $input_line;
    }
    $commands->{$name}->{type} = $type;
  } sort @{PosdaDB::Queries->GetOperations()};

  return $commands;
}

# Standard name-based execute
sub execute{
  my ($self,
  $done_callback,

  # optional params
  $from_spreadsheet,
  $from_button,
  $query_invoked_by_dbif_id,
  $button_name) = @_;
  DEBUG "called";

  my $op_details = PosdaDB::Queries->GetOperationDetails($self->{name});
  DEBUG Dumper($op_details);

  my $command_line = $self->{cmdline};
  my $op_name = $self->{name};

  DEBUG "op_name: $op_name";
  DEBUG "command_line: $command_line";

  $self->execute_generic(
    $command_line,
    $op_name,
    $self->{user},
    $self->{stdin},
    $self->{spreadsheet_uploaded_id},
    $done_callback,
    $self->{from_spreadsheet},
    $self->{from_button},
    $self->{query_invoked_by_dbif_id},
    $self->{button_name}
  );
}

sub execute_generic {
  my ($self,
  $command_line,
  $op_name,
  $user,
  $stdin,
  $spreadsheet_uploaded_id,
  $done_callback,

  # optional params
  $from_spreadsheet,
  $from_button,
  $query_invoked_by_dbif_id,
  $button_name) = @_;
  DEBUG "called";

  # Set default values
  $from_spreadsheet = defined $from_spreadsheet? $from_spreadsheet: 0;
  $from_button = defined $from_button? $from_button: 0;

  my $cmd = $command_line;

  my $subprocess_invocation_id = PosdaDB::Queries::invoke_subprocess(
    $from_spreadsheet,                        # from_spreadsheet
    $from_button,                             # from_button
    $spreadsheet_uploaded_id,                 # spreadsheet_uploaded_id
    $query_invoked_by_dbif_id,                # query_invoked_by_dbif_id
    $button_name,                             # button_name
    $cmd,                                     # command_line
    $user,                                    # user
    $op_name                                  # operation_name
  );

  # set the bkgrnd_id field
  $cmd =~ s/<\?bkgrnd_id\?>/$subprocess_invocation_id/;
  $cmd =~ s/<\?spreadsheet_id\?>/$spreadsheet_uploaded_id/;

  Dispatch::LineReaderWriter->write_and_read_all(
    $cmd,
    $stdin,
    sub {
  my ($return, $pid) = @_;
      $self->{Results} = $return;
      DEBUG "Results are in!";

      if (defined $subprocess_invocation_id) {
        # TODO: Is this really useful? the way write_and_read_all()
        # works, the subprocess should always be dead by the time
        # we get here. This is in the spec, but maybe it should be
        # modified?
        PosdaDB::Queries::set_subprocess_pid(
          $subprocess_invocation_id, $pid);
        PosdaDB::Queries::record_subprocess_lines(
          $subprocess_invocation_id, $return);
      }
      if (defined $done_callback) {
        &$done_callback($return);
      }
    }
  );
}

1;

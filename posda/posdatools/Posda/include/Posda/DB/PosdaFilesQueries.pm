package PosdaDB::Queries;

use Modern::Perl;

use JSON;
use DBI;

use Posda::Config 'Database';
use Dispatch::EventHandler;
use Dispatch::TopHalfAsyncQuery;

use Posda::DebugLog 'on';
use Data::Dumper;

my $db_handle;
my $db_handle_cache = {};

sub reset_db_handles {
  my ($self) = @_;
  for my $i (keys %$db_handle_cache){
    $db_handle_cache->{$i}->disconnect;
    delete $db_handle_cache->{$i};
    if(defined $db_handle){
      $db_handle->disconnect;
      $db_handle = undef;
    }
  }
}

sub _get_handle {
  if (not defined $db_handle) {
    $db_handle = DBI->connect(Database('posda_queries'));
  }
  return $db_handle;
}

sub _get_handle_main {
  my ($connect) = @_;
  if (not defined $db_handle_cache->{$connect}) {
    $db_handle_cache->{$connect} = DBI->connect($connect)
      or die "Could not connect to DB with connect string: $connect";
  }

  return $db_handle_cache->{$connect};
}

sub GetQueryInstance {
  my ($class, $name) = @_;
  return PosdaDB::Queries->new($name, 0);
};
sub GetQueryInstanceAsync {
  my ($class, $name) = @_;
  return PosdaDB::Queries->new($name, 1);
};

sub new {
  my ($class, $name, $async) = @_;
  my $self = {
    dbh => undef,
    async => $async
  };

  bless $self, $class;

  $self->_load_query($name);

  return $self;
};

sub MakeStorable {
  my ($self) = @_;
  $self->{dbh} = undef;
}

sub Save {
  my ($self) = @_;
  my $dbh = _get_handle();
  DEBUG "Saving query...";
  my $query = qq{
    update queries
    set 
        query = ?,
        args = ?,
        columns = ?,
        tags = ?,
        schema = ?,
        description = ?
    where name = ?

  };
  my $qh = $dbh->prepare($query);
  $qh->execute($self->{query},
               $self->{args},
               $self->{columns},
               $self->{tags},
               $self->{schema},
               $self->{description},
               $self->{name});
}

sub Clone {
  my ($source_name, $dest_name) = @_;
  my $dbh = _get_handle();
  my $qh = $dbh->prepare(qq{
    insert into queries
    select ?, query, args, columns, tags, schema, description
    from queries
    where name = ?
  });

  $qh->execute($dest_name, $source_name);

}

sub Delete {
  my ($name) = @_;
  my $dbh = _get_handle();
  my $qh = $dbh->prepare(qq{
    delete from queries where name = ?
  });

  $qh->execute($name);
}

sub _load_query {
  my ($self, $name) = @_;
  my $dbh = _get_handle();
  my $qh = $dbh->prepare(qq{
    select * 
    from queries
    where name = ?
  });

  my $rows = $qh->execute($name);
  unless($rows > 0){
    die "############\nQuery: $name isn't defined\n#########";
  }

  my ($name_, $query, $args, 
      $columns, $tags, $schema, $description) = @{$qh->fetchrow_arrayref()};

  # TODO: Is there a prettier way to merge hashes?
  $self->{name} = $name_;
  $self->{query} = $query;
  $self->{args} = $args;
  $self->{columns} = $columns;
  $self->{tags} = $tags;
  $self->{schema} = $schema;
  $self->{description} = $description;
  $self->{connect} = Database($schema);

}

sub SetAsync {
  my ($self, $async) = @_;

  if (not defined $async) {
    $async = 1;
  }

  $self->{async} = $async;
}

sub SetNewAsync {
  my ($self) = @_;

  $self->{new_async} = 1;
}

# Execute the query
# Call signature is:
#   RunQuery($row_callback, $end_callback, $err_callback, @bind_variables);
# 
# The query is executed sync or async depending on the setting,
# and $row_callback is called for each row returned. $end_callback
# is called after all rows have been processed.
#
# If there is an error, $err_callback is called and passed the error
# message. 
#
# NOTE: $err_callback is technically optional, but this behavior may
# be deprecated in the future.
#
# If the query is an INSERT or UPDATE, $row_callback is called 
# one time, and passed [$row_count_affected].
sub RunQuery {
  my $self = shift;

  if ($self->{new_async}) {
    return $self->_RunQueryNewAsync(@_);
  } elsif ($self->{async}){
    return $self->_RunQueryAsync(@_);
  } else {
    return $self->_RunQueryBlocking(@_);
  }
}


sub FetchOneHash {
  # Fetch the first row of results as a hash
  my ($self) = shift;

  my $dbh = _get_handle_main($self->{connect});

  if (not defined $self->{handle}) {
    $self->Prepare($dbh);
  }

  my $rows_affected = $self->Execute(@_);

  return $self->{handle}->fetchrow_hashref;
}

sub FetchResults {
  # Alternate method to simply fetch all results
  # using fetchall_arrayref

  my ($self) = shift;

  my $dbh = _get_handle_main($self->{connect});

  if (not defined $self->{handle}) {
    $self->Prepare($dbh);
  }

  my $rows_affected = $self->Execute(@_);

  return $self->{handle}->fetchall_arrayref;
}

sub _RunQueryBlocking {
  my($self) = shift;
  my $row_callback = shift;
  my $end_callback = shift;

  my $dbh = _get_handle_main($self->{connect});

  if (not defined $self->{handle}) {
    $self->Prepare($dbh);
  }

  my $select = ($self->{query} =~ /^\s*select/i)? 1:0;

  my $rows_affected = $self->Execute(@_);

  if ($select) {
    # return the results
    while(my @h = $self->{handle}->fetchrow_array){
      if (defined $row_callback) {
        &$row_callback(\@h);
      }
    }
  } else {
    if (defined $row_callback) {
      &$row_callback([$rows_affected]);
    }
  }
  if(ref($end_callback) eq "CODE"){
    &$end_callback();
  }
}

sub _RunQueryAsync {
  my($self) = shift;
  my $row_callback = shift;
  my $end_callback = shift;
  my $error_callback = shift;

  # error_callback might actually be the first bind variable, or
  # even undef. If it's not code put it back!

  if (ref($error_callback) ne 'CODE') {
    if (defined $error_callback) {
      unshift @_, $error_callback;
    }

    $error_callback = sub {
      my $message = shift;
      print STDERR "Error in query, but no error_callback passed!\n$message\n";
    }
  }


  # Is there a better way to do this? There is no new() on this class
  my $ev = {};
  bless $ev, 'Dispatch::EventHandler';

  $self->{bindings} = [@_];

  my $parameters =  {
    connect => $self->{connect},
    args => $self->{args},
    columns => $self->{columns},
    tags => $self->{tags},
    description => $self->{description},
    query => $self->{query},
    bindings => $self->{bindings},
    name => $self->{name},
  };
  $ev->SerializedSubProcess(
    $parameters, 
    "SubProcessQuery.pl",
    sub {
      my $status = shift;
      my $result = shift;
      if ($result->{Status} eq 'Error') {
        &$error_callback($result->{Message});
      } else {
        if (defined $result->{NumRows}) {
          &$row_callback($result->{NumRows});
        } else {
          for my $row (@{$result->{Rows}}) {
            &$row_callback($row);
          }
        }
        &$end_callback();
      }
    }
  );
}
sub _RunQueryNewAsync {
  my($self) = shift;
  my $row_callback = shift;
  my $end_callback = shift;
  my $error_callback = shift;

  # error_callback might actually be the first bind variable, or
  # even undef. If it's not code put it back!

  if (ref($error_callback) ne 'CODE') {
    if (defined $error_callback) {
      unshift @_, $error_callback;
    }

    $error_callback = sub {
      my $message = shift;
      print STDERR "Error in query, but no error_callback passed!\n$message\n";
    }
  }

  $self->{bindings} = [@_];

  my $parameters =  {
    connect => $self->{connect},
    args => $self->{args},
    columns => $self->{columns},
    tags => $self->{tags},
    description => $self->{description},
    query => $self->{query},
    bindings => $self->{bindings},
    name => $self->{name},
  };
  my $ev = Dispatch::TopHalfAsyncQuery->new_serialized_cmd(
    $parameters, 
    sub {
      my($row) = @_;
      &$row_callback($row);
    },
    sub{
      my($status) = @_;
      &$end_callback($status);
    }
  );
}

sub GetDescription{
  my($this) = @_;
  return $this->{description};
}
sub GetArgs{
  my($this) = @_;
  return $this->{args};
}
sub GetColumns{
  my($this) = @_;
  return $this->{columns};
}
sub GetQuery{
  my($this) = @_;
  return $this->{query};
}
sub GetSchema{
  my($this) = @_;
  return $this->{schema};
}
sub GetType{
  my($this) = @_;
  if($this->{query} =~ /^(\S*)\s/){ return $1 } else { return undef }
}
sub Prepare{
  my($this, $dbh) = @_;
  my $qh = $dbh->prepare($this->{query});
  unless($qh) { die "unable to prepare query: $this->{name}" }
  $this->{handle} = $qh;
}
sub Execute{
  my $this = shift(@_);
  unless($this->{handle}) { die "Execute unprepared $this->{name}" }
  unless($#_ == $#{$this->{args}}){
    my $req = $#{$this->{args}};
    my $sup = $#_;
    die "arg mismatch ($this->{name}): $sup vs $req";
  }
#  print STDERR "Execute $this->{name}:\n";
  return $this->{handle}->execute(@_);
}

#########################
# Class methods
#

sub record_spreadsheet_upload {
  my ($is_executable, $user, $file_id, $rowcount) = @_;
  my $dbh = _get_handle();

  my $qh = $dbh->prepare(qq{
    insert into spreadsheet_uploaded
    (time_uploaded, is_executable, uploading_user, file_id_in_posda, number_rows)
    values (now(), ?, ?, ?, ?)
    returning spreadsheet_uploaded_id
  });
  $qh->execute($is_executable, $user, $file_id, $rowcount);
  my $results = $qh->fetchall_arrayref();

  return $results->[0]->[0];

}

func invoke_subprocess(
  $from_spreadsheet, $from_button, $spreadsheet_uploaded_id,
  $query_invoked_by_dbif_id, $button_name, $command_line, $user,
  $operation_name
) {
  my $dbh = _get_handle();

  my $qh = $dbh->prepare(qq{
    insert into subprocess_invocation
    (from_spreadsheet, from_button, spreadsheet_uploaded_id, 
     query_invoked_by_dbif_id, button_name, command_line, 
     invoking_user, when_invoked, operation_name)
    values (?, ?, ?, ?, ?, ?, ?, now(), ?)
    returning subprocess_invocation_id
  });
  $qh->execute($from_spreadsheet, $from_button, $spreadsheet_uploaded_id,
    $query_invoked_by_dbif_id, $button_name, $command_line, $user,
    $operation_name);
  my $results = $qh->fetchall_arrayref();

  return $results->[0]->[0];
}

sub set_subprocess_pid {
  my ($subprocess_invocation_id, $pid) = @_;
  my $dbh = _get_handle();

  my $qh = $dbh->prepare(qq{
    update subprocess_invocation
    set process_pid = ?
    where subprocess_invocation_id = ?
  });

  $qh->execute($pid, $subprocess_invocation_id);
}

sub record_subprocess_lines {
  my ($subprocess_invocation_id, $lines) = @_;
  my $dbh = _get_handle();

  my $qh = $dbh->prepare(qq{
    insert into subprocess_lines
    values (?, ?, ?)
  });
  my $line_no = 0;
  for my $line (@$lines) {
    $qh->execute($subprocess_invocation_id, $line_no++, $line);
  }
}


sub GetChainedQueries {
  my ($class, $query) = @_;

  # TODO: Add some type of caching to this method!

  my $dbh = _get_handle();
  my $qh = $dbh->prepare(qq{
    select caption, chained_query_id, to_query
    from chained_query 
    where from_query = ?
  });

  $qh->execute($query);

  my $results = $qh->fetchall_arrayref({});

  return $results;
};

sub GetChainedQueryDetails {
  my ($class, $chained_query_id) = @_;

  # TODO: Add some type of caching to this method!

  my $dbh = _get_handle();
  my $qh = $dbh->prepare(qq{
    select
      from_column_name,
      to_parameter_name
    from chained_query_cols_to_params
    where chained_query_id = ?
  });

  $qh->execute($chained_query_id);

  my $results = $qh->fetchall_arrayref({});

  return $results;
}


sub GetRoles {
  my ($self) = @_;
  my $dbh = _get_handle();
  my $qh = $dbh->prepare(qq{
    select role_name
    from role
  });

  $qh->execute();

  my $results = $qh->fetchall_arrayref({});

  # return a simple arrayref
  return [map { 
    $_->{role_name}
  } @$results];
}

sub GetTabsByRole {
  my ($class, $role) = @_;

  # TODO: Add some type of caching to this method!

  my $dbh = _get_handle();
  my $qh = $dbh->prepare(qq{
    select
        qt.query_tab_name,
        qt.query_tab_description,
        qt.defines_dropdown,
        rt.sort_order,
        qt.defines_search_engine
    from role_tabs rt
    join query_tabs qt
      on rt.query_tab_name = qt.query_tab_name
    where role_name = ?
    order by rt.sort_order
  });

  $qh->execute($role);

  my $results = $qh->fetchall_arrayref({});

  return $results;
};
sub GetTabs {
  my ($self) = @_;

  # TODO: Add some type of caching to this method!

  my $dbh = _get_handle();
  my $qh = $dbh->prepare(qq{
    select 
      query_tab_name,
      query_tab_description,
      defines_dropdown,
      sort_order,
      defines_search_engine
    from query_tabs
    order by sort_order
  });

  $qh->execute();

  my $results = $qh->fetchall_arrayref({});

  return $results;
};

sub GetTabFilters {
  my ($class, $tab) = @_;
  # TODO: Add some type of caching to this method!

  my $dbh = _get_handle();
  my $qh = $dbh->prepare(qq{
    select 
      filter_name,
      sort_order
    from query_tabs_query_tag_filter
    where query_tab_name = ?
    order by sort_order
  });

  $qh->execute($tab);

  my $results = $qh->fetchall_arrayref({});

  return $results;

}

sub GetList {
  my ($self) = @_;

  my $dbh = _get_handle();
  my $qh = $dbh->prepare(qq{
    select name 
    from queries
  });

  $qh->execute();

  my $results = $qh->fetchall_arrayref();

  # convert one-column rows into a simple list
  return [map {
   $_->[0];
  } @$results];
};

# Get queires with at least one of the given tags
sub GetQueriesWithTags {
  my ($class, $tags) = @_;
  # TODO: if $tags not arrayref error

  my $dbh = _get_handle();
  # The && operator returns matches that intersect 
  # (special postgres array syntax)
  my $qh = $dbh->prepare(qq{
    select name 
    from queries 
    where tags && ?;
  });

  $qh->execute($tags);

  my $results = $qh->fetchall_arrayref();

  # convert one-column rows into a simple list
  return [map {
   $_->[0];
  } @$results];

}

sub GetOperationsWithTags {
  my ($class, $tags) = @_;
  # TODO: if $tags not arrayref error

  my $dbh = _get_handle();
  # The && operator returns matches that intersect 
  # (special postgres array syntax)
  my $qh = $dbh->prepare(qq{
    select * 
    from spreadsheet_operation 
    where tags && ?
    order by operation_name
  });

  $qh->execute($tags);

  my $results = $qh->fetchall_arrayref();

  # convert one-column rows into a simple list
  # return [map {
  #  $_->[0];
  # } @$results];
  return $results;

}

sub GetOperations {
  my ($self) = @_;

  my $dbh = _get_handle();

  my $qh = $dbh->prepare(qq{
    select * 
    from spreadsheet_operation 
  });

  $qh->execute();

  my $results = $qh->fetchall_arrayref();

  return $results;

}

sub GetOperationDetails {
  my ($class, $operation_name) = @_;

  my $dbh = _get_handle();

  my $qh = $dbh->prepare(qq{
    select * 
    from spreadsheet_operation 
    where operation_name = ?
  });

  $qh->execute($operation_name);

  my $results = $qh->fetchrow_hashref();

  return $results;

}

sub GetPopupsForQuery {
  my ($self, $query_name) = @_;
  my $dbh = _get_handle();

  my $qh = $dbh->prepare(qq{
    select
      popup_button_id,
      name,
      object_class,
      btn_col,
      is_full_table,
      btn_name
    from popup_buttons
    where ? like name
  });

  $qh->execute($query_name);

  my $results = $qh->fetchall_arrayref();

  return $results;
}

# sub Freeze{
#   my($class, $file_name) = @_;
#   my $struct = { queries => \%Queries };
#   my $json = JSON->new();
#   $json->pretty(1);
#   my $fh;
#   open($fh, ">$file_name") or die "can't open file for writing";
#   print $fh $json->encode($struct);
#   close $fh;
# }
# sub Clear{
#   my($class, $file_name) = @_;
#   $Queries = {};
# }

sub GetQuerysWithArg {
  my ($class, $arg) = @_;
  my $dbh = _get_handle();
  # The && operator returns matches that intersect 
  # (special postgres array syntax)
  my $qh = $dbh->prepare(qq{
    select name, description
    from queries 
    where ? = ANY(args)
  });

  $qh->execute($arg);

  my $results = $qh->fetchall_arrayref();

  # convert one-column rows into a simple list
  # return [map {
  #  $_->[0];
  # } @$results];
  return $results;

}


sub GetTags {
  my ($class, $name) = @_;
  my $dbh = _get_handle();

  my $qh = $dbh->prepare(qq{
    select unnest(tags) from queries
    where name = ?
  });

  $qh->execute($name);

  my $results = $qh->fetchall_arrayref();
  return [map {
   $_->[0];
  } @$results];

}

sub GetAllTags{
  my($class) = @_;

  my $dbh = _get_handle();

  my $qh = $dbh->prepare(qq{
    select distinct unnest(tags) from queries
  });

  $qh->execute();

  my $results = $qh->fetchall_arrayref();

  # convert one-column rows into a simple list
  return [map {
   $_->[0];
  } @$results];
}

sub GetAllArgs{
  my($class) = @_;

  my $dbh = _get_handle();

  my $qh = $dbh->prepare(qq{
    select distinct unnest(args) from queries
  });

  $qh->execute();

  my $results = $qh->fetchall_arrayref();

  # convert one-column rows into a simple list
  return [map {
   $_->[0];
  } @$results];
}

# sub Delete{
#   my($class, $q_name) = @_;
#   delete $Queries->{$q_name};
# }
# sub Load{
#   my($class, $file) = @_;
#   my $text = "";
#   my $data;
#   my $cf;

#   unless (open($cf, '<', $file)) {
#     print STDERR "ReadJsonFile:: can not open config file: $file, Error $!.\n";
#     return undef;
#   }

#   # load the file in, ignoring comment lines
#   # NOTE: JSON does not actually allow comments, so they have to be
#   # stripped out here!
#   while (<$cf>) {
#     chomp;
#     unless ($_ =~ m/^\s*\/\//) {
#       $text .= $_;
#     }
#   }
#   close($cf);
#   my $json = JSON->new();
#   $json->relaxed(1);
#   eval {
#     $data = $json->decode($text);
#   };

#   if ($@) {
#     print STDERR "ReadJsonFile:: bad json file: $file.\n";
#     print STDERR "##########\n$@\n###########\n";
#     return undef;
#   }
 
#   unless(exists $data->{queries} && ref($data->{queries}) eq "HASH"){
#     print STDERR "No queries defined in $file\n";
#     return undef;
#   }
#   for my $q (keys %{$data->{queries}}){
#     if(exists $Queries->{$q}){
#       print STDERR "Replacing $q from $file\n";
#     } else {
#       print STDERR "Adding $q from $file\n";
#     }
#     $Queries->{$q} = $data->{queries}->{$q};
#   }
#   return 1;
# }

1;

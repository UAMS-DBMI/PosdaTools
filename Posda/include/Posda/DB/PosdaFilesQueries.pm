package PosdaDB::Queries;

use Modern::Perl;
use Method::Signatures::Simple;

use JSON;
use DBI;

use Posda::Config 'Database';
use Dispatch::EventHandler;

use Posda::DebugLog 'on';
use Data::Dumper;

my $db_handle;
my $db_handle_cache = {};

sub _get_handle {
  if (not defined $db_handle) {
    $db_handle = DBI->connect(Database('posda_queries'));
  }
  return $db_handle;
}

func _get_handle_main($connect) {
  if (not defined $db_handle_cache->{$connect}) {
    $db_handle_cache->{$connect} = DBI->connect($connect)
      or die "Could not connect to DB with connect string: $connect";
  }

  return $db_handle_cache->{$connect};
}

method GetQueryInstance($class: $name) {
  return PosdaDB::Queries->new($name, 0);
};
method GetQueryInstanceAsync($class: $name) {
  return PosdaDB::Queries->new($name, 1);
};

method new($class: $name, $async) {
  my $self = {
    dbh => undef,
    async => $async
  };

  bless $self, $class;

  $self->_load_query($name);

  return $self;
};

method MakeStorable() {
  $self->{dbh} = undef;
}

method Save() {
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

func Clone($source_name, $dest_name) {
  my $dbh = _get_handle();
  my $qh = $dbh->prepare(qq{
    insert into queries
    select ?, query, args, columns, tags, schema, description
    from queries
    where name = ?
  });

  $qh->execute($dest_name, $source_name);

}

func Delete($name) {
  my $dbh = _get_handle();
  my $qh = $dbh->prepare(qq{
    delete from queries where name = ?
  });

  $qh->execute($name);
}

method _load_query($name) {
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

method SetAsync($async) {

  if (not defined $async) {
    $async = 1;
  }

  $self->{async} = $async;
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

  if ($self->{async}) {
    return $self->_RunQueryAsync(@_);
  } else {
    return $self->_RunQueryBlocking(@_);
  }
}

sub _RunQueryBlocking {
  my($self) = shift;
  my $row_callback = shift;
  my $end_callback = shift;

  my $dbh = _get_handle_main($self->{connect});

  if (not defined $self->{handle}) {
    $self->Prepare($dbh);
  }

  my $select = ($self->{query} =~ /^select/i)? 1:0;

  my $rows_affected = $self->Execute(@_);

  if ($select) {
    # return the results
    while(my $h = $self->{handle}->fetchrow_arrayref){
      &$row_callback($h);
    }
  } else {
    &$row_callback([$rows_affected]);
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

method GetChainedQueries($class: $query) {

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

method GetChainedQueryDetails($class: $chained_query_id) {

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



method GetTabs($class:){

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

method GetTabFilters($class: $tab) {
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

method GetList($class:){

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
method GetQueriesWithTags($class: $tags) {
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

method GetOperationsWithTags($class: $tags) {
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
method GetOperations($class:) {

  my $dbh = _get_handle();

  my $qh = $dbh->prepare(qq{
    select * 
    from spreadsheet_operation 
  });

  $qh->execute();

  my $results = $qh->fetchall_arrayref();

  return $results;

}

method GetPopupsForQuery($query_name) {
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

method GetQuerysWithArg($class: $arg) {
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


method GetTags($class: $name) {
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

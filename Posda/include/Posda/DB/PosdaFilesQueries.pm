package PosdaDB::Queries;

use Modern::Perl;
use Method::Signatures::Simple;

use JSON;
use DBI;

use Posda::Config 'Database';
use Dispatch::EventHandler;

use Data::Dumper;

my $db_handle;

sub _get_handle {
  if (not defined $db_handle) {
    $db_handle = DBI->connect(Database('posda_queries'));
  }
  return $db_handle;
}

method GetQueryInstance($class: $name) {
  return PosdaDB::Queries->new($name, 0);
};
method GetQueryInstanceAsync($class: $name) {
  return PosdaDB::Queries->new($name, 1);
};

method new($class: $name, $async) {
  my $self = {
    dbh => DBI->connect(Database('posda_queries')),
    async => $async
  };

  bless $self, $class;

  $self->_load_query($name);

  return $self;
};

method MakeStorable() {
  $self->{dbh} = undef;
}

method _load_query($name) {
  my $qh = $self->{dbh}->prepare(qq{
    select * 
    from queries
    where name = ?
  });

  $qh->execute($name);

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

sub RunQuery {
  my $self = shift;

  say "Async set to: $self->{async}";

  if ($self->{async}) {
    return $self->_RunQueryAsync(@_);
  } else {
    return $self->_RunQueryBlocking(@_);
  }
}

sub _RunQueryBlocking {
  print "RunQueryBlocking\n";
  my($self) = shift;
  my $row_callback = shift;
  my $end_callback = shift;

  my $dbh = DBI->connect($self->{connect});

  if (not defined $self->{handle}) {
    $self->Prepare($dbh);
  }

  $self->Execute(@_);

  # return the results
  while(my $h = $self->{handle}->fetchrow_arrayref){
    &$row_callback($h);
  }
  if(ref($end_callback) eq "CODE"){
    &$end_callback();
  }
}

sub _RunQueryAsync {
  print "RunQueryAsync\n";
  my($self) = shift;
  my $row_callback = shift;
  my $end_callback = shift;

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
      for my $row (@{$result->{Rows}}) {
        &$row_callback($row);
      }
      &$end_callback();
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
  return $this->{handle}->execute(@_);
}

#########################
# Class methods

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

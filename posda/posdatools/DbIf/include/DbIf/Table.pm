package DbIf::Table;

use Modern::Perl '2010';

use List::MoreUtils 'first_index';
use File::Basename 'basename';

use Data::Dumper;

##########################################
sub test {
  say 'testing';

  # simple
  my $table = DbIf::Table->new();
  say Dumper($table);


  #from a query
  my $query = {
    columns => ['first_name', 'last_name', 'age'],
  };

  my $struct = {
    Rows => [
      ['Quasar', 'Jarosz', 34],
      ['Joseph', 'Utecht', 28],
      ['Emel', 'Şeker', 21],
    ]
  };

  my $t2 = DbIf::Table::from_query($query, $struct, time);
  $t2->add_filter('last_name', 'e');
  $t2->add_filter('first_name', 'm');
  $t2->print;

  $t2->add_filter('first_name', undef);
  $t2->print;

  $t2->clear_filters;
  $t2->print;


  # test csv
  my $csv_struct = {
    rows => [
      ['first_name', 'last_name', 'age'],
      ['Quasar', 'Jarosz', 34],
      ['Joseph', 'Utecht', 28],
      ['Emel', 'Şeker', 21],
    ]
  };

  my $t3 = DbIf::Table::from_csv('/tmp/some/file.csv', $csv_struct, time);
  # say Dumper($t3);
  $t3->print;
  

}
##########################################
sub from_csv {
  my ($filename, $struct, $start_time) = @_;
  my $rows = $struct->{rows};
  my $columns = shift @$rows;

  my $table = DbIf::Table->new(
    'FromCsv',
    $start_time,
    $columns,
    $rows
  );

  $table->{file} = $filename;
  $table->{basename} = basename($filename);

  return $table;
}

sub from_query {
  my ($query, $struct, $start_time) = @_;
  my $table = DbIf::Table->new(
    'FromQuery',
    $start_time,
    $query->{columns},
    $struct->{Rows}
  );

  $table->{query} = $query;
  return $table;
}
sub new {
  my ($class, $type, $start_time, $columns, $rows) = @_;
  if (not defined $rows) { $rows = [] }
  if (not defined $columns) { $columns = [] }
  if (not defined $start_time) { $start_time = time }

  my $self = {
    type => $type,
    at => $start_time,
    duration => time - $start_time,
    columns => $columns,
    rows => $rows,
    filters => {}
  };

  bless $self, $class;

  return $self;
}
sub print {
  my ($self) = @_;
  say qq{#####################################################################
DbIf::Table:
  Type: $self->{type}
  Began at: $self->{at}
  Duration: $self->{duration}

Full data follows.
};

  # Actually print the table, as csv data
  say join(',', @{$self->{columns}});
  for my $row (@{$self->{rows}}) {
    say join(',', @$row);
  }

  say '#####################################################################';
}

sub clear_filters {
  my ($self) = @_;
  $self->{filters} = undef;
  $self->apply_filters;
}

sub add_filter {
  my ($self, $column_name, $filter_regex) = @_;
  $self->{filters}->{$column_name} = $filter_regex;
  $self->apply_filters;

}

sub apply_filters {
  my ($self) = @_;
  if (not defined $self->{original_rows}) {
    $self->{original_rows} = $self->{rows};
  }

  # Reset all filters
  $self->{rows} = $self->{original_rows};

  for my $col (keys %{$self->{filters}}) {
    $self->apply_single_filter($col, $self->{filters}->{$col});
  }

}

sub apply_single_filter {
  my ($self, $column_name, $filter_regex) = @_;
  if (not defined $filter_regex or
      $filter_regex eq '') {
      return;
  }

  my $column_index = first_index {$_ eq $column_name} @{$self->{columns}};

  if (not defined $self->{original_rows}) {
    $self->{original_rows} = $self->{rows};
  }

  $self->{rows} = [grep {
    $_->[$column_index] =~ /$filter_regex/
  } @{$self->{rows}}];
}

1;

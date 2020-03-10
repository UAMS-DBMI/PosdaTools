package ActivityBasedCuration::PopupHelp;

use Modern::Perl;

use Posda::PopupWindow;
use Posda::Config ('Config','Database');

use Dispatch::LineReader;

use Data::Dumper;
use DBI;
use HTML::Entities;
use Posda::DB ("Query");

use File::Find 'find';

use vars qw( @ISA );
@ISA = ("Posda::PopupWindow");

my $db_handle;

sub SpecificInitialize {
  my ($self, $params) = @_;
  $self->{params} = $params;
  my ($name) = @$params;
  $self->{title} = "Help for command: $name";

  Query('GetSpreadsheetOperationByName')->RunQuery(sub {
    my($row) = @_;
    my($name, $command_line, $operation_type, $input_line_format, $tags, $can_chain) = @$row;
    $self->{name} = $name;
    $self->{cmdline} = encode_entities($command_line);
    $self->{op_type} = $operation_type;
    if (defined $input_line_format) {
      $self->{input_fmt} = encode_entities($input_line_format);
    } else {
      $self->{input_fmt} = ''
    }
    if (defined $tags) {
      $self->{tags} = join(', ', @$tags);
    } else {
      $self->{tags} = '';
    }
  }, sub {}, $name);


  # attempt to guess what the command is, given the cmdline
  my $command = $name;
  for my $i (split(' ', $self->{cmdline})) {
    $command = $i;
    last;
  }
  # if it's still not defined it probably had no spaces, so just
  # take the whole thing
  if (not defined $command) {
    $command = $self->{cmdline};
  }
  $self->{command} = $command;

  # execute the command with -h
  #

  eval {
    my @lines;
    Dispatch::LineReader->new_cmd(
      "$command -h 2>&1",  # Because the commands print -h to STDERR
      sub {
  my ($line) = @_;
        push @lines, $line;
      },
      sub {
        $self->{lines} = \@lines;
        $self->AutoRefresh;
      }
    );
  };

  if ($@) {
    $self->{lines} = [
      'Error executing command!', 
      'This probably means the script does not exist on this host.'
    ];
    $self->AutoRefresh;
  }
}

sub ContentResponse {
  my ($self, $http, $dyn) = @_;
  $http->queue(qq{
    <h2>$self->{command} Help</h2>
    <div class="panel panel-info">
      <div class="panel-heading">
        Below is the result of running the above named
        command with <span>-h</span>
      </div>
      <div class="panel-body">
  });
  if (defined $self->{lines}) {
    $http->queue("<pre>");
    if ($#{$self->{lines}} < 1) {
      $http->queue("Command produced no output! Perhaps you should ask the author to write a -h response?");
    }
    for my $line (@{$self->{lines}}) {
      $http->queue(encode_entities("$line\n"));
    }
    $http->queue("</pre>");
  } else {
    $http->queue('Waiting on command...');
  }

  $http->queue(qq{
      </div>
    </div>

    <div class="panel panel-default">
    <div class="panel-heading">
      Command details from database
    </div>

    <table class="table">
      <tr>
        <th>Name</th>
        <td>$self->{name}</td>
      </tr>
      <tr>
        <th>Command Line</th>
        <td>$self->{cmdline}</td>
      </tr>
      <tr>
        <th>Operation Type</th>
        <td>$self->{op_type}</td>
      </tr>
      <tr>
        <th>Input Format</th>
        <td>$self->{input_fmt}</td>
      </tr>
      <tr>
        <th>Associated Tags</th>
        <td>$self->{tags}</td>
      </tr>
    </table>
    </div>

    <div class="panel panel-default">
      <div class="panel-heading">
        Full code of command
      </div>
      <div class="panel-body">
        <pre>${\$self->GetCommandCode($self->{command})}</pre>
      </div>
    </div>
  });
}

sub GetCommandCode {
  my ($self, $filename) = @_;
  if (not defined $self->{command_code}) {
    $self->{command_code} = 
      encode_entities($self->GetCommandCode_PreCache($filename));
  }

  return $self->{command_code};
}

sub GetCommandCode_PreCache {
  my ($self, $filename) = @_;
  my $possible_locations = [
    'Posda/bin',
    'bin'
  ];

  # Test to see if it's in any of the possible paths
  for my $loc (@$possible_locations) {
    if (-e "$loc/$filename") {
      return read_contents("$loc/$filename");
    }
  }

  # If it's not there, try a recursive search of the whole
  # code path.
  my $found;

  # Using ugly goto-ish syntax to escape from find early
  # Note this generates a warning in the log output
  SEARCH: {
    find({no_chdir => 1, wanted => sub {
        if ($_ =~ $self->{command}) {
          $found = $File::Find::name;
          last SEARCH;
        }
    }}, '.');
  }

  if (defined $found) {
    return read_contents($found);
  } else {
    # If it's still not there, nothing we can do
    return "Command could not be found :(";
  }
}

sub read_contents {
  my ($filename) = @_;
  my $content;
  local $/ = undef;

  eval {
    open FILE, $filename or die "Failed to open file: $filename";
    binmode FILE;
    $content = <FILE>;
    close FILE;
  };
  if ($@) {
    return "$@";
  } else {
    return $content;
  }
}

sub MenuResponse {
  my ($self, $http, $dyn) = @_;
}

1;

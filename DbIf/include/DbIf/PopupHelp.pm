package DbIf::PopupHelp;

use Modern::Perl;
use Method::Signatures::Simple;

use Posda::PopupWindow;
use Posda::Config ('Config','Database');

use Dispatch::LineReader;

use Data::Dumper;
use DBI;
use HTML::Entities;

use vars qw( @ISA );
@ISA = ("Posda::PopupWindow");

my $db_handle;

method SpecificInitialize($params) {
  my ($name, $cmdline, $op_type, $input_fmt, $tags) = @$params;
  $self->{title} = "Help for command: $name";
  $self->{name} = $name;
  $self->{cmdline} = encode_entities($cmdline);
  $self->{op_type} = $op_type;

  if (defined $input_fmt) {
    $self->{input_fmt} = encode_entities($input_fmt);
  } else {
    $self->{input_fmt} = ''
  }

  if (defined $tags) {
    $self->{tags} = join(', ', @$tags);
  } else {
    $self->{tags} = '';
  }

  # attempt to guess what the command is, given the cmdline
  my $command;
  for my $i (split(' ', $cmdline)) {
    $command = $i;
    last;
  }
  # if it's still not defined it probably had no spaces, so just
  # take the whole thing
  if (not defined $command) {
    $command = $cmdline;
  }
  $self->{command} = $command;

  # execute the command with -h
  #

  my @lines;
  Dispatch::LineReader->new_cmd(
    "$command -h 2>&1",  # Because the commands print -h to STDERR
    func($line) {
      push @lines, $line;
    },
    func() {
      say STDERR "Finished reading command -h"; 
      $self->{lines} = \@lines;
      $self->AutoRefresh;
    }
  );
}

method ContentResponse($http, $dyn) {
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
  });


}

method MenuResponse($http, $dyn) {
}

1;

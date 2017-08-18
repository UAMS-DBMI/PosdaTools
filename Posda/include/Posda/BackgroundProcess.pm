package Posda::BackgroundProcess;

use Modern::Perl;
use Method::Signatures::Simple;

use FileHandle;

use Posda::DB::PosdaFilesQueries;

sub new {
  my($class, $invoc_id, $notify) = @_;
  my $this = {
    invoc_id => $invoc_id,
    notify => $notify,
    child_pid => $$,
    command_line => $0,
    script_start_time => time,
    input_line_query => PosdaDB::Queries->GetQueryInstance("CreateBackgroundInputLine"),
    input_line_no => 0
  };
  bless($this, $class);

  $this->StartBackgroundProcess($invoc_id, $this->{command_line},
                                $this->{child_pid}, $notify);

  return $this;
}

sub ForkAndExit {
  my ($this) = @_;
  PosdaDB::Queries->reset_db_handles();
  $this->{input_line_query} = undef;

  # This appears to be the proper way to fork, and release discriptors 
  # so the parent is released but the child still functions
  shutdown STDOUT, 1;
  if(fork){
    close STDIN;
    close STDOUT;
    exit;
  }

  $this->{grandchild_pid} = $$;


  # Setup various queries for later use
  my($add_time_rows_to_bkgrnd, $add_bgrnd_sub_error, $add_comp_to_bgrnd_sub);

  eval {
    $add_bgrnd_sub_error = PosdaDB::Queries->GetQueryInstance(
      "AddErrorToBackgroundProcess");
  };
  if($@){
    die "############ Subprocess die-ing silently\n" .
        "Can't get query to record error:\n" .
        "\tCreateBackgroundSubprocessError\n" .
        "($@)\n" .
        "#######################################\n";
  }
  eval {
    $add_time_rows_to_bkgrnd = PosdaDB::Queries->GetQueryInstance(
      "AddBackgroundTimeAndRowsToBackgroundProcess");
    $add_comp_to_bgrnd_sub = PosdaDB::Queries->GetQueryInstance(
      "AddCompletionTimeToBackgroundProcess");
  };
  if($@){
    print STDERR "#######################################\n";
    print STDERR "Error: $@\n";
    print STDERR "#######################################\n";
    $add_bgrnd_sub_error->RunQuery(sub{},sub{},
      $@, $this->{background_id}
    );
    die "Script errored with update to table ($@)";
  }

  $this->{add_time_rows_query} = $add_time_rows_to_bkgrnd;
  $this->{add_comp_time_query} = $add_comp_to_bgrnd_sub;
  $this->{add_sub_error_query} = $add_bgrnd_sub_error;

  # Setup email handle
  my $EmailHandle = FileHandle->new("|mail -s \"Posda Job Complete\" $this->{notify}");
  unless($EmailHandle) { die "Couldn't open email handle ($!)" }
  $this->{email_handle} = $EmailHandle;

  return; # only the grandchild returns
}

sub WriteToEmail {
  my ($this, $line) = @_;

  $this->{email_handle}->print($line);
}

sub LogCompletionTime {
  my ($this) = @_;

  $this->{add_comp_time_query}->RunQuery(
    sub{}, sub{}, $this->{background_id});
}

sub LogError {
  my ($this, $error) = @_;

  #TODO: something is wrong with this!
  print STDERR "Logging error: $error\n";
  $this->{add_sub_error_query}->RunQuery(sub{}, sub{},
      $error, $this->{background_id}
    );
}

sub LogInputCount {
  my ($this, $count) = @_;

  $this->{add_time_rows_query}->RunQuery(sub {}, sub{},
    $count, $this->{grandchild_pid}, $this->{background_id}
  );
}

sub LogInputLine {
  my ($this, $line) = @_;
  $this->{input_line_query}->RunQuery(
    sub{}, sub{}, $this->{background_id}, $this->{input_line_no}, $line);
  $this->{input_line_no} += 1;
}

sub GetBackgroundID{
  my ($this) = @_;
  return $this->{background_id};
}

sub StartBackgroundProcess {
  my ($this, $invoc_id, $command_line, $child_pid, $notify) = @_;

  my $bkgrnd_id;
  my $q1 = PosdaDB::Queries->GetQueryInstance("CreateBackgroundSubprocess");
  $q1->RunQuery(sub{}, sub{}, $invoc_id, $command_line, $child_pid, $notify);


  # TODO: RunQuery currently won't return rows from an insert, even
  # if the query has a 'returning' clause. fix it?
  my $q2 = PosdaDB::Queries->GetQueryInstance("GetBackgroundSubprocessId");
  $q2->RunQuery(sub{my($row) = @_;  $bkgrnd_id = $row->[0];}, sub{});
  print STDERR "## New background id is: $bkgrnd_id\n";

  unless(defined $bkgrnd_id){
    my $error = "Error: unable to create row in background_subprocess";
    print "$error\n";
    die $error;
  }

  my $q3 = PosdaDB::Queries->GetQueryInstance("CreateBackgroundSubprocessParam");
  for my $i (0 .. $#ARGV){
    $q3->RunQuery(sub {}, sub {}, $bkgrnd_id, $i, $ARGV[$i]);
  }

  $this->{background_id} = $bkgrnd_id;
  return $bkgrnd_id;
}

1;

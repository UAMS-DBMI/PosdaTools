package Posda::Log;
# This is a very simple logging library.
# Usage is simple:
#
# use Posda::Log;  # ensure this comes AFTER your package declaration!
#
# # Or, if you want to use a custom name for the logger:
# use Posda::Log "logger_name";
#
# Logging functions will then be imported as below:
# These levels are supported, Low to High:
#
# DEBUG
# INFO
# WARN
# ERROR
# FATAL
#
# If given,  logger_name will be printed instead of the calling module.

my $configured;

sub import {
  no strict 'refs';

  my ($this, $logger_name) = @_;

  # If a logger name is not used, just use the caller's name
  # This is probably what the user wants 99% of the time anyway.
  if (not defined ($logger_name)) {
    $logger_name = caller;
  }

  my $caller = caller;

  # Manually build a set of closures in the caller's namespace
  *{ "${caller}::DEBUG" } = sub {
    dispatch_message(0, "$logger_name: @_");
  };
  *{ "${caller}::INFO" } = sub {
    dispatch_message(1, "$logger_name: @_");
  };
  *{ "${caller}::WARN" } = sub {
    dispatch_message(2, "$logger_name: @_");
  };
  *{ "${caller}::ERROR" } = sub {
    dispatch_message(3, "$logger_name: @_");
  };
  *{ "${caller}::FATAL" } = sub {
    dispatch_message(4, "$logger_name: @_");
  };
}


{ # inline package def
  package Posda::Log::Output;

  sub new {
    my ($class, $args) = @_;

    $this = {
      level => $args->{level},
      output => $args->{output}
    };

    return bless $this, $class;
  }

  sub print {
    # Print if level is <= our level
    my ($this, $level, $message) = @_;

    # only print the date prefix to files
    my $prefix = "";
    if ($this->{output} ne STDOUT) {
      $prefix = gmtime() . ": ";
    }

    if ($level >= $this->{level}) {
      print {$this->{output}} "$prefix$message";
    }
  }
};

our @names = qw(DEBUG INFO WARN ERROR FATAL);
our @outputs = ();

sub init {
  my ($filename) = @_;

  my $screen = Posda::Log::Output->new({
      level => 0,
      output => STDOUT
  });
  push @outputs, $screen;

  # TODO: This should be configurable
  # Maybe pass in a list of Log::Output objects?
  if (defined($filename)) {
    open(my $FH, ">>", $filename);
    print {$FH} gmtime() . ": Logfile Opened\n";
    my $file = Posda::Log::Output->new({
        level => 1,
        output => $FH
    });
    push @outputs, $file;
  }
  $configured = 1;
}

sub init_screen_only {
  my $screen = Posda::Log::Output->new({
      level => 0,
      output => STDOUT
  });
  push @outputs, $screen;

  $configured = 1;
}

sub dispatch_message {
  my $level = shift @_;
  if (not defined($configured)){
    init_screen_only();
    dispatch_message(2, "Explicit Posda::Log::init not called, defaulting to screen-only output!");
  }

  # apply rules based on current setting
  my $level_name = $names[$level];

  # Simply print to every output
  foreach my $output (@outputs) {
    $output->print($level, "$level_name: @_\n");
  }
}

1;
# vim: set foldmethod=marker ts=2 shiftwidth=2 expandtab:

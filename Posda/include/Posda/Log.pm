package Posda::Log;
# This is a very simple logging library.
#
# These levels are supported, Low to High:
# 0 DEBUG
# 1 INFO
# 2 WARN
# 3 ERROR
# 4 FATAL

require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(DEBUG INFO WARN ERROR FATAL);
my $configured;

sub DEBUG {#{{{
  dispatch_message(0, @_);
}
sub INFO {
  dispatch_message(1, @_);
}
sub WARN {
  dispatch_message(2, @_);
}
sub ERROR {
  dispatch_message(3, @_);
}
sub FATAL {
  dispatch_message(4, @_);
}#}}}


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
  $level = shift @_;
  if (not defined($configured)){
    init_screen_only();
    WARN "Explicit Posda::Log::init not called, defaulting to screen-only output!";
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

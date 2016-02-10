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
use Cwd 'abs_path';

@ISA = qw(Exporter);
@EXPORT = qw(DEBUG INFO WARN ERROR FATAL);
my $configured;

sub DEBUG {#{{{
  dispatch_message(0, scalar caller, @_);
}
sub INFO {
  dispatch_message(1, scalar caller, @_);
}
sub WARN {
  dispatch_message(2, scalar caller, @_);
}
sub ERROR {
  dispatch_message(3, scalar caller, @_);
}
sub FATAL {
  dispatch_message(4, scalar caller, @_);
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
      #print "Prefix set, so this isn't STDOUT!!\n";
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
    $abs_path = abs_path($filename);
    print "Posda::Log opening log file at: $abs_path\n";
    open(my $FH, ">>", $abs_path);
    print {$FH} gmtime() . ": Logfile Opened\n";
    my $file = Posda::Log::Output->new({
        level => 0,
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
  $caller = shift @_;

  if (not defined($configured)){
    init_screen_only();
    dispatch_message(2, $caller, "Explicit Posda::Log::init not called, defaulting to screen-only output!");
  }

  # apply rules based on current setting
  my $level_name = $names[$level];

  # Simply print to every output
  foreach my $output (@outputs) {
    $output->print($level, "$level_name: $caller: @_\n");
  }
}

1;
# vim: set foldmethod=marker ts=2 shiftwidth=2 expandtab:

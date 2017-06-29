package Dispatch::LineReaderWriter;

use Method::Signatures::Simple;
use Modern::Perl;

# Execute the command, sending all data one line at
# a time, and collecting the output into an array,
# and pass that finished array to $finished_callback
# at the end.
func write_and_read_all($class: $cmd, $data, $finished_callback) {
  # create an instance of EventHandler.
  # It lacks a new() for who-knows-why and I don't
  # want to subclass it.
  my $handler = bless {}, 'Dispatch::EventHandler';

  my($fh, $pid) = $handler->ReadWriteChild($cmd);
  Dispatch::Select::Socket->new(
    func($dispatch, $sock) {
      if (my $line = shift @$data) {
        my $bytes_written = syswrite $sock, "$line\n";
      } else {
        # remove from the queue when out of data to write
        shutdown($sock, 1);
        $dispatch->Remove("writer");
      }
    },
    $fh)->Add("writer");

  # Attach a line reader directly to the fh
  my @results;
  Dispatch::LineReader->new_fh($fh,
    func($line) {
      push @results, $line;
    },
    func() {
      ($finished_callback)->(\@results, $pid);
    }, 
    $pid
  );
}

1;

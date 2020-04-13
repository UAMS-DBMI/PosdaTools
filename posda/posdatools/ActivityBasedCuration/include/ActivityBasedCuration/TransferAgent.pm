#!/usr/bin/perl -w
use strict;
package ActivityBasedCuration::TransferAgent;
use Posda::DB qw(Query);
use Debug;
my $dbg = sub { print STDERR @_ };
sub new {
  my($class, $export_event_id, $num_files, $configuration, $protocol_specific_params) = @_;
  my $this = {
    export_event_id => $export_event_id,
    num_files => $num_files,
    config => $configuration,
    params => $protocol_specific_params
  };

  print STDERR "Transfer Agent ($class): ";
  Debug::GenPrint($dbg, $this, 1);
  print STDERR "\n";
  return bless  $this, $class;
}

# Override this method

sub TransferAnImage{
  my($this, $file_id, $file_location, $protocol_specific_file_params) = @_;
  die "The method TransferAnImage needs to be overridden is classes " .
    "derived from ActivityBasedCuration::TransferAgent";
};
1;

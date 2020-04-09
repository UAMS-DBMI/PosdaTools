#!/usr/bin/perl -w
use strict;
package ActivityBasedCuration::SimulateSlowSend;
use Posda::DB qw(Query);
sub new {
  my($class) = @_;
  my $this = {
  };
  return bless  $this, $class;
}
sub TransferAnImage{
  my($this, $export_event_id, $file_id, $file_location) = @_;

#  sleep 1;

  Query("SetFileExportComplete")->RunQuery(sub{},sub{},
    "success", $export_event_id, $file_id);
};
1;

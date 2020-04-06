#!/usr/bin/perl -w
use strict;
package ActivityBasedCuration::SimulateSlowSend;
use Posda::DB qw(Query);
sub new {
  my($class, $export_event_id, $waiting_files,
    $pending_files, $transferred_files, 
    $failed_permanent_files, $failed_temporary_files) = @_;
  my $this = {
    export_event_id => $export_event_id,
    pending_files => $pending_files,
    transferred_files => $transferred_files,
    failed_permanent_files => $failed_permanent_files,
    failed_temporary_files => $failed_temporary_files,
  };
  return bless  $this, $class;
}
sub TransferAnImage{
  my($this, $export_event_id, $file_id, $file_location) = @_;
  unless(exists $this->{pending_files}->{$file_id}){
    return;
  }
  my $info = $this->{pending_files}->{$file_id};
  delete $this->{pending_files}->{$file_id};
  sleep(10);
  $this->{transferred_files}->{$file_id} = $info;
  Query("SetFileExportComplete")->RunQuery(sub{},sub{},
    "success", $export_event_id, $file_id)
};
1;

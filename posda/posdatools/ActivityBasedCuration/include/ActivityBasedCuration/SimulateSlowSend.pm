#!/usr/bin/perl -w
use strict;
package ActivityBasedCuration::SimulateSlowSend;
use ActivityBasedCuration::TransferAgent;
use vars qw( @ISA );
@ISA = ("ActivityBasedCuration::TransferAgent");
use Posda::DB qw(Query);

sub TransferAnImage{
  my($this, $file_id, $file_location, $delete_after_transfer, $protocol_specific_file_params) = @_;

  if(defined($this->{config}->{sleep_time})){
    sleep $this->{config}->{sleep_time};
  }

  Query("SetFileExportComplete")->RunQuery(sub{},sub{},
    "success", $this->{export_event_id}, $file_id);
  if($delete_after_transfer) {
    print STDERR "Deleting $file_location\n";
    unlink($file_location);
  } else {
    print STDERR "Not Deleteing $file_location\n";
  }
};
1;

#!/usr/bin/perl -w
use strict;
package ActivityBasedCuration::NbiaTransferAgent;
use ActivityBasedCuration::TransferAgent;
use vars qw( @ISA );
@ISA = ("ActivityBasedCuration::TransferAgent");
use Posda::DB qw(Query);

sub TransferAnImage{
  my($this, $file_id, $file_location, $protocol_specific_file_params) = @_;

  if(defined($this->{config}->{sleep_time})){
    sleep $this->{config}->{sleep_time};
  }

  Query("SetFileExportComplete")->RunQuery(sub{},sub{},
    "success", $this->{export_event_id}, $file_id);
};
1;

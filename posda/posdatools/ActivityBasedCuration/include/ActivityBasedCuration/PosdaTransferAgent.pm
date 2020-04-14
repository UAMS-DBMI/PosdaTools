#!/usr/bin/perl -w
use strict;
package ActivityBasedCuration::PosdaTransferAgent;
use ActivityBasedCuration::TransferAgent;
use vars qw( @ISA );
@ISA = ("ActivityBasedCuration::TransferAgent");
use Posda::DB qw(Query);

sub TransferAnImage{
  my($this, $file_id, $file_location, $delete_after_transfer, $protocol_specific_file_params) = @_;

  Query("SetFileExportComplete")->RunQuery(sub{},sub{},
    "success", $this->{export_event_id}, $file_id);
  if($delete_after_transfer){
    unlink($file_location);
  }
};
1;

#!/usr/bin/perl -w
use strict;
package ActivityBasedCuration::NbiaTransferAgent;
use ActivityBasedCuration::TransferAgent;
use vars qw( @ISA );
@ISA = ("ActivityBasedCuration::TransferAgent");
use Posda::DB qw(Query);
use Debug;
my $dbg = sub { print STDERR @_};

sub TransferAnImage{
  my($this, $file_id, $file_location, $delete_after_transfer, $protocol_specific_file_params) = @_;


  print STDERR "###################\n";
  print STDERR "In NBIA TransferAnImage($file_id, $file_location, $delete_after_transfer, ";
  Debug::GenPrint($dbg, $protocol_specific_file_params, 1);
  print STDERR ");\n";
  
  my $from_path;
  Query("GetFilePath")->RunQuery(sub {
    my($row) = @_;
    $from_path = $row->[0];
  }, sub {}, $file_id);

  open FILE, "LongCondensedDicomDiffReport.pl $from_path $file_location|";
  while(my $line = <FILE>){
    print STDERR $line;
  }

  Query("SetFileExportComplete")->RunQuery(sub{},sub{},
    "success", $this->{export_event_id}, $file_id);
  if($delete_after_transfer){
    print STDERR "Modified file (NOT deleted, but should have been): $file_location\n";
    #unlink($file_location);
  } else {
    print STDERR "Modified file (not deleted): $file_location\n";
  }
  print STDERR "###################\n";
};
1;

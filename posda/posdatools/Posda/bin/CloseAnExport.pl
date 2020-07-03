#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use ActivityBasedCuration::PosdaTransferAgent;
use JSON;

my $usage = <<EOF;
CloseAnExport.pl.pl <?bkgrnd_id?> <activity_id> <export_event_id> <notify>
  activity_id - activity id
  export_event_id -  export_event_id
  notify - email address for completion notification

uses queries:
  ExportDestinationInfoByExportId

Expects nothing on STDIN

EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}

unless($#ARGV == 3){
  print "$usage\n";
  die "######################## subprocess failed to start:\n" .
      "$usage\n" .
      "#####################################################\n";
}
my($invoc_id, $act_id, $export_event_id, $notify) = @ARGV;

#  export_destination_name,
#  destination_import_event_id,
#  destination_import_event_closed,
#  protocol,
#  base_url,
#  configuration,
#  num_files


my($export_destination_name, $destination_import_event_id, $destination_import_event_closed,
  $protocol, $base_url, $config_string, $export_destination_config, $num_files);
Query("ExportDestinationInfoByExportId")->RunQuery(sub{
  my($row) = @_;
  ($export_destination_name, $destination_import_event_id, $destination_import_event_closed,
    $protocol, $base_url, $config_string, $export_destination_config, $num_files) = @$row;
}, sub {}, $export_event_id);
unless($protocol eq "posda"){
  print "Only exports with protocol \"posda\" are eligible for closing\n";
  exit;
}
if($destination_import_event_closed){
  print "Export event $export_event_id is already closed\n";
  exit;
}

if(defined $config_string) {
  $export_destination_config = decode_json($config_string);
}
print "\nEntering background to close export_event $export_event_id\n";

my $bg = Posda::BackgroundProcess->new($invoc_id, $notify, $act_id);
$bg->Daemonize;

my $prot_parms = { destination_import_event_id  => $destination_import_event_id };
my $prot_hand = ActivityBasedCuration::PosdaTransferAgent->new($export_event_id, $base_url, $num_files,
  $export_destination_config, $prot_parms);
my $start = time;
my $date = `date`;
$bg->WriteToEmail("Closing export_event:\n" .
  " Export_event: $export_event_id\n" .
  " Export Destination Name: $export_destination_name\n" .
  " Destination Import Id: $destination_import_event_id\n"
);
print STDERR "Closing export_event:\n" .
  " Export_event: $export_event_id\n" .
  " Export Destination Name: $export_destination_name\n" .
  " Destination Import Id: $destination_import_event_id\n";
my $status;
eval { $status = $prot_hand->CloseImportEvent() };
if($@){
  print STDERR "CloseImportEvent threw: \"$@\"\n";
  $bg->WriteToEmail("CloseImportEvent threw: \"$@\"\n");
}
print STDERR "Attempted Close of Event Id: $export_event_id:\n$status\n"; 
$bg->WriteToEmail("Attempted Close of Event Id: $export_event_id:\n$status\n");

$bg->Finish($status);

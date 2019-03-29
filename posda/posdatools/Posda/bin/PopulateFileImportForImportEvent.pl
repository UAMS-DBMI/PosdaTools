#!/usr/bin/perl -w
use strict;
use Posda::BackgroundProcess;
use Posda::DB 'Query';

my $usage = <<EOF;
PopulateFileImportForImportEvent.pl <?bkgrnd_id?> <import_event_id> <notify>
or
PopulateFileImportForImportEvent.pl -h

Expects lines of the following format on STDIN:

<file_name>&<digest>

Generates a csv report file

EOF

$|=1;

unless($#ARGV == 2 ){ die $usage }

my ($invoc_id, $import_id, $notify) = @ARGV;

my $back = Posda::BackgroundProcess->new($invoc_id, $notify);


my @Files;
while(my $line = <STDIN>){
  chomp $line;
  my($file, $digest) = split(/&/, $line);
  push @Files, [$file, $digest];
}
my $num_files = @Files;
print "$num_files files identified\n";

$back->Daemonize;;

my $get_file_id = Query("GetFileIdByDigest");
my $get_path = Query("GetLoadPathByImportEventIdAndFileId");
my $set_path = Query("SetLoadPathByImportEventIdAndFileId");
my $rpt = $back->CreateReport("File Import Update Report");
$rpt->print("digest,file_id,file,report\n");
$back->WriteToEmail("Populating filename in file_import\n");
$back->WriteToEmail("Import Event Id: $import_id\n");
file:
for my $i (@Files){
  my($file_name, $digest) = @$i;
  my $file_id;
  $get_file_id->RunQuery(sub{
    my($row) = @_;
    $file_id = $row->[0];
  }, sub{}, $digest);
  unless(defined $file_id) {
    $rpt->print("$digest,,\"$file_name\",file not in db\n");
    next file;
  }
  my $file_in_db;
  my $num_rows;
  $get_path->RunQuery(sub{
    my($row) = @_;
    $file_in_db = $row->[0];
    $num_rows += 1;
  }, sub {}, $file_id, $import_id);
  my $status = "";
  if($num_rows < 1){
    $rpt->print("$digest,$file_id,\"$file_name\"," .
      "no existing file_import row\n");
    next file;
  }
  if($num_rows > 1){ $status .= "$num_rows in file_import" }
  if(defined $file_in_db && $file_in_db eq $file_name){
    if($status ne "") {$status .= "; "}
    $status .= "matching files";
    $rpt->print("$digest,$file_id,\"$file_name\",$status\n");
    next file;
  }
  if(defined $file_in_db && $file_in_db eq $file_name){
    if($status ne "") {$status .= "; "}
    $status .= "non matching files";
  }
  $set_path->RunQuery(sub {
  }, sub {}, $file_name, $file_id, $import_id);
  if($status ne "") {$status .= "; "}
  $status .= "updated file";
  $rpt->print("$digest,$file_id,\"$file_name\",$status\n");
}
$back->Finish;

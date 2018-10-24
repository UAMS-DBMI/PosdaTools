#!/usr/bin/perl -w 
use strict;
use Posda::DB::PosdaFilesQueries;
use Posda::Config 'Database';
$| = 1;
my $usage = <<EOF;
 PosdaFileProcessDaemon.pl
   Enter loop processing files ready for import in posda_files db
 PosdaFileProcessDaemon.pl -h
   Print this message 
EOF
if($#ARGV >= 0){ print $usage; exit }
my $con_string = Database('posda_files');
####
# Create Query Handles
my $get_import = PosdaDB::Queries->GetQueryInstance(
  "GetPosdaFilesImportControl");
my $go_in_service = PosdaDB::Queries->GetQueryInstance(
  "GoInServicePosdaImport");
my $quit = PosdaDB::Queries->GetQueryInstance(
  "RelinquishControlPosdaImport");
sub Loop{
  my($status, $pid, $idle, $pend_req, $file_count);
  round:
  while(1){
    $get_import->RunQuery(
      sub {
        my($row) = @_;
        ($status, $pid, $idle, $pend_req, $file_count) = @$row;
      },
      sub {},
    );
    if($status eq "waiting to go inservice"){
      $go_in_service->RunQuery(sub {}, sub {}, $$);
      next round;
    }
    if($status eq "service process running"){
      unless($pid == $$){
        print STDERR "Some other process controlling import\n";
        return;
      }
      if($pend_req && $pend_req eq "shutdown"){
        $quit->RunQuery(sub {}, sub {});
        print STDERR "Relinquished control of posda_import\n";
        return;
      }
      my $cmd = "NewProcessFilesInDb.pl \"$con_string\" $file_count";
      open CMD, "$cmd|" or die "Can't open $cmd";
      my $remain_count;
      while(my $line = <CMD>){
        print $line;
        chomp $line;
        if($line =~/remaining: (\d+)$/){
          $remain_count = $1;
        }
      }
      if($remain_count == 0){
        print STDERR "Sleeping $idle seconds\n";
        sleep $idle;
      }
    } else {
      print STDERR "unknown state ($status) for posda_import\n";
      return;
    }
  }
};
Loop();

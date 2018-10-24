#!/usr/bin/perl -w 
use strict;
use Posda::DB::PosdaFilesQueries;
use Digest::MD5;
####
# Create Query Handles
my $g_f_and_d = PosdaDB::Queries->GetQueryInstance(
  "GetAllFilesAndDigests");
####

####
# Run the loop
sub Loop{
  my $tot_files;
  my $start = time;
  my $per_rpt = 10000;
  my $break_count = $per_rpt;
  my($file, $digest);
  $g_f_and_d->RunQuery(
    sub {
      my($row) = @_;
      ($file, $digest) = @$row;
      my $ctx = Digest::MD5->new;
      open FILE, "<$file" or die "can't open $file";
      $ctx->addfile(*FILE);
      close FILE;
      my $dig = $ctx->hexdigest;
      unless($dig eq $digest) {
        print STDERR "Bad digest $file:\n" .
          "\t$dig\n" .
          "vs\n" .
          "\t$digest\n";
      }
      $tot_files += 1;
      $break_count -= 1;
      if($break_count <= 0){
        my $now = time;
        my $elapsed = $now - $start;
        print STDERR "$tot_files processed in $elapsed seconds\n";
        $break_count = $per_rpt;
      }
    },
    sub {}
  );
  print STDERR "Finished\n" .
    "$tot_files processed\n";
}
####
Loop();

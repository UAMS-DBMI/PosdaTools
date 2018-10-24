#!/usr/bin/perl -w
use strict;
use Debug;
use PosdaCuration::ExtractionManagerIf;
use Posda::UUID;
my $usage = <<EOF;
SendSeries_list.pl <root> <ex_port> <host> <dicom_port> <calling> <called> <caption> <collection> <site> <pat_id> <series_uid> [<series_uid> ...]
EOF
unless($#ARGV >= 8) { die $usage }
my $root = shift @ARGV;
my $port = shift @ARGV;
my $host = shift @ARGV;
my $di_port = shift @ARGV;
my $calling = shift @ARGV;
my $called = shift @ARGV;
my $caption = shift @ARGV;
my $collection = shift @ARGV;
my $site = shift @ARGV;
my $pat_id = shift @ARGV;
my @SeriesList = @ARGV;

my $pid = $0;
my $user = `whoami`;
chomp $user;
my $session = Posda::UUID::GetGuid();
#my $Bulk = PosdaCuration::PerformBulkOperations->new(
#  $root, $collection, $site, $session, $user, $port);
my $ExIf = PosdaCuration::ExtractionManagerIf->new(
  $port, $user, $session, $pid, 0);
my $lines = $ExIf->SendSeriesList($collection, $site, $pat_id, 
  \@SeriesList, $host, $di_port, $calling, $called, $caption);
for my $i (@$lines){
  print "$i\n";
}

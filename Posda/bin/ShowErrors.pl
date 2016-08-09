#!/usr/bin/perl -w
use strict;
use PosdaCuration::PerformBulkOperations;
use Posda::UUID;
use Posda::Try;
my $usage = <<EOF;
ShowErrors.pl <collection> <site> <port> <root>
EOF
unless($#ARGV == 3) { die $usage }
my $collection = $ARGV[0];
my $site = $ARGV[1];
my $port = $ARGV[2];
my $root = $ARGV[3];
my $sub = sub {
  my($coll, $site, $subj, $f_list, $info) = @_;
  if(exists $info->{"error.pinfo"}){
    print "$subj has errors:\n";
    for my $i (@{$info->{"error.pinfo"}}){
      print "\t$i->{message}\n";
    }
  }
  return undef;
};
my $user = `whoami`;
chomp $user;
my $session = Posda::UUID::GetGuid;
my $Bulk = PosdaCuration::PerformBulkOperations->new(
  $root, $collection, $site, $session, $user, $port);
$Bulk->MapEdits($sub, $0);

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
  my $has_dups = 0;
  if(exists $info->{"error.pinfo"}){
    for my $i (@{$info->{"error.pinfo"}}){
      if($i->{message} =~ /SOP instances/){ $has_dups = 1 }
    }
  }
  if($has_dups){
    print "$coll, $site, $subj has dups\n";
  }
  return undef;
};
my $user = `whoami`;
chomp $user;
my $session = Posda::UUID::GetGuid;
my $Bulk = PosdaCuration::PerformBulkOperations->new(
  $root, $collection, $site, $session, $user, $port);
$Bulk->MapEdits($sub, $0);

#!/usr/bin/perl -w
use strict;
use PosdaCuration::PerformBulkOperations;
use Posda::UUID;
use Posda::Try;
my $sub = sub {
  my($coll, $site, $subj, $f_list, $info) = @_;
  my $current_rev;
  if(exists $info->{CurrentRev}){
    my $num_edits = $info->{CurrentRev};
    if($num_edits == 0){
      return "DiscardExtractionTransaction.pl \"$coll\" \"$site\" \"$subj\"";
    }
  }
  return undef;
};
my $usage = <<EOF;
CountRevisions.pl <collection> <site> <port> <root>
EOF
unless($#ARGV == 3) { die $usage }
my $collection = $ARGV[0];
my $site = $ARGV[1];
my $port = $ARGV[2];
my $root = $ARGV[3];
my $user = `whoami`;
chomp $user;
my $session = Posda::UUID::GetGuid;
my $Bulk = PosdaCuration::PerformBulkOperations->new(
  $root, $collection, $site, $session, $user, $port);
my $list = $Bulk->MapUnlocked($sub, $0);
for my $line (@$list){
  if(defined $line){
    print "$line\n";
  }
}

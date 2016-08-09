#!/usr/bin/perl -w
use strict;
use PosdaCuration::PerformBulkOperations;
use Posda::UUID;
use Posda::Try;
my $sub = sub {
  my($coll, $site, $subj, $f_list, $info) = @_;
  if(exists $info->{"error.pinfo"}){
    my %errors;
    for my $i (@{$info->{"error.pinfo"}}){
      $errors{$i->{message}} += 1;
    }
    my $ret = "$coll, $site, $subj has errors:\n";
    my @err_list = keys %errors;
    for my $i (0 .. $#err_list){
      my $e = $err_list[$i];
      $ret .= "\t$e : $errors{$e} times";
      if($i < $#err_list) { $ret .= "\n" }
    }
    return $ret;
  }
  return "$coll, $site, $subj: no errors";
};
my $usage = <<EOF;
ShowErrors.pl <collection> <site> <port> <root>
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
  print "$line\n";
}

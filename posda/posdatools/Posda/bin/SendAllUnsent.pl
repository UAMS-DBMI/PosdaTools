#!/usr/bin/perl -w
use strict;
use PosdaCuration::PerformBulkOperations;
use Posda::UUID;
use Posda::Try;
sub MakeClosure{
  my($session, $user, $host, $di_port, $calling, $called, $caption, $ExIf) = @_;
  my $sub = sub {
    my($coll, $site, $subj, $f_list, $info) = @_;
    if(exists $info->{"send_hist.pinfo"}){
      for my $i (@{$info->{"send_hist.pinfo"}}){
        if($i->{host} eq $host && $i->{port} eq $di_port){
          return "Already sent $coll, $site, $subj to ($host, $di_port)";
        }
      }
    }
    my $ret = "Queueing send if $coll, $site, $subj to ($host, $di_port)\n";
    my $lines = $ExIf->SendExtraction(
      $coll, $site, $subj, $host, $di_port, $calling, $called, $caption);
    for my $line (@$lines){
      $ret .= "\t$line\n";
    }
    return $ret;
  };
  return $sub;
}
my $usage = <<EOF;
SendAllUnsent.pl <root> <collection> <site> <ex_port> <di_host> <di_port> <called> <calling> <caption>
EOF
unless($#ARGV == 8) { die $usage }
my $root = $ARGV[0];
my $collection = $ARGV[1];
my $site = $ARGV[2];
my $port = $ARGV[3];
my $host = $ARGV[4];
my $di_port = $ARGV[5];
my $called = $ARGV[6];
my $calling = $ARGV[7];
my $caption = $ARGV[8];
my $pid = $$;
my $user = `whoami`;
chomp $user;
my $session = Posda::UUID::GetGuid;
my $Bulk = PosdaCuration::PerformBulkOperations->new(
  $root, $collection, $site, $session, $user, $port);
my $ExIf = PosdaCuration::ExtractionManagerIf->new(
  $port, $user, $session, $pid, 0);
my $list = $Bulk->MapUnlocked(
  MakeClosure(
   $session, $user, $host, $di_port, $calling, $called, $caption, $ExIf),
  $0);
for my $line (@$list){
  print "$line\n";
}

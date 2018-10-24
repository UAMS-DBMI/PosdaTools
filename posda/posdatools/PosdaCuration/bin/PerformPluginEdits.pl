#!/usr/bin/perl -w
#
use strict;
use Storable;
use PosdaCuration::ExtractionManagerIf;
my $usage = "PerformPluginEdits.pl <root> <collection> <site> <session> <user> <plugin_name> <port>\n";
unless($#ARGV == 6) { die $usage }
my $pid = $0;
my $root = $ARGV[0];
my $col = $ARGV[1];
my $site = $ARGV[2];
my $session = $ARGV[3];
my $user = $ARGV[4];
my $plugin = $ARGV[5];
my $port = $ARGV[6];
my $root_dir = "$root/$col/$site";
unless(-d $root_dir) { die "root_dir is not a directory" };
opendir ROOT, $root_dir or die "Can't opendir $root_dir";
my @subjs;
while (my $subj = readdir(ROOT)){
  if($subj =~ /^\./) {next}
  unless(-d "$root_dir/$subj") { next }
  push(@subjs, $subj);
}
closedir ROOT;
my $ExIf = PosdaCuration::ExtractionManagerIf->new(
  $port, $user, $session, $pid, 0
);
subj:
for my $subj (@subjs){
  print STDERR "Locking $col, $site, $subj, $plugin\n";
  my $lines = $ExIf->LockForEdit($col, $site, $subj, $plugin);
  my %resp;
  for my $line (@$lines){
    if($line =~ /(.*):\s*(.*)$/){
      my $k = $1; my $v = $2;
      $resp{$k} = $v;
    }
  }
  if(exists($resp{Locked}) && $resp{Locked} eq "OK"){  
    my $trans_id = $resp{Id};
    print STDERR "Locked $col, $site, $subj\n";
    for my $k (sort keys %resp){
      print STDERR "\t$k: $resp{$k}\n";
    }
    print STDERR "Unlocking Id: $trans_id:\n";
    my $rlines = $ExIf->ReleaseLockWithNoEdit($trans_id);
    for my $rline (@$rlines){
      print STDERR "\t$rline\n";
    }
  } else {
    print STDERR "Error locking $col, $site, $subj:\n" .
      "\t$resp{Error}\n";
  }
}

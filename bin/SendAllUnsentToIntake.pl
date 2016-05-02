#!/usr/bin/perl -w
#
use strict;
use Storable;
use PosdaCuration::ExtractionManagerIf;
use Debug;
my $dbg = sub { print STDERR @_ };
my $usage = "SendAllUnsentToIntake.pl.pl <root> <collection> <site> <session> <user> <ex_port> <host> <di_port> <called> <calling> <caption>\n";
unless($#ARGV == 10) { die $usage }
my $pid = $0;
my $root = $ARGV[0];
my $col = $ARGV[1];
my $site = $ARGV[2];
my $session = $ARGV[3];
my $user = $ARGV[4];
my $port = $ARGV[5];
my $host = $ARGV[6];
my $di_port = $ARGV[7];
my $called = $ARGV[8];
my $calling = $ARGV[9];
my $caption = $ARGV[10];
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
for my $subj (sort @subjs){
  unless(-d "$root_dir/$subj" && -f "$root_dir/$subj/rev_hist.pinfo"){
    next subj;
  }
  my $rev_hist = Storable::retrieve("$root_dir/$subj/rev_hist.pinfo");
  my $current_rev = $rev_hist->{CurrentRev};
  my $old_info_dir = "$root_dir/$subj/revisions/$current_rev";
  my $source_dir = "$old_info_dir/files";
  unless(-d $old_info_dir && -f "$old_info_dir/dicom.pinfo"){
    next subj;
  }
  if(-f "$old_info_dir/send_hist.pinfo"){
    my $send_hist = Storable::retrieve("$old_info_dir/send_hist.pinfo");
    for my $i (@$send_hist){
      if(
        $i->{host} eq $host &&
        $i->{port} eq $di_port
      ){
        print STDERR "Already sent to $col, $site, $subj ($host, $port)\n";
        next subj;
      }
    }
  }
  print "Sending $col, $site, $subj to ($host, $port)\n";
  my $lines = $ExIf->SendExtraction(
    $col, $site, $subj, $host, $di_port, $calling, $called, $caption);
  for my $line (@$lines){
    print "\t$line\n";
  }
}

#!/usr/bin/perl -w
#
use strict;
use Storable qw( store_fd );
my $usage = "ConsolidatePhiScans.pl <root_dir> <results>\n";
unless($#ARGV == 1){ die $usage }
opendir DIR, $ARGV[0] or die "Can't open $ARGV[0]";
my @phi_files;
subject:
while(my $d = readdir(DIR)){
  if($d =~ /^\./) { next }
  unless(-d "$ARGV[0]/$d"){
    print STDERR "Non directory $d found in $ARGV[0]\n";
    next subject;
  }
  unless(-d "$ARGV[0]/$d/revisions"){
    print STDERR "$ARGV[0]/$d has no revisions directory\n";
    next subject;
  }
  unless(opendir DIR1, "$ARGV[0]/$d/revisions"){
    print "Couldn't opendir $ARGV[0]/$d/revisions\n";
    next subject;
  }
  my @revs;
  revision:
  while(my $r = readdir DIR1){
    if($r =~ /^\./) { next }
    unless($r =~ /^[0-9]+$/) {
      print "Bad rev dir ($r) found in $ARGV[0]/$d/revisions\n";
      next revision;
    }
    push @revs, $r;
  }
  if($#revs < 0){
    print "No revisions found in $ARGV[0]/$d/revisions\n";
    next subject;
  }
  @revs = sort {$a <=> $b} @revs;
  my $last_rev = $revs[$#revs];
  if(-f "$ARGV[0]/$d/revisions/$last_rev/PhiCheck.info"){
    push(@phi_files, "$ARGV[0]/$d/revisions/$last_rev/PhiCheck.info");
  } else {
    print STDERR "$ARGV[0]/$d/revisions/$last_rev has no PhiCheck.info\n";
    next subject;
  }
}
my %ConsolidatedReport;
for my $f (@phi_files){
  my $rpt = Storable::retrieve($f);
  for my $vr (keys %{$rpt->{results}}){
    for my $value (keys %{$rpt->{results}->{$vr}}){
      for my $tag (keys %{$rpt->{results}->{$vr}->{$value}}){
        for my $file (keys %{$rpt->{results}->{$vr}->{$value}->{$tag}}){
          $ConsolidatedReport{$value}->{$tag}->{vr} = $vr;
          $ConsolidatedReport{$value}->{$tag}->{files}->{$file} = 1;
        }
      }
    }
  }
}
Storable::store \%ConsolidatedReport, $ARGV[1];

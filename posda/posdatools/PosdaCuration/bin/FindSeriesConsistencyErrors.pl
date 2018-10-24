#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/PosdaCuration/bin/RemovePhiScans.pl,v $
#$Date: 2016/01/26 19:51:30 $
#$Revision: 1.1 $
#
use strict;
use Storable qw( store_fd );
use Debug;
my $dbg = sub { print @_ };
my %CollectedErrors;
my $usage = "FindSeriesConsistencyErrors.pl <root_dir>\n";
unless($#ARGV == 0){ die $usage }
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
  my $error_file = "$ARGV[0]/$d/revisions/$last_rev/error.pinfo";
  if(-f "$ARGV[0]/$d/revisions/$last_rev/error.pinfo"){
    my $Info = Storable::retrieve($error_file);
    for my $i (@$Info){
      if($i->{message} =~ /^Error in series_consistency/){
        unless(exists $CollectedErrors{$d}){
          $CollectedErrors{$d} = [];
        }
        push(@{$CollectedErrors{$d}}, $i);
      }
    }
  } else {
    print STDERR "no error file: $error_file\n";
    next subject;
  }
}
Storable::store_fd(\%CollectedErrors, \*STDOUT);
#print "Results: ";
#Debug::GenPrint($dbg, \%CollectedErrors, 1);
#print "\n";

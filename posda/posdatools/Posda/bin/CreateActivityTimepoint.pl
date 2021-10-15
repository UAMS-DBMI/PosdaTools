#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Debug;
my $dbg = sub { print @_ };

my $usage = <<EOF;
Usage:
CreateActivityTimepointId.pl <activity_id> "<comment>" <creator>
  or
CreateActivityTimepointId.pl -h
Expects lines on STDIN:
<file_id>
...
EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){ print $usage; exit }

my $num_args = @ARGV;
unless($#ARGV == 2) { die "wrong number of args ($num_args vs 2):\n $usage" }

my($activity_id, $comment, $creator) = @ARGV;
my $start = time;
my %Files;
while (my $line = <STDIN>){
  chomp $line;
  $Files{$line} = 1;
}
my $tot_files = keys %Files;

my $cre = Query("CreateActivityTimepoint");
$cre->RunQuery(sub {}, sub {},
  $activity_id, $0, $comment, $creator);
my $act_time_id;
my $gid = Query("GetActivityTimepointId");
$gid->RunQuery(sub {
  my($row) = @_;
  $act_time_id = $row->[0];
}, sub{});
unless(defined $act_time_id){
  die "Error - unable to get activity timepoint id.";
}

my $ins_file = Query("InsertActivityTimepointFile");
my $num_files = 0;
for my $file_id (keys %Files){
  $ins_file->RunQuery(sub{}, sub{}, $act_time_id, $file_id);
}

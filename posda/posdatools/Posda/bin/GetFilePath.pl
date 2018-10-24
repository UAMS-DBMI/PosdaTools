#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';

my $usage = <<EOF;
Usage: GetFilePath.pl <file_id>
or
GetFilePath.pl -h

EOF
if($#ARGV == 0 && $ARGV[0] eq "-h") { print "$usage\n\n"; exit }
if($#ARGV != 0){
  my $num_args = $#ARGV;
  print "Wrong args: ($num_args vs 1)\n$usage\n";
  exit;
}
my($file_id) = $ARGV[0];
my $pq = Query("GetFilePath");
my $path;
$pq->RunQuery(sub {
  my($row) = @_;
  $path = $row->[0];
}, sub {}, $file_id);
print "$path\n";

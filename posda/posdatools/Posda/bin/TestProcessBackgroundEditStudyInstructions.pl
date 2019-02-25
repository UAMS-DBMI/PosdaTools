#!/usr/bin/perl -w
use strict;
use Posda::ProcessBackgroundEditStudyInstructions;
use Posda::BackgroundProcess;
use Debug;
my $dbg = sub {print @_};

my $usage = <<EOF;
Usage:
TestProcessBackgroundEditFileInstructions.pl <bkgrnd_id> <notify>
or
TestProcessBackgroundEditFileInstructions.pl -h
Expects lines of the form:
<file_id>&<op>&<tag>&<val1>&<val2>

EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 1){
  my $num_args = @ARGV;
  print "Error: wrong number of args ($num_args vs 2)\n";
  print $usage;
  exit;
}
my $process = Posda::ProcessBackgroundEditStudyInstructions->new;
$process->ProcessInput(*STDIN);
$process->Debug($dbg);

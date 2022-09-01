#!/usr/bin/perl -w
use strict;
use Posda::EditStateChange;
use JSON;
use Debug;
my $dbg = sub {print @_};

my $usage = <<EOF;
TestApiStateChangeNoModLib.pl <edit_id> <expected_state> <new_state>

EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 2){
  my $num_args = @ARGV;
  die "wrong number of args $num_args vs 3\n$usage";
}
my($edit_id, $expected_state, $new_state) = @ARGV;
my ($code, $content) = Posda::EditStateChange::Trans(
  $edit_id, $expected_state, $new_state);
if($code == 200){
  print "State change completed \"$expected_state\" => \"$new_state\"\n";
} else {
  print "Code: $code\n";
  if($content eq ""){
    print "No Json Content\n";
  } else {
    print "Json: ";
    Debug::GenPrint($dbg, decode_json($content), 1);
    print "\n";
  }
}

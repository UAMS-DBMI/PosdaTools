#!/usr/bin/perl -w
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Try;
use Posda::UUID;
use Debug;
my $dbg = sub { print STDERR @_ };
use Storable qw( store_fd fd_retrieve );
my $help = <<EOF;
 Structure Set relinker meant to run as a sub-process
 Receives parameters via fd_retrive from STDIN.
 Writes results to STDOUT via store_fd
 incoming data structure:
 \$in = {
   from_file => <path to from file>,
   dir => <directory path for new file>,
};
EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print STDERR $help;
  exit;
}
unless($#ARGV == -1){
  print STDERR $help;
  exit;
}
my $results = {};
sub Error{
  my($message, $addl) = @_;
  $results->{Status} = "Error";
  $results->{message} = $message;
  if($addl){ $results->{additional_info} = $addl }
  store_fd($results, \*STDOUT);
  exit;
}
my $edits;
eval { $edits = fd_retrieve(\*STDIN) };
if($@){
  print STDERR
    "SubProcessRelinker.pl: unable to fd_retrieve from STDIN ($@)\n";
  Error("unable to retrieve from STDIN", $@);
}
unless(exists $edits->{from_file}){ Error("No from_file in edits") }
$results->{from_file} = $edits->{from_file};
my $try = Posda::Try->new($edits->{from_file});
unless(exists $try->{dataset}) { 
  Error("file $edits->{from_file} didn't parse", $try);
}
my $ds = $try->{dataset};
my $new_root = Posda::UUID::GetUUID;
my $new_study = "$new_root.1";
my $new_series = "$new_root.1.1";
my $new_uid = "$new_root.1.1.1";
my $modality = $ds->Get("(0008,0060)");
my $new_fn = "$edits->{dir}/${modality}_$new_uid.dcm";
#$ds->Insert("(0020,000d)", $new_study);
$ds->Insert("(0020,000e)", $new_series);
$ds->Insert("(0008,0018)", $new_uid);
eval {
  $ds->WritePart10($new_fn, $try->{xfr_stx}, "POSDA", undef, undef);
};
if($@){
  print STDERR "Can't write $new_fn ($@)\n";
  Error("Can't write $new_fn", $@);
}
$results->{cloned_file} = $new_fn;
$results->{Status} = "OK";
store_fd($results, \*STDOUT);

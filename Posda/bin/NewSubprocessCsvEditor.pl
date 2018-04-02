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
use Digest::MD5;
use Posda::PrivateDispositions;
use Debug;
my $dbg = sub { print STDERR @_ };
use Storable qw( store_fd fd_retrieve );
my $help = <<EOF;
 Csv File Anonymizer meant to run as a sub-process
 Receives parameters via fd_retrive from STDIN.
 Writes results to STDOUT via store_fd
 incoming data structure:
 \$in = {
   from_file => <path to from file>,
   to_file => <path to to file>,
   edits => [
     <edit_spec>,
     ...
   ],
 };

  where:
  <edit_spec> = {
    op => <operation>,
    path => <tag>,
    arg1 => <arg1 of op>,
    arg2 => <arg2 of op>
    arg3 => <arg3 of op>
  };

  <path> is of the following format:
    [<row_num][<col_num]

  <op> specifies the operation to be performed on the tag or tags identified
  by <path>
  <arg1>, <arg2>, and <arg2> are the arguments of these operands:
    shift_date_time(number_of_days) - shift a date by an integer number of days.
                                 to shift backwards supply negative integer.
                                 Value at path must be in form yyyymmdd[.<anything>]
    shift_date_yyyy-mm-dd - like shift_date_time except date format "yyyy-mm-dd"
    shift_date_mm-dd-yy - like shift_date_time except date format "mm-dd-yy".
                          Only works for dates > 2000/01/01.
    delete_value() - Set the value at the path to "";
    set_value(value) - Set the value of a tag unconditionally.
                     Even if not present.
    hash_unhashed_uid(uid_root) - hash the value of the tag unless the current
                                  value of the tag is either empty, or matches
                                  the supplied uid_root.

EOF
if($#ARGV == 0 && ($ARGV[0] eq "-h")){
  print $help;
  exit;
}
my $results = {};
sub Error{
  my($message, $addl) = @_;
print STDERR "#################\n" .
  "Error: $message\n" .
  "#################\n";
  $results->{Status} = "Error";
  $results->{message} = $message;
  if($addl){ $results->{additional_info} = $addl }
  store_fd($results, \*STDOUT);
  exit;
}
my $buff;
#my $count = sysread(STDIN, $buff, 65535);
#unless(defined $count) { print STDERR "Child read error: $!\n" }
#print STDERR "read $count bytes\n";
#exit;
my $edits = fd_retrieve(\*STDIN);
unless(exists $edits->{from_file}){ Error("No from_file in edits") }
unless(-f $edits->{from_file}){ Error("file not found: $edits->{from_file}") }

$results->{from_file} = $edits->{from_file};
$results->{to_file} = $edits->{to_file};
### read in CSV file
my $cmd = "CsvToPerlStructVanilla.pl \"$edits->{from_file}\"";
unless(open READSTRUCT, "-|", $cmd){
  Error("Can't open pipe from $cmd\n");
}
my $csv_struct = slurp(\*READSTRUCT);
my $CsvStruct;
if($csv_struct =~/^pst0(.*)$/s){
  $csv_struct = $1;
}
my $struct_len = length $csv_struct;
eval{
   $CsvStruct = &Storable::thaw($csv_struct);
};
if($@) {
  Error("Can't unfreeze structure of length: $struct_len ($@)");
}
#print STDERR "CsvStruct = ";
#Debug::GenPrint($dbg, $CsvStruct, 1);
#print STDERR "\n";
for my $e (@{$edits->{edits}}){
  my $op = $e->{op};
  my $path = $e->{path};
  unless($path =~ /\[(\d+)\]\[(\d+)\]/){
    Error("bad path: \"$path\"");
  }
  my $row = $1;  my $col = $2;
  my $arg1 = $e->{arg1};
  my $arg2 = $e->{arg2};
  my $arg3 = $e->{arg2};
  if($op eq "shift_date_time"){
    unless($arg1 =~ /^(.*) days$/){
      Error("Bad arg to shift_date_time: $arg1");
    }
    my $shift = $1;
    my $shifter = Posda::PrivateDispositions->new(
      undef, $shift, undef, undef
    );
    my $date_time = $CsvStruct->[$row]->[$col];
    unless($date_time =~ /^\d\d\d\d\d\d\d\d\..*$/){
      Error("Bad date time: $date_time");
    }
    $CsvStruct->[$row]->[$col] = $shifter->ShiftDate($date_time);
  }elsif($op eq "shift_date_yyyy-mm-dd"){
    unless($arg1 =~ /^(.*) days$/){
      Error("Bad arg to shift_date_time: $arg1");
    }
    my $shift = $1;
    my $shifter = Posda::PrivateDispositions->new(
      undef, $shift, undef, undef
    );
    my $date = $CsvStruct->[$row]->[$col];
    unless($date =~ /^(\d\d\d\d)-(\d\d)-(\d\d)$/){
      Error("Bad date (yyyy-mm-dd): $date");
    }
    my $new_date = "$1$2$3";
    $CsvStruct->[$row]->[$col] = $shifter->ShiftDate($new_date);
  }elsif($op eq "shift_date_mm-dd-yy"){
    unless($arg1 =~ /^(.*) days$/){
      Error("Bad arg to shift_date_time: $arg1");
    }
    my $shift = $1;
    my $shifter = Posda::PrivateDispositions->new(
      undef, $shift, undef, undef
    );
    my $date = $CsvStruct->[$row]->[$col];
    unless($date =~ /^(\d\d)-(\d\d)-(\d\d)$/){
      Error("Bad date (mm-dd-yy): $date");
    }
    my $new_date = "20$3$1$2";
    $CsvStruct->[$row]->[$col] = $shifter->ShiftDate($new_date);
  }elsif($op eq "delete_value"){
    $CsvStruct->[$row]->[$col] = "";
  }elsif($op eq "set_value"){
    $CsvStruct->[$row]->[$col] = $arg1;
  }elsif($op eq "hash_unhashed_uid"){
    my $value = $CsvStruct->[$row]->[$col];
    unless($value =~ /^$arg1.*$/){
      my $ctx = Digest::MD5->new;
      $ctx->add($value);
      my $dig = $ctx->digest;
      my $dig_str = Posda::UUID::FromDigest($dig);
      my $new_uid = "$arg1" . "." . "$dig_str";
      my $new_str = substr($new_uid, 0, 64);
      $CsvStruct->[$row]->[$col] = $new_str;
    }
  }else{
    Error("Unsupported op: $op");
  }
}

eval {
  my $cmd = "PerlStructToCsvVanilla.pl >\"$edits->{to_file}\"";
  my $serialized_csv = &Storable::freeze($CsvStruct);
  unless(open NEWCSV, "|-", $cmd){
    Error("Can't open pipe to PerlStructToCsvVanilla.pl");
  }
  print NEWCSV "pst0$serialized_csv";
};
if($@){
  print STDERR "Can't write $edits->{to_file} ($@)\n";
  Error("Can't write $edits->{to_file}", $@);
}
$results->{to_file} = $edits->{to_file};
$results->{Status} = "OK";
store_fd($results, \*STDOUT);
sub slurp {
  my $fh = shift;
  local $/ = undef;
  my $cont = <$fh>;
  close $fh;
  return $cont;
}

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
use JSON;
use Debug;
my $dbg = sub { print STDERR @_ };
use Storable qw( store_fd fd_retrieve );
my $help = <<EOF;
 Json File Anonymizer meant to run as a sub-process
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
    <index1><index2>..
  where each index is a hash index enclosed in curly brackets or
  and array index enclosed in square brackets

  <op> specifies the operation to be performed on the tag or tags identified
  by <path>
  <arg1>, <arg2>, and <arg3> are the arguments of these operands:
    map_date(number_of_days) - shift a date by an integer number of days.
                                 to shift backwards supply negative integer.
                                 Value at path must be in form "mm/dd/yyyy"
    map_date_m/d/yy - like map_date except date format "m/d/yy"
                          Only works for dates > 2000/01/01.
    map_date_m/d/yyyy - like map_date except date format "m/d/yyyy"
    map_date_m-dd-yyyy - like shift_date_time except date format "mm-dd-yyyy".
    map_date_mm/d/yyyy - ditto
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
### read in JSON file
my $fh;
unless(open $fh, "<", $edits->{from_file}){
  Error("Can't open $edits->{from_file}");
}
my $j_struct = slurp($fh);
my $struct_len = length $j_struct;
my $JsonStruct;
eval{
   $JsonStruct = decode_json $j_struct;
};
if($@) {
  Error("Can't decode json_text of length: $struct_len ($@)");
}
#print STDERR "CsvStruct = ";
#Debug::GenPrint($dbg, $CsvStruct, 1);
#print STDERR "\n";
for my $e (@{$edits->{edits}}){
  my $op = $e->{op};
  my $path = $e->{path};
  my($ptr, $index, $type) = GetPtrIndexTypeFromPath($path, $JsonStruct);
  my $arg1 = $e->{arg1};
  my $arg2 = $e->{arg2};
  my $arg3 = $e->{arg3};
  my $date_shift;
  my $shifter;
  my $date;
  if($op =~ /map_date/){
    unless($arg1 =~ /^(.*) days$/){
      Error("Bad arg to $op: $arg1");
    }
    $date_shift = $1;
print STDERR "shift date by $date_shift\n";
    $shifter = Posda::PrivateDispositions->new(
      undef, $date_shift, undef, undef
    );
    if($type eq "ARRAY"){
      $date = $ptr->[$index];
    } elsif($type eq "HASH"){
      $date = $ptr->{$index};
    }
  }
  if($op eq "map_date"){
    unless($date =~ /^(\d\d)\/(\d\d)\/(\d\d\d\d)$/){
      Error("Bad date (mm/dd/yyyy): '$date'");
    }
    my $new_date = "$3$1$2";
    if($type eq "ARRAY"){
      $ptr->[$index] = $shifter->ShiftDate($new_date);
    } elsif($type eq "HASH"){
      $ptr->{$index} = $shifter->ShiftDate($new_date);
    }
  } elsif($op eq "map_date_mm/d/yyyy"){
    unless($date =~ /^(\d\d)\/(\d)\/(\d\d\d\d)$/){
      Error("Bad date (mm/d/yyyy): '$date'");
    }
    my $new_date = $3 . $1. "0" .$2;
    if($type eq "ARRAY"){
      $ptr->[$index] = $shifter->ShiftDate($new_date);
    } elsif($type eq "HASH"){
      $ptr->{$index} = $shifter->ShiftDate($new_date);
    }
  } elsif($op eq "map_date_m/d/yy"){
    unless($date =~ /^(\d)\/(\d)\/(\d\d)$/){
      Error("Bad date (m/d/yy): $date");
    }
    my $new_date = "20" . $3 . "0" . $1 . "0" . $2;
    if($type eq "ARRAY"){
      $ptr->[$index] = $shifter->ShiftDate($new_date);
    } elsif($type eq "HASH"){
      $ptr->{$index} = $shifter->ShiftDate($new_date);
    }
  } elsif($op eq "map_date_m/d/yyyy"){
    unless($date =~ /^(\d)\/(\d)\/(\d\d\d\d)$/){
      Error("Bad date (m/d/yyyy): $date");
    }
    my $new_date = $3 . "0" . $1 . "0" . $2;
    if($type eq "ARRAY"){
      $ptr->[$index] = $shifter->ShiftDate($new_date);
    } elsif($type eq "HASH"){
      $ptr->{$index} = $shifter->ShiftDate($new_date);
    }
  } elsif($op eq "map_date_m/dd/yyyy"){
    unless($date =~ /^(\d)\/(\d\d)\/(\d\d\d\d)$/){
      Error("Bad date (m/dd/yyyy): $date");
    }
    my $new_date = $3 . "0" . $1 . $2;
    if($type eq "ARRAY"){
      $ptr->[$index] = $shifter->ShiftDate($new_date);
    } elsif($type eq "HASH"){
      $ptr->{$index} = $shifter->ShiftDate($new_date);
    }
  }elsif($op eq "delete_value"){
    if($type eq "ARRAY"){
      $ptr->[$index] = undef;
    } elsif($type eq "HASH") {
      $ptr->{$index} = undef;
    }
  }elsif($op eq "set_value"){
    if($type eq "ARRAY"){
      $ptr->[$index] = $arg1;
    } elsif($type eq "HASH") {
      $ptr->{$index} = $arg1;
    }
  }else{
    Error("Unsupported op: $op");
  }
}
sub GetPtrIndexTypeFromPath{
  my($path, $root_ptr) = @_;
  my $remain = $path;
  my $ptr = $root_ptr;
  my $type;
  my $index;
  my $num_loops = 0;
  while ($remain ne "") {
    if($remain =~ /^\{([^\}]+)\}(.*)$/){
      $index = $1;
      $remain = $2;
      $type = "HASH";
      if($remain ne ""){
        $ptr = $ptr->{$index};
        $index = undef;
        $type = undef;
      }
    } elsif ($remain =~ /^\[([^\]]+)\](.*)$/){
      $index = $1;
      $remain = $2;
      $type = "ARRAY";
      if($remain ne ""){
        $ptr = $ptr->[$index];
        $index = undef;
        $type = undef;
      }
    } else {
      Error("Can't parse path ---$path---");
    }
    $num_loops += 1;
    if($num_loops > 10){
      Error("Path too long ----$path----");
    }
  }
  return ($ptr, $index, $type);
}

eval {
  open FILE, ">", $edits->{to_file} or 
  die ("Can't open $edits->{to_file} ($!)");
  my $json = JSON->new->allow_nonref->pretty;
  print FILE $json->encode($JsonStruct);
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

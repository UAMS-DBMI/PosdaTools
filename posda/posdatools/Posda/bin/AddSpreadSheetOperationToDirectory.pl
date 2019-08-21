#!/usr/bin/perl -w
use strict;
use Posda::DB qw(Query);
use Debug;
my $dbg = sub { print @_ };
sub PrintArray{
  my($array, $fh) = @_;
  if(ref($array) eq "ARRAY" && $#{$array} >= 0){
    for my $i (0 .. $#{$array}){
      print $fh "'$array->[$i]'";
      unless($i eq $#{$array}){ print $fh ", " }
    }
  }
}
sub PrintSpreadSheetOpFile{
  my($so, $fh) = @_;
  print $fh ":operation_name: $so->{operation_name}\n";
  print $fh ":command_line: $so->{command_line}\n";
  print $fh ":operation_type: $so->{operation_type}\n";
  print $fh ":input_line_format: $so->{input_line_format}\n";
  print $fh ":tags: [";
  PrintArray($so->{tags}, $fh);
  print $fh "]\n";
  print $fh ":can_chain: $so->{can_chain}\n";
}

my $dir = '/home/posda/posdatools/spreadsheet_operations/rows';
my $s_name = $ARGV[0];
my $f_name = "$dir/$s_name.row";
if (-f $f_name) {
  print STDERR "Warning: $f_name already exists\n";
  exit;
}
open FILE, ">$f_name";
Query('GetSpreadsheetOperationByName')->RunQuery(sub{
  my($row) = @_;
  my($operation_name, $command_line, $operation_type,
     $input_line_format, $tags, $can_chain) =
    @$row;
  my $q = {
    operation_name => $operation_name,
    command_line => $command_line,
    operation_type => $operation_type,
    input_line_format => $input_line_format,
    tags => $tags,
    can_chain => $can_chain,
  };
  PrintSpreadSheetOpFile($q, *STDOUT);
  PrintSpreadSheetOpFile($q, *FILE);
}, sub {}, $s_name);

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
sub PrintSpreadsheetOperationFile{
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

sub ParseArray{
  my($str) = @_;
  unless(defined $str) { return [] }
  if($str eq "None") { return [] }
  my @ret;
  my @elements = split(/,/, $str);
  for my $e (@elements){
    $e =~ s/^\s*'//;
    $e =~ s/'\s*//;
    push @ret, $e;
  }
  return \@ret;
}
sub ParseSpreadsheetOperationFile{
  my($file_name) = @_;
  my $h = {};
  open FILE, "<$file_name" or die "Can't open $file_name";
  while (my $line = <FILE>){
    if($line =~ /^:([^:]*):\s*(.*)$/){
      my $key  = $1;
      my $value = $2;
      if($key eq "tags"){
        if($value =~ /^\[(.*)\]$/){
          $h->{$key} = ParseArray($1);
        } else {
          $h->{$key} = [];
        }
      } else{
        $h->{$key} = $value;
      }
    }
  }
  if($h->{can_chain} eq ""){
    $h->{can_chain} = undef;
  }
  return $h;
}
sub CompareArray{
  my($a1, $a2) = @_;
  unless(ref($a1) eq 'ARRAY' && ref($a2) eq "ARRAY"){
    if(!defined($a1) && !defined($a2)) {return 1}
    if(defined($a1) && !defined($a2)) { return 0 }
    if(!defined($a1) && defined($a2)) { return 0 }
    unless($#{$a1} == $#{$a2}) { return 0 }
  }
  for my $i (0 .. $#{$a1}){
    unless($a1->[$i] eq $a2->[$i]) { return 0 }
  }
  return 1;
}
sub CompareSpreadsheetOperations{
  my($op_name, $on_disk, $in_db) = @_;
  for my $col (
    "command_line", "operation_type",
    "input_line_format"
  ){
    #unless(defined($on_disk->{$col})){ print "on_disk{$col} undefined\n"}
    #unless(defined($in_db->{$col})){ print "in_db{$col} undefined\n"}
    unless(
      $on_disk->{$col} eq
      $in_db->{$col}
    ){
      print "$op_name has non matching $col values:\n";
      print "In DB   ############\n$in_db->{$col}\n";
      print "--------------------\n$on_disk->{$col}\n";
      print "In File ############\n";
    }
  }
  unless(CompareArray($in_db->{tags}, $on_disk->{tags})){
    print "$op_name has non matching tags values:\n";
    print "In DB   ############\n";
    PrintArray($in_db->{tags}, \*STDOUT);
    print "\n--------------------\n";
    PrintArray($on_disk->{tags}, \*STDOUT);
    print "\nIn File ############\n";
  }
}
my $g_q = Query('GetSpreadsheetOperationByName');
sub GetSpreadsheetOperationByName{
  my($op_name) = @_;
  my $q;
  $g_q->RunQuery(sub{
    my($row) = @_;
    my($operation_name, $command_line, $operation_type, $input_line_format, $tags, $can_chain) =
      @$row;
    unless(defined $tags) { $tags = [] }
    $q = {
      operation_name => $operation_name,
      command_line => $command_line,
      operation_type => $operation_type,
      input_line_format => $input_line_format,
      tags => $tags,
      can_chain => $can_chain,
    };
  }, sub {}, $op_name);
  return $q;
}


my $usage = <<EOF;
usage:
SynchronizeSpreadsheetOperation.pl <op_name> <op>
or 
SynchronizeQuery.pl -h

Where:
  <op_name> = name of spreadsheet_operation
  <op> = take_disk | take_db | compare

Processing:
  if(op eq take_disk){
    if(-f /home/posda/posdatools/spreadsheet_operation/rows/<op_name>.sql){
      parse file;
      if(<op_name> is in spreadsheet_operation table){
        update spreadsheet_operation table from parsed file
      } else {
        insert into spreadsheet_operation from parsed file
      }
    } else {
      error ("<op_name> is not in spreadsheet_operation directory")
    }
  } else if (op eq "take_db"){
    fetch spreadsheet_operation from db
    if(operation_exists){
      write file from operation
    } else {
      error ("<op_name> is not in db")
    } 
  } else if (op eq "compare"){
    fetch db_operation from db;
    parse file_operation from file;
    if(defined db_operation and defined file_operation){
      CompareSpreadsheetOperations(<op_name>, disk_op, db_op);
    } else if (defined db_op)
      error ("<op_name> is not in db")
    } else {
      error ("<file> is not in spreadsheet_operation dir")
    }
  }
EOF
my $dir = '/home/posda/posdatools/spreadsheet_operation/row';
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 1){
  my $num_args = @ARGV;
  die "Wrong # args ($num_args vs 2), usage:\n$usage";
}

my $op_name = $ARGV[0];
my $op = $ARGV[1];
my $file = "/home/posda/posdatools/spreadsheet_operations/rows/$op_name.row"; 
my $op_disk;
if(-f $file){
  $op_disk = ParseSpreadsheetOperationFile($file);
}
my $op_db = GetSpreadsheetOperationByName($op_name);
if($op eq "take_disk"){
  if(defined $op_disk){
    if(defined $op_db){
      #update spreadsheet_operation  table from parsed file
      Query('UpdateSpreadsheetOperationRow')->RunQuery(sub{}, sub{},
       $op_disk->{command_line}, $op_disk->{operation_type},
       $op_disk->{input_line_format}, $op_disk->{tags},
       $op_disk->{can_chain},
       $op_disk->{operation_name});
      
    } else {
      #insert into queries from parsed file
      Query('CreateSpreadsheetOperation')->RunQuery(sub{}, sub{},
       $op_disk->{operation_name}, $op_disk->{command_line},
       $op_disk->{operation_type}, $op_disk->{input_line_format},
       $op_disk->{tags}, $op_disk->{can_chain});
    }
  } else {
    die ("$op_name is not in queries directory")
  }
} elsif ($op eq "take_db"){
  if(defined $op_db){
    #write file from query
    open FILE, ">$file" or die "Can't open $file";
    PrintSpreadsheetOperationFile($op_db,\*FILE);
    close FILE;
  } else {
    die ("$op_name is not in db")
  } 
} elsif ($op eq "compare"){
  if(defined $op_db && defined $op_disk){
    CompareSpreadsheetOperations($op_name, $op_disk, $op_db);
  } elsif (defined $op_disk){
    die ("$op_name is not in db")
  } else {
    die ("$op_name.row is not in directory")
  }
}


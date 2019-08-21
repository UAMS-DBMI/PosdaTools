#!/usr/bin/perl -w
use strict;
use Posda::DB qw(Query);
use Debug;
my $dbg = sub { print @_ };
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
sub PrintArray{
  my($array, $fh) = @_;
  if(ref($array) eq "ARRAY" && $#{$array} >= 0){
    for my $i (0 .. $#{$array}){
      print $fh "'$array->[$i]'";
      unless($i eq $#{$array}){ print $fh ", " }
    }
  }
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
        }
      } else{
        $h->{$key} = $value;
      }
    }
  }
  return $h;
}
my $dir = '/home/posda/posdatools/spreadsheet_operations/rows';
opendir DIR, $dir or die "Can't opendir $dir";;
my %SsOpFiles;
while(my $file = readdir(DIR)){
  unless($file =~ /^(.*)\.row$/) { next }
  my $q_name = $1;
  $SsOpFiles{$q_name} = ParseSpreadsheetOperationFile("$dir/$file");
}
my %SsOpRows;
Query('GetAllSpreadsheetOperations')->RunQuery(sub {
  my($row) = @_;
  my($operation_name, $command_line, $operation_type,
    $input_line_format, $tags, $can_chain) =
    @$row;
  $SsOpRows{$operation_name} = {
    operation_name => $operation_name,
    command_line => $command_line,
    operation_type => $operation_type,
    input_line_format => $input_line_format,
    tags => $tags,
    can_chain => $can_chain,
  };
}, sub{});
for my $op_name (keys %SsOpRows){
  if(exists $SsOpFiles{$op_name}){
    for my $col (
      "command_line", "operation_type",
      "input_line_format"
    ){
      unless(
        $SsOpRows{$op_name}->{$col} eq
        $SsOpFiles{$op_name}->{$col}
      ){
        print "$op_name has non matching $col values:\n";
        print "In DB   ############\n$SsOpRows{$op_name}->{$col}\n";
        print "--------------------\n$SsOpFiles{$op_name}->{$col}\n";
        print "In File ############\n";
      }
    }
    unless(CompareArray($SsOpRows{$op_name}->{tags}, $SsOpFiles{$op_name}->{tags})){
      print "$op_name has non matching tags values:\n";
      print "In DB   ############\n";
      PrintArray($SsOpRows{$op_name}->{tags}, \*STDOUT);
      print "\n--------------------\n";
      PrintArray($SsOpFiles{$op_name}->{tags}, \*STDOUT);
      print "\nIn File ############\n";
    }
  } else {
    print "$op_name is in DB, not in spreadsheet_operation directory\n";;
  }
}
for my $op_name (keys %SsOpFiles){
  unless(exists $SsOpRows{$op_name}){
    print "$op_name is in spreadsheet_operation directory, not in DB\n";;
  }
}

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
sub PrintQueryFile{
  my($query, $fh) = @_;
  print $fh "-- Name: $query->{name}\n";
  print $fh "-- Schema: $query->{schema}\n";
  print $fh "-- Columns: [";
  PrintArray($query->{columns}, $fh);
  print $fh "]\n";
  print $fh "-- Args: [";
  PrintArray($query->{args}, $fh);
  print $fh "]\n";
  print $fh "-- Tags: [";
  PrintArray($query->{tags}, $fh);
  print $fh "]\n";
  print $fh "-- Description: ";
  my @lines = split(/\n/, $query->{description});
  print $fh "$lines[0]\n";
  for my $i (1 .. $#lines){
    print $fh "-- $lines[$i]\n";
  }
  print $fh "--\n\n";
  print $fh $query->{query};
}

my $dir = '/home/posda/posdatools/queries/sql';
my $q_name = $ARGV[0];
my $f_name = "$dir/$q_name.sql";
if (-f $f_name) {
  print STDERR "Warning: $f_name already exists\n";
  exit;
}
open FILE, ">$f_name";
Query('GetQueryByName')->RunQuery(sub{
  my($row) = @_;
  my($name, $query, $args, $columns, $tags, $schema, $description) =
    @$row;
  my $q = {
    name => $name,
    query => $query,
    args => $args,
    columns => $columns,
    tags => $tags,
    schema => $schema,
    description => $description,
  };
  #PrintQueryFile($q, *STDOUT);
  PrintQueryFile($q, *FILE);
}, sub {}, $q_name);

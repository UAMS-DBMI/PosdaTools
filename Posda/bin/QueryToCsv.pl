#! /usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use DBI;
my $usage = "Usage:\n" .
  "  QueryToCsv.pl help\n" .
  "  QueryToCsv.pl help <query_name>\n" .
  "  QueryToCsv.pl describe <query_name>\n" .
  "  QueryToCsv.pl <db> <query_name> [arg, ...]\n";
if($#ARGV < 0){
   die $usage;
}
if($#ARGV == 0){
  if($ARGV[0] eq "help"){
    my @list = PosdaDB::Queries->GetList;
    print "Available Queries:\n";
    for my $i (@list) {
      print "  $i\n";
    }
  } else { die "usage" }
}
if($#ARGV == 1){
  if($ARGV[0] eq "help"){
    my $q = PosdaDB::Queries->GetQueryInstance($ARGV[1]);
    unless(defined $q) { die "No query $ARGV[1]\n" }
    my $type = $q->GetType;
    my $args = $q->GetArgs;
    print "QueryToCsv.pl <db> $ARGV[1] ";
    for my $i (0 .. $#{$args}){
      my $arg = $args->[$i];
      print "<$arg>";
      unless($i =~ $#{$args}){ print " " }
    }
    print "\n";
    my $cols = $q->GetColumns;
    print "returns columns:\n";
    for my $col (@$cols){
      print "  $col\n";
    }
    exit;
  } elsif ($ARGV[0] eq "describe"){
    my $q = PosdaDB::Queries->GetQueryInstance($ARGV[1]);
    unless(defined $q) { die "No query $ARGV[1]\n" }
    my $type = $q->GetType;
    my $args = $q->GetArgs;
    my $description = $q->GetDescription;
    my $schema = $q->GetSchema;
    my $cols = $q->GetColumns;
    my $query = $q->GetQuery;
    my @qlines = split /\n/, $query;
    print "Query Name: $ARGV[1]\n";
    print $description;
    print "Type: $type\n";
    print "Schema: $schema\n";
    print "Args:\n";
    for my $i (0 .. $#{$args}){
      print "  $args->[$i]\n";
    }
    if($type eq "select"){
      print "Returns columns:\n";
      for my $col (@$cols){
        print "  $col\n";
      }
    }
    print "Query:\n";
    for my $line(@qlines){
      print "  $line\n";
    }
    exit;
  }
}
if($#ARGV >= 1){
  my $q_name = $ARGV[1];
  my $q = PosdaDB::Queries->GetQueryInstance($ARGV[1]);
  unless(defined $q) { die "No query $ARGV[1]\n" }
  my $num_parms = $#ARGV - 1;
  my $args = $q->GetArgs;
  my $type = $q->GetType;
  unless($#{$args} + 1 == $num_parms){
    my $num_req = @$args;
    die "arg mismatch ($ARGV[1]): $num_req vs $num_parms\n";
  }
  
  if($ARGV[0] eq "help") { die $usage }
  my $dbh = DBI->connect("dbi:Pg:dbname=$ARGV[0];");
  unless($dbh) {die "Can't connect to db: $ARGV[0]\n" };
  my $cols = $q->GetColumns;
  for my $c (0 .. $#{$cols}){
    my $c_name = $cols->[$c];
    print "\"$c_name\"";
    unless($c == $#{$cols}){ print "," }
  }
  print "\n";
  $q->Prepare($dbh);
  shift @ARGV; shift @ARGV;
  my $ex_result = $q->Execute(@ARGV);
  if($type eq "select"){
    $q->Rows(
      sub {
        my($h) = @_;
        for my $c (0 .. $#{$cols}){
          my $c_name = $cols->[$c];
          my $v = $h->{$c_name};
          unless(defined $v) { $v = "" }
          print "\"$v\"";
          unless($c == $#{$cols}){ print "," }
        }
        print "\n";
      }
    );
  } else {
    print "Execute result: $ex_result\n";
  }
}

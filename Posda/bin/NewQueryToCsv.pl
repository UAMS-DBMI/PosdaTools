#! /usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Posda::Config 'Config';
use Dispatch::EventHandler;
use Storable qw (store retrieve fd_retrieve store_fd );
use DBI;
{
  package DBQuerier;
  use vars qw( @ISA );
  @ISA = ( "Dispatch::EventHandler" );
  sub new {
    my($class, $descriptor) = @_;
    return bless $descriptor, $class;
  }
  sub execute{
    my($this) = @_;
    my $command = "SubProcessQuery.pl";
    $this->SerializedSubProcess($this, $command, $this->done);
  }
  sub done{
    my($this) = @_;
    my $sub = sub {
      my($status, $struct) = @_;
      if($status = "Succeeded" && $struct->{Status} eq "OK"){
        if(exists $struct->{NumRows}){
          print "Number of rows: $struct->{NumRows}\n";;
        } elsif(exists $struct->{Rows}){
          my $cols = $this->{columns};
          for my $c (0 .. $#{$cols}){
            my $c_name = $cols->[$c];
            print "\"$c_name\"";
            unless($c == $#{$cols}){ print "," }
          }
          print "\n";
          for my $row (@{$struct->{Rows}}){
            for my $c (0 .. $#{$row}){
              my $c_name = $row->[$c];
              unless(defined $c_name) { $c_name = "" }
              print "\"$c_name\"";
              unless($c == $#{$row}){ print "," }
            }
            print "\n";
          }
        }
      } else {
        print "Status: $status\n";
        if(exists $struct->{Message}){
          print "Message: $struct->{Message}\n";
        }
      }
    };
    return $sub;
  }
}
sub Launcher{
  my($spec) = @_;
  my $sub = sub {
    my($disp) = @_;
    my $queries = DBQuerier->new($spec);
    $queries->execute;
  };
  return $sub;
}
sub to_db {
  # Look up the given schema name in the environment
  my ($name) = @_;
  my $schema_map = {
    posda_nicknames => "NICKNAMES_DB_NAME",
    posda_files => "FILES_DB_NAME",
  };

  my $config_var = $schema_map->{$name};
  if (defined $config_var) {
    return Config($config_var);
  } else {
    return 'NONE';
  }
}

my $usage = "Usage:\n" .
  "  QueryToCsv.pl freeze <file_name>\n" .
  "  QueryToCsv.pl help\n" .
  "  QueryToCsv.pl help <query_name>\n" .
  "  QueryToCsv.pl describe <query_name>\n" .
  "  QueryToCsv.pl query <query_name> [arg, ...]\n";
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
    print "QueryToCsv.pl query $ARGV[1] ";
    for my $i (0 .. $#{$args}){
      my $arg = $args->[$i];
      print "<$arg>";
      unless($i =~ $#{$args}){ print " " }
    }
    print "\n";
    if($q->GetQuery =~ /^select/){
      my $cols = $q->GetColumns;
      print "returns columns:\n";
      for my $col (@$cols){
        print "  $col\n";
      }
    }
    exit;
  } elsif($ARGV[0] eq "freeze"){
    my $file = $ARGV[1];
    PosdaDB::Queries->Freeze($file);
    exit(0);
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
if($#ARGV >= 1 && $ARGV[0] eq "query"){
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
  shift @ARGV; shift @ARGV;
  $q->{bindings} = \@ARGV;
  Dispatch::Select::Background->new(Launcher($q))->queue;
  Dispatch::Select::Dispatch();
}

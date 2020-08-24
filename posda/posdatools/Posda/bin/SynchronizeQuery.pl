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
  print $fh "-- \n\n";
  print $fh $query->{query};
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
sub ParseQueryFile{
  my($file_name) = @_;
  my $h = {};
  open FILE, "<$file_name" or die "Can't open $file_name";
  my $mode = 'Name';
  my $description;
  my $query;
  while (my $line = <FILE>){
    if($mode eq 'Name'){
      chomp $line;
      unless($line =~ /^-- Name: (.*)\s*$/){
        print "Unable to parse $file_name - bad name format:\n\"$line\"\n";
        exit;
      }
      $h->{name} = $1;
      $mode = 'Schema';
    } elsif ($mode eq "Schema"){
      chomp $line;
      unless($line =~ /^-- Schema: (.*)\s*$/){
        print "Unable to parse $file_name - bad schema format:\n\"$line\"\n";
        exit;
      }
      $h->{schema} = $1;
      $mode = 'Columns';
    } elsif ($mode eq "Columns"){
      chomp $line;
      if($line =~ /^-- Columns: \[(.*)\]\s*$/){
        $h->{columns} = ParseArray($1);
        $mode = 'Args';
      } else {
        if($line =~ /^-- Columns: None$/){
          $h->{args} = ParseArray($1);
          $mode = 'Args';
        } else {
          print "Unable to parse $file_name - bad columns format:\n\"$line\"\n";
          exit;
        }
      }
    } elsif ($mode eq "Args"){
      chomp $line;
      if($line =~ /^-- Args: \[(.*)\]\s*$/){
        $h->{args} = ParseArray($1);
        $mode = 'Tags';
      } else {
        if($line =~ /^-- Args: None$/){
          $h->{args} = ParseArray($1);
          $mode = 'Tags';
        } else {
          print "Unable to parse $file_name - bad args format:\n\"$line\"\n";
          exit;
        }
      }
    } elsif ($mode eq "Tags"){
      chomp $line;
      if($line =~ /^-- Tags: \[(.*)\]\s*$/){
        $h->{tags} = ParseArray($1);
        $mode = 'Description';
      } else {
        if($line =~ /^-- Tags: None$/){
          $h->{tags} = ParseArray($1);
          $mode = 'Description';
        } else {
          print "Unable to parse $file_name - bad tags format:\n\"$line\"\n";
          exit;
        }
      }
    } elsif ($mode eq "Description"){
      chomp $line;
      unless($line =~ /^-- Description: (.*)$/){
        print "Unable to parse $file_name - bad description format:\n\"$line\"\n";
        exit;
      }
      $description = "$1";
      $mode = 'DescriptionLines';
    } elsif ($mode eq "DescriptionLines"){
      chomp $line;
      if($line =~ /^-- (.*)/){
        $description .= "\n$1";
      } elsif($line =~ /^\s*$/) {
        $h->{description} = $description;
        $mode = 'QueryLines';
      }
    } elsif ($mode eq "QueryLines"){
      $query .= $line;
    }
  }
  $h->{query} = $query;
  return $h;
}
sub CompareQueries{
  my($q_name, $on_disk, $in_db) = @_;
  my $q_disk = $on_disk->{query};
  my $q_in_db = $in_db->{query};
  $q_disk =~ s/\s*$//;
  $q_disk =~ s/^\s*//;
  $q_in_db =~ s/\s*$//;
  $q_in_db =~ s/^\s*//;
  unless($q_disk eq $q_in_db){
    print "$q_name has non matching query values:\n";
    print "On disk ###########\n$q_disk\n";
    print "-------------------\n$q_in_db\n";
    print "In DB #############\n";
  }
  my $desc_disk =  $on_disk->{description};
  my $desc_in_db = $in_db->{description};
  $desc_disk =~ s/\s*$//;
  $desc_disk =~ s/^\s*//;
  $desc_in_db =~ s/\s*$//;
  $desc_in_db =~ s/^\s*//;
  unless($desc_disk eq $desc_in_db){
    print "$q_name has non matching description:\n";
    print "On disk ############\n$desc_disk\n";
    print "--------------------\n$desc_in_db\n";
    print "In DB ##############\n";
  }
}
my $g_q = Query('GetQueryByName');
sub GetQueryByName{
  my($q_name) = @_;
  my $q;
  $g_q->RunQuery(sub{
    my($row) = @_;
    my($name, $query, $args, $columns, $tags, $schema, $description) =
      @$row;
    $q = {
      name => $name,
      query => $query,
      args => $args,
      columns => $columns,
      tags => $tags,
      schema => $schema,
      description => $description,
    };
  }, sub {}, $q_name);
  return $q;
}


my $usage = <<EOF;
usage:
SynchronizeQuery.pl <query_name> <op>
or 
SynchronizeQuery.pl -h

Where:
  <query_name> = name of query
  <op> = take_disk | take_db | compare

Processing:
  if(op eq take_disk){
    if(-f /home/posda/posdatools/queries/sql/<query_name>.sql){
      parse file;
      if(<query_name> is in queries table){
        update queriea table from parsed file
      } else {
        insert into queries from parsed file
      }
    } else {
      error ("<query_name> is not in queries directory")
    }
  } else if (op eq "take_db"){
    fetch query from db
    if(query_exists){
      write file from query
    } else {
      error ("<query_name> is not in db")
    } 
  } else if (op eq "compare"){
    fetch db_query from db;
    parse file_query from file;
    if(defined db_query and defined file_query){
      CompareQueries(<query_name>, disk_query, db_query);
    } else if (defined db_query)
      error ("<q_name> is not in db")
    } else {
      error ("<file> is not in queries_directory")
    }
  }
EOF
my $dir = '/home/posda/posdatools/queries/sql';
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 1){
  my $num_args = @ARGV;
  die "Wrong # args ($num_args vs 2), usage:\n$usage";
}

my $q_name = $ARGV[0];
my $op = $ARGV[1];
my $file = "/home/posda/posdatools/queries/sql/$q_name.sql"; 
my $q_disk;
if(-f $file){
  $q_disk = ParseQueryFile($file);
}
my $q_db = GetQueryByName($q_name);
if($op eq "take_disk"){
  if(defined $q_disk){
    if(defined $q_db){
      #update queriea table from parsed file
      Query('UpdateQueryRow')->RunQuery(sub{}, sub{},
       $q_disk->{query}, $q_disk->{args},
       $q_disk->{columns}, $q_disk->{tags},
       $q_disk->{schema}, $q_disk->{description},
       $q_disk->{name});
      
    } else {
      #insert into queries from parsed file
      Query('CreateQuery')->RunQuery(sub{}, sub{},
       $q_disk->{name}, $q_disk->{query},
       $q_disk->{args}, $q_disk->{columns},
       $q_disk->{tags}, $q_disk->{schema},
       $q_disk->{description});
    }
  } else {
    die ("$q_name is not in queries directory")
  }
} elsif ($op eq "take_db"){
  if(defined $q_db){
    #write file from query
    open FILE, ">$file" or die "Can't open $file";
    PrintQueryFile($q_db,\*FILE);
    close FILE;
  } else {
    die ("$q_name is not in db")
  } 
} elsif ($op eq "compare"){
  if(defined $q_db && defined $q_disk){
    CompareQueries($q_name, $q_disk, $q_db);
  } elsif (defined $q_disk){
    die ("$q_name is not in db")
  } else {
    error ("$q_name.sql is not in queries_directory")
  }
}

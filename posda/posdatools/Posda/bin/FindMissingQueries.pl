#!/usr/bin/perl -w
use strict;
use Posda::DB qw(Query);
use Debug;
my $dbg = sub { print STDERR @_ };
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
        if($line =~ /^-- Columns: (None)$/){
          $h->{columns} = ParseArray($1);
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
      unless($line =~ /^-- Description:(.*)$/){
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
sub PrintArray{
  my($array, $fh) = @_;
  if(ref($array) eq "ARRAY" && $#{$array} >= 0){
    for my $i (0 .. $#{$array}){
      print $fh "'$array->[$i]'";
      unless($i eq $#{$array}){ print $fh ", " }
    }
  }
}

my $dir = '/home/posda/posdatools/queries/sql';
opendir DIR, $dir or die "Can't opendir $dir";;
my %QueryFiles;
while(my $file = readdir(DIR)){
  unless($file =~ /^(.*)\.sql$/) { next }
  my $q_name = $1;
  $QueryFiles{$q_name} = ParseQueryFile("$dir/$file");
}
my %Queries;
Query('GetAllQueries')->RunQuery(sub {
  my($row) = @_;
  my($name, $query, $args, $columns, $tags, $schema, $description) =
    @$row;
  $Queries{$name} = {
    name => $name,
    query => $query,
    args => $args,
    columns => $columns,
    tags => $tags,
    schema => $schema,
    description => $description,
  };
  unless (defined($Queries{$name}->{columns})){
    $Queries{$name}->{columns} = [];
  }
}, sub{});
for my $i (keys %Queries){
  if(exists $QueryFiles{$i}){
#    print "$i is in both\n";
    my $q1 = $Queries{$i}->{query};
    my $q2 = $QueryFiles{$i}->{query};
    $q1 =~ s/\s*$//;
    $q1 =~ s/^\s*//;
    $q2 =~ s/\s*$//;
    $q2 =~ s/^\s*//;
    unless($q1 eq $q2){
      print "$i has non matching query values:\n";
      print "In DB   ################\n$q1\n";
      print "---------------------- -\n$q2\n";
      print "In File ################\n";
    }
    my $desc1 = $Queries{$i}->{description};
    my $desc2 = $QueryFiles{$i}->{description};
    $desc1 =~ s/\s*$//;
    $desc1 =~ s/^\s*//;
    $desc2 =~ s/\s*$//;
    $desc2 =~ s/^\s*//;
    unless($desc1 eq $desc2){
      print "$i has non matching description:\n";
      print "In DB ##############\n$desc1\n";
      print "--------------------\n$desc2\n";
      print "In File ############\n";
    }
    unless(CompareArray($Queries{$i}->{args}, $QueryFiles{$i}->{args})){
      print "$i has non matching args values:\n";
      print "In DB ################\n[";
      PrintArray($Queries{$i}->{args}, *STDOUT);
      print "]\n-------------------\n[";
      PrintArray($QueryFiles{$i}->{args}, *STDOUT);
      print "]\nIn Dir###########\n";
    }
    unless(CompareArray($Queries{$i}->{columns}, $QueryFiles{$i}->{columns})){
      print "$i has non matching columns values:\n";
      print "In DB ################\n[";
      PrintArray($Queries{$i}->{columns}, *STDOUT);
      print "]\n-------------------\n[";
      PrintArray($QueryFiles{$i}->{columns}, *STDOUT);
      print "]\nIn Dir###########\n";
    }
    unless(CompareArray($Queries{$i}->{tags}, $QueryFiles{$i}->{tags})){
      print "$i has non matching tags values:\n";
      print "In DB ################\n[";
      PrintArray($Queries{$i}->{tags}, *STDOUT);
      print "]\n-------------------\n[";
      PrintArray($QueryFiles{$i}->{tags}, *STDOUT);
      print "]\nIn Dir###########\n";
    }
  } else {
    print "$i is in DB, not in queries directory\n";;
    print STDERR "foo: ";
    Debug::GenPrint($dbg, $Queries{$i}, 1);
    print STDERR "\n";
  }
}
for my $i (keys %QueryFiles){
  unless(exists $Queries{$i}){
    print "$i is in queries directory, not in DB\n";;
  }
}

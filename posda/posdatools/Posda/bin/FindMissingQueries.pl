#!/usr/bin/perl -w
use strict;
use Posda::DB qw(Query);
use Debug;
my $dbg = sub { print @_ };
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
        $h->{args} = ParseArray($1);
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
  $Queries{$row->[0]} = {
    name => $name,
    query => $query,
    args => $args,
    columns => $columns,
    tags => $tags,
    schema => $schema,
    description => $description,
  };
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
      print "####################\n$q1\n";
      print "####################\n$q2\n";
      print "####################\n";
    }
    my $desc1 = $Queries{$i}->{description};
    my $desc2 = $QueryFiles{$i}->{description};
    $desc1 =~ s/\s*$//;
    $desc1 =~ s/^\s*//;
    $desc2 =~ s/\s*$//;
    $desc2 =~ s/^\s*//;
    unless($desc1 eq $desc2){
      print "$i has non matching description:\n";
      print "####################\n$desc1\n";
      print "####################\n$desc2\n";
      print "####################\n";
    }
  } else {
    print "$i is in DB, not in queries directory\n";;
  }
}
for my $i (keys %QueryFiles){
  unless(exists $Queries{$i}){
    print "$i is in queries directory, not in DB\n";;
  }
}

#!/usr/bin/perl -w
use strict;
use DBI;
my $dbh = DBI->connect("dbi:Pg:dbname=public_tag_disposition");
my $insert = $dbh->prepare(
"insert into public_tag_disposition(tag_name, name, disposition) values (?,?,?)"
);
while (my $line = <STDIN>){
  chomp $line;
  my($tag, $name, $disposition) = split (/\s+/, $line);
  unless($tag =~ /^(....)(....)$/){
    print STDERR "Bad tag: $tag\n";
    next;
  }
  my $group = $1; my $ele = $2;
  my $groupn = hex($group);
  if($groupn & 1) {
    print STDERR "Group: $group is private\n";
    next;
  }
  my $tagn = "($group,$ele)";
  print "$tagn\n";
  $insert->execute($tagn, $name, $disposition);
}

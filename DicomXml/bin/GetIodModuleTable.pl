#!/usr/bin/perl
#$Source: /home/bbennett/pass/archive/DicomXml/bin/GetIodModuleTable.pl,v $
#$Date: 2014/07/25 13:51:40 $
#$Revision: 1.1 $
#
#Copyright 2014, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use XML::Parser;
use Storable qw( retrieve store_fd);
use Debug;
my $dbg = sub { print @_ };
use Cwd;
unless($#ARGV == 1) {
  die "usage: GetIodModuleTable.pl <parsed_xml_file> <id>";
}
my $doc = retrieve($ARGV[0]);
my $rows;
for my $i (@{$doc->{index}->{$ARGV[1]}->{content}}){
  unless(ref($i)) { next }
  if($i->{el} eq "tbody"){ $rows = $i->{content} }
}
$rows = DeleteWhiteSpace($rows);
#print "Rows: ";
#Debug::GenPrint($dbg, $rows, 1, 5);
#print "\n";
my $entity;
my $module;
my $ref;
my $req;
for my $row (@$rows){
  if($#{$row->{content}} == 3){
    $entity = CollapseContent(GetContent($row->{content}->[0]));
    $module = CollapseContent(GetContent($row->{content}->[1]));
    $ref = GetTable(GetLabel($row->{content}->[2]));
    $req = GetUsage($row->{content}->[3]);
  } elsif($#{$row->{content}} == 2){
    $module = CollapseContent(GetContent($row->{content}->[0]));
    $ref = GetTable(GetLabel($row->{content}->[1]));
    $req = GetUsage($row->{content}->[2]);
  } else {
    my $num_cols = $#{$row->{content}};
    die "$num_cols in row";
  }
  print "$entity|$module|$ref|$req\n";
}
sub DeleteWhiteSpace{
  my($c) = @_;
  my @nc;
  if(ref($c) eq "HASH") {
    my %h;
    for my $key (keys %$c) {
      unless($key eq "content") { $h{$key} = $c->{$key} }
    }
    $h{content} = DeleteWhiteSpace($c->{content});
    return \%h;
  }
  for my $i (@$c){
    if(ref($i)){
      $i->{content} = DeleteWhiteSpace($i->{content});
      push @nc, $i;
    } else {
      if($i =~ /^\s*$/s){ next }
      else { push @nc, $i }
    }
  }
  return \@nc;
}
sub GetContent{
  my($h) = @_;
  my @content;
  for my $i (@{$h->{content}}){
    if(ref($i)){
      my $ref = ref($i);
      my $sub_content = GetContent($i);
      for my $j (@$sub_content) { push @content, $j }
    } else { push @content, $i }
  }
  return \@content;
}
sub CollapseContent{
  my($a) = @_;
  my $text = "";
  for my $i (@$a){ $text .= $i }
  return $text;
}
sub GetLabel{
  my($c) = @_;
  unless(ref($c) eq "HASH") { return undef }
  if($c->{el} eq "xref") { return $c->{attrs}->{linkend} }
  for my $i (@{$c->{content}}){
    my $foo = GetLabel($i);
    if(defined $foo) { return $foo }
  }
}
sub GetUsage{
  my($c) = @_;
  return CollapseContent(GetContent($c));
}
sub GetTable{
  my($label) = @_;
  my $sect = DeleteWhiteSpace($doc->{index}->{$label});
  my $title;
  my $table;
#print "Section: ";
#Debug::GenPrint($dbg, $sect, 1);
#print "\n";
  for my $i (@{$sect->{content}}){
    if($i->{el} eq "title"){
      $title = CollapseContent(GetContent($i));
    }
    if($i->{el} eq "table") { $table = $i->{attrs}->{"xml:id"} }
  }
  return $table;
}

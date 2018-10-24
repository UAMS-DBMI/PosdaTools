#!/usr/bin/perl -w
#
#Copyright 2014, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use File::Find;
use Cwd;
use Storable;
my $usage = <<EOF;
CheckDupId.pl <parsed_dir>
EOF
unless($#ARGV == 0) { die $usage }
my $dir = $ARGV[0];
my $cwd = getcwd;
unless($dir =~ /^\//) { $dir = "$cwd/$dir" }
my $finder = sub {
  my $file = $File::Find::name;
  unless(-f $file) { return }
  if($_ eq "XmlIdIndex"){ return }
  my $parsed;
  eval { $parsed = retrieve($file) };
  if($@) {
    print STDERR "can't retrieve from $file:\n" .
      "$@\n";
    return;
  } else {
  }
  unless(exists($parsed->{index}) && ref($parsed->{index}) eq "HASH") { return }
  my $index = $parsed->{index};
  for my $k (keys %$index){
    if(ref($parsed->{index}->{$k}) eq "ARRAY"){
      print "$k is multiply defined in $file\n";
    } elsif (ref($parsed->{index}->{$k}) eq "HASH"){
      print "$k is uniquely defined in $file\n";
    } else {
      print "$k is not defined in $file\n";
    }
  }
};
find($finder, $dir);
use strict;
use File::Find;
use Cwd;
use Storable;
use Debug;
my $dbg = sub { print @_ };
my $usage = <<EOF;
GenerateXmlIdIndex.pl <parsed_dir>
EOF
unless($#ARGV == 0) { die $usage }
my $dir = $ARGV[0];
my $cwd = getcwd;
unless($dir =~ /^\//) { $dir = "$cwd/$dir" }
my %ById;
my %ByFile;
my %ByTopLevelElement;
my $finder = sub {
  my $file = $File::Find::name;
  unless(-f $file) { return }
  if($_ eq "XmlIdIndex"){ return }
  my $parsed;
  eval { $parsed = retrieve($file) };
  if($@) {
    print STDERR "can't retrieve from $file:\n" .
      "$@\n";
    return;
  } else {
    print "Retrieved from $file\n";
  }
  my $f_index = "<unknown>";
  if($file =~ /^$dir\/(.*).perl/){
    $f_index = $1;
  }
  my $top_level = $parsed->{content}->{el};
  $ByTopLevelElement{$top_level}->{$f_index} = 1;
  my $index = $parsed->{index};
  for my $k (keys %$index){
    if(exists $ById{$k}){
      unless(ref($ById{$k}) eq "ARRAY"){
        $ById{$k} = [ $ById{$k} ];
      }
      push @{$ById{$k}}, $f_index;
    } else {
      $ById{$k} = $f_index;
    }
    $ByFile{$f_index}->{$k} = GetTitleOrCaption($parsed->{index}->{$k}, $k);
  }
  
};
find($finder, $dir);
my $results = {
  ById => \%ById,
  ByFile => \%ByFile,
  ByEl => \%ByTopLevelElement,
};
store $results, "$dir/XmlIdIndex";
sub GetTitleOrCaption{
  my($section, $index) = @_;
  for my $i (@{$section->{content}}){
    unless(ref($i) eq "HASH") { next }
    unless(exists $i->{el}) { next }
    unless($i->{el} eq "title" || $i->{el} eq "caption") { next }
    return $i->{el} . " - " . GetText($i);
  }
  return "no title or caption";
}
sub GetText{
  my($xml) = @_;
#print "Xml: ";
#Debug::GenPrint($dbg, $xml, 1);
#print "\n";
  unless(ref($xml)){ return $xml }
  if(ref($xml) eq "HASH"){
    my $text = "";
    for my $i (@{$xml->{content}}){
      $text .= GetText($i);
    }
    return $text;
  }
  print STDERR "malformed xml\n";
  return "";
}

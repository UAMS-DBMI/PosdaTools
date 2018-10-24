#!/usr/bin/perl -w
use strict;
use XMLParse;
use Debug;
my $dbg = sub { print STDERR @_ };
my $parser = XMLParse->newTree;
open my $fh, "<$ARGV[0]" or die "can't open $ARGV[0]";
unless($parser->parse($fh)){
  die "Failed to parse";
}
my $v = {
  tag => $parser->{el}->{tag},
  attrs => $parser->{el}->{value}->{attrs},
  content => $parser->{el}->{value}->{content},
};
DumpXml($v, "");
sub DumpXml{
  my($struct, $indent) = @_;
  if(ref($struct) eq "HASH"){
    print "$indent<$struct->{tag}";
    my $new_indent = $indent . "  ";
    my @keys = sort keys %{$struct->{attrs}};
    if(@keys > 0){
      print "\n";
      for my $i (0 .. $#keys){
        my $k = $keys[$i];
        print "$new_indent$k=\"$struct->{attrs}->{$k}\"";
        if($i != $#keys) {
          print "\n";
        };
      }
    }
    if($#{$struct->{content}} < 0) {
      print "/>\n";
    } else {
      print ">\n";
      for my $s (@{$struct->{content}}){
        DumpXml($s, $new_indent);
      }
      print "$indent</$struct->{tag}>\n";
    }
  } else {
    print "$indent$struct\n";
  }
}

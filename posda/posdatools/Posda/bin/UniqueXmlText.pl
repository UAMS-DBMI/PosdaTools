#!/usr/bin/perl -w
use strict;
use XMLParse;
#use Debug;
#my $dbg = sub { print STDERR @_ };
my $show_indices = 0;
if($#ARGV == 1 && $ARGV[1] eq 'indices'){ $show_indices = 1 }
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
DumpXml($v, ".", "");
my %Values;
sub DumpXml{
  my($struct, $indent, $indices) = @_;
  if(ref($struct) eq "HASH"){
    $Values{$struct->{tag}}->{tag_name}->{$indent}->{$indices} = 1;
    my $new_indent = $indent . "/$struct->{tag}";
    my @keys = sort keys %{$struct->{attrs}};
    if(@keys > 0){
      for my $i (0 .. $#keys){
        my $k = $keys[$i];
        $Values{$k}->{attribute_name}->{$new_indent}->{$indices} = 1;
        my $attr_path = $new_indent . "{$k}";
        $Values{$struct->{attrs}->{$k}}->{attribute_value}->{$attr_path}->{$indices} = 1;
      }
    }
    unless($#{$struct->{content}} < 0) {
      for my $i (0 .. $#{$struct->{content}}){
        my $s = $struct->{content}->[$i];
        my $new_indices;
        if($indices eq ""){
          $new_indices = $indices . "$i";
        } else {
          $new_indices = $indices . ",$i";
        }
        DumpXml($s, $new_indent . "[-]", $new_indices);
      }
    }
  } else {
    $Values{$struct}->{text}->{$indent} = 1;
  }
}
for my $v (sort keys %Values){
  for my $t (sort keys %{$Values{$v}}){
    for my $p (sort keys %{$Values{$v}->{$t}}){
      if($show_indices){
        for my $i (sort keys %{$Values{$v}->{$t}->{$p}}){
          print "$v|$t|$p|$i\n";
        }
      } else {
        print "$v|$t|$p\n";
      }
    }
  }
}
#print STDERR "Values = ";
#Debug::GenPrint($dbg, \%Values, 1, 5);
#print STDERR "\n";

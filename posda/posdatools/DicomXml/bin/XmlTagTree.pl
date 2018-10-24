#!/usr/bin/perl
#
#Copyright 2014, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use XML::Parser;
unless($#ARGV == 0) {
  die "usage: XmlTagTree.pl <file>";
}
{
  package XmlTagTree;
  sub new{
    my($class) = @_;
    my $this = {
      level => 0,
    };
    return bless $this, $class;
  }
  sub Handlers{
    my($this) = @_;
    my $start = $this->Start;
    my $end = $this->End;
    my $char = $this->Char;
    return ($start, $end, $char);
  }
  sub Start{
    my($this) = @_;
    my $sub = sub {
      my $parser = shift;
      my $el = shift;
      my %attrs = @_;
      #---
      print "  " x $this->{level}, "<$el";
      $this->{level} += 1;
      for my $k (keys %attrs){
        print " $k=\"$attrs{$k}\"";
      }
      print ">\n";
    };
    return $sub;
  };
  sub Char{
    my($this) = @_;
    my $sub = sub {
      my $parser = shift;
      my $string = shift;
      if($string =~ /^\s*$/) { return }
      #---
      print "  " x $this->{level}, "$string\n";
    };
    return $sub;
  };
  sub End{
    my($this) = @_;
    my $sub = sub {
      my $parser = shift;
      my $el = shift;
      #---
      $this->{level} -= 1;
      print "  " x $this->{level}, "</$el>\n";
    };
    return $sub;
  };
}
my $obj = XmlTagTree->new;
print "Obj: $obj\n";
my($start, $end, $char) = $obj->Handlers;
my $parser = XML::Parser->new(Handlers => {
  Start => $start,
  End => $end,
  Char => $char
});
$parser->parsefile($ARGV[0]);

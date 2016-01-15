#!/usr/bin/perl
#$Source: /home/bbennett/pass/archive/DicomXml/bin/GetWords.pl,v $
#$Date: 2014/03/21 19:53:49 $
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
use utf8;
unless($#ARGV == 0) {
  die "usage: XmlTagTree.pl <file>";
}
{
  package XmlWords;
  sub new{
    my($class) = @_;
    my $this = {
      words =>{
      },
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
    };
  };
  sub Char{
    my($this) = @_;
    my $sub = sub {
      my $parser = shift;
      my $string = shift;
      if($string =~ /^\s*$/) { return }
      #---
      my @words = split(/[\s,\.\?\"\'\(\)\[\}\]\{\;\:]+/, $string);
      for my $word (@words){  print "$word\n" }
    };
    return $sub;
  };
  sub End{
    my($this) = @_;
    my $sub = sub {
      my $parser = shift;
      my $el = shift;
      #---
    };
  };
}
my $obj = XmlWords->new;
print "Obj: $obj\n";
my($start, $end, $char) = $obj->Handlers;
my $parser = XML::Parser->new(Handlers => {
  Start => $start,
  End => $end,
  Char => $char
});
$parser->parsefile($ARGV[0]);

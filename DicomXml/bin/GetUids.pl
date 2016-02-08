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
  die "usage: GetUniqueWords.pl <file>";
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
      if(exists $this->{characters}){
        $this->ProcessCharacters;
      }
      $this->{characters} = "";
    };
  };
  sub Char{
    my($this) = @_;
    my $sub = sub {
      my $parser = shift;
      my $string = shift;
      #---
      $this->{characters} .= $string;
    };
    return $sub;
  };
  sub End{
    my($this) = @_;
    my $sub = sub {
      my $parser = shift;
      my $el = shift;
      #---
      if($this->{characters}){
        $this->ProcessCharacters;
      }
    }
  };
  sub ProcessCharacters{
    my($this, $characters) = @_;
    my $string = $this->{characters};
    if($string =~ /^[\d\N{ZERO WIDTH SPACE}\.\s]+$/){
      my $new_string = $string;
      $new_string =~ s/\N{ZERO WIDTH SPACE}//g;
      if($new_string =~ /^(\d+\.)+\d+$/){
        $this->{words}->{$new_string} = 1;
      }
    }
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
for my $i (sort keys %{$obj->{words}}){
  print "\"$i\"\n";
}

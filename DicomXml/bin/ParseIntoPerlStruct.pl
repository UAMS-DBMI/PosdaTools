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
use Storable;
use Cwd;
use Debug;
my $dbg = sub { print @_ };
unless($#ARGV == 1) {
  die "usage: ParseIntoPerlStruct.pl <xml_file> <storable_file>";
}
{
  package XmlStruct;
  sub new{
    my($class) = @_;
    my $this = {
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
      unless(exists $this->{stack}) { $this->{stack} = [] }
      if($this->{el}){
        push(@{$this->{stack}}, 
          [$this->{el}, $this->{content}, $this->{attrs}]);
      } else {
      }
      $this->{content} = [];
      $this->{attrs} = \%attrs;
      $this->{el}  = $el;
    };
    return $sub;
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
      if(defined($this->{characters})){
        $this->ProcessCharacters;
      }
      unless($this->{el} eq $el){
        print STDERR "End($el) doesn't match start($el)\n";
      }
      my $content_item = {
        el => $this->{el},
      };
      if(scalar keys %{$this->{attrs}}){
        $content_item->{attrs} = $this->{attrs};
      }
      if(scalar @{$this->{content}}){
        $content_item->{content} = $this->{content};
      }
      if(exists $this->{attrs}->{"xml:id"}){
        my $index = $this->{attrs}->{"xml:id"};
        if(exists $this->{index}->{$index}){
          unless(ref($this->{index}->{$index}) eq "ARRAY"){
            $this->{index}->{$index} = [ $this->{index}->{$index} ];
          }
          push(@{$this->{index}->{$index}}, $content_item);
        } else {
          $this->{index}->{$this->{attrs}->{"xml:id"}} = $content_item;
        }
      }
      if(
        exists($this->{stack}) && ref($this->{stack}) eq "ARRAY" &&
        $#{$this->{stack}} >= 0
      ){
        my $frame = pop @{$this->{stack}};
        my($pop_ele, $pop_content, $pop_attrs) = @{$frame};
        $this->{el} = $pop_ele;
        $this->{attrs} = $pop_attrs;
        $this->{content} = $pop_content;
        push(@{$this->{content}}, $content_item);
      } else {
        $this->{content} = $content_item;
        delete $this->{el};
        delete $this->{attrs};
        delete $this->{stack};
      }
    };
    return $sub;
  };
  sub ProcessCharacters{
    my($this, $characters) = @_;
    my $string = $this->{characters};
    push(@{$this->{content}}, $string);
    delete $this->{characters};
  };
}
my $obj = XmlStruct->new;
my($start, $end, $char) = $obj->Handlers;
my $parser = XML::Parser->new(Handlers => {
  Start => $start,
  End => $end,
  Char => $char
});
my $work_dir = getcwd;
my $xml_file = $ARGV[0];
unless($xml_file =~ /^\//){ $xml_file = "$work_dir/$xml_file" }
my $storable_file = $ARGV[1];
unless($storable_file =~ /^\//){ $storable_file = "$work_dir/$storable_file" }
$parser->parsefile($xml_file);
store $obj, $storable_file;

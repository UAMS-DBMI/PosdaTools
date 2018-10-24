#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
#
package XMLParse;
use strict;
use XML::Parser;
use Debug;
use Encode qw(encode decode);
my $dbg = sub {print @_};

sub new{
  my $class = shift;
  my $handlers = shift;
  my $defaults = shift;
  my $this = {
    handlers => $handlers,
    defaults => $defaults,
  };
  my $start = sub {
    my $parser = shift;
    my $el = shift;
    my %attrs = @_;
    my @attrlist = sort keys %attrs;
    my $i;
    my $parent;
    my $depth = 0;
    if(exists $this->{el}){
      $parent = $this->{el};
      $this->{el} = {
        parent => $parent,
      };
      $depth = $parent->{depth} + 1;
    } else {
      $this->{el} = {};
    }
    $this->{el}->{tag} = $el;
    $this->{el}->{attrs} = \%attrs;
    $this->{el}->{list} = [];
    $this->{el}->{depth} = $depth;
    $this->{el}->{count} = 0;
    if(exists($this->{handlers}->{Start}->{$el})){
      &{$this->{handlers}->{Start}->{$el}}($this);
    } elsif(exists $this->{defaults}->{Start}) {
      &{$this->{defaults}->{Start}}($this);
    }
  };

  my $end = sub {
    my $parser = shift;
    my $el = shift;
    unless($el eq $this->{el}->{tag}){ 
      die "Non matching tags: $el $this->{el}->{tag}" 
    }
    if(exists($this->{handlers}->{End}->{$el})){
      &{$this->{handlers}->{End}->{$el}}($this);
    } elsif(exists $this->{defaults}->{End}) {
      &{$this->{defaults}->{End}}($this);
    }
    if(exists $this->{el}->{parent}){
      $this->{el} = $this->{el}->{parent};
    } else {
      delete $this->{el};
    }
  };

  my $char = sub {
    my $parser = shift;
    my $string = shift;
    my $el = $this->{el}->{tag};
    if(exists($this->{handlers}->{Char}->{$el})){
      &{$this->{handlers}->{Char}->{$el}}($this, $string);
    } elsif(exists $this->{defaults}->{Char}) {
      &{$this->{defaults}->{Char}}($this, $string);
    }
  };

  $this->{parser} = XML::Parser->new(Handlers => {
    Start => $start,
    End => $end,
    Char => $char,
  });
  $this->{depth} = 0;
  return bless($this, $class);
}

sub parse{
  my $this = shift;
  my $fh = shift;
  $this->{parser}->parse($fh);
};

sub newTree{
  my $class = shift;
  my $this;
  my $start = sub {
    my $parser = shift;
    my $el = shift;
    my %attrs = @_;
    my $parent;
    if(exists $this->{el}){
      $parent = $this->{el},
      $this->{el} = {
        parent => $parent,
      };
    } else {
      $this->{el} = {};
    }
    $this->{el}->{tag} = $el;
    $this->{el}->{value} = {
      tag => $el,
      attrs => \%attrs,
      content => [],
    }
  };
  my $end = sub {
    my $parser = shift;
    my $el = shift;
    unless($el eq $this->{el}->{tag}){ 
      die "Non matching tags: $el $this->{el}->{tag}" 
    }
    if(exists $this->{el}->{value}->{content}){
      $this->{el}->{value}->{content} = 
        $this->CollapseText($this->{el}->{value}->{content});
    }
    if(exists $this->{el}->{parent}){
      push(@{$this->{el}->{parent}->{value}->{content}}, $this->{el}->{value});
    }
    if(exists $this->{el}->{parent}){
      $this->{el} = $this->{el}->{parent};
    }
  };
  my $char = sub {
    my $parser = shift;
    my $string = shift;
    my $el = $this->{el}->{tag};
    if($string =~ /^\s*$/){
      if($string eq "\r"){
        push(@{$this->{el}->{value}->{content}}, $string)
      } elsif($string eq "\n"){
        push(@{$this->{el}->{value}->{content}}, $string)
      } else {
        push(@{$this->{el}->{value}->{content}}, " ")
      }
    } else {
      push(@{$this->{el}->{value}->{content}}, $string)
    }
  };
  $this->{parser} = XML::Parser->new(Handlers => {
    Start => $start,
    End => $end,
    Char => $char,
  });
  return bless($this, $class);
}
sub ParseTree{
  my($this) = @_;
  my $ret = {
    tag => $this->{el}->{tag},
    attrs => $this->{el}->{value}->{attrs},
    content => $this->{el}->{value}->{content}
  };
  return $ret;
}
sub CollapseText{
  my $this = shift;
  my $content = shift;
  my @collapsed_content;
  my $running_text = "";
  item:
  for my $i (0 .. $#{$content}){
    my $item = $content->[$i];
    my $type = ref($item);
    if(ref($item) ne "HASH"){
      $running_text .= $item;
      next item;
    } else {
      if($running_text ne ""){
        push @collapsed_content, encode('utf8', $running_text);
        $running_text = "";
      }
      push @collapsed_content, $item;
      next item;
    }
  }
  if($running_text ne ""){
    push @collapsed_content, encode('utf8', $running_text);
  }
  return \@collapsed_content;
}
1;

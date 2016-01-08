#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/LinePseudoPrinter.pm,v $
#$Date: 2010/10/27 12:18:20 $
#$Revision: 1.1 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
package LinePseudoPrinter;
use vars qw( @ISA );
@ISA = ( "Posda::HttpObj" );
sub new{
  my($class, $session, $this_name, $obj_name, $method) = @_;
  my $this = Posda::HttpObj->new($session, $this_name);
  $this->{stream} = "";
  $this->{obj_name} = $obj_name;
  $this->{method} = $method;
  return bless $this, $class;
}
sub print{
  my($this, $string) = @_;
  $this->{stream} .= $string;
  my $eol = 0;
  if($this->{stream} =~ /\n$/m){
    $eol = 1;
  }
  my @lines = split(/\n/m, $this->{stream});
  my $out_obj = $this->get_obj($this->{obj_name});
  my $method = $this->{method};
  if($#lines > 0){
    for my $li (0 .. $#lines){
      my $line = shift @lines;
      $out_obj->$method($line);
    }
  }
  if($eol){
    my $line = shift @lines;
    $out_obj->$method($line);
    $this->{stream} = "";
  } else {
    $this->{stream} = shift @lines;
  }
}
1;

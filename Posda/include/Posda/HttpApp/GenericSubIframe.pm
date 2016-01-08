#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/HttpApp/GenericSubIframe.pm,v $
#$Date: 2012/09/14 15:05:56 $
#$Revision: 1.2 $
#
use strict;
package Posda::HttpApp::GenericSubIframe;
use vars qw( @ISA );
@ISA = ( "Posda::HttpApp::GenericIframe" );
sub AutoRefresh{
  my($this) = @_;
  my $p = $this->parent;
  if($p && $p->can("AutoRefresh")){ $p->AutoRefresh }
  #my $controller = $this->Controller;
  #if (defined $controller)
  #  { $controller->RefreshSubFrame($this->parent->{path}, $this->{path}); }
}
1;

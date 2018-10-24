#!/usr/bin/perl -w
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

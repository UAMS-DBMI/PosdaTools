#!/bin/perl -w
#
use strict;
package Posda::HttpApp::SubController;
use Posda::HttpApp::Controller;
use vars qw( @ISA );
@ISA = ( "Posda::HttpApp::Controller" );
sub new {
  my($class, $sess, $path) = @_;
  my $this = Posda::HttpApp::Controller->new($sess, $path);
  $this->{ThisIsASubWindow} = "Yes";
  my $parent =  $this->parent;
  if(defined($parent) && $parent->can("parent")){
    my $gp = $parent->parent;
    if(defined($gp) && $gp->can("Controller")){
      $this->{ControllerToNotify} = $gp->Controller->{path};
    }
  }
  return bless $this, $class;
}
sub CleanUp{
  my($this) = @_;
  # print "Posda::HttpApp::SubController::CleanUp called.\n";
  if (defined $this->{ControllerToNotify}) {
    my $cont2not = $this->get_obj($this->{ControllerToNotify});
    if(
      defined($cont2not) && 
      $cont2not->can("sibling") &&
      $cont2not->can("iframe_name")
    ){
      my $wb_obj = $cont2not->sibling("WindowButtons");
      if (
        defined($wb_obj) && 
        $wb_obj->can("iframe_name")
      ) {
        $cont2not->RefreshFrame($wb_obj->iframe_name);
      }
    }
  }
}
1;

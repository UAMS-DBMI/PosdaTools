#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/HttpApp/GenericMfWindow.pm,v $
#$Date: 2013/06/25 14:39:50 $
#$Revision: 1.3 $
#
use strict;
{
  package Posda::HttpApp::GenericMfWindow;
  use Posda::HttpApp::GenericWindow;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericWindow" );
  sub new{
    my($class, $sess, $path) = @_;
    my $this = Posda::HttpApp::GenericWindow->new($sess, $path);
    $this->{title} = "Generic Mult Frame Window (please set title)";
    $this->{RoutesBelow}->{Controller} = 1;
    # Posda::HttpApp::SubController->new($this->{session},
    #    $this->child_path("Controller"));
    bless $this, $class;
    return $this;
  }
  sub Controller{
    my($this) = @_;
    # print "NewItcTools::GenericMfWindow: Controller called: $this->{path}/Controller.\n";
    # my $controller = $this->get_obj("$this->{path}/Controller");
    # unless (defined $controller){
    #   print STDERR 
    #     "$this->{path}::Controller, Error: no Controller obj.\n";
    #   my($package, $filename, $line, $subroutine, $hasargs,
    #     $wantarray, $evaltext, $is_require, $hints, $bit_mask);
    #   for my $i (1 .. 20){
    #     ($package, $filename, $line, $subroutine, $hasargs,
    #     $wantarray, $evaltext, $is_require, $hints, $bit_mask) = caller($i);
    #     unless (defined $filename) { last; }
    #     print STDERR "\tfrom:$filename, $line\n";
    #   }
    # }
    # return $controller;
    return $this->get_obj("$this->{path}/Controller");
  }
}
1

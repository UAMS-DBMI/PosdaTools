#!/usr/bin/perl -w
#
use strict;
use Posda::HttpApp::GenericIframe;
package FileDist::CombineAssociations;
use vars qw( @ISA );
@ISA = ( "Posda::HttpApp::GenericIframe" );
sub new{
  my($class, $sess, $path) = @_;
  my $this = Posda::HttpApp::GenericIframe->new($sess, $path);
  bless $this, $class;
  return $this;
}
my $content = <<EOF;
This is the association combiner object.
EOF
sub Content{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn, $content);
}
1;

package Posda::TestProcessPopup;

use Posda::ProcessPopup;

use vars qw( @ISA );
@ISA = ( "Posda::ProcessPopup" );

use Debug;
sub MakeDebugQueuer{
  my($queuer) = @_;
  my $sub = sub {
    my($text) = @_;
    $queuer->queue($text);
  };
  return $sub;
}

###############################################################################
# Override below here
###############################################################################

sub ContentResponse{
  my($self, $http, $dyn) = @_;
  $http->queue("<pre>Self: ");
  Debug::GenPrint(MakeDebugQueuer($http), $self, 1);
  $http->queue("\n</pre>");
}

sub MenuResponse{
  my($self, $http, $dyn) = @_;
  #$http->queue($self->{menustuff});
}

sub TestOp{
  my($self, $http, $dyn) = @_;
   say STDERR "TestOp called";
   #$self->{menustuff} = "TestOp Called";
 }

1;

package Posda::Error;
# Simple base class for Posda Errors

use Modern::Perl;

sub new {
  my ($class, $message) = @_;
  return bless {
    message => $message
  }, $class;
}

1;

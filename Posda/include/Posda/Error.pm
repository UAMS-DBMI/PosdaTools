package Posda::Error;
# Simple base class for Posda Errors

use Modern::Perl;
use Method::Signatures::Simple;

method new($class: $message) {
  return bless {
    message => $message
  }, $class;
}

1;

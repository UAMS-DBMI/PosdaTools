package Posda::DebugLog;
# 
# This is a very simple source-filter based debug module
#
# It allows you to insert debug statements that
# can be easily disabled for release, without having
# to call a function each time to see if debug is turned on.
#
# It requires 'say'
#
# Usage example:
#
# use Posda::DebugLog 'on';
#
# DEBUG "this is a debug message";
# DEBUG $some_var
#

my $DEBUG = 0;
sub import {
  shift;
  if (shift eq 'on') {
    $DEBUG = 1;
  }
}

use Filter::Simple;

FILTER_ONLY code => sub {
    if ($DEBUG) {
      s/DEBUG/say STDERR 'DEBUG:', time, ':', (caller(0))[3], ': ', /g;
    } else {
      s/DEBUG/#/g;
    };
  };

1;

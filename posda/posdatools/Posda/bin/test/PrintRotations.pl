#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use VectorMath;
my $twenty_four = [
  [[1, 0, 0], [0, 1, 0]],
  [[1, 0, 0], [0, 0, 1]],
  [[1, 0, 0], [0, -1, 0]],
  [[1, 0, 0], [0, 0, -1]],
  [[-1, 0, 0], [0, 1, 0]],
  [[-1, 0, 0], [0, 0, 1]],
  [[-1, 0, 0], [0, -1, 0]],
  [[-1, 0, 0], [0, 0, -1]],
  [[0, 1, 0], [1, 0, 0]],
  [[0, 1, 0], [0, 0, 1]],
  [[0, 1, 0], [-1, 0, 0]],
  [[0, 1, 0], [0, 0, -1]],
  [[0, -1, 0], [1, 0, 0]],
  [[0, -1, 0], [0, 0, 1]],
  [[0, -1, 0], [-1, 0, 0]],
  [[0, -1, 0], [0, 0, -1]],
  [[0, 0, 1], [1, 0, 0]],
  [[0, 0, 1], [0, 1, 0]],
  [[0, 0, 1], [-1, 0, 0]],
  [[0, 0, 1], [0, -1, 0]],
  [[0, 0, -1], [1, 0, 0]],
  [[0, 0, -1], [0, 1, 0]],
  [[0, 0, -1], [-1, 0, 0]],
  [[0, 0, -1], [0, -1, 0]],
];
for my $i (@$twenty_four){
  my $norm = VectorMath::cross($i->[0], $i->[1]);
  my $rot = [
    $i->[0],
    $i->[1],
    $norm
  ];
  my $foo = VectorMath::Rot3D($rot, [10,20,30]);
  print "[$foo->[0], $foo->[1], $foo->[2]]\n";
  if($i->[0]->[0] == 1) { print "x ->  x ; "
  } elsif ($i->[0]->[0] == -1) { print "x -> -x ; "
  } elsif ($i->[0]->[1] == 1) { print "x ->  y ; "
  } elsif ($i->[0]->[1] == -1) { print "x -> -y ; "
  } elsif ($i->[0]->[2] == 1) { print "x ->  z ; "
  } else { print "x -> -z ; " }
  if($i->[1]->[0] == 1) { print "y ->  x ; "
  } elsif ($i->[1]->[0] == -1) { print "y -> -x ; "
  } elsif ($i->[1]->[1] == 1) { print "y ->  y ; "
  } elsif ($i->[1]->[1] == -1) { print "y -> -y ; "
  } elsif ($i->[1]->[2] == 1) { print "y ->  z ; "
  } else { print "y -> -z ; " }
  if($norm->[0] == 1) { print "z ->  x ;\n"
  } elsif ($norm->[0] == -1) { print "z -> -x ;\n"
  } elsif ($norm->[1] == 1) { print "z ->  y ;\n"
  } elsif ($norm->[1] == -1) { print "z -> -y ;\n"
  } elsif ($norm->[2] == 1) { print "z ->  z ;\n"
  } else { print "z -> -z ;\n" }
}

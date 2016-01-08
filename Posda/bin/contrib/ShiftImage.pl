#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/contrib/ShiftImage.pl,v $
#$Date: 2012/03/28 13:50:57 $
#$Revision: 1.1 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

use strict;
use Cwd;
use Posda::Try;
my($file, $x, $y, $z);
for my $i (0 .. $#ARGV){
  my $arg = $ARGV[$i];
  unless($arg =~ /(.*)=(.*)/){
    print STDERR "ignoring bad arg: \"$arg\"\n";
    next;
  }
  my $key = $1;
  my $value = $2;
  if($key eq "file") { $file = $value;
  } elsif($key eq "x") { $x = $value;
  } elsif($key eq "y") { $y = $value;
  } elsif($key eq "z") { $z = $value;
  } else { print STDERR "ignoring bad key: $key\n" }
}
unless(defined $x) { $x = 0 }
unless(defined $y) { $y = 0 }
unless(defined $z) { $z = 0 }
unless(defined $file) { die "You must specify a file" }
my $dir = cwd;
unless($file =~ /^\//){ $file = "$dir/$file" }
my $try = Posda::Try->new($file);
unless(exists $try->{dataset}){ die "$file didn't parse" }
my $ipp = $try->{dataset}->Get("(0020,0032)");
$ipp->[0] += $x;
$ipp->[1] += $y;
$ipp->[2] += $z;
$try->{dataset}->Insert("(0020,0032)", $ipp);
my $new_file = "$file.new";
$try->{dataset}->WritePart10($new_file, $try->{xfr_stx}, "POSDA", undef, undef);

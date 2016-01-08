#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/test/echo_dose.pl,v $
#$Date: 2011/06/10 17:09:01 $
#$Revision: 1.2 $
#
#Copyright 2011, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
my $buff;
my($rows, $cols, $frames, $bytes, $scaling) = @ARGV;
my $len = $rows * $cols * $frames * $bytes;
my $pixels = "\0" x $len;
my $so_far = 0;
while($so_far < $len){
  my $len_read = sysread(STDIN, $pixels, 65535, $so_far);
  unless(defined $len_read) {
    die "Error on sysread in child: $!";
  }
  $so_far += $len_read;
}
print STDERR "Read $so_far bytes from parent\n";
my $new_scaling = $scaling * 10;
syswrite(STDOUT, sprintf("grid_scaling: $new_scaling\ndose:\n"));
$so_far = 0;
while($so_far < $len){
  my $len_written = syswrite(STDOUT, $pixels, 65535, $so_far);
  unless(defined $len_written) {
    die "Error on sysread in child: $!";
  }
  $so_far += $len_written;
}
print STDERR "Wrote $so_far bytes to parent\n";

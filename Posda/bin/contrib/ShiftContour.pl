#!/usr/bin/perl -w
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
unless(defined $file) { die "You must specifiy a file" }
my $dir = cwd;
unless($file =~ /^\//){ $file = "$dir/$file" }
my $try = Posda::Try->new($file);
unless(exists $try->{dataset}){ die "$file didn't parse" }
my $data = $try->{dataset}->Search(
  "(3006,0039)[<0>](3006,0040)[<1>](3006,0050)");
for my $i (@$data){
  my $item_sig = "(3006,0039)[$i->[0]](3006,0040)[$i->[1]](3006,0050)";
  my $np_sig = "(3006,0039)[$i->[0]](3006,0040)[$i->[1]](3006,0046)";
  my $item = $try->{dataset}->Get($item_sig);
  my $num_points = $try->{dataset}->Get($np_sig);
  unless(ref($item) eq "ARRAY"){
    die "element $item_sig doesn't have array value";
  }
  my $num_floats = @$item;
  unless(($num_points * 3) == $num_floats){
    die "$np_sig says $num_points but\n$item_sig has $num_floats";
  }
  my @new_item;
  for my $j (0 .. $num_points - 1){
    my $x_i = $j * 3;
    my $y_i = $x_i + 1;
    my $z_i = $y_i + 1;
    push(@new_item, $item->[$x_i] + $x);
    push(@new_item, $item->[$y_i] + $y);
    push(@new_item, $item->[$z_i] + $z);
  }
  $try->{dataset}->Insert($item_sig, \@new_item);
}
my $new_file = "$file.new";
$try->{dataset}->WritePart10($new_file, $try->{xfr_stx}, "POSDA", undef, undef);

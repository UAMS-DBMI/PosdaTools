#!/usr/bin/perl -w
#
use strict;
use Storable qw( store_fd fd_retrieve );
use Posda::FlipRotate;
use Debug;
$| = 1;
my $dbg = sub {print STDERR @_ };
my $to_do = fd_retrieve(\*STDIN);
unless(ref($to_do) eq "HASH"){
  die "Instructions are not a hash";
}
my $source_file_name = $to_do->{source_file_name};
my $pixel_offset = $to_do->{pixel_offset};
my $pixel_length = $to_do->{pixel_length};
my $gray_file_name = $to_do->{gray_file_name};
my $jpeg_file_name = $to_do->{jpeg_file_name};
my $slope = $to_do->{slope};
if (!defined $slope || $slope eq "<undef>"){ $slope = 1 }
my $intercept = $to_do->{intercept};
if (!defined $intercept || $intercept eq "<undef>"){ $intercept = 0 }
my $window_center = $to_do->{window_center};
my $window_width = $to_do->{window_width};
my $bytes = $to_do->{bytes};
my $signed = $to_do->{signed};
my $rows = $to_do->{rows};
my $cols = $to_do->{cols};
unless(-f $gray_file_name) {
  my $cmd = "ExtractPixel.pl " .
    "\"$source_file_name\" " .
    "$pixel_offset $pixel_length $bytes $slope $intercept " .
    "$window_center $window_width $signed " .
    "\"$gray_file_name\"";
  open my $fh, "$cmd|" or die "Can't open $cmd|\n($!)";
  my @lines = <$fh>;
  for my $i (@lines) { print $i }
}
unless(-f $jpeg_file_name){
  my $cmd = "convert -endian MSB -size ${cols}x${rows} " .
    "-depth 8 gray:\"$gray_file_name\" \"$jpeg_file_name\"";
  open my $fh, "$cmd|" or die "Can't open $cmd|\n($!)";
  my @lines = <$fh>;
  for my $i (@lines) { print $i }
}
print "Wrote jpeg to $jpeg_file_name\n";
exit(0);

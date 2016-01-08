#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/contrib/PixelDigest.pl,v $
#$Date: 2013/04/01 19:46:51 $
#$Revision: 1.4 $
#
use strict;
use Digest::MD5;
my $usage = "PixelDigest.pl <file> <offset> <length>";
unless($#ARGV == 2) { die $usage }
my $file = $ARGV[0];
my $offset = $ARGV[1];
my $length = $ARGV[2];
open my $fh, $file or die "can't open $file";
sysseek $fh, $offset, 0;
my $pix;
my $len = sysread($fh, $pix, $length);
unless($len = $length) { die "read $len vs $length" }
my $ctx = Digest::MD5->new;
$ctx->add($pix);
my $dig = $ctx->hexdigest;
print "Digest: $dig\n";
close($fh);

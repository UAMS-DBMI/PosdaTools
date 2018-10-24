#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Digest::MD5;
use Cwd;
unless($#ARGV == 0) { die "usage: $0 <file>" }
my $file = $ARGV[0];
my $cwd = getcwd;
unless($file =~ /^\//) { $file = "$cwd/$file" }
open FILE, "<$file" or die "can't open $file";
my $ctx = Digest::MD5->new;
$ctx->addfile(*FILE);
close FILE;
my $digest = $ctx->hexdigest;
print "$digest\n";

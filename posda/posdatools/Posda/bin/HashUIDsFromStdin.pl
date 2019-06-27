#!/usr/bin/perl -w
use strict;
use Posda::PrivateDispositions;
use Digest::MD5;

my $usage = q{
HashUIDsFromStdin.pl <uid_root>

This script expects one UID per line.
};

if ($#ARGV != 0) {
  die $usage;
}


my $uid_root = $ARGV[0];
my $priv = Posda::PrivateDispositions->new($uid_root);

while (<STDIN>) {
  chomp;
  my $new_uid = $priv->HashUID($_);
  print "$_,$new_uid\n";
}

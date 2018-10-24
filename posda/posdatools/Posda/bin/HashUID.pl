#!/usr/bin/perl -w
use strict;
use Posda::PrivateDispositions;
use Digest::MD5;
my $uid = $ARGV[0];
my $uid_root = $ARGV[1];
my $priv = Posda::PrivateDispositions->new($uid_root);
my $new_uid = $priv->HashUID($uid);
print "$new_uid\n";

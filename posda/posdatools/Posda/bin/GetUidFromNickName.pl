#!/usr/bin/perl -w
use strict;
use Posda::Nicknames2Factory;
my $usage = "GetUidFromNickName.pl <proj> <site> <subj> <nn>";
unless($#ARGV == 3) { die $usage }
my $proj = $ARGV[0];
my $site = $ARGV[1];
my $subj = $ARGV[2];
my $nn = $ARGV[3];
my $fact = Posda::Nicknames2Factory::get($proj, $site, $subj);
my $uid;
if($nn =~/^STUDY/){
  $uid = $fact->ToStudyUID($nn);
} elsif($nn =~ /^SERIES/){
  $uid = $fact->ToSeriesUID($nn);
} elsif($nn =~ /^FILE/){
  $uid = $fact->ToSopUID($nn);
}
print "$nn represents $uid\n";

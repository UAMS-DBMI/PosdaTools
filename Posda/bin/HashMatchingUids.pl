#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Cwd;
use strict;
use Posda::Parser;
use Posda::Dataset;
use Digest::MD5;
use Posda::UUID;

my $usage = "usage: $0 <source> <destination> <root> [<tag> ...]\n";

Posda::Dataset::InitDD();

if($#ARGV < 3) { die $usage }

my $from = $ARGV[0];
my $to = $ARGV[1];
my $root = $ARGV[2];
unless($from =~ /^\//) {$from = getcwd."/$from"}
unless($to =~ /^\//) {$to = getcwd."/$to"}

my($df, $ds, $size, $xfr_stx, $errors)  = Posda::Dataset::Try($ARGV[0]);
unless($ds) { die "$from didn't parse into a dataset" }
my $sub_count = 0;
tag:
for my $i (3 .. $#ARGV){
  my $Tag = $ARGV[$i];
  my $m = $ds->Search($Tag);
print "Tag Pattern: $Tag\n";
  unless(
    defined($m) && ref($m) eq "ARRAY"
  ) { 
    print "No tags matching \"$Tag\" found in\n$from\n\n";
    next tag;
  }
  for my $s (@$m){
print "Match: ";
for my $mi (0 .. $#{$s}){
  print "<$mi> = $s->[$mi] ";
}
print "\n";
    my $subst = $Tag;
    subst:
    for my $in (0 .. $#{$s}){
      print "Subst (before): $subst\n";
      my $sub = "<$in>";
      my $repl = $s->[$in];
      $subst =~ s/$sub/$repl/;
      print "Subst (after): $subst\n";
    }
    my $uid = $ds->Get($subst);
    unless(defined $uid){
      print "$Tag($subst) has no value in\n$from\n\n";
      next subst;
    }
    if($uid =~ /^$root.*$/){
      print "Not hashing previously hashed uid in " .
        "$Tag($subst) in\n$from\n\n";
      next subst;
    } else {
      my $old = $uid;
      my $ctx = Digest::MD5->new;
      $ctx->add($old);
      my $dig = $ctx->digest;
      my $new_value = "$root." . Posda::UUID::FromDigest($dig);
      $ds->Insert($subst, $new_value);
      $sub_count += 1;
      print "$Tag($subst):\n$uid => $new_value in\n$from\n\n";
    }
  }
}
if($sub_count < 1){
  print "No substitutions, new file not written\n";
} else {
  $ds->WritePart10($to, $xfr_stx, "DICOM_TEST", undef, undef);
}

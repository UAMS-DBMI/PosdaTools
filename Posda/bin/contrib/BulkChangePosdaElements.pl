#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/contrib/BulkChangePosdaElements.pl,v $
#$Date: 2011/06/23 15:31:26 $
#$Revision: 1.2 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Cwd;
use strict;
use Posda::Dataset;
use Posda::Find;
Posda::Dataset::InitDD();

my $usage = sub {
	print "usage: $0 <source directory> <target directory> [<ele> ...]";
	exit -1;
};
unless(
	$#ARGV >= 2
) {
	&$usage();
}

my $from = $ARGV[0]; unless($from=~/^\//){$from=getcwd."/$from"}
my $to = $ARGV[1]; unless($to=~/^\//){$to=getcwd."/$to"}
unless(-d $from) { die "First arg must be a directory" }
unless(-d $to) { die "Second arg must be a directory" }
my $count = @ARGV;
unless(($count & 1) == 0){
  for my $i (0 .. $#ARGV){
    print "ARGV[$i] = $ARGV[$i]\n";
  }
  die "need an even number of args"
};
my %Substitutions;
my $pairs = $#ARGV/2;
if($pairs > 0){
  for my $i (1 .. $pairs){
    my $pair_id = $i * 2;
    my $sig = $ARGV[$pair_id];
    my $value = $ARGV[$pair_id + 1];
    $Substitutions{$sig} = $value;
    print "$sig => $value\n";
  }
}

sub handle {
  my($path, $df, $ds, $size, $xfr_stx, $errors) = @_;
  unless($path =~ /^(.*)\/([^\/]+)$/){
    print STDERR "unparsable path: $path\n";
    return;
  }
  my $dir = $1;
  my $file = $2;
  unless($dir = $from){
    print STDERR 
      "Warning: nested directories may cause filename collisions\n";
  }
  for my $i (keys %Substitutions){
    if($ds->Get($i)){
      $ds->Insert($i, $Substitutions{$i});
    }
  }
  $ds->WritePart10("$to/$file", $xfr_stx, "POSDA", undef, undef);
}
Posda::Find::SearchDir($from, \&handle);

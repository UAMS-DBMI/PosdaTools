#!/usr/bin/perl -w
#
#Copyright 2014, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use File::Find;
use Cwd;
use Storable;
my $usage = <<EOF;
CheckDupId.pl <parsed_dir>
EOF
unless($#ARGV == 0) { die $usage }
my $dir = $ARGV[0];
my $cwd = getcwd;
unless($dir =~ /^\//) { $dir = "$cwd/$dir" }
my $finder = sub {
  my $file = $File::Find::name;
  unless(-f $file) { return }
  if($_ eq "XmlIdIndex"){ return }
  my $parsed;
  eval { $parsed = retrieve($file) };
  if($@) {
    print STDERR "can't retrieve from $file:\n" .
      "$@\n";
    return;
  } else {
  }
  unless(exists($parsed->{index}) && ref($parsed->{index}) eq "HASH") { return }
  my $index = $parsed->{index};
  for my $k (keys %$index){
    if(ref($parsed->{index}->{$k}) eq "ARRAY"){
      print "$k is multiply defined in $file\n";
    } elsif (ref($parsed->{index}->{$k}) eq "HASH"){
      print "$k is uniquely defined in $file\n";
    } else {
      print "$k is not defined in $file\n";
    }
  }
};
find($finder, $dir);

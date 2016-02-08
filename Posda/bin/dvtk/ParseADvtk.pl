#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Dvtk;
use Debug;
my $file_name = shift @ARGV;
my $depth = shift @ARGV;
unless(defined $depth) {$depth = 20}
unless(-f $file_name){
  if(defined $ENV{DVTK_DEFS}){
    if(-f "$ENV{DVTK_DEFS}/$file_name"){
      $file_name = "$ENV{DVTK_DEFS}/$file_name";
    } elsif(-f "$ENV{DVTK_DEFS}/$file_name.def"){
      $file_name = "$ENV{DVTK_DEFS}/$file_name.def";
    } elsif(-f "$ENV{DVTK_DEFS}/$file_name.def"){
    } else {
      die "can't find file based on $file_name";
    }
  } else {
    die "can't find file based on $file_name";
  }
}
my $dbg = sub {print @_};
my $dvtk = Posda::Dvtk->new($file_name);
my $prefix = "dvtk";
my $target = $dvtk;
for my $index (@ARGV){
  unless(ref($target)){ die "can't index ($index) scalar: $prefix" }
  if(
    ref($target) eq "HASH" ||
    ref($target) eq "ARRAY" ||
    $target->isa("HASH") ||
    $target->isa("ARRAY")
  ){
    if(ref($target) eq "HASH") {
      $prefix .= "->{$index}";
      $target = $target->{$index};
    } elsif(ref($target) eq "ARRAY"){
      $prefix .= "->[$index]";
      $target = $target->[$index];
    } elsif($target->isa("HASH")){
      $prefix .= "->{$index}";
      $target = $target->{$index};
    } elsif($target->isa("ARRAY")){
      $prefix .= "->[$index]";
      $target = $target->[$index];
    } else {
      die "can't find $index in $prefix ($target)";
    }
  } else {
    die "can't find $index in $prefix ($target)";
  }
}
print "$prefix =  ";
Debug::GenPrint($dbg, $target, 1, $depth);
print "\n";

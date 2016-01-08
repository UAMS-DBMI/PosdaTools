#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/dclunie/ExpandAllModulesFromDir.pl,v $
#$Date: 2009/08/29 16:13:47 $
#$Revision: 1.1 $
#
#Copyright 2009, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

use strict;
use Posda::Dclunie;
use Debug;
unless($#ARGV == 4 || $#ARGV == 5){
  die "usage: ExpandAllModulesFromDir.pl <dd_dir> <module_dir> <entity> <iod> <usage> [<depth>]\n"
}
my $dbg = sub {print @_};
my $dd_dir = $ARGV[0];
my $module_dir = $ARGV[1];
my $entity = $ARGV[2];
my $iod = $ARGV[3];
my $usage = $ARGV[4];
my $depth = 2;
if(defined $ARGV[5]) { $depth = $ARGV[5] }
my $list = [];
opendir DD, $dd_dir or die "can't opendir $dd_dir";
while(my $file = readdir DD){
  if($file =~ /\.tpl$/){
    Posda::Dclunie::parse_dict_file("$dd_dir/$file", $list);
  }
}
closedir DD;
my $dd = Posda::Dclunie::dd_to_keywordhash($list);

my $mod = {};
opendir MOD, $module_dir or die "can't opendir $module_dir";
while(my $file = readdir MOD){
  if($file =~ /\.tpl$/){
    Posda::Dclunie::parse_module_file("$module_dir/$file", $mod);
  }
}
my $macros = $mod->{macros};
my $modules = $mod->{modules};

my @module_names = sort keys %$modules;

my $hash = {};
for my $i (@module_names){
  my $ex = Posda::Dclunie::expand_a_module_file($dd, $macros, $modules, $i,
    $entity, $iod, $usage, $hash);
}
print "result: ";
Debug::GenPrint($dbg, $hash, 1, $depth);
print "\n";

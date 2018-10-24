#!/usr/bin/perl -w
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
unless($#ARGV == 3 || $#ARGV == 4){
  die "usage: ExpandAnIod.pl <dd_dir> <module_dir> <iod_dir> <iod_name> [<depth>]\n"
}
my $dbg = sub {print @_};
my $dd_dir = $ARGV[0];
my $module_dir = $ARGV[1];
my $iod_dir = $ARGV[2];
my $iod_name = $ARGV[3];
my $depth = 3;
if(defined $ARGV[4]) { $depth = $ARGV[4] }
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
closedir MOD;
my $macros = $mod->{macros};
my $modules = $mod->{modules};

my $iods= {};
opendir IOD, $iod_dir or die "can't opendir $iod_dir";
while(my $file = readdir IOD){
  if($file =~ /\.tpl$/){
    Posda::Dclunie::parse_iod_file("$iod_dir/$file", $iods);
  }
}
print "iod_name: $iod_name ";
unless(exists $iods->{$iod_name}) { print "doesn't exist\n"} else{
  print "exists\n";
}
my $exp = Posda::Dclunie::ExpandAnIod(
  $iods->{$iod_name}, $modules, $macros, $dd);

print "$iod_name: ";
Debug::GenPrint($dbg, $exp, 1, $depth);
print "\n";


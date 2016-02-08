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
unless($#ARGV == 2 || $#ARGV == 3){
  die "usage: RenderParsedModule.pl <dd_dir> <module_dir>  <module_name> [<depth>]\n"
}
my $dbg = sub {print @_};
my $dd_dir = $ARGV[0];
my $module_dir = $ARGV[1];
my $mod_name = $ARGV[2];
my $depth = 3;
if(defined $ARGV[3]) { $depth = $ARGV[3] }
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

print "$mod_name: ";
Debug::GenPrint($dbg, $macros->{$mod_name}, 1, $depth);
print "\n";

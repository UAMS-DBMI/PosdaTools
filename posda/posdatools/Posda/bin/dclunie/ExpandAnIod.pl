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
unless(exists $iods->{$iod_name}){ die "iod: $iod_name doesn't exist" }
print "iod_name: $iod_name:\n";
my $exp = Posda::Dclunie::ExpandAnIod(
  $iods->{$iod_name}, $modules, $macros, $dd);

for my $sig (sort keys %{$exp->{elements}}){
  unless($sig =~ /^\(/){print "sig = $sig????\n"; next }
  for my $p (@{$exp->{elements}->{$sig}->{ElementPresence}}){
    unless(ref($p) eq "HASH") { print "############ $p\n"; next; }
    print "P:$sig|$p->{item}->{attributes}->{Type}|$p->{vr}|";
    if($p->{vr} eq "SQ"){
      print "$p->{item}->{attributes}->{VM}|";
    } else {
      print "$p->{vm}|";
    }
    print "$p->{name}|";
    for my $attr (sort keys %{$p->{item}->{attributes}}){
      if($attr eq "Type" || $attr eq "VM") {next}
      print "$attr=\"$p->{item}->{attributes}->{$attr}\" ";
    }
    print "\n";
  }
  if(exists $exp->{elements}->{$sig}->{ElementVerification}){
    for my $p (@{$exp->{elements}->{$sig}->{ElementVerification}}){
      print "V:$sig|";
      for my $attr (sort keys %{$p->{item}->{attributes}}){
        print "$attr=\"$p->{item}->{attributes}->{$attr}\" ";
      }
      print "\n";
    }
  }
}


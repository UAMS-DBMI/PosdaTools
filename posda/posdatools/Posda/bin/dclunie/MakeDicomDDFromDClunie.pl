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
use DBI;
#use Term::ReadKey;
#print "User: ";
#my $user = ReadLine 0;
#chomp $user;
#print "Password: ";
#ReadMode 'noecho';
#my $password = ReadLine 0;
#chomp $password;
#ReadMode 'normal';
my $user = '';
my $password = '';

my $file = $ARGV[0];
open FILE, "<$file" or die "can't open $file";

my $db = DBI->connect("dbi:Pg:dbname=new_dicom_dd", $user, $password);

my $list = Posda::Dclunie::parse_dict(\*FILE);

my $len = @$list;

for my $item (@$list){
  my $sig;
  if(exists $item->{Owner}){
    $item->{grp} =~ tr/A-F/a-f/;
    $item->{ele} =~ tr/A-F/a-f/;
    if($item->{ele} =~ /^\s*00(..)\s*$/){
      $sig = "($item->{grp},\"$item->{Owner}\",$1)";
    } else {
      print STDERR "++++++++++++++++++\n";
      print STDERR "illegal element number for private element: $item->{ele}\n";
      print STDERR "Owner: $item->{Owner}\n";
      print STDERR "Group: $item->{grp}\n";
      print STDERR "++++++++++++++++++\n";
      next;
    }
  } else {
    $item->{grp} =~ tr/A-F/a-f/;
    $item->{ele} =~ tr/A-F/a-f/;
    $sig = "($item->{grp},$item->{ele})";
  }
  my $keyword = $item->{Keyword};
  my $vers = $item->{VERS};
  my $ret;
  if($vers && $vers =~ /RET/){ $ret = "true" } else { $ret = "false" }
  my $vm = $item->{VM};
  my $vr = $item->{VR};
  my $name = $item->{Name};
  my $owned_by = $item->{Owner};
  my $fix_ele = $item->{ele};
  $fix_ele =~ s/x/0/g;
  my $ele = hex($fix_ele);
  my $fix_grp = $item->{grp};
  $fix_grp =~ s/x/0/g;
  my $grp = hex($fix_grp);
  my $private_block = $item->{PrivateBlock};
  my($pvt,$std);
  if($grp & 1){
    $pvt = "true";
    $std = "false";
    unless(defined($item->{Owner})){
      die "$sig has no owner";
    }
  } else {
    $std = "true";
    $pvt = "false";
    if(defined($item->{Owner} && $item->{grp} =~ /x$/)){
      $pvt = "true";
      $std = "false";
    }
  }
  my $q = $db->prepare(
    "insert into ele (\n" .
    "  ele_sig, grp, ele, grp_mask, ele_mask,\n" .
    "  grp_shift, ele_shift, vr, vm, vers, owned_by,\n" .
    "  name, std, pvt, retired, keyword, private_block\n" .
    ") values(\n" .
    "  ?, ?, ?, ?, ?,\n" .
    "  ?, ?, ?, ?, ?,?,\n" .
    "  ?, ?, ?, ?, ?,?\n" .
    ")"
  );
  $q->execute(
   $sig, $grp, $ele, undef, undef,
   undef, undef, $vr, $vm, $vers, $owned_by,
   $name, $std, $pvt, $ret, $keyword, $private_block
  );
}

$db->disconnect();


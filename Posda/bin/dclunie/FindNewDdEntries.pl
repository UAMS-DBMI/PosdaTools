#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/dclunie/FindNewDdEntries.pl,v $
#$Date: 2010/04/30 20:15:09 $
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

my $db = DBI->connect("dbi:Pg:dbname=dicom_dd", $user, $password);

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
      print "++++++++++++++++++\n";
      print "illegal element number for private element: $item->{ele}\n";
      print "Owner: $item->{Owner}\n";
      print "Group: $item->{grp}\n";
      if(exists $item->{PrivateBlock}){
        print "But it may be OK because it has private block $item->{PrivateBlock}\n";
      }
      print "++++++++++++++++++\n";
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
  if($private_block) {
    print "Found item($sig) with private block: $private_block\n";
  }
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
  my $q = $db->prepare("select * from ele where ele_sig = ?");
  $q->execute($sig);
  my @res;
  while(my $h = $q->fetchrow_hashref()){
    push(@res, $h);
  }
  if($#res < 0){
    print "$sig is not in db\n";
    next;
  } elsif($#res > 0){
    my $times = scalar @res;
    print "$sig is in db $times times\n";
    next;
  }
}

$db->disconnect();


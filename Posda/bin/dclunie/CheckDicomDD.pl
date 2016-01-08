#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/dclunie/CheckDicomDD.pl,v $
#$Date: 2009/03/25 13:46:10 $
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
  my $q = $db->prepare("select * from ele where ele_sig = ?");
  $q->execute($sig);
  my @rows;
  while (my $r = $q->fetchrow_hashref()){
    push(@rows, $r);
  }
  if($#rows == 0){
  } elsif($#rows < 0){
    print "No rows for $sig ($item->{Name})\n";
    next;
  } else {
    print "Multiple rows for $sig\n";
  }
}

$db->disconnect();

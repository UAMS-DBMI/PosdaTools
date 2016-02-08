#!/usr/bin/perl -w
#
#Copyright 2009, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

use strict;
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

my $db = DBI->connect("dbi:Pg:dbname=new_dicom_dd", $user, $password);

my $q = $db->prepare(
  "select distinct ele_sig, private_block, count(*) from ele
  where private_block is not null
  group by ele_sig, private_block  order by count desc"
);
$q->execute();
my @list;
while (my $h = $q->fetchrow_hashref()){
  if($h->{count} == 1) {
    $q->finish();
    last;
  }
  my $q1 = $db->prepare("select * from ele where ele_sig = ? and private_block is not null and private_block = ?");
  $q1->execute($h->{ele_sig}, $h->{private_block});
  my @list;
  while(my $h1 = $q1->fetchrow_hashref()){
    push(@list, $h1);
  }
  process_list(\@list, $h->{ele_sig}, $h->{private_block});
}

$db->disconnect();

sub process_list{
  my($list, $sig, $block) = @_;
  my $count = @$list;
  print "$sig, $block has $count rows\n";
  my @new_list;
  for my $i (@$list){
    if($#new_list == -1){ 
      push(@new_list, $i);
      next;
    }
    my $new;
    my $some_match = 0;
    new_loop:
    for my $j (@new_list){
      my %keys;
      for my $k (keys %$i) { $keys{$k} = 1 }
      for my $k (keys %$j) { $keys{$k} = 1 }
      my $match = 1;
      key_loop:
      for my $k (keys %keys){
        if(
          (defined($i->{$k}) && !defined($j->{$k})) ||
          (!defined($i->{$k}) && defined($j->{$k})) ||
          (defined($i->{$k}) && defined($j->{$k}) && ($i->{$k} ne $j->{$k}))
        ){
          $match = 0;
          last key_loop;
        }
      }
      if($match){
        $some_match = 1;
        last new_loop;
      }
    }
    unless($some_match){ push @new_list, $i }
  }
  my $unique = @new_list;
  print "$unique are unique\n";
}

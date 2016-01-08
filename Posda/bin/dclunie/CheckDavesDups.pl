#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/dclunie/CheckDavesDups.pl,v $
#$Date: 2009/03/25 13:45:12 $
#$Revision: 1.1 $
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
  "select distinct ele_sig, count(*) from ele
  group by ele_sig order by count desc"
);
$q->execute();
my @list;
while (my $h = $q->fetchrow_hashref()){
  if($h->{count} == 1) {
    $q->finish();
    last;
  }
  my $q1 = $db->prepare("select * from ele where ele_sig = ?");
  $q1->execute($h->{ele_sig});
  my @list;
  while(my $h1 = $q1->fetchrow_hashref()){
    push(@list, $h1);
  }
  process_list(\@list, $h->{ele_sig});
}

$db->disconnect();

sub process_list{
  my($list, $sig) = @_;
  my $count = @$list;
  my @new_list;
  outer_loop:
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
  if($unique == 1) {
#    print "+++++++++++++++++++++++++++++++++++++++++\n|";
#    print "$sig has $count identical rows\n";
  } else {
    print "+++++++++++++++++++++++++++++++++++++++++\n|";
    print "$sig has $count rows\n";
    print "$unique are unique\n";
    my %keys;
    for my $i (@new_list){
      for my $j (keys %$i){
        $keys{$j} = 1;
      }
  }
    print "|";
    for my $k (sort keys %keys){
      print "$k|";
    }
    print "\n";
    for my $i (@new_list){
      print "|";
      for my $k (sort keys %keys){
        my $text = $i->{$k};
        unless(defined $text){$text = ""}
        print "$text|";
      }
      print "\n";
    }
  }
}

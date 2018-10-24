#!/usr/bin/perl -w
#
#Copyright 2009, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

package Posda::Dcmtk;

sub parse{
  my $fh = shift;
  while(my $line = <$fh>){
    chomp $line;
    if($line =~ /^\s*$/) { next }
    if($line =~ /^#/) { next }
    my %hash;
    if($line =~ /^\((....),(....)\)(.*)$/){
      $hash{grp} = $1;
      $hash{ele} = $2;
      $hash{remain} = $3;
    } elsif($line =~ /^\((....)-(....),(....)\)(.*)/){
      $hash{from} = $1;
      $hash{to} = $2;
      $inc_type = "even";
      $hash{ele} = $3;
      $remain = $4;
    } elsif($line =~ /^\((....)-o-(....),(....)\)(.*)/){
      $hash{from} = $1;
      $hash{to} = $2;
      $hash{inc_type} = "odd";
      $hash{ele} = $3;
      $hash{remain} = $4;
    } elsif($line =~ /^\((....)-u-(....),(....)\)(.*)/){
      $hash{from} = $1;
      $hash{to} = $2;
      $hash{inc_type} = "both";
      $hash{ele} = $3;
      $hash{remain} = $4;
    } elsif($line =~ /^\((....),(....)-(....)\)(.*)/){
      $hash{grp} = $1;
      $hash{ele_from} = $2;
      $hash{ele_to} = $3;
      $hash{inc_type} = "both";
      $hash{remain} = $4;
    } elsif($line =~ /^\((....),"([^"]+)",(..)\)(.*)/){
      $hash{grp} = $1;
      $hash{owner} = $2;
      $hash{ele} = $3;
      $hash{remain} = $4;
    } elsif($line =~ /^\((....),"([^"]+)",(..)(..)\)(.*)/){
      $hash{grp} = $1;
      $hash{owner} = $2;
      $hash{private_block} = "${3}00";
      $hash{ele} = $4;
      $hash{remain} = $5;
    } elsif($line =~ /^\((....)-o-(....),"([^"]+)",(..)\)(.*)/){
      $hash{from} = $1;
      $hash{to} = $2;
      $hash{inc_type} = "odd";
      $hash{owner} = $3;
      $hash{ele} = $4;
      $hash{remain} = $5;
    } else {
      print "non-matching line: $line\n";
    }
  }
}
1;

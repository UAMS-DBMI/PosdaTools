#!/usr/bin/perl -w 
#$Source: /home/bbennett/pass/archive/Posda/bin/EleDumpDicom.pl,v $
#$Date: 2008/07/31 18:12:04 $
#$Revision: 1.1 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Posda::Parser;
use Posda::Dataset;

my $infile = $ARGV[0];
my $max_len1 = $ARGV[1];
my $max_len2 = $ARGV[2];
unless(defined $max_len1) {$max_len1 = 64}
unless(defined $max_len2) {$max_len2 = 300}

Posda::Dataset::InitDD();
my $dd = $Posda::Dataset::DD;

my($df, $ds, $size, $xfr_stx, $errors)  = Posda::Dataset::Try($ARGV[0]);
if($ds){
  if($df){
    print "Part10 Metaheader:";
    print "\n";
    my $mh = $df->{metaheader};
    for my $key (sort keys %$mh){
      if($key eq "(0002,0000)") { next }
      if($key eq "(0002,0001)") { next }
      my $value = $mh->{$key};
      print "$key: \"$value\"";
      if(exists $dd->{SopCl}->{$value}){
        print " ($dd->{SopCl}->{$value}->{sopcl_desc})";
      } elsif (exists $dd->{XferSyntax}->{$value}){
        print " ($dd->{XferSyntax}->{$value}->{name})";
      }
      print "\n";
    }
    print "Dataset:\n";
  }
  $ds->DumpStyle1(\*STDOUT, $max_len1, $max_len2);
  if($errors && ref($errors) eq "ARRAY" && $#{$errors} >= 0){
    print "Errors encountered in parsing:\n";
    for my $e (@$errors){
      print "$e\n";
    }
  }
} else {
  for my $i(@$errors){
     print "$i\n";
  }
}

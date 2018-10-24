#!/usr/bin/perl -w 
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Cwd;
use Posda::Parser;
use Posda::Dataset;

my $usage = "Usage: $0 <file> [<len>] [<len>]";
unless ($#ARGV >= 0) {die $usage;}

my $dir = getcwd;
my $infile = $ARGV[0];
unless($infile =~ /^\//) {
	$infile = "$dir/$infile";
}
my $max_len1 = $ARGV[1];
my $max_len2 = $ARGV[2];
unless(defined $max_len1) {$max_len1 = 64}
unless(defined $max_len2) {$max_len2 = 300}

Posda::Dataset::InitDD();
my $dd = $Posda::Dataset::DD;

my($df, $ds, $size, $xfr_stx, $errors)  = Posda::Dataset::Try($infile);
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
  } else {
    print "No meta header - xfersyntax: $xfr_stx\n";
  }
  $ds->DumpStyle0(\*STDOUT, $max_len1, $max_len2);
  if($errors && ref($errors) eq "ARRAY" && $#{$errors} >= 0){
    print "Errors encountered in parsing:\n";
    for my $e (@$errors){
      print "$e\n";
    }
  }
  if(
    exists($df->{warnings}) &&
    ref($df->{warnings}) eq "ARRAY" &&
    $#{$df->{warnings}} >= 0
  ){
    print "Errors encountered in parsing metaheader:\n";
    for my $e (@{$df->{warnings}}){
      print "$e\n";
    }
  }
} else {
  for my $i(@$errors){
     print "$i\n";
  }
}

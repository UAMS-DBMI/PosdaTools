#!/usr/bin/perl -w 
#$Source: /home/bbennett/pass/archive/Posda/bin/ExtremelyVerbose.pl,v $
#$Date: 2012/02/15 18:30:50 $
#$Revision: 1.1 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Cwd;
use Posda::Try;
#use Posda::Parser;
#use Posda::Dataset;

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

my $try  = Posda::Try->new($infile, undef, 1);
my($df, $ds, $size, $xfr_stx, $errors);
$df = $try->{metaheader};
$ds = $try->{dataset};
$size = $try->{size};
$errors = $try->{parse_errors};
$xfr_stx = $try->{xfr_stx};
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
} else {
  for my $i(@$errors){
     print "$i\n";
  }
}

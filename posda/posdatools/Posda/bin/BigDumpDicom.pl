#!/usr/bin/perl -w
# Alter to the directory that other DICOM files are installed in.
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
my $dbg = sub { print @_ };

my $usage = "usage: $0 <file> [len] [len]";
unless($#ARGV == 2) {die $usage}
my $dir = getcwd;
my $infile = $ARGV[0];
my $max_1 = $ARGV[1];
my $max_2 = $ARGV[2];
unless(defined $max_1) { $max_1 = 100000 }
unless(defined $max_2) { $max_2 = 10000000 }
unless($infile =~ /^\//) {$infile = "$dir/$infile"}

Posda::Dataset::InitDD();


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
      if(exists $Posda::Dataset::DD->{SopCl}->{$value}){
        print " ($Posda::Dataset::DD->{SopCl}->{$value}->{sopcl_desc})";
      } elsif (exists $Posda::Dataset::DD->{XferSyntax}->{$value}){
        print " ($Posda::Dataset::DD->{XferSyntax}->{$value}->{name})";
      }
      print "\n";
    }
    print "Dataset:\n";
  }
  $ds->DumpStyle0(\*STDOUT, $max_1, $max_2);
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

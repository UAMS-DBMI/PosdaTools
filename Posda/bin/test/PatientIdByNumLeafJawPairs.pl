#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

#  Finds all files under a directory
#  For those with names like "RTP...", assumes they are RT Plans, and
#  Looks for all "Number of Leaf" elements and "Patient Id" Elements
#  prepares a report by Number of Leaf Pairs of all Patient Id's for
#  file which contain a beam with the number of leaf pairs
use strict;
use File::Find;
use Cwd;
unless ($#ARGV == 0) { die "usage: $0  <dir>\n" }
unless( -d $ARGV[0] ) { die "$ARGV[0] is not a directory" }
my $this_dir = getcwd;
my $dir = $ARGV[0];
unless($dir =~ /^\//) {
	$dir = "$this_dir/$dir";
}
my %Results;
my $finder = sub {
  my $file = $File::Find::name;
  unless(-f $file) { return }
  unless($_ =~ /^RTP/) { return }
  my $patient_id = "<unknown>";
  open my $fh, "DumpDicom.pl $file |";
  while (my $line = <$fh>){
    chomp $line;
    my @fields = split(/:/, $line);
    if($fields[0] eq "(0010,0020)") {
      $patient_id = $fields[3];
      if($patient_id =~ /^"(.*)"/){
        $patient_id = $1;
      }
#      print "File: $file patient id: $patient_id\n";
    } elsif (
      defined($fields[2]) &&
      $fields[2] eq "Number of Leaf/Jaw Pairs"
    ){
      my $num_lp = $fields[3];
      if($num_lp =~ /^"(.*)"$/){
        $num_lp = $1;
      }
      $Results{$num_lp}->{$patient_id} = 1;
    }
  }
};
find($finder, $dir);
for my $i (keys %Results){
  print "Number of L/J pairs: $i\n";
  for my $id (keys %{$Results{$i}}){
    print "\t$id\n";
  }
}

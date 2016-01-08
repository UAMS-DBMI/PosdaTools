#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/GetElementValue.pl,v $
#$Date: 2012/03/28 12:21:27 $
#$Revision: 1.5 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Parser;
use Posda::Dataset;
use Cwd;

Posda::Dataset::InitDD();

my $usage = sub {
	print "usage: $0 <file> <ele_sig>";
	exit(-1);
};
unless(
	$#ARGV == 1
) {
	&$usage();
}

my $file = $ARGV[0]; unless($file =~ /^\//) { $file = getcwd."/$file" }

my($df, $ds, $size, $xfr_stx, $errors)  = Posda::Dataset::Try($ARGV[0]);
unless($ds) { die "$file didn't parse into a dataset" }
my $ele_sig = $ARGV[1];
my $value = $ds->Get($ele_sig);
my $type = $Posda::Dataset::DD->get_type_by_sig($ele_sig);
if(ref($value) eq "ARRAY"){
  if($type eq "text"){
    my $new_value = join("\\", @$value);
    print $new_value;
  } else {
    my $new_value = join("", @$value);
    print $new_value;
  }
} else {
  print $value;
}

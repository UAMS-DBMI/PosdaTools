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
use Posda::Try;
use Debug;
my $dbg = sub {print @_ };

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

my($try)  = Posda::Try->new($infile);
unless(exists $try->{dataset}) { die "$infile is not DICOM file" }
my $ds = $try->{dataset};
my($sop_cl) = $ds->Get("(0008,0016)");
unless(defined $sop_cl) { die "$infile is not a DICOM SOP instance" }
my $sop_cl_name = $dd->GetSopClName($sop_cl);
print "Sop Class: $sop_cl_name\n";
unless($sop_cl_name =~ /SR Storage$/){
  die "Doesn't look like an SR type object";
}
my $container = $ds->Get("(0040,a040)");
unless($container eq "CONTAINER"){
  die "So sorry, I only know how to dump SR objects with Value type of CONTAINER\n" .
      "This one has a value type of \"$container\"\n";
}
my $doc_type = $ds->Get("(0040,a043)[0](0008,0104)");
my $c_scheme = $ds->Get("(0040,a043)[0](0008,0102)");
my $c_value = $ds->Get("(0040,a043)[0](0008,0100)");
print "Document type: $doc_type ($c_value of $c_scheme)\n";

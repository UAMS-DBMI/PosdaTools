#!/usr/bin/perl -w 
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Cwd;
use Posda::Try;
use Posda::SimpleDicomAnalysis;
use Posda::Dataset;
use Debug;
my $dbg = sub {print @_};

my $usage = "Usage: $0 <file>\n";
unless ($#ARGV ==  0) {die $usage;}

my $dir = getcwd;
my $infile = $ARGV[0];
unless($infile =~ /^\//) {
	$infile = "$dir/$infile";
}
my $try = Posda::Try->new($infile);
unless($try && exists($try->{dataset})){
  die "$infile didn't parse as a DICOM file";
}
my $modality = $try->{dataset}->Get("(0008,0060)");
unless($modality eq "RTSTRUCT"){
  die "$infile isn't and RTSTRUCT";
}
my $analysis = Posda::SimpleDicomAnalysis::Analyze($try);
for my $i (sort {$a <=> $b} keys %{$analysis->{rois}}){
  my $roi = $analysis->{rois}->{$i};
  print "roi($i) $roi->{roi_name}:\n";
  if(
    defined($roi->{min_x}) &&
    defined($roi->{max_x}) &&
    defined($roi->{min_y}) &&
    defined($roi->{max_y}) &&
    defined($roi->{min_z}) &&
    defined($roi->{max_z})
  ){
    print "\t$roi->{min_x} < x < $roi->{max_x}\n";
    print "\t$roi->{min_y} < y < $roi->{max_y}\n";
    print "\t$roi->{min_z} < z < $roi->{max_z}\n";
  }
}

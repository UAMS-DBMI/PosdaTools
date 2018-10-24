#!/usr/bin/perl -w
#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Try;
use Posda::DatasetRepair;
use FileHandle;
my $file_i = $ARGV[0];
my $file_o = $ARGV[1];
my $try = Posda::Try->new($file_i);
if(exists $try->{dataset}){
  print "$file_i parses as a DICOM file so $file_o not written\n";
  exit;
}
unless(exists $try->{metaheader}){
  print "$file_i doesn't parse either a dataset or a metaheader" .
    " - I'm done, no fix.\n";
  exit;
}
unless($try->{metaheader}->{xfrstx} eq "1.2.840.10008.1.2.1"){
  print "$file_i doesn't have xfr_stx of 1.2.840.10008.1.2.1 in metaheader" .
    " - I'm done, no fix.\n";
  exit;
}
unless($try->{parse_errors}->[0] =~ /unknown explicit VR/){
  print "Parse error doesn't include \"unknown explicit VR\"" .
    " - I'm done, no fix.\n";
  exit;
}
#for my $i (keys %$try){
#  print "$i: $try->{$i}\n";
#}
#for my $i (keys %{$try->{metaheader}}){
#  print "metaheader->{$i}: $try->{metaheader}->{$i}\n";
#}
print "Proceeding to try and fix dataset\n";
my $dataset_start = $try->{metaheader}->{DataSetStart};
my $dataset_len = $try->{metaheader}->{DataSetSize};
$try = undef;
my $fhi = FileHandle->new("<$file_i");
my $fho = FileHandle->new(">$file_o");
unless($fhi){ die "Couldn't open $file_i (?? how'd I get this far)" }
unless($fho){ die "Couldn't open $file_o" }
my $meta;
my $r = $fhi->read($meta, $dataset_start);
unless($r == $dataset_start){
  die "read $r, sought $dataset_start (copying metaheader)";
}
$fho->print($meta);
Posda::DatasetRepair::RepairExplicitDataset($fhi, $fho, $dataset_len);
$fhi->close;
$fho->close;

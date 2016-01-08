#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/contrib/MergeSeries.pl,v $
#$Date: 2011/06/23 15:31:26 $
#$Revision: 1.4 $
#
#Copyright 2009, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Cwd;
use strict;
use Posda::Dataset;
use Posda::Find;
use Posda::UID;
Posda::Dataset::InitDD();

my $usage = "usage: $0 <source> <destination>";
unless($#ARGV == 1) {die $usage}
my $from = $ARGV[0];
my $to = $ARGV[1];
unless($from =~ /^\//) {$from = getcwd."/$from"}
unless($to =~ /^\//) {$to = getcwd."/$to"}
my $user = `whoami`;
chomp $user;
my $system = `hostname`;
chomp $system;
my $new_root = Posda::UID::GetPosdaRoot( {
  program => $0,
  user => $user,
  system => $system,
  purpose => "Merging series",
}
);
unless(-d $from) { die "First arg must be a directory" }
unless(-d $to) { die "Second arg must be a directory" }

my @FoundCts;  # This array will be populated descriptions of the files

#
# This routine (handle) will be called for every Found DICOM file
#
sub handle {
  my($path, $df, $ds, $size, $xfr_stx, $errors) = @_;
  unless($path =~ /^(.*)\/([^\/]+)$/){
    print STDERR "unparsable path: $path\n";
    return;
  }
  my $dir = $1;
  my $file = $2;

  #  unless its a CT, ignore
  my $SeriesUID = $ds->Get("(0020,000e)");
  my $SopClass = $ds->Get("(0008,0016)");
  unless($SopClass eq "1.2.840.10008.5.1.4.1.1.2") { return }

  my $z = $ds->Get("(0020,0032)[2]");
  my $info = {
    path => $path,
    file => $file,
    z => $z,
  };
  push(@FoundCts, $info);
}

# Go find the files and populate @FoundCts:

Posda::Find::SearchDir($from, \&handle);

my %SeenZs;
my $NewSeriesUID = $new_root;
my $seq = 0;
for my $i (sort {$a->{z} <=> $b->{z}} @FoundCts){
  # If they're close enough, skip the second:
  my $ThisZ = sprintf("%0.3f", $i->{z});
  if(exists($SeenZs{$ThisZ})){ next }

  $SeenZs{$ThisZ} = 1;
  $seq += 1;
  my $new_uid = "$NewSeriesUID.$seq";
  my($df, $ds, $size, $xfr_stx, $errors) = Posda::Dataset::Try($i->{path});
  unless($ds) {die "$i->{path} didn't parse a second time - wtf?"}
  my $old_uid = $ds->Get("(0008,0018)");
  $ds->Insert("(0020,0013)", $seq);           # Instance number
  $ds->Insert("(0020,000e)", $NewSeriesUID);  # Series Instance UID
  $ds->Insert("(0008,0018)", $new_uid);       # Sop Instance UID
  $ds->Insert("(0020,0011)", "");             # Series number
# The following are really only required if you resample, but ...
  $ds->Insert("(0008,0070)", "Posda Script Works"); # Manufacturer
  $ds->Insert("(0008,1090)", "MergeSeries.pl");     #   model number
# For fun, lets reference the original image
  $ds->Insert("(0008,1140)[0](0008,1150)", "1.2.840.10008.5.1.4.1.1.2");
  $ds->Insert("(0008,1140)[0](0008,1155)", $old_uid);
  $ds->Insert("(0008,2111)", "Copied as part of Series Merge");

# Create the new file
  $ds->WritePart10("$to/$new_uid.dcm", $xfr_stx, "POSDA", undef, undef);
}

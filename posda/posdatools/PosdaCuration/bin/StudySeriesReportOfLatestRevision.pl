#!/usr/bin/perl -w
#
use strict;
use Storable qw( store_fd );
my $usage = "StudySeriesReportOfLatestRevision.pl <root_dir> <Collection> " .
  "<site> <subj>\n";
unless($#ARGV == 3){ die $usage }
my $edit_hist_dir = "$ARGV[0]/$ARGV[1]/$ARGV[2]/$ARGV[3]";
unless(-d $edit_hist_dir) { die "No directory: $edit_hist_dir" }
my $rev_hist_file = "$edit_hist_dir/rev_hist.pinfo";
my $rev_hist = Storable::retrieve($rev_hist_file);
my $current_rev = $rev_hist->{CurrentRev};
my $cur_revision_dir = "$edit_hist_dir/revisions/$current_rev";
#my $dicom_info = Storable::retrieve("$cur_revision_dir/dicom.pinfo");
my $hierarchy = Storable::retrieve("$cur_revision_dir/hierarchy.pinfo");
unless (exists $hierarchy->{$ARGV[3]}){
  die "No patient hierarchy for $ARGV[3]";
}

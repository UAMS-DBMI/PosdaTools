#!/usr/bin/perl -w
use Posda::DB::PosdaFilesQueries;
use strict;
my $usage = <<EOF;
LinkFileHierarchy.pl <root_dir>
  reads lines in the following format on STDIN:
<patient_id> <study_instance_uid> <series_instance_uid>
...

Gets all the files in the series, links a file named
  <sop_instance_uid>.dcm to the file in the directory
  <root_dir>/<patient_id>/<study_instance_uid>/<series_instance_uid>

Assumes <root_dir> is in same file_system as the root path in posda_files

EOF
unless($#ARGV == 0){ die $usage }
if($ARGV[0] eq '-h'){ die $usage }
unless(-d $ARGV[0]) { die "$ARGV[0] is not a directory" }
my %series_uids;
while(my $line = <STDIN>){
  chomp $line;
  my($patient_id, $study, $series) = split /\s+/, $line;
  my $dir = "$ARGV[0]/$patient_id";
  unless(-d $dir) {
    unless(mkdir $dir) { die "Can't mkdir $dir ($!)" }
  }
  $dir = "$ARGV[0]/$patient_id/$study";
  unless(-d $dir) {
    unless(mkdir $dir) { die "Can't mkdir $dir ($!)" }
  }
  $dir = "$ARGV[0]/$patient_id/$study/$series";
  unless(-d $dir) {
    unless(mkdir $dir) { die "Can't mkdir $dir ($!)" }
  }
  $series_uids{$series} = $dir;
}
my $num_dirs = keys %series_uids;
print "Created $num_dirs directories for copy\n";
print "Forking to do copy in backgound\n";
close STDOUT;
close STDIN;
fork and exit;
print STDERR "Survived fork\n";
my $num_linked = 0;
my $qh = PosdaDB::Queries->GetQueryInstance("FilesInSeriesForSend");
for my $series(keys %series_uids){
  my $sop;
  my $path;
  my $dir = $series_uids{$series};
  $qh->RunQuery(sub{
    my($row) = @_;
    $path = $row->[1];
    $sop = $row->[6];
    if(link $path, "$dir/$sop.dcm"){
      print STDERR "linked $dir/$sop.dcm to $path\n";
      $num_linked += 1;
    } else {
      print STDERR "link failed ($!) $dir/$sop.dcm to $path\n";
    }
  }, sub { }, $series);
}
print STDERR "Finished linking $num_linked files\n";

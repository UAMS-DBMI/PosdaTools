#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
my $usage = <<EOF;
PhiDirFastScan.pl <dir> <description>
  dir - directory to scan for files
      - Must be hierarchy:
         <dir>/<site>/<patient>/<study>/<series>/<mod>_<sop>.dcm
  description - description of scan
EOF
unless($#ARGV == 1){
  die "$usage\n";
}
my($dir, $desc) = @ARGV;
my %Series;
unless(-d $dir) { die "$dir is not a directory" }
opendir ROOTDIR, $dir or die "Can't opendir($dir) ($!)";
site:
while(my $site = readdir(ROOTDIR)){
  if($site =~ /^\./) { next site }
  unless(-d "$dir/$site") { next site }
  my $site_dir = "$dir/$site";
  opendir SITEDIR, $site_dir or die "Can't opendir($site_dir) ($!)";
  pat:
  while(my $pat_id = readdir(SITEDIR)){
    if($pat_id =~ /^\./) { next pat }
    unless(-d "$site_dir/$pat_id") { next pat }
    my $pat_dir = "$site_dir/$pat_id";
    opendir PATDIR, $pat_dir or die "Can't opendir($pat_dir) ($!)";
    stud:
    while(my $study = readdir(PATDIR)){
      if($study =~ /^\./) { next stud }
      unless(-d "$pat_dir/$study") { next stud }
      my $study_dir = "$pat_dir/$study";
        opendir STUDYDIR, $study_dir or die "Can't opendir($study_dir) ($!)";
      series:
      while(my $series = readdir(STUDYDIR)){
        if($series =~ /^\./) { next series }
        unless(-d "$study_dir/$series") { next series; }
        my $series_dir = "$study_dir/$series";
        my $modality;
        my $sop;
        my $path;
        opendir SERIESDIR, "$series_dir" or die 
          "Can't opendir($series_dir) ($!)";
        file:
        while(my $file = readdir(SERIESDIR)){
          if($file =~ /^([^\_]+)_([0-9\.]+)\.dcm$/){
            $modality = $1;
            $sop = $2;
            $path = "$series_dir/$file";
            last file;
          } else {
          }
        }
        closedir SERIESDIR;
        $Series{$series} = [
          $sop,
          $modality,
          $path,
        ];
      }
      closedir STUDYDIR;
    }
    closedir PATDIR;
  }
  close SITEDIR;
}
closedir ROOTDIR;
my $num_series = keys %Series;
print "Found list of $num_series series to scan\n";
close STDOUT;
close STDIN;
fork and exit;
print STDERR "Survived fork with $num_series to process\n";
my $create_scan = PosdaDB::Queries->GetQueryInstance("CreateScanEvent");
my $get_scan_id = PosdaDB::Queries->GetQueryInstance("GetScanEventEventId");
my $update_series_scanned = PosdaDB::Queries->GetQueryInstance("UpdateSeriesScanned");
my $finish_scan = PosdaDB::Queries->GetQueryInstance("UpdateSeriesFinished");
$create_scan->RunQuery(sub {}, sub {}, $desc, $num_series);
my $scan_id;
$get_scan_id->RunQuery(sub{
   my($row) = @_;
  $scan_id = $row->[0];
}, sub {});
unless(defined $scan_id) { die "Can't get scan_id" }
my $num_scanned = 0;
series:
for my $series (keys %Series){
  my $sop = $Series{$series}->[0];
  my $modality = $Series{$series}->[1];
  my $file = $Series{$series}->[2];
  my $command = "PhiSeriesScan.pl $series '<unknown>' $scan_id " .
    "'$file'";
  open COMMAND, "$command|" or die "can't open command";
  my $resp;
  while (my $line = <COMMAND>){
    $resp .= $line;
  }
  $num_scanned += 1;
  $update_series_scanned->RunQuery(sub{}, sub{}, $num_scanned, $scan_id);
}
$finish_scan->RunQuery(sub{}, sub{}, $scan_id);

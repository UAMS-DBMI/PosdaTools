#! /usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use DBI;
my $usage = "GetPixelRenderingInfoForSeries.pl <db> <sop_instance_uid>\n";
unless($#ARGV == 1) { die $usage }
my $dbh = DBI->connect("dbi:Pg:dbname=$ARGV[0];");
my $pq = PosdaDB::Queries->GetQueryInstance("PixelInfoBySopInstance");
my $sq = PosdaDB::Queries->GetQueryInstance("GetSlopeIntercept");
my $wq = PosdaDB::Queries->GetQueryInstance("GetWinLev");
$pq->Prepare($dbh);
$sq->Prepare($dbh);
$wq->Prepare($dbh);
$pq->Execute($ARGV[1]);
$pq->Rows(sub {
  my($h) = @_;
  my $slope;
  my $intercept;
  my @window_width;
  my @window_center;
  $sq->Execute($h->{file_id});
  $sq->Rows(sub {
    my($h1) = @_;
    $slope = $h1->{slope};
    $intercept = $h1->{intercept};
  });
  $wq->Execute($h->{file_id});
  $wq->Rows(sub {
    my($h1) = @_;
    push(@window_width, $h1->{window_width});
    push(@window_center, $h1->{window_center});
  });
  my $cols = $pq->GetColumns;
  for my $col (@$cols){
    unless(defined $h->{$col}){ $h->{$col} = "" }
    print "$h->{$col}|";
  }
  unless(defined $window_width[0]){
    $window_width[0] = "";
    $window_center[0] = "";
  }
  unless(defined $slope){
    $slope = "";
    $intercept = "";
  }
  print "$slope|$intercept|$window_width[0]|$window_center[0]|end\n";
});

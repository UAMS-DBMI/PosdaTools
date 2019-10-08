#! /usr/bin/perl -w
use Modern::Perl;

use Posda::DB::PosdaFilesQueries;
use DBI;
use Data::Dumper;

my $usage = "GetPixelRenderingInfoForSeries.pl <junk> <series_instance_uid>\n";
unless($#ARGV == 1) { die $usage }

my $pq = PosdaDB::Queries->GetQueryInstance("PixelInfoBySeries");
my $sq = PosdaDB::Queries->GetQueryInstance("GetSlopeIntercept");
my $wq = PosdaDB::Queries->GetQueryInstance("GetWinLev");

# $pq->Prepare($dbh);
# $sq->Prepare($dbh);
# $wq->Prepare($dbh);

# $pq->Execute($ARGV[1]);
$pq->RunQuery(
  sub {
  my ($h) = @_;
    my $slope;
    my $intercept;
    my @window_width;
    my @window_center;

    my $file_id = $h->[0];

    # Get the slope and intercept for this file
    $sq->RunQuery(
      sub {
  my ($h1) = @_;
        $slope = $h1->[0];
        $intercept = $h1->[1];
      },
      sub {},
      $file_id);

    # Get the window lev for this file(s?)
    $wq->RunQuery(
      sub {
  my ($h1) = @_;
        push(@window_width, $h1->[0]);
        push(@window_center, $h1->[1]);
      },
      sub {},
      $file_id
    );

    # output the query results
    for my $i (@$h) {
      if (not defined $i) {
        $i = "";
      }
      print "$i|";
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
  },
  sub {},
  $ARGV[1]);

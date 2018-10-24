#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
my $collection = $ARGV[0];
my $get_series = Query('CtSeriesWithCtImageInfoByCollection');
my %Series;
my $num_rows = 0;
$get_series->RunQuery(sub {
  my($row) = @_;
  my($series, $count) = @$row;
  $num_rows += 1;
  $Series{$series} = 1;
}, sub{}, $collection);
my $num_series = keys %Series;
print "Num series: $num_series\n";
print "Num rows: $num_rows\n";
my $get_series_consist = Query("CtImageDataConsistencyAcrossSeries");
my %ByNumRows;
my %Inconsistent;
for my $s (keys %Series){
  my $num_rows = 0;
  $get_series_consist->RunQuery(sub {
    my($row) = @_;
    $num_rows += 1;
  }, sub {}, $s);
  unless(exists $ByNumRows{$num_rows}){ $ByNumRows{$num_rows} = 0 }
  $ByNumRows{$num_rows} += 1;
  if($num_rows > 1) { $Inconsistent{$s} = 1 }
}
for my $n (keys %ByNumRows){
  print "$n: $ByNumRows{$n}\n";
}
for my $s (keys %Inconsistent){
  print "$s\n";
}

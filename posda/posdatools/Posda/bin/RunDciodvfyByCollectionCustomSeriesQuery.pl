#!/usr/bin/perl -w
use strict;
use DBI;
use Posda::DB::PosdaFilesQueries;
use Debug;
my $dbg = sub {print @_ };
my $usage = <<EOF;
RunDciodvfyFromByCollectionCustomSeriesQuery.pl <collection> <query_name> [<args>..]
EOF
my $dciodvfy = "/opt/dicom3tools/bin/dciodvfy";
unless($#ARGV > 1) { die $usage }
my $collection = shift @ARGV;
my $q_name = shift @ARGV;
my $get_s = PosdaDB::Queries->GetQueryInstance($q_name);
my $get_ff = PosdaDB::Queries->GetQueryInstance("FirstFileInSeriesPosda");
sub MakeFileRow{
  my($FileList, $series_instance_uid) = @_;
  my $sub = sub {
    my($row) = @_;
    push @$FileList, [$series_instance_uid, $row->[0]];
  };
  return $sub;
}
sub MakeSeriesRow{
  my($FileList) = @_;
  my $sub = sub {
    my($row) = @_;
print "Series: $row->[2]\n";
    $get_ff->RunQuery(
      MakeFileRow($FileList, $row->[2]),
      sub {},
      $row->[2]);
  };
  return $sub;
}
my @FileList;
$get_s->RunQuery(MakeSeriesRow(\@FileList),sub{}, $collection, @ARGV);

my %ErrorsToSeries;
for my $i (@FileList){
  my $series_uid = $i->[0];
  my $first_file = $i->[1];
  my $cmd = "$dciodvfy \"$first_file\"";
  open FILE, "$cmd 2>&1|grep Error|grep -v \"(0x0018,0x9445)\"|sort -u |";
  my @lines;
  while (my $line = <FILE>){
    chomp $line;
    push @lines, $line;
  }
  close FILE;
  if($#lines >= 0){
    my $ErrorMsg = join "\n", @lines;
    $ErrorsToSeries{$ErrorMsg}->{$series_uid} = 1;
  }
}
print "\"Errors\",\"SeriesInstanceUids\"\r\n";
for my $e (keys %ErrorsToSeries){
  my $en = $e;
  $en =~ s/\n/\r\n/g;
  $en =~ s/"/""/g;
  print "\"$en\",\"";
  for my $s (keys %{$ErrorsToSeries{$e}}){
     print "$s\r\n";
  }
  print "\"\r\n";
}

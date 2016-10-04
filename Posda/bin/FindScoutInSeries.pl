#!/usr/bin/perl -w 
use strict;
use DBI;
my $usage = "FindScoutInSeries.pl <series_instance_uid>";
unless($#ARGV == 0) { die $usage }
my $series = $ARGV[0];
my $dbh = DBI->connect("dbi:Pg:dbname=posda_files");
my $get_files = $dbh->prepare(
  "select\n" .
  "  distinct (file_id) from file_series natural join ctp_file\n" .
  "where series_instance_uid = ? and visibility is null"
);
$get_files->execute($series);
my @file_ids;
while(my $h = $get_files->fetchrow_hashref){
  push(@file_ids, $h->{file_id});
}
my $num_file_ids = @file_ids;
#print "$num_file_ids file_ids\n";
unless(@file_ids > 3){ die "$series has no identifiable scout" }
my $get_geo = $dbh->prepare(
  "select iop\n" .
  "from file_image natural join image_geometry\n" .
  "where file_id = ?"
);
my %Iops;
for my $file_id (@file_ids){
  my $iop;
  $get_geo->execute($file_id);
  my $h = $get_geo->fetchrow_hashref;
  $get_geo->finish;
  $iop = $h->{iop};
  unless(defined $iop) { die "$series has no identifiable scout" }
#print "$file_id, $iop\n";
  my @nums = split(/\\/, $iop);
  my @rounded_nums;
  for my $n (@nums) { push @rounded_nums, sprintf("%1.3f", $n) }
  my $riop = join "\\", @rounded_nums;
  $Iops{$riop}->{$file_id} = 1;
}
my $scout;
for my $iop (keys %Iops){
  my $count = keys %{$Iops{$iop}};
#print "$count of $iop\n";
  if($count == 1){
    if(defined $scout) { die "$series doesn't work with this method" }
    $scout = [ keys %{$Iops{$iop}} ]->[0];
  }
}
if(defined $scout){
  print "Scout: $scout\n";
} else {
  print "Can't find scout for $series\n";
}

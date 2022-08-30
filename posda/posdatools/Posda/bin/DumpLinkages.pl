#!/usr/bin/perl -w
use strict;
use Posda::Try;
use Posda::DB 'Query';
use Debug;
my $dbg = sub {print @_ };

my $file_path = $ARGV[0];
my $activity_id = $ARGV[1];

my $try = Posda::Try->new($file_path);
unless(exists $try->{dataset}){
  die "$file_path didn't parse";
}
my $ds = $try->{dataset};
my $q = Query("GetImageGeoInTpBySop");
print "Volume:\n";
print "index|z|sop_instance\n";
my $matches = $ds->Search("(3006,0010)[<0>](3006,0012)[<1>](3006,0014)[<2>](3006,0016)[<3>](0008,1155)");
for my $m (@$matches){
  my $i = $m->[0];
  my $j = $m->[1];
  my $k = $m->[2];
  my $p= $m->[3];
  my $v = $ds->Get("(3006,0010)[$i](3006,0012)[$j](3006,0014)[$k](3006,0016)[$p](0008,1155)");
  my $z;
  $q->RunQuery(sub{
    my($row) = @_;
    my $x; my $y;
    ($x, $y, $z) = split(/\\/, $row->[1]);
  }, sub{}, $v, $activity_id);
  unless(defined $z) { $z = "<unknown>" }
  print "$p|$z|$v\n";
}
print "Linked Contours:\n";
print "index|linked_sop|geometric_type|num_pts|ref_roi_num|contour_num|z\n";
$matches = $ds->Search("(3006,0039)[<0>](3006,0040)[<1>](3006,0016)[<2>](0008,1155)");
for my $m (@$matches){
  my $i = $m->[0];
  my $j = $m->[1];
  my $k = $m->[2];
  my $sop = $ds->Get("(3006,0039)[$i](3006,0040)[$j](3006,0016)[$k](0008,1155)");
  my $geo_type = $ds->Get("(3006,0039)[$i](3006,0040)[$j](3006,0042)");
  my $num_pts = $ds->Get("(3006,0039)[$i](3006,0040)[$j](3006,0046)");
  my $ref_roi_num = $ds->Get("(3006,0039)[$i](3006,0084)");
  my $cont_num = $ds->Get("(3006,0039)[$i](3006,0040)[$j](3006,0048)");
  my $cont_dat = $ds->Get("(3006,0039)[$i](3006,0040)[$j](3006,0050)");
  my $z;
  if(ref($cont_dat) eq "ARRAY"){
    $z = $cont_dat->[2];
  }
  print "$i|$sop|$geo_type|$num_pts|$ref_roi_num|$cont_num|$z\n";
}
print "ROIs:\n";
print "roi_num|roi_name|alg_type|frame_of_ref\n";
$matches = $ds->Search("(3006,0020)[<0>](3006,0022)");
for my $m (@$matches){
  my $i = $m->[0];
  my $roi_num = $ds->Get("(3006,0020)[$i](3006,0022)");
  my $roi_name = $ds->Get("(3006,0020)[$i](3006,0026)");
  my $roi_alg = $ds->Get("(3006,0020)[$i](3006,0036)");
  my $roi_for = $ds->Get("(3006,0020)[$i](3006,0024)");
  print "$roi_num|$roi_name|$roi_alg|$roi_for\n";
}

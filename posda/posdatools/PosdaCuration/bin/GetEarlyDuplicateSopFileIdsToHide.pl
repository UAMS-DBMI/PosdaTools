#!/usr/bin/perl -w
#
use strict;
use DBI;
my $usage = "GetEarlyDuplicateSopFileIdsToHide.pl <db_name> <patient_id>/n";
unless($#ARGV == 1){ die $usage }
my $dbh = DBI->connect("DBI:Pg:database=$ARGV[0]", "", "");
my $q1 = <<EOF;
select
  sop_instance_uid
from (
  select
    distinct sop_instance_uid, count(*)
  from
    file_sop_common natural join ctp_file natural join file_patient
  where patient_id = ?
  group by sop_instance_uid) as foo 
where count > 1
EOF
my $q2 = <<EOF;
select
  file_id, import_time
from
  file_import natural join import_event natural join ctp_file
  natural join file_sop_common
where
  sop_instance_uid = ?
EOF
my $qh1 = $dbh->prepare($q1);
my $qh2 = $dbh->prepare($q2);
$qh1->execute($ARGV[1]);
while(my $h1 = $qh1->fetchrow_hashref){
#print STDERR "Looking for dups of $h1->{sop_instance_uid}\n";
  my %TimesByFile;
  $qh2->execute($h1->{sop_instance_uid});
  while (my $h2 = $qh2->fetchrow_hashref){
    unless(exists $TimesByFile{$h2->{file_id}}){
      $TimesByFile{$h2->{file_id}} = $h2->{import_time};
    }
    if($h2->{import_time} gt $TimesByFile{$h2->{file_id}}){
      $TimesByFile{$h2->{file_id}} = $h2->{import_time};
    }
  }
  my @times;
  for my $f (keys %TimesByFile){
    my $t = $TimesByFile{$f};
      push @times, [$t, $f];
  }
  @times = sort {$a->[0] cmp $b->[0]} @times;
  if(@times > 1){
    for my $i (0 .. $#times - 1){
      my $t = $times[$i];
      print "discard($i), file_id = $t->[1], time = $t->[0]\n";
    }
    print   "keep   ($#times), file_id = $times[$#times]->[1]," .
     " time = $times[$#times]->[0]\n";
  } else {
  }
}

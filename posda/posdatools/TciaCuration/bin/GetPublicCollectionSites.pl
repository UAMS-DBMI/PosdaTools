#!/usr/bin/perl -w
#
use strict;
use DBI;
my $dbh = DBI->connect("DBI:mysql:database=ncia;host=10.28.163.86", "nciauser",
                       "nciA#112");
my $q = <<EOF;
select 
  distinct project, dp_site_name 
from trial_data_provenance 
order by 
  project, dp_site_name
EOF
my $query = $dbh->prepare($q);
$query->execute;
my $count = 0;
while(my $h = $query->fetchrow_hashref){
  print ">>>>>>>" .
        "Collection: $h->{project}  " .
        "Site: $h->{dp_site_name}\n";
  $count += 1;
  my $cmd = "GetPublicFilesByCollectionSite.pl $h->{project} $h->{dp_site_name}" or die "can't open sub_process ($!)";
  print "Command: $cmd\n";
  open my $fh, "$cmd|" or die "can't open sub_process ($!)";
  while(my $line = <$fh>){
    print $line;
  }
  close $fh;
}
print "Total: $count\n";

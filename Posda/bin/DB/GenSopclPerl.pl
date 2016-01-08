#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/DB/GenSopclPerl.pl,v $
#$Date: 2010/02/19 16:26:35 $
#$Revision: 1.1 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use DBI;
my $db = DBI->connect("dbi:Pg:dbname=dicom_dd", "", "");
my $q = $db->prepare("select * from sopcl order by sopcl_uid");
print "my \$SopCl = {\n";
$q->execute();
while (my $h = $q->fetchrow_hashref()){
  print "  \"$h->{sopcl_uid}\" => {\n";
  for my $key (keys %$h){
    if($key eq "sopcl_uid") { next }
    if(defined($h->{$key}) && $h->{$key}){
      print "    $key => \"$h->{$key}\",\n";
    }
  }
  print "  },\n";
}
print "};\n";

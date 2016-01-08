#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/DB/GenStdPerl.pl,v $
#$Date: 2010/02/19 16:27:13 $
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
my $q = $db->prepare("select * from ele where std order by grp, ele");
$q->execute();
my $grp;
print "my \$Dict = {\n";
while(my $h = $q->fetchrow_hashref()){
  if(!defined($grp) || $h->{grp} ne $grp){
     if(defined $grp){
       print "  },\n";
     }
     print "  \"$h->{grp}\" => {\n";
     $grp = $h->{grp};
  }
  print "    \"$h->{ele}\" => {\n";
  print "      \"VM\" => \"$h->{vm}\",\n";
  print "      \"VR\" => \"$h->{vr}\",\n";
  printf "      \"ele\" => \"%04x\",\n", $h->{ele};
  printf "      \"group\" => \"%04x\",\n", $h->{grp};
  print "      \"Name\" => \"$h->{name}\",\n";
  print "    },\n";
};
print "  },\n";
print "};\n";

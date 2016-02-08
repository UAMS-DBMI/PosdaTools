#!/usr/bin/perl -w
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
my $q = $db->prepare("select * from xfr_stx order by xfr_stx_uid");
print "my \$XferSyntax = {\n";
$q->execute();
while (my $h = $q->fetchrow_hashref()){
  print "  \"$h->{xfr_stx_uid}\" => {\n";
  for my $key (
    "vax", "name", "explicit", "short_len", "encap", "std", "retired",
  ){
    if(defined($h->{$key}) && $h->{$key}){
      print "    $key => \"$h->{$key}\",\n";
    }
  }
  for my $key (
    "short_len", "encap", "std"
  ){
    if(defined($h->{$key})){
      if($h->{$key}){
        print "    $key => \"1\",\n";
      } else {
        print "    $key => \"0\",\n";
      }
    }
  }
  print "  },\n";
}
print "};\n";

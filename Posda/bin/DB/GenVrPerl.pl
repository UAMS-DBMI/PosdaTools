#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/DB/GenVrPerl.pl,v $
#$Date: 2010/02/19 16:27:36 $
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
my $q = $db->prepare("select * from vr order by vr_code");
print "my \$VRDesc = {\n";
$q->execute();
my $convert_col = {
  vr_name => "name",
  len => "len",
  vr_type => "type",
  fixed => "fixed",
  strip_trailing => "striptrailing",
  pad_trailing => "padtrailing",
  strip_leading => "stripleading",
  pad_trailing => "padtrailing",
  strip_trailing_null => "striptrailingnull",
  pad_null => "padnull",
};
while (my $h = $q->fetchrow_hashref()){
  print "  $h->{vr_code} => {\n";
  for my $key (
    "vr_name", "len", "vr_type", "fixed", "strip_trailing",
    "strip_leading", "pad_trailing", "strip_trailing_null", "pad_null"
  ){
    if(defined($h->{$key}) && $h->{$key}){
      print "    $convert_col->{$key} => \"$h->{$key}\",\n";
    }
  }
  print "  },\n";
}
print "};\n";

#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/GenDataDict.pl,v $
#$Date: 2008/04/30 19:17:34 $
#$Revision: 1.5 $
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
$q = $db->prepare("select * from ele where pvt order by owned_by, grp, ele");
$q->execute();
my $own;
print "my \$PvtDict = {\n";
while(my $h = $q->fetchrow_hashref()){
  if(!defined($own) || $h->{owned_by} ne $own){
     if(defined $own){
       print "    },\n";
       print "  },\n";
     }
     print "  \"$h->{owned_by}\" => {\n";
     $own = $h->{owned_by};
     $grp = undef;
  }
  if(!defined($grp) || $h->{grp} ne $grp){
     if(defined $grp){
       print "    },\n";
     }
     print "    \"$h->{grp}\" => {\n";
     $grp = $h->{grp};
  }
  print "      \"$h->{ele}\" => {\n";
  print "        \"VM\" => \"$h->{vm}\",\n";
  print "        \"VR\" => \"$h->{vr}\",\n";
  printf "        \"ele\" => \"%04x\",\n", $h->{ele};
  printf "        \"group\" => \"%04x\",\n", $h->{grp};
  print "        \"Name\" => \"$h->{name}\",\n";
  print "      },\n";
};
print "    },\n";
print "  },\n";
print "};\n";
$q = $db->prepare("select * from vr order by vr_code");
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
$q = $db->prepare("select * from xfr_stx order by xfr_stx_uid");
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
$q = $db->prepare("select * from sopcl order by sopcl_uid");
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

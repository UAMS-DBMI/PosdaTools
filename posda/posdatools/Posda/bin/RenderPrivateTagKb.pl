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
my $db = DBI->connect("dbi:Pg:dbname=private_tag_kb	", "", "");
my $qt = <<EOF;
select
pt_signature as sig, pt_owner as owned_by, pt_group as grp,
pt_element as ele, pt_consensus_vr as vr,
pt_consensus_vm as vm, pt_consensus_name as name
from pt
where not pt_is_specific_to_block;
EOF
my $q = $db->prepare($qt);
$q->execute();
my $own;
print "my \$PvtDict = {\n";
my $grp;
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
  printf "        \"ele\" => \"%02x\",\n", $h->{ele};
  printf "        \"group\" => \"%04x\",\n", $h->{grp};
  print "        \"Name\" => \"$h->{name}\",\n";
  print "      },\n";
};
print "    },\n";
print "  },\n";
print "};\n";

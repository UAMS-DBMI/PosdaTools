#!/usr/bin/perl -w
#
# Pipe the following comand to this script
# % echo "select '&' ||
#pt_signature || '&' ||
#pt_owner || '&' ||
#pt_group || '&' ||
#pt_element || '&' ||
#pt_consensus_vr || '&' ||
#pt_consensus_vm || '&' ||
#pt_consensus_name || '&'
#from pt
#where
#not pt_is_specific_to_block
#order by pt_signature;"|psql private_tag_kb|grep '&'
#

my $own;
print "\$Posda::DataDict::PvtDict = {\n";
my $grp;
while(my $line = <STDIN>){
  chomp $line;
  my($pre,$sig,$owned_by,$t_grp,$ele,$vr,$vm,$name) = split(/&/, $line);
  if(!defined($own) || $owned_by ne $own){
     if(defined $own){
       print "    },\n";
       print "  },\n";
     }
     print "  \"$owned_by\" => {\n";
     $own = $owned_by;
     $grp = undef;
  }
  if(!defined($grp) || $grp ne $t_grp){
     if(defined $grp){
       print "    },\n";
     }
     print "    \"$t_grp\" => {\n";
     $grp = $t_grp;
  }
  print "      \"$ele\" => {\n";
  print "        \"VM\" => \"$vm\",\n";
  print "        \"VR\" => \"$vr\",\n";
  printf "        \"ele\" => \"%02x\",\n", $ele;
  printf "        \"group\" => \"%04x\",\n", $t_grp;
  print "        \"Name\" => \"$name\",\n";
  print "      },\n";
};
print "    },\n";
print "  },\n";
print "};\n";
print "1;\n";

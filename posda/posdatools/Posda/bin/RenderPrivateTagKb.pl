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

my $grp;
while(my $line = <STDIN>){
  chomp $line;
  my($pre,$sig,$owned_by,$t_grp,$ele,$vr,$vm,$name) = split(/&/, $line);
  $t_grp = 0 + $t_grp;
  $ele = 0 + $ele;
  print "\$Posda::DataDict::PvtDict->{\"$owned_by\"}->{$t_grp}->{$ele} = {\n" .
    "  \"VM\" => \"$vm\",\n" .
    "  \"VR\" => \"$vr\",\n";
  printf("  \"ele\" => \"%02x\",\n", $ele);
  printf("  \"grp\" => \"%04x\",\n", $t_grp);
  print "  \"Name\" => \"$name\",\n" .
    "};\n";
}
  
print "1;\n";

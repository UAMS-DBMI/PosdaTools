#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

use DBI;
my $db_name = $ARGV[0];
my $db = DBI->connect("dbi:Pg:dbname=$db_name", "", "");
my $q = $db->prepare("select * from ele where pvt order by owned_by, grp, ele");
$q->execute();
my($cur_owner, $cur_grp);
print "my \$PvtDict = {\n";
while (my $h = $q->fetchrow_hashref){
  my $ele = sprintf("%02x", $h->{ele});
  my $grp = sprintf("%04x", $h->{grp});
  my $sig = "($grp,\"$h->{owned_by}\",$ele)";
#  print "$sig\n";
  unless(defined($cur_owner) && $cur_owner eq $h->{owned_by}){
    if(defined($cur_owner)){
      print "    },\n";
      print "  },\n";
    }
    $cur_owner = $h->{owned_by};
    print "  \"$h->{owned_by}\" => {\n";
    $cur_grp = undef;
  }
  unless(defined($cur_grp) && $cur_grp eq $h->{grp}){
    if(defined($cur_grp)){
      print "    },\n";
    }
    $cur_grp = $h->{grp};
    print "    \"$h->{grp}\" => {\n";
  }
  print "      \"$h->{ele}\" => {\n";
  print "        \"VM\" => \"$h->{vm}\",\n";
  print "        \"VR\" => \"$h->{vr}\",\n";
  print "        \"ele\" => \"$ele\",\n";
  print "        \"group\" => \"$grp\",\n";
  print "        \"Name\" => \"$h->{name}\",\n";
  print "      },\n";
}
print "    },\n";
print "  },\n";
print "};\n";

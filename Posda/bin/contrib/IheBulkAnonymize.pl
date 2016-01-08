#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/contrib/IheBulkAnonymize.pl,v $
#$Date: 2013/05/01 12:49:02 $
#$Revision: 1.1 $
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
#####
# Customize this first:
my $root_of_orig = "/Users/bbennett/DicomSubmissions/ihe-ro/incoming/zip";
my $output_root = "/Users/bbennett/CustomizedDicomWithDob";
my $list_of_outputs = [
  {
    code => "AA",
    vendor => "Test Vendor",
    dob => "20001203",
  },
];
#####
opendir DIR, "$root_of_orig" or die "can't opendir $root_of_orig";
my @base_list;
while(my $f = readdir(DIR)){
  if($f =~ /^\./){ next }
  unless(-f "$root_of_orig/$f") { next }
  if($f =~ /^(.*)\.zip$/){
    my $id = $1;
    unless($id =~ /^(.*)..$/) { next }
    push @base_list, { root => $1, zip => $f};
  }
}
for my $i (@base_list) {
  for my $j (@$list_of_outputs){
    print "IheRoAnonymizer.pl " .
      "\"$root_of_orig/$i->{zip}\" " .
      "\"$output_root/$i->{root}$j->{code}\" " .
      "\"$i->{root}$j->{code}\" " .
      "\"$i->{root}$j->{code}^$j->{vendor}\" " .
      "\"$j->{dob}\"\n";
  }
}

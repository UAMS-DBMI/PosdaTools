#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;

my %PatientNames;

my $RootDir = $ARGV[0];
my $Count = $ARGV[1];
opendir DIR, "$RootDir/Source" or die "can't opendir $RootDir/Source";
while(my $f_name = readdir(DIR)){
print "Name: $f_name\n";
  if($f_name =~ /^\./) { next }
  unless(-d "$RootDir/Source/$f_name") { next }
  $PatientNames{$f_name} = "$RootDir/Source/$f_name";
}
closedir DIR;
for my $i (sort keys %PatientNames){
  my $ConfigFile = "$RootDir/Pseudo_config/$i.pseudo";
  unless(-f $ConfigFile){
    print "$ConfigFile doesn't exist\n";
    next;
  }
  for my $count (1 .. $Count){
    my $AnonConfig = "$RootDir/Anon_config/$i" . "_$count.anon";
    my $Pseudo_command = "PseudoMap.pl $ConfigFile $AnonConfig";
    print "Command: $Pseudo_command\n";
    `$Pseudo_command`;
  }
}

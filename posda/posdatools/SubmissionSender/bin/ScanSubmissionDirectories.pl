#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/PosdaCuration/bin/BuildExtractionCommands.pl,v $ #$Date: 2015/12/15 14:10:27 $
#$Revision: 1.2 $
#
use strict;
my $usage = "ScanSubmissionDirectories.pl <root>\n";
unless($#ARGV == 0){ die $usage }
my $root_dir = $ARGV[0];
unless(-d $root_dir) { die "$root_dir is a directory" }
opendir ROOT, $root_dir or die "can't opendir $root_dir";
coll:
while (my $collection = readdir(ROOT)){
  if($collection =~ /^\./) { next coll }
  unless(-d "$root_dir/$collection") {
    print STDERR "$root_dir/$collection is not a directory\n";
    next coll;
  }
  unless(opendir SITE, "$root_dir/$collection"){
    print STDERR "Can't opendir $root_dir/$collection\n";
    next coll;
  }
  site:
  while(my $site = readdir(SITE)){
    if($site =~ /^\./) { next site }
    unless(-d "$root_dir/$collection/$site") {
      print STDERR "$root_dir/$collection/$site is not a directory\n";
      next site;
    }
    unless(opendir SUBJ, "$root_dir/$collection/$site"){
      print STDERR "Can't opendir $root_dir/$collection/$site\n";
      next site;
    }
    subj:
    while(my $subj = readdir(SUBJ)){
      if($subj =~ /^\./){ next subj }
      unless(-d "$root_dir/$collection/$site/$subj") {
        print STDERR "$root_dir/$collection/$site/$subj is not a directory\n";
        next subj;
      }
      my $conv_coll = $collection;
      if($collection =~ /^[0-9A-F]+$/) {$conv_coll = Convert($collection)}
      my $conv_site = $site;
      if($site =~ /^[0-9A-F]+$/) {$conv_site = Convert($site)}
      print "$conv_coll|$conv_site|$subj|$collection/$site/$subj\n";
    }
  }
}
sub Convert{
  my($string) = @_;
  my $conv_string = "";
  while($string =~ /^([0-9A-F][0-9A-F])(.*)$/){
    my $hex_char = $1;
    $string = $2;
    if($hex_char ne "00"){
      $conv_string .=  unpack("a", pack("c", hex($hex_char)));
    }
  }
  $conv_string =~ s/\s*$//;
  return $conv_string;
}

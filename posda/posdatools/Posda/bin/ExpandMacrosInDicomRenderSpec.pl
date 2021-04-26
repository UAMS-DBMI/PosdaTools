#!/usr/bin/perl -w
use strict;
my $usage = <<EOF;
ExpandMacrosInDicomRenderSpec.pl <path_to_rendering_inst> <path_of_inherit_file> <path_of_dest_file>

EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 2){
  my $num_args = @ARGV;
  die "wrong number of args ($num_args vs 3):\n$usage\n";
}
my($rend_path, $inh_path, $dest_path) = @ARGV;
my @lines;
open REND, "<$rend_path" or die "can't open $rend_path";
while(my $l = <REND>){
  chomp $l;
  push @lines, $l;
}
close REND;
open FILE, ">$dest_path" or die "Can't open $dest_path ($!)";
for my $i (@lines){
  if($i =~ /^#/){
    print FILE "$i\n";
    next;
  }
  my($tag, $value) = split(/:/, $i);
  $value =~ s/^\s*//;
  $value =~ s/\s*$//;
  if($value =~ /^<\?(.*)\?>$/){
    my $macro = $1;
    print "Expanding macro $macro\n";
    if($macro =~ /inherit file_id=(.*)/){
      my $cmd = "GetElementValue.pl $inh_path '$tag'";
      $value = `$cmd`;
      chomp $value;
    }
  }
  print FILE "$tag: $value\n";
}

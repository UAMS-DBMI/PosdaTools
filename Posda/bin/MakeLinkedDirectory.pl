#!/usr/bin/perl -w
use strict;
my $usage = <<EOF;
MakeLinkedDirectory.pl <dir>
  dir is destination directory
  expects a list of files on STDIN
  files must be in same file system as cache_root
EOF
if($#ARGV != 0 || $ARGV[0] eq "-h"){
   die $usage;
}
if($ARGV[0] eq '-h'){ die $usage }
unless(-d $ARGV[0]) { die "$ARGV[0] is not a directory" }
while(my $line = <STDIN>){
  chomp $line;
  my($path_on_posda, $sop_instance_uid) = split(/\s*,\s*/,$line);
  unless($path_on_posda =~ /\/([^\/]+)$/){
    die "Can't extract file from path: $path_on_posda";
  }
  my $link = "$ARGV[0]/$sop_instance_uid.dcm";
  if(link $path_on_posda, $link){
    print "created link $link => $path_on_posda\n";
  } else {
    print "couldn't create ($!) link $link => $path_on_posda\n";
  }
}

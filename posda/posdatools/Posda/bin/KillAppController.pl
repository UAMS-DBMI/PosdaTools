#!/usr/bin/perl -w
##
#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

use strict;
my $usage = <<EOF;
KillAppController.pl <port> [old|new]
EOF
my $fh;
unless(open $fh, "ps -A -o pid,args|"){
  die "Can't open ps ";
}
unless(
  $#ARGV == 0 || $#ARGV == 1
){ die "$usage\n" }
if($#ARGV == 0 || $ARGV[1] eq "old"){
  old_line:
  while (my $line = <$fh>){
    chomp $line;
    $line =~ s/^\s*//;
    my ($pid, $perl, $w, $appc, $host, $port, $config) = split(/\s+/,$line);
    if(
      defined($pid) && defined($perl) && defined($w) &&
      defined($appc) && defined($host) && defined($port) &&
      $perl eq "/usr/bin/perl" &&
      $w eq "-w" &&
      $appc =~ /\/AppController.pl$/ &&
      $host eq "localhost" &&
      $port eq $ARGV[0]
    ) {
      print "Killing $pid\n";
      kill "KILL", $pid;
    }
  }
  exit;
}
new_line:
while (my $line = <$fh>){
  chomp $line;
  $line =~ s/^\s*//;
  my ($pid, $port, $appc) = 
    split(/\s+/,$line);
  if(
    defined($pid) && defined($port) && defined($appc) &&
    $appc eq "AppController" &&
    $port eq $ARGV[0]
  ) {
    print "Killing $pid\n";
    kill "KILL", $pid;
  }
}

#!/usr/bin/perl -w
#
#Copyright 2009, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Debug;
my $dbg = sub {print @_};
my %Errors;
while (my $line = <STDIN>){
  chomp $line;
  my($type, $message, $descrip) = split(/ - /, $line);
  if($descrip =~ /Element=<([^>]+)> IE=<([^>]+)> for file/){
    my $Element = $1;
    my $Ie = $2;
    $Errors{$type}->{$Ie}->{$Element} += 1;
  }
}
print "Errors: ";
Debug::GenPrint($dbg, \%Errors, 1);
print "\n";

#!/usr/bin/perl -w
#
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
package Posda::PseudoNym;
use IO::Socket;
sub Get{
  my($type) = @_;
  my $req = "/cgi-bin/request_pseudo_nym.pl";
  if($type eq "female"){
    $req .= "?type=female";
  }
  my $s = IO::Socket::INET->new(PeerAddr => 'posda.com',
    PeerPort => 'http(80)',
    Proto => 'tcp',
  ) or die "can't connect to posda.com";
  $s->print("GET $req HTTP/1.0\n");
  $s->print("Host: posda.com\n");
  $s->print("ACCEPT: */*\n\n");
  my $line;
  my $response = 1;
  my $in_header = 1;
  while($line = $s->getline()){
    chomp $line;
    $line =~ s/\r//;
    if($response) {
      $response = 0;
      my @fields = split(/\s/, $line);
      unless($fields[1] == 200){
        die "bad response from posda.com ($line)";
      }
    }
    if($line =~ /^$/){
      $in_header = 0;
      next;
    }
    if($in_header) { next }
    return $line;
  }
};
1

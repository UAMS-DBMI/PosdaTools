#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/UID.pm,v $
#$Date: 2009/01/07 19:01:22 $
#$Revision: 1.4 $
#
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
package Posda::UID;
use IO::Socket;
sub GetPosdaRoot{
  my($h) = @_;
  unless(ref($h) eq "HASH") { die "specify some attributes" };
  my $args = "";
  unless(exists $h->{user}){
    my $user = `whoami`;
    chomp $user;
    $h->{user} = $user;
  }
  unless(exists $h->{host}){
    my $host = `hostname`;
    chomp $host;
    $h->{host} = $host;
  }
  for my $k (keys %$h){
    my $value = $h->{$k};
    $value =~ s/([^\w])/"%" . unpack("H2", $1)/eg;
    $args .= "$k=$value&";
  }
  my $s = IO::Socket::INET->new(PeerAddr => 'posda.com',
    PeerPort => 'http(80)',
    Proto => 'tcp',
  ) or die "can't connect to posda.com";
  $s->print("GET /cgi-bin/request_uid.pl?$args HTTP/1.0\n");
  $s->print("Host: posda.com\n");
  $s->print("ACCEPT: */*\n\n");
  my $line;
  my $response = 1;
  my $in_header = 1;
  while($line = $s->getline()){
    chomp $line;
    $line =~ s/\r//;
    if($response){
      $response = 0;
      my @fields = split(/\s/, $line);
      unless($fields[1] == 200){
        die "bad response from posda.com";
      }
    }
    if($line =~ /^$/){
      $in_header = 0;
      next;
    }
    if($in_header) { next }
    $s->close();
    return $line;
  }
};
sub GetUIDFromServer{
  my($h, $host, $port) = @_;
  unless(ref($h) eq "HASH") { die "specify some attributes" };
  my $args = "";
  unless(exists $h->{user}){
    my $user = `whoami`;
    chomp $user;
    $h->{user} = $user;
  }
  unless(exists $h->{host}){
    my $host = `hostname`;
    chomp $host;
    $h->{host} = $host;
  }
  for my $k (keys %$h){
    my $value = $h->{$k};
    $value =~ s/(\n)/"%" . unpack("H2", $1)/eg;
    $args .= "$k:$value\n";
  }
  my $s = IO::Socket::INET->new(PeerAddr => $host,
    PeerPort => $port,
    Proto => 'tcp',
  ) or die "can't connect to $host:$port";
  $s->print("$args\n");
  my $line = $s->getline();
  chomp $line;
  return $line;
};
sub GetUID{
  my($h) = @_;
  unless(ref($h) eq "HASH") { die "attributes please" }
  if(
    defined($ENV{POSDA_UID_HOST}) && defined($ENV{POSDA_UID_PORT})
  ){
   return GetUIDFromServer($h, $ENV{POSDA_UID_HOST}, $ENV{POSDA_UID_PORT});
  } else {
   return GetPosdaRoot($h);
  }
};
1

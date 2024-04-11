#!/usr/bin/perl -w
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

use constant {
  ImplicitVRLittleEndian => '1.2.840.10008.1.2',
  ExplicitVRLittleEndian => '1.2.840.10008.1.2.1',
  DeflatedExplicitVRLittleEndian => '1.2.840.10008.1.2.1.99',
  ExplicitVRBigEndian => '1.2.840.10008.1.2.2',
  JPEGBaseline8Bit => '1.2.840.10008.1.2.4.50',
  JPEGExtended12Bit => '1.2.840.10008.1.2.4.51',
  JPEGLosslessP14 => '1.2.840.10008.1.2.4.57',
  JPEGLosslessSV1 => '1.2.840.10008.1.2.4.70',
  JPEGLSLossless => '1.2.840.10008.1.2.4.80',
  JPEGLSNearLossless => '1.2.840.10008.1.2.4.81',
  JPEG2000Lossless => '1.2.840.10008.1.2.4.90',
  JPEG2000 => '1.2.840.10008.1.2.4.91',
  JPEG2000MCLossless => '1.2.840.10008.1.2.4.92',
  JPEG2000MC => '1.2.840.10008.1.2.4.93',
  MPEG2MPML => '1.2.840.10008.1.2.4.100',
  MPEG2MPHL => '1.2.840.10008.1.2.4.101',
  MPEG4HP41 => '1.2.840.10008.1.2.4.102',
  MPEG4HP41BD => '1.2.840.10008.1.2.4.103',
  MPEG4HP422D => '1.2.840.10008.1.2.4.104',
  MPEG4HP423D => '1.2.840.10008.1.2.4.105',
  MPEG4HP42STEREO => '1.2.840.10008.1.2.4.106',
  HEVCMP51 => '1.2.840.10008.1.2.4.107',
  HEVCM10P51 => '1.2.840.10008.1.2.4.108',
  RLELossless => '1.2.840.10008.1.2.5',
};


1

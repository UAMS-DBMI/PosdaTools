#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/Ae/AssocRelease.pm,v $
#$Date: 2010/01/03 22:43:53 $
#$Revision: 1.1 $

use strict;
{
  package Posda::Ae::AReleaseRq;
  sub new {
    my($class) = @_;
    my $this = {};
    bless $this, $class;
    if($ENV{POSDA_DEBUG}){
      print "NEW: $this\n";
    }
    return $this;
  }
  sub from_pdu{
    my($class, $pdu) = @_;
    my $this = {};
    my ($type, $foo, $len, $foo1) = unpack("ccNcccc", $pdu);
    unless($type == 0x5) { die "pdu is not AssocRj ($type)" }
    unless($len == 0x4) { die "pdu is not length 4 ($len)" }
    bless $this, $class;
    if($ENV{POSDA_DEBUG}){
      print "NEW (from PDU): $this\n";
    }
    return $this;
  }
  sub to_pdu{
    my($this) = @_;
    my $string = pack("ccNN", 0x5, 0, 4, 0);
    return $string;
  }
  sub from_db{
    my($class, $db, $id) = @_;
    my $get = $db->prepare(
      "select * from a_release_rq where a_release_rq_id = ?"
    );
    $get->execute($id);
    my $h = $get->fetchrow_hashref();
    $get->finish();
    unless($h && ref($h) eq "HASH"){ die "couldn't get assoc_rj($id)" }
    my $this = {
      id => $h->{a_release_rq_id},
    };
    bless $this, $class;
    if($ENV{POSDA_DEBUG}){
      print "NEW (from DB): $this\n";
    }
    return $this;
  }
  sub instantiate{
    my($this, $db) = @_;
    my $ins = $db->prepare("insert into a_release_rq");
    $ins->execute();
    my $get_id = $db->prepare(
      "select currval('assoc_rj_assoc_rj_id_seq') as id"
    );
    $get_id->execute();
    my $h = $get_id->fetchrow_hashref();
    $this->{id} = $h->{id};
  }
  sub DESTROY{
    my($this) = @_;
    if($ENV{POSDA_DEBUG}){
      print "DESTROY: $this\n";
    }
  }
}
1;

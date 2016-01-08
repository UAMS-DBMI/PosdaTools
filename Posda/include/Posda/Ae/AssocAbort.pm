#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/Ae/AssocAbort.pm,v $
#$Date: 2010/01/03 22:43:13 $
#$Revision: 1.1 $

use strict;
{
  package Posda::Ae::AAbort;
  sub new {
    my($class, $source, $reason) = @_;
    my $this = {
      source => $source,
      reason => $reason
    };
    bless $this, $class;
    if($ENV{POSDA_DEBUG}){
      print "NEW: $this\n";
    }
    return $this;
  }
  sub from_pdu{
    my($class, $pdu) = @_;
    my ($type, $foo, $len, $foo1, $result, $source, $reason) = 
      unpack("ccNcccc", $pdu);
    unless($type == 0x7) { die "pdu is not AssocRj ($type)" }
    unless($len == 0x4) { die "pdu is not length 4 ($len)" }
    my $this = {
      source => $source,
      reason => $reason,
    };
    bless $this, $class;
    if($ENV{POSDA_DEBUG}){
      print "NEW (from PDU): $this\n";
    }
    return $this;
  }
  sub to_pdu{
    my($this) = @_;
    my $string = pack("ccNcccc", 0x3, 0, 4, 0, 0,
      $this->{source}, $this->{reason});
    return $string;
  }
  sub from_db{
    my($class, $db, $id) = @_;
    my $get = $db->prepare(
      "select * from a_abort where a_abort_id = ?"
    );
    $get->execute($id);
    my $h = $get->fetchrow_hashref();
    $get->finish();
    unless($h && ref($h) eq "HASH"){ die "couldn't get a_abort($id)" }
    my $this = {
      id => $h->{a_abort_id},
      source => $h->{rj_source},
      reason => $h->{rj_reason},
    };
    bless $this, $class;
    if($ENV{POSDA_DEBUG}){
      print "NEW (from DB): $this\n";
    }
    return $this;
  }
  sub instantiate{
    my($this, $db) = @_;
    my $ins = $db->prepare(
      "insert into a_abort (\n" .
      "  rj_source,\n" .
      "  rj_reason\n" .
      ") values (\n" .
      "  ?, ?\n" .
      ")"
    );
    $ins->execute($this->{rj_source}, $this->{rj_reason});
    my $get_id = $db->prepare(
      "select currval('a_abort_a_abort_id_seq') as id"
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

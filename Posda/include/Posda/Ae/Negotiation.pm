#!/usr/bin/perl -w

use strict;
{
  #########################
  # AssociationNegotiation
  #   Takes a Posda::Ae::AssocRq object, and
  #   a Posda::Ae::LocalServer object, and produces
  #   either a Posda::Ae::AssocRj object, or a 
  #   Posda::Ae::AssocAc object
  #
  # $assoc_rq = {
  #  called => <text>,
  #  calling => <text>,
  #  ver => <text>,
  #  app_context => <text>,
  #  imp_class_uid => <text>, (must be a uid)
  #  imp_ver_name => <text>,
  #  max_length => <int>,
  #  max_i => <null> or <int>,
  #  max_p => <null> or <int>,
  #  roles => {
  #    <sop_class_uid> =>{
  #      scu => 1 or 0,
  #      scp => 1 or 0,
  #    },
  #    ...
  #  },
  #  presentation_contexts => {
  #    <pres_ctx_id> => {
  #      abstract_syntax => <abs_stx_uid>,
  #      transfer_syntaxes => [ <xfr_stx_uid>, ... ],
  #    },
  #    ...
  #  },
  #};
  # $local_server = {
  #  ae_local_title => <text>, (unless is_anonymous)
  #  description => <text>,
  #  is_promiscuous => <null> or 1,
  #  is_anonymous => <null> or 1,
  #  auth_clients => {        # (only if is_promiscuous is null)
  #     <calling_ae_title_1> => 1,
  #     <calling_ae_title_2> => 1,
  #     ....
  #  },
  #  app_context => <text>,
  #  imp_class_uid => <text>, (must be a uid)
  #  imp_ver_name => <text>,
  #  protocol_version => <text>,
  #  max_length => <int>,
  #  num_invoked => <null> or <int>,
  #  num_performed => <null> or <int>,
  #  scu_scp_role => {
  #    <sop_class_uid> =>{
  #      scu_role => 1 or 0,
  #      scp_role => 1 or 0,
  #    },
  #    ...
  #  },
  #  pres_ctx => {
  #    <abs_stx> => {
  #      implementation_class => "STORAGE", "VERIFICATION", "QUERY_RETRIEVE", 
  #            or "NORMALIZED",
  #      xfr_stx => { 
  #        <xfr_stx_uid> => 1, 
  #        ... 
  #      },
  #    },
  #    ...
  #};
  # $assoc_ac = {
  #  called => <text>,
  #  calling => <text>,
  #  ver => <text>,
  #  app_context => <text>,
  #  imp_class_uid => <text>, (must be a uid)
  #  imp_ver_name => <text>,
  #  max_length => <int>,
  #  max_i => <null> or <int>,
  #  max_p => <null> or <int>,
  #  roles => {
  #    <sop_class_uid> =>{
  #      scu => 1 or 0,
  #      scp => 1 or 0,
  #    },
  #    ...
  #  },
  #  presentation_contexts => {
  #    <pres_ctx_id> => {
  #      result => <result>, ( 0 means accepted )
  #      transfer_syntax => <xfr_stx_uid>,
  #    },
  #    ...
  #  },
  #};
  #$assoc_rj = {
  #  result => <int>,
  #  source => <int>,
  #  reason => <int>
  #};
  ########################################
  package Posda::Ae::Negotiation;
  sub Negotiate{
    my($assoc_rq, $local_server) = @_;
  }
}
{
  package Posda::Ae::AssocRj;
  sub new {
    my($class, $result, $source, $reason) = @_;
    my $this = {
      result => $result,
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
    unless($type == 0x3) { die "pdu is not AssocRj ($type)" }
    unless($len == 0x4) { die "pdu is not length 4 ($len)" }
    my $this = {
      result => $result,
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
    my $string = pack("ccNcccc", 0x3, 0, 4, 0, $this->{result},
      $this->{source}, $this->{reason});
    return $string;
  }
  sub from_db{
    my($class, $db, $id) = @_;
    my $get = $db->prepare(
      "select * from assoc_rj where assoc_rj_id = ?"
    );
    $get->execute($id);
    my $h = $get->fetchrow_hashref();
    $get->finish();
    unless($h && ref($h) eq "HASH"){ die "couldn't get assoc_rj($id)" }
    my $this = {
      id => $h->{assoc_jr_id},
      result => $h->{rj_result},
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
      "insert into assoc_rj (\n" .
      "  rj_result,\n" .
      "  rj_source,\n" .
      "  rj_reason\n" .
      ") values (\n" .
      "  ?, ?, ?\n" .
      ")"
    );
    $ins->execute($this->{rj_result}, $this->{rj_source}, $this->{rj_reason});
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

#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/Ae/LocalServer.pm,v $
#$Date: 2010/01/03 22:44:36 $
#$Revision: 1.3 $
use strict;
{
  ########################################
  # $local_server = {
  #  ae_local_title => <text>,
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
  ########################################
  package Posda::Ae::LocalServer;
  #
  # To create from config file
  #
  sub new_from_config{
    my($class, $file)  = @_;
    my $this = {};
    open FILE, "<$file" or die "can't open $file";
    line:
    while(my $line = <FILE>){
      chomp $line;
      if($line =~ /^#/) { next line }
      unless($line =~ /^([a-zA-Z_]+):\s*(.*)\s*$/) { next line }
      my $type = $1;
      my $fields = $2;
      my @fields_array = split(/\|/, $fields);
      if($type eq "ae_title"){
        $this->{ae_local_title} = $fields_array[0];
      } elsif($type eq "description"){
        $this->{description} = $fields_array[0];
      } elsif($type eq "IsPromiscuous"){
        $this->{is_promiscuous} = 1;
      } elsif($type eq "IsAnonymous"){
        $this->{is_anonymous} = 1;
      } elsif($type eq "allowed_calling_ae_titles"){
        for my $i (sort @fields_array){
          $this->{auth_clients}->{$i} = 1;
        }
      } elsif($type eq "app_context"){
        $this->{app_context} = $fields_array[0];
      } elsif($type eq "imp_class_uid"){
        $this->{imp_class_uid} = $fields_array[0];
      } elsif($type eq "imp_ver_name"){
        $this->{imp_ver_name} = $fields_array[0];
      } elsif($type eq "protocol_version"){
        $this->{protocol_version} = $fields_array[0];
      } elsif($type eq "max_length"){
        $this->{max_length} = $fields_array[0];
      } elsif($type eq "num_invoked"){
        $this->{num_invoked} = $fields_array[0];
      } elsif($type eq "num_performed"){
        $this->{num_performed} = $fields_array[0];
      } elsif($type eq "scu_scp_role"){
        my $sop_class = $fields_array[0];
        my $scu_role = $fields_array[1];
        my $scp_role = $fields_array[2];
        $this->{sc_roles}->{$sop_class}->{scu_role} = $scu_role;
        $this->{sc_roles}->{$sop_class}->{scp_role} = $scp_role;
      } elsif(
        $type eq "storage_pres_context" ||
        $type eq "delayed_storage_pres_context" ||
        $type eq "verification_pres_context" ||
        $type eq "query_retreive_pres_context" ||
        $type eq "normalized_pres_context"
      ){
        for my $i (1 .. $#fields_array){
          $this->{pres_ctx}->
           {$fields_array[0]}->{xfr_stx}->{$fields_array[$i]} = 1;
        }
        if($type eq "storage_pres_context"){
          $this->{pres_ctx}->{$fields_array[0]}->{implementation_class} =
            "STORAGE";
        }
        if($type eq "verification_pres_context"){
          $this->{pres_ctx}->{$fields_array[0]}->{implementation_class} =
            "VERIFICATION";
        }
        if($type eq "query_retrieve_pres_context"){
          $this->{pres_ctx}->{$fields_array[0]}->{implementation_class} =
            "QUERY_RETREIVE";
        }
        if($type eq "normalized_pres_context"){
          $this->{pres_ctx}->{$fields_array[0]}->{implementation_class} =
            "NORMALIZED";
        }
      }
    }
    close FILE;
    bless $this, $class;
    if($ENV{POSDA_DEBUG}){
      print "NEW (from config): $this\n";
    }
    return $this;
  }
  sub new_from_db{
    my($class, $db, $id) = @_;
    my $this = {};
    my $get_local_aes = $db->prepare(
      "select * from ae_local_server where ae_local_server_id = ?"
    );
    my $get_pres_ctx = $db->prepare(
      "select * from \n" .
      "  ae_local_rcv_pres_ctx\n" .
      "where ae_local_server_id = ?\n" .
      "order by sop_class_uid asc"
    );
    my $get_auth_clients = $db->prepare(
      "select * from ae_local_server_authorized_clients\n" .
      "where ae_local_server_id = ?"
    );
    my $get_scu_scp_role = $db->prepare(
      "select * from ae_local_server_sopclass_role\n" .
      "where ae_local_server_id = ?"
    );
    $get_local_aes->execute($id);
    my $hash = $get_local_aes->fetchrow_hashref();
    $get_local_aes->finish();
    unless($hash && ref($hash) eq "HASH") {
      die "undefined ae_local_server: $id"
    };
    $this->{description} = $hash->{description};
    if($hash->{is_anonymous}){
      $this->{is_anonymous} = 1;
    }
    if($hash->{is_promiscuous}){
      $this->{is_promiscuous} = 1;
    }
    $this->{ae_local_title} = $hash->{ae_local_title};
    $this->{id} = $hash->{ae_local_server_id};
    $this->{app_context} = $hash->{aels_app_context};
    $this->{imp_class_uid} = $hash->{aels_imp_class_uid};
    $this->{imp_ver_name} = $hash->{aels_imp_ver_name};
    $this->{protocol_version} = $hash->{aels_protocol_version};
    $this->{max_length} = $hash->{aels_max_length};
    $this->{num_invoked} = $hash->{aels_num_invoked};
    $this->{num_performed} = $hash->{aels_num_performed};
    $get_pres_ctx->execute($id);
    while(my $hash = $get_pres_ctx->fetchrow_hashref()){
      $this->{pres_ctx}->{$hash->{sop_class_uid}}->
        {xfr_stx}->{$hash->{xfr_stx_uid}} = 1;
      $this->{pres_ctx}->{$hash->{sop_class_uid}}->
        {implementation_class} = 
        $hash->{aels_implementation_class};
    }
    $get_auth_clients->execute($id);
    while(my $hash = $get_auth_clients->fetchrow_hashref()){
      $this->{auth_clients}->{$hash->{ae_calling_ae_title}} = 1;
    }
    $get_scu_scp_role->execute($id);
    while(my $hash = $get_scu_scp_role->fetchrow_hashref()){
      $this->{sc_roles}->{$hash->{sop_class_uid}}->{scu_role} = 
        $hash->{scu_role};
      $this->{sc_roles}->{$hash->{sop_class_uid}}->{scp_role} = 
        $hash->{scp_role};
    }
    bless $this, $class;
    if($ENV{POSDA_DEBUG}){
      print "NEW (from db): $this\n";
    }
    return $this;
  }
  sub instantiate_in_db{
    my($this, $db) = @_;
    if(exists $this->{id}) { die "already has id" }
    my $create_ae_local_receiver = $db->prepare(
      "insert into ae_local_server(\n" .
      "  description,\n" .
      "  aels_app_context,\n" .
      "  aels_imp_class_uid,\n" .
      "  aels_imp_ver_name,\n" .
      "  aels_protocol_version,\n" .
      "  aels_max_length,\n" .
      "  aels_num_invoked,\n" .
      "  aels_num_performed\n" .
      ") values (\n" .
      "  ?, ?, ?, ?, ?, ?, ?, ?\n" .
      ")"
    );
    $create_ae_local_receiver->execute(
      $this->{description},
      $this->{app_context},
      $this->{imp_class_uid},
      $this->{imp_ver_name},
      $this->{protocol_version},
      $this->{max_length},
      $this->{num_invoked},
      $this->{num_performed}
    );
    my $make_aelr_anonymous = $db->prepare(
      "update ae_local_server set is_anonymous = TRUE\n" .
      "where ae_local_server_id = \n" .
      "  currval('ae_local_server_ae_local_server_id_seq')"
    );
    my $assign_ae_local_title = $db->prepare(
      "update ae_local_server set ae_local_title = ?\n" .
      "where ae_local_server_id = \n" .
      "  currval('ae_local_server_ae_local_server_id_seq')"
    );
    if(exists $this->{is_anonymous}){
      $make_aelr_anonymous->execute();
    } else {
      $assign_ae_local_title->execute($this->{ae_local_title});
    }
    my $make_aelr_promiscuous = $db->prepare(
      "update ae_local_server set is_promiscuous = TRUE\n" .
      "where ae_local_server_id = \n" .
      "  currval('ae_local_server_ae_local_server_id_seq')"
    );
    my $create_auth_clients = $db->prepare(
      "insert into ae_local_server_authorized_clients(\n" .
      "  ae_local_server_id,\n" .
      "  ae_calling_ae_title\n" .
      ") values (\n" .
      "  currval('ae_local_server_ae_local_server_id_seq'),\n" .
      "  ?\n" .
      ")"
    );
    if(exists $this->{is_promiscuous}){
      $make_aelr_promiscuous->execute();
    } else {
      for my $i (sort keys %{$this->{auth_clients}}){
        $create_auth_clients->execute($i);
      }
    }
    my $create_pres_ctx_ent = $db->prepare(
      "insert into ae_local_rcv_pres_ctx(\n" .
      "  ae_local_server_id,\n" .
      "  sop_class_uid,\n" .
      "  xfr_stx_uid,\n" .
      "  aels_implementation_class\n" .
      ") values (\n" .
      "  currval('ae_local_server_ae_local_server_id_seq'),\n" .
      "  ?, ?, ?\n" .
      ")"
    );
    for my $sop_class (sort keys %{$this->{pres_ctx}}){
      for my $xfr_stx(keys %{$this->{pres_ctx}->{$sop_class}->{xfr_stx}}){
        my $imp_class = $this->{pres_ctx}->{$sop_class}->{implementation_class};
        $create_pres_ctx_ent->execute(
           $sop_class,
           $xfr_stx,
           $imp_class
        );
      }
    }
    my $create_sc_role = $db->prepare(
      "insert into ae_local_server_sopclass_role(\n" .
      "  ae_local_server_id text,\n" .
      "  sop_class_uid text,\n" .
      "  aels_scu_role boolean,\n" .
      "  aels_scp_role boolean\n" .
      ") values ( \n" .
      "  currval('ae_local_server_ae_local_server_id_seq'),\n" .
      "  ?,\n" .
      "  ?,\n" .
      "  ?\n" .
      ")"
    );
    for my $sop_class (sort keys %{$this->{sc_roles}}){
      $create_sc_role->execute(
        $sop_class,
        $this->{sc_roles}->{sop_class}->{scu_role},
        $this->{sc_roles}->{sop_class}->{scp_role}
      );
    }
    my $get_id = $db->prepare(
      "select currval('ae_local_server_ae_local_server_id_seq') as id"
    );
    $get_id->execute();
    my $h = $get_id->fetchrow_hashref();
    $this->{id} = $h->{id};
    $get_id->finish;
  }
  sub DumpGuts{
    my($this, $out) = @_;
    my $class = ref($this);
    my $instance_id = "<uninstantiated>";
    if(exists $this->{id}){
      $instance_id = $this->{id};
    }
    print $out "##########################\n";
    print $out "Instance ($instance_id) of $class:\n";
    print $out "\tDescription: $this->{description}\n";
    if(exists $this->{is_anonymous}){
      print $out "\tIs anonymous\n";
    } else {
      print $out "\tCalled ae_title: $this->{ae_local_title}\n";
    }
    if(exists $this->{is_promiscuous}){
      print $out "\tIs promiscuous\n";
    } else {
      print $out "\tAllowed calling ae_titles:\n";
      for my $i (sort keys %{$this->{auth_clients}}){
        print $out "\t\t$i\n";
      }
    }
    print $out "\tApplication Context UID:  $this->{app_context}\n";
    print $out "\tImplementation Class UID: $this->{imp_class_uid}\n";
    print $out "\tImplementation Version Name: $this->{imp_ver_name}\n";
    print $out "\tProtocol Version: $this->{protocol_version}\n";
    print $out "\tMax Length: $this->{max_length}\n";
    if(exists $this->{num_invoked}){
      print $out "\tMax Invoked: $this->{num_invoked}\n";
    }
    if(exists $this->{num_performed}){
      print $out "\tMax Performed: $this->{num_performed}\n";
    }
    print $out "\tAcceptable for Presentation Contexts:\n";
    for my $sop_class (sort keys %{$this->{pres_ctx}}){
      print $out "\t\t$sop_class " .
        "($this->{pres_ctx}->{$sop_class}->{implementation_class})\n";
      for my $xfr_stx (sort keys %{$this->{pres_ctx}->{$sop_class}->{xfr_stx}}){
        print $out "\t\t\t$xfr_stx\n";
      }
    }
    if(exists $this->{sc_role}){
      print $out "\tSop Class Roles:\n";
      for my $sop_class (keys %{$this->{sc_roles}}){
        print $out "\t\t$sop_class:\n";
        print $out 
          "\t\t\tScu: $this->{sc_roles}->{$sop_class}->{scu_role}\n";
        print $out 
          "\t\t\tScp: $this->{sc_roles}->{$sop_class}->{scp_role}\n";
      }
    }
    print $out "##########################\n";
  }
  sub DESTROY{
    my($this) = @_;
    if($ENV{POSDA_DEBUG}){
      print "DESTROY: $this\n";
    }
  }
}
1;

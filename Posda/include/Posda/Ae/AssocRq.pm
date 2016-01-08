#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/Ae/AssocRq.pm,v $
#$Date: 2010/01/03 22:44:23 $
#$Revision: 1.2 $

use strict;
{
  ########################################
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
  ########################################
  package Posda::Ae::AssocRq;
  #########################
  # Build programatically
  #    new
  #    add_num_invoked
  #    add_num_performed
  #    add_pres_ctx
  #    add_sop_class_role
  #
  sub new {
    my ($class, $calling_ae_title, $called_ae_title) = @_;
    my $this = {
      calling => $calling_ae_title,
      called => $called_ae_title,
      app_context => "1.2.840.10008.3.1.1.1",
      imp_class_uid => "1.3.6.1.4.1.22213.1.69",
      imp_ver_name =>  "posda_assoc_mgr_1",
      ver => 1,
      max_length => 16384,
    };
    bless $this, $class;
    if($ENV{POSDA_DEBUG}){
      print "NEW: $this\n";
    }
    return $this;
  }
  sub add_num_invoked{
    my($this, $num) = @_;
    $this->{max_i} = $num;
  }
  sub add_num_performed{
    my($this, $num) = @_;
    $this->{max_p} = $num;
  }
  sub add_pres_ctx{
    my $this = shift(@_);
    my $pres_ctx_id = shift(@_);
    unless(($pres_ctx_id & 1) && $pres_ctx_id > 0 && $pres_ctx_id < 256){
      die "invalid presentation context: $pres_ctx_id";
    }
    my $abs_stx_id = shift(@_);
    $this->{presentation_contexts}->{$pres_ctx_id}->{abstract_syntax} = 
      $abs_stx_id;
    while (my $xfr_stx = shift(@_)){
      push(
        @{$this->{presentation_contexts}->{$pres_ctx_id}->{transfer_syntaxes}}, 
        $xfr_stx);
    }
  }
  sub add_sop_class_role{
    my($this, $sop_class, $is_scu, $is_scp) = @_;
    $this->{sop_class_role}->{$sop_class}->{is_scu} = $is_scu;
    $this->{sop_class_role}->{$sop_class}->{is_scp} = $is_scp;
  }
  #########################
  # From config (for testing)
  #    from_config
  sub from_config{
    my($class, $file) = @_;
    open FILE, "<$file" or die "can't open $file";
    my($calling, $called, $max_length, $num_i, $num_p);
    my @pres_ctxs;
    my %roles;
    line:
    while(my $line = <FILE>){
      chomp $line;
      if($line =~ /^#/) { next line }
      unless($line =~ /^([a-zA-Z_]+):\s*(.*)\s*$/) { next line }
      my $type = $1;
      my $fields = $2;
      my @fields_array = split(/\|/, $fields);
      if($type eq "calling"){
        $calling = $fields_array[0];
      } elsif($type eq "called"){
        $called = $fields_array[0];
      } elsif($type eq "max_length"){
        $max_length = $fields_array[0];
      } elsif($type eq "num_invoked"){
        $num_i = $fields_array[0];
      } elsif($type eq "num_performed"){
        $num_p = $fields_array[0];
      } elsif($type eq "scu_scp_role"){
        my $sop_class = $fields_array[0];
        my $scu_role = $fields_array[1];
        my $scp_role = $fields_array[2];
        $roles{$sop_class}->{scu_role} = $scu_role;
        $roles{$sop_class}->{scp_role} = $scp_role;
      } elsif(
        $type eq "storage_pres_context" ||
        $type eq "delayed_storage_pres_context" ||
        $type eq "verification_pres_context" ||
        $type eq "query_retreive_pres_context" ||
        $type eq "normalized_pres_context"
      ){
        push(@pres_ctxs, \@fields_array);
      }
    }
    close FILE;
    my $this = $class->new($calling, $called);
    if(defined $max_length){ $this->{max_length} = $max_length;}
    if(defined $num_i){ $this->add_num_invoked($num_i);}
    if(defined $num_p){ $this->add_num_performed($num_p);}
    for my $pctx (0 .. $#pres_ctxs){
      my $pc_id = ($pctx * 2) + 1;
      $this->add_pres_ctx($pc_id, @{$pres_ctxs[$pctx]});
    }
    if($ENV{POSDA_DEBUG}){
      print "NEW (from config): $this\n";
    }
    return $this;
  }
  #########################
  #  Construct from a pdu (from_pdu)
  #    parse_user_info
  #    parse_pres_cont_item
  #    from_pdu
  sub parse_user_info{
    my($this, $string) = @_;
    my $remaining = $string;
    while(length($remaining) > 0){
      my($item_type, $foo1, $item_len, $left) = unpack("CCna*", $remaining);
      if($item_type == 0x51){
        my($b, $remain) = unpack("a${item_len}a*", $left);
        my $len = unpack("N", $b);
        $this->{max_length} = $len;
        $remaining = $remain;
      } elsif ($item_type == 0x52){
        my($b, $remain) = unpack("a${item_len}a*", $left);
        $b =~ s/\0+$//;
        $this->{imp_class_uid} = $b;
        $remaining = $remain;
      } elsif ($item_type == 0x53){
        my($max_i, $max_p, $remain) = unpack("nna*", $left);
        $this->{max_i} = $max_i;
        $this->{max_p} = $max_p;
        $remaining = $remain;
      } elsif ($item_type == 0x54){
        my($uid_len, $remain) = unpack("va*", $left);
        $left = $remain;
        my($uid, $scu, $scp);
        ($uid, $scu, $scp, $remain) = unpack("a{$uid_len}CCa*", $left);
        $uid =~ s/\0$//;
        $this->{roles}->{$uid}->{scu} = $scu;
        $this->{roles}->{$uid}->{scp} = $scp;
        $remaining = $remain;
      } elsif ($item_type == 0x55){
        my($b, $remain) = unpack("a${item_len}a*", $left);
        $b =~ s/\0+$//;
        $this->{imp_ver_name} = $b;
        $remaining = $remain;
      } elsif ($item_type == 0x56){
        printf STDERR
          "Ignoring unsupported SOP Class Extended: 0x%x\n", $item_type;
      } elsif ($item_type == 0x57){
        printf STDERR
          "Ignoring unsupported SOP Class Extended: 0x%x\n", $item_type;
      } elsif ($item_type == 0x58){
        printf STDERR
          "Ignoring unsupported user identity negotiation: 0x%x\n", $item_type;
      } elsif ($item_type == 0x59){
        printf STDERR
          "Ignoring unsupported user identity negotiation: 0x%x\n", $item_type;
      } else {
        printf STDERR "Ignoring unsuppored user_info: 0x%x\n", $item_type;
      }
    }
  }
  sub parse_pres_cont_item{
    my($this, $id, $string) = @_;
    my $remaining = $string;
    while(length($remaining) > 0){
      my($item_type, $foo1, $item_len, $left) = unpack("CCna*", $remaining);
      if($item_type == 0x30){
        my($abstract_syntax, $remain) = unpack("a${item_len}a*", $left);
        $abstract_syntax =~ s/\0+$//;
        $remaining = $remain;
        $this->{presentation_contexts}->{$id}->{abstract_syntax} =
          $abstract_syntax;
      } elsif ($item_type == 0x40){
        my($transfer_syntax, $remain) = unpack("a${item_len}a*", $left);
        $transfer_syntax =~ s/\0+$//;
        push(@{$this->{presentation_contexts}->{$id}->{transfer_syntaxes}},
          $transfer_syntax);
        $remaining = $remain;
      } else {
        die sprintf "unknown item type 0x%x", $item_type;
      }
    }
  }
  sub from_pdu {
    my($class, $pdu) = @_;
    my $this = {};
    bless $this, $class;
    my $length = length($pdu);
    my($pdu_type, $foo0, $pdu_len, $ver, $foo1, $called, $calling, $foo2, $remaining) =
      unpack("CCNna[2]a[16]a[16]a[32]a*", $pdu);
    $called =~ s/\0+$//;
    $calling =~ s/\0+$//;
    $this->{ver} = $ver;
    $this->{called} = $called;
    $this->{calling} = $calling;
    my $len = length($remaining);
    while(length($remaining) > 0){
      my($item_type, $foo1, $item_len, $left) = unpack("CCna*", $remaining);
      if($item_type == 0x10){
        my($app_context, $remain) = unpack("a${item_len}a*", $left);
        $this->{app_context} = $app_context;
        $remaining = $remain;
      } elsif($item_type == 0x20 || $item_type == 0x21){
        my $content_len = $item_len - 4;
        my($pc_id, $foo1, $foo2, $foo3, $pc_content, $remain) =
          unpack("CCCCa${content_len}a*", $left);
        my $len = length($pc_content);
        $this->parse_pres_cont_item($pc_id, $pc_content);
        $remaining = $remain;
      } elsif($item_type == 0x50){
        my($user_item, $remain) = unpack("a${item_len}a*", $left);
        my $len = length($user_item);
        $this->parse_user_info($user_item);
        $remaining = $remain;
      } else {
        die sprintf "unknown item at this level: 0x%x", $item_type;
      }
    }
    bless $this, $class;
    if($ENV{POSDA_DEBUG}){
      print "NEW(from pdu): $this\n";
    }
    return $this;
  }
  #########################
  #  To DB (instantiate) and From DB (from_db)
  sub instantiate {
    my($this, $db) = @_;
    my $create_assoc_rq = $db->prepare(
      "insert into assoc_rq (\n" .
      "  arq_calling_ae_title,\n" .
      "  arq_called_ae_title,\n" .
      "  arq_app_context,\n" .
      "  arq_imp_class_uid,\n" .
      "  arq_imp_ver_name,\n" .
      "  arq_protocol_version,\n" .
      "  arq_max_length,\n" .
      "  arq_num_invoked,\n" .
      "  arq_num_performed\n" .
      ") values (\n" .
      "  ?, ?, ?, ?, ?, ?, ?, ?, ?\n" .
      ")"
    );
    $create_assoc_rq->execute( 
      $this->{calling},
      $this->{called},
      $this->{app_context},
      $this->{imp_class_uid},
      $this->{imp_ver_name},
      $this->{ver},
      $this->{max_length},
      $this->{max_i},
      $this->{max_p},
    );
    my $get_id = $db->prepare(
      "select currval('assoc_rq_assoc_rq_id_seq') as id"
    );
    $get_id->execute();
    my $h = $get_id->fetchrow_hashref();
    my $id = $h->{id};
    $this->{id} = $id;
    $get_id->finish();
    
    my $insert_rq_pres_ctx = $db->prepare(
      "insert into assoc_rq_pres_ctx(\n" .
      "  assoc_rq_id,\n" .
      "  pres_ctx_id,\n" .
      "  sop_class_uid\n" .
      ") values (\n" .
      "  ?, ?, ?\n" .
      ")"
    );
    my $insert_rq_trans_stx = $db->prepare(
      "insert into assoc_rq_xfr_stx(\n" .
      "  assoc_rq_id,\n" .
      "  pres_ctx_id,\n" .
      "  rq_xfr_stx_uid,\n" .
      "  sort_order\n" .
      ") values (\n" .
      "  ?, ?, ?, ?\n" .
      ")"
    );
    for my $pres_ctx_id (
      sort {$a <=> $b} keys %{$this->{presentation_contexts}}
    ){
      $insert_rq_pres_ctx->execute(
         $id,
         $pres_ctx_id,
         $this->{presentation_contexts}->{$pres_ctx_id}->{abstract_syntax}
      );
      my $index = 0;
      for my $trans_stx (
        @{$this->{presentation_contexts}->{$pres_ctx_id}->{transfer_syntaxes}}
      ){
        $index += 1;
        $insert_rq_trans_stx->execute(
          $id,
          $pres_ctx_id,
          $trans_stx,
          $index
        );
      }
    }
    my $insert_rq_soc_role = $db->prepare(
      "insert into assoc_rq_sop_class_role(\n" .
      "  assoc_rq_id,\n" .
      "  sop_class_uid,\n" .
      "  assoc_rq_scu_role,\n" .
      "  assoc_rq_scp_role\n" .
      ") values (\n" .
      "  ?, ?, ?, ?\n" .
      ")"
    );
    if(exists $this->{roles}){
      for my $sop_class (sort keys %{$this->{roles}}){
        $insert_rq_soc_role->execute(
          $id,
          $sop_class,
          $this->{roles}->{$sop_class}->{scu},
          $this->{sop_class_role}->{$sop_class}->{scp}
        );
      }
    }
  }
  ########################################
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
  ########################################
  sub from_db {
    my($class, $db, $id) = @_;
    my $this = {};
    my $get_assoc_rq = $db->prepare(
      "select * from assoc_rq where assoc_rq_id = ?"
    );
    $get_assoc_rq->execute($id);
    my $h = $get_assoc_rq->fetchrow_hashref();
    $get_assoc_rq->finish();
    $this->{id} = $h->{assoc_rq_id};
    $this->{calling} = $h->{arq_calling_ae_title};
    $this->{called} = $h->{arq_called_ae_title};
    $this->{app_context} = $h->{arq_app_context};
    $this->{ver} = $h->{arq_protocol_version};
    $this->{imp_class_uid} = $h->{arq_imp_class_uid};
    $this->{imp_ver_name} = $h->{arq_imp_ver_name};
    $this->{max_length} = $h->{arq_max_length};
    if(defined($h->{arq_num_invoked})){
      $this->{max_i} = $h->{arq_num_invoked};
    }
    if(defined($h->{arq_num_performed})){
      $this->{max_p} = $h->{arq_num_performed};
    }
    my $get_pres_ctx = $db->prepare(
      "select * from assoc_rq_pres_ctx where assoc_rq_id = ?"
    );
    my $get_xfr_stx = $db->prepare(
      "select * from assoc_rq_xfr_stx where assoc_rq_id = ?\n" .
      "and pres_ctx_id = ? order by sort_order"
    );
    $get_pres_ctx->execute($id);
    while(my $h = $get_pres_ctx->fetchrow_hashref()){
      my $pres_ctx_id = $h->{pres_ctx_id};
      my $sop_class_uid = $h->{sop_class_uid};
      $this->{presentation_contexts}->{$pres_ctx_id}->{abstract_syntax} = 
        $sop_class_uid;
      $get_xfr_stx->execute($id, $pres_ctx_id);
      while(my $h1 = $get_xfr_stx->fetchrow_hashref){
        push(
          @{$this->{presentation_contexts}->{$pres_ctx_id}->{transfer_syntaxes}},
          $h1->{rq_xfr_stx_uid}
        );
      }
    }
    my $get_rq_scrole = $db->prepare(
      "select * from assoc_rq_sop_class_role where assoc_rq_id = ?"
    );
    $get_rq_scrole->execute($id);
    while (my $h = $get_rq_scrole->fetchrow_hashref()){
      $this->{sop_class_role}->{$h->{sop_class_uid}}->{scu_role} = 
        $h->{assoc_rq_scu_role};
      $this->{sop_class_role}->{$h->{sop_class_uid}}->{scp_role} = 
        $h->{assoc_rq_scp_role};
    }
    bless $this, $class;
    if($ENV{POSDA_DEBUG}){
      print "NEW (from db): $this\n";
    }
    return $this;
  }
  #########################
  # Convert to a pdu (to_pdu)
  #   encode_var_field
  #   encode_app_ctx
  #   encode_max_length
  #   encode_pres_ctx
  #   encode_scu_scp_role
  #   encode_app_id
  #   encode_imp_ver_name
  #   encode_async
  #   encode_user_info
  #   to_pdu
  #
  sub encode_var_field{
    my($this, $code, $field) = @_;
    unless(defined($field)) { die "field undefined" }
    my $len = length($field);
    my $ret = pack("ccn", $code, 0, length($field));
    $ret .= $field;
    return $ret;
  }
  sub encode_app_ctx{
    my $this = shift;
    return $this->encode_var_field(0x10, $this->{app_context});
  }
  sub encode_max_length{
    my $this = shift;
    my $max_length = $this->{max_length};
    my $ret = pack("CCnN", 0x51, 0, 4, $max_length);
    return $ret;
  }
  sub encode_pres_ctx{
    my $this = shift;
    my $pl = $this->{presentation_contexts};
    my $pres_list = "";
    for my $id (sort { $a <=> $b } keys %$pl){
      my $abs_stx = $pl->{$id}->{abstract_syntax};
      if(length($abs_stx) & 1){
        $abs_stx .= "\0";
      }
      my $abs_stx_item = $this->encode_var_field(0x30, $abs_stx);
      for my $trans_syntax (@{$pl->{$id}->{transfer_syntaxes}}){
        my $xfr_item .= $this->encode_var_field(0x40, $trans_syntax);
        $abs_stx_item .= $xfr_item;
      }
      my $pres_hdr = pack("CCCC", $id, 0, 0, 0);
      my $pres_item_data = $pres_hdr . $abs_stx_item;
      $pres_list .= $this->encode_var_field(0x20, $pres_item_data);
    }
    return $pres_list;
  }
  sub encode_scu_scp_role{
    my $this = shift;
    my $ret;
    for my $sopcl (keys %{$this->{roles}}){
      my $foo = pack("n", length($sopcl)) . $sopcl .
        pack("C*",
          $this->{roles}->{$sopcl}->{scu},
          $this->{roles}->{$sopcl}->{scp}
        );
      $ret .= pack("CCnN", 0x54, 0, 4, length($foo)) . $foo;
    }
    return $ret;
  }
  sub encode_app_uid{
    my $this = shift;
    my $imp_class_uid = $this->{imp_class_uid};
    my $ret = $this->encode_var_field(0x52, $imp_class_uid);
    return $ret;
  }
  sub encode_imp_ver_name{
    my $this = shift;
    my $imp_ver_name = $this->{imp_ver_name};
    my $ret = $this->encode_var_field(0x55, $imp_ver_name);
    return $ret;
  }
  sub encode_async{
    my $this = shift;
    my $max_i = $this->{max_i};
    my $max_p = $this->{max_p};
    my $ret = pack("CCnnn", 0x53, 0, 4, $max_i, $max_p);
    return $ret;
  }
  sub encode_user_info{
    my $this = shift;
    my $content = encode_max_length($this);
    $content .= encode_app_uid($this);
    $content .= encode_imp_ver_name($this);
    if(defined $this->{max_i}){
      $content .= encode_async($this);
    }
    my $ret = $this->encode_var_field(0x50, $content);
    return $ret;
  }
  sub to_pdu{
    my $this = shift;
    my $app_ctx_item = $this->encode_app_ctx();
    my $pres_ctx_item = $this->encode_pres_ctx();
    my $user_info_item = $this->encode_user_info();
    my $var_len = length($app_ctx_item) + length($pres_ctx_item) +
       length($user_info_item);;
    my $pdu_len = $var_len + 2 + 2 + 16 + 16 + 32;
    my $calling = $this->{calling};
    my $called = $this->{called};
    if (length($calling) > 16) { die "Calling is too long" }
    if (length($called) > 16) { die "Called is too long" }
    my $hdr = pack("ccNnna[16]a[16]",
       ref($this) eq "Dispatch::Dicom::AssocAc" ? 2 : 1, 0, $pdu_len,
       $this->{ver}, 0, $called, $calling);
    my $mess = $hdr . "\0" x 32 . $app_ctx_item . $pres_ctx_item .
      $user_info_item;
    return $mess;
  }
  #########################
  # DumpGuts
  #
  sub DumpGuts {
    my($this, $out) = @_;
    my $class = ref($this);
    my $instance_id = "<uninstantiated>";
    if(exists $this->{id}){
      $instance_id = $this->{id};
    }
    print $out "##########################\n";
    print $out "Instance ($instance_id) of $class:\n";
    print $out "\tCalled AE Title: $this->{called}\n";
    print $out "\tCalling AE Title: $this->{calling}\n";
    print $out "\tApplication Context UID: $this->{app_context}\n";
    print $out "\tProtocol Version: $this->{ver}\n";
    print $out "\tImplementation Class UID: $this->{imp_class_uid}\n";
    print $out "\tImplementation Version name: $this->{imp_ver_name}\n";
    print $out "\tMax Length: $this->{max_length}\n";
    if(defined $this->{max_i}){
      print $out "\tMax Invoked: $this->{max_i}\n";
    }
    if(defined $this->{max_p}){
      print $out "\tMax Performed: $this->{max_p}\n";
    }
    for my $pc_id (sort {$a <=> $b} keys %{$this->{presentation_contexts}}){
      print $out "\tPresentation Context $pc_id:\n";
      print $out "\t\tAbstract Syntax UID: " .
        $this->{presentation_contexts}->{$pc_id}->{abstract_syntax} . 
        "\n\t\tTransfer Syntaxes:\n";
      for my $trans_stx (
        @{$this->{presentation_contexts}->{$pc_id}->{transfer_syntaxes}}
      ){
        print $out "\t\t\t$trans_stx\n";
      }
    }
    if(exists $this->{roles}){
      print $out "\tSop Class Roles:\n";
      for my $sop_class (keys %{$this->{roles}}){
        print $out "\t\t$sop_class:\n";
        print $out
          "\t\t\tScu: $this->{roles}->{$sop_class}->{scu}\n";
        print $out
          "\t\t\tScp: $this->{roles}->{$sop_class}->{scp}\n";
      }
    }
    print $out "##########################\n";
  }
  #########################
  # DESTROY
  #
  sub DESTROY{
    my($this) = @_;
    if($ENV{POSDA_DEBUG}){
      print "DESTROY: $this\n";
    }
  }
}
1;

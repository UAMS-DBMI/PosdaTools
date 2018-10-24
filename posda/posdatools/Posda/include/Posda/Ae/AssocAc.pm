#!/usr/bin/perl -w

use strict;
{
  ########################################
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
  ########################################

  package Posda::Ae::AssocAc;
  ########################################
  # Create and populate
  #  new
  #  add_num_invoked
  #  add_num_performed
  #  add_pres_ctx
  #  add_sop_class_role
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
    my($this, $id, $result, $xfr_stx) = @_;
    unless(($id & 1) && $id > 0 && $id < 256){
      die "invalid presentation context: $id";
    }
    $this->{presentation_contexts}->{$id}->{result} = $result;
    $this->{presentation_contexts}->{$id}->{transfer_syntax} = $xfr_stx;
  }
  sub add_sop_class_role{
    my($this, $sop_class, $is_scu, $is_scp) = @_;
    $this->{sop_class_role}->{$sop_class}->{is_scu} = $is_scu;
    $this->{sop_class_role}->{$sop_class}->{is_scp} = $is_scp;
  }
  ########################################
  # from_config (for testing)
  #
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
      } elsif($type eq "pres_context"){
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
      $this->add_pres_ctx(@{$pres_ctxs[$pctx]});
    }
    if($ENV{POSDA_DEBUG}){
      print "NEW (from config): $this\n";
    }
    return $this;
  }

  #########################
  # from_pdu
  #   parse_user_info
  #   parse_pres_cont_item
  #   from_pdu
  #   
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
    my($this, $id, $reason, $string) = @_;
    my $remaining = $string;
    while(length($remaining) > 0){
      my($item_type, $foo1, $item_len, $left) = unpack("CCna*", $remaining);
      if($item_type == 0x30){
        die "Assoc-AC can't have abstract syntax";
      } elsif ($item_type == 0x40){
        my($transfer_syntax, $remain) = unpack("a${item_len}a*", $left);
        $transfer_syntax =~ s/\0+$//;
        if(exists $this->{presentation_contexts}->{$id}){
          print STDERR "more than one ts in a pres_contx\n";
        }
        $this->{presentation_contexts}->{$id}->{result} = $reason;
        $this->{presentation_contexts}->{$id}->{transfer_syntax} = 
          $transfer_syntax;
        $remaining = $remain;
      } else {
        die sprintf "unknown item type 0x%x", $item_type;
      }
      if($remaining ne '') { die "data after xfer_stax in pc_item in assoc_ac" }
    }
  }
  sub from_pdu {
    my($class, $pdu) = @_;
    my $this = {};
    bless $this, $class;
    my $length = length($pdu);
    my($pdu_type, $foo0, $pdu_len, $ver, $foo1, $called, $calling, 
      $foo2, $remaining) = unpack("CCNna[2]a[16]a[16]a[32]a*", $pdu);
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
      } elsif($item_type == 0x20){
        die "assoc_ac shouldn't have item 0x20";
      } elsif($item_type == 0x21){
        my $content_len = $item_len - 4;
        my($pc_id, $foo1, $result, $foo3, $pc_content, $remain) =
          unpack("CCCCa${content_len}a*", $left);
        my $len = length($pc_content);
        $this->parse_pres_cont_item($pc_id, $result, $pc_content);
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
  # to and from db
  #   instantiate
  #   from_db
  #
  sub instantiate {
    my($this, $db) = @_;
    my $create_assoc_ac = $db->prepare(
      "insert into assoc_ac (\n" .
      "  aac_calling_ae_title,\n" .
      "  aac_called_ae_title,\n" .
      "  aac_app_context,\n" .
      "  aac_imp_class_uid,\n" .
      "  aac_imp_ver_name,\n" .
      "  aac_protocol_version,\n" .
      "  aac_max_length,\n" .
      "  aac_num_invoked,\n" .
      "  aac_num_performed\n" .
      ") values (\n" .
      "  ?, ?, ?, ?, ?, ?, ?, ?, ?\n" .
      ")"
    );
    $create_assoc_ac->execute( 
      $this->{calling},
      $this->{called},
      $this->{app_context},
      $this->{imp_class_uid},
      $this->{imp_ver_name},
      $this->{ver},
      $this->{max_length},
      $this->{max_i},
      $this->{max_p}
    );
    my $get_id = $db->prepare(
      "select currval('assoc_ac_assoc_ac_id_seq') as id"
    );
    $get_id->execute();
    my $h = $get_id->fetchrow_hashref();
    my $id = $h->{id};
    $this->{id} = $id;
    $get_id->finish();
    
    my $insert_ac_pres_ctx = $db->prepare(
      "insert into assoc_ac_pres_ctx(\n" .
      "  assoc_ac_id,\n" .
      "  pres_ctx_id,\n" .
      "  assoc_ac_pc_result,\n" .
      "  aac_xfr_stx_uid\n" .
      ") values (\n" .
      "  ?, ?, ?, ?\n" .
      ")"
    );
    for my $pres_ctx_id (
      sort {$a <=> $b} keys %{$this->{presentation_contexts}}
    ){
      $insert_ac_pres_ctx->execute(
         $id,
         $pres_ctx_id,
         $this->{presentation_contexts}->{$pres_ctx_id}->{result},
         $this->{presentation_contexts}->{$pres_ctx_id}->{transfer_syntax}
      );
    }
    my $insert_ac_soc_role = $db->prepare(
      "insert into assoc_ac_sop_class_role(\n" .
      "  assoc_ac_id,\n" .
      "  sop_class_uid,\n" .
      "  assoc_ac_scu_role,\n" .
      "  assoc_ac_scp_role\n" .
      ") values (\n" .
      "  ?, ?, ?, ?\n" .
      ")"
    );
    for my $sop_class (sort keys %{$this->{sop_class_role}}){
      $insert_ac_soc_role->execute(
        $id,
        $sop_class,
        $this->{roles}->{$sop_class}->{scu},
        $this->{roles}->{$sop_class}->{scp}
      );
    }
  }
  sub from_db {
    my($class, $db, $id) = @_;
    my $this = { id => $id };
    my $get_assoc_ac = $db->prepare(
      "select * from assoc_ac where assoc_ac_id = ?"
    );
    $get_assoc_ac->execute($id);
    my $h = $get_assoc_ac->fetchrow_hashref();
    $get_assoc_ac->finish();
    $this->{calling} = $h->{aac_calling_ae_title};
    $this->{called} = $h->{aac_called_ae_title};
    $this->{app_context} = $h->{aac_app_context};
    $this->{imp_ver_name} = $h->{aac_imp_ver_name};
    $this->{imp_class_uid} = $h->{aac_imp_class_uid};
    $this->{ver} = $h->{aac_protocol_version};
    $this->{max_length} = $h->{aac_max_length};
    if(defined($h->{aac_num_invoked})){
      $this->{max_i} = $h->{aac_num_invoked};
    }
    if(defined($h->{aac_num_performed})){
      $this->{max_p} = $h->{aac_num_performed};
    }
    my $get_pres_ctx = $db->prepare(
      "select * from assoc_ac_pres_ctx where assoc_ac_id = ?"
    );
    $get_pres_ctx->execute($id);
    while(my $h = $get_pres_ctx->fetchrow_hashref()){
      my $pres_ctx_id = $h->{pres_ctx_id};
      my $result = $h->{assoc_ac_pc_result};
      my $xfr_stx = $h->{aac_xfr_stx_uid};
      $this->{presentation_contexts}->{$pres_ctx_id}->{result} = $result;
      $this->{presentation_contexts}->{$pres_ctx_id}->{transfer_syntax} = 
        $xfr_stx;
    }
    my $get_ac_scrole = $db->prepare(
      "select * from assoc_ac_sop_class_role where assoc_ac_id = ?"
    );
    $get_ac_scrole->execute($id);
    while (my $h = $get_ac_scrole->fetchrow_hashref()){
      $this->{roles}->{$h->{sop_class_uid}}->{scu} = 
        $h->{assoc_ac_scu_role};
      $this->{roles}->{$h->{sop_class_uid}}->{scp} = 
        $h->{assoc_ac_scp_role};
    }
    bless $this, $class;
    if($ENV{POSDA_DEBUG}){
      print "NEW (from db): $this\n";
    }
    return $this;
  }
  #########################
  # to_pdu
  #   encode_var_field
  #   encode_app_ctx
  #   encode_max_length
  #   encode pres_ctx
  #   encode_scu_scp_role
  #   encode_app_uid
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
      my $result = $pl->{$id}->{result};
      my $trans_syntax = $pl->{$id}->{transfer_syntax};
      my $xfr_item .= $this->encode_var_field(0x40, $trans_syntax);
      my $pres_hdr = pack("CCCC", $id, 0, $result, 0);
      my $pres_item_data = $pres_hdr . $xfr_item;
      $pres_list .= $this->encode_var_field(0x21, $pres_item_data);
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
    if(exists $this->{max_i}){
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
    my $hdr = pack("ccNnna[16]a[16]", 2, 0, $pdu_len,
       $this->{ver}, 0, $called, $calling);
    my $mess = $hdr . "\0" x 32 . $app_ctx_item . $pres_ctx_item .
      $user_info_item;
    return $mess;
  }
  #########################
  # DumpGuts
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
      print $out "\t\tResult: ";
      my $result = $this->{presentation_contexts}->{$pc_id}->{result};
      if($result < 0 || $result > 4){
        print $out "<invalid>\n";
      } else {
        my $value = [ "acceptance", "user-rejection", "no-reason",
          "abstract-syntax-not-supported",
          "transfer_syntaxes-not-supported" ]->[$result];
        print $out "$value\n";
      }
      print $out "\t\tTransfer Syntax: " .
        $this->{presentation_contexts}->{$pc_id}->{transfer_syntax} . "\n";
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
  sub DESTROY{
    my($this) = @_;
    if($ENV{POSDA_DEBUG}){
      print "DESTROY: $this\n";
    }
  }
}
1;

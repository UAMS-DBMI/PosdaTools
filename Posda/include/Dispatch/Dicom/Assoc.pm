#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Dispatch/Dicom/Assoc.pm,v $
#$Date: 2014/01/16 15:52:37 $
#$Revision: 1.10 $

use strict;
{
  package Dispatch::Dicom::AssocEncoder;
  sub encode_var_field{
    my($this, $code, $field) = @_;
    unless(defined($field)) { die "field undefined" }
    my $len = length($field);
#    if($len & 1){
#      $field = $field . "\0";
#    }
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
  sub encode_scu_scp_role{
    my $this = shift;
    my $ret;
    for my $sopcl (keys %{$this->{roles}}){
#      if(length($sopcl) & 1){
#        $sopcl .= "\0";
#      }
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
  sub encode{
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
#    if(length($calling) < 16) { $calling .= " " x (16 - length($calling)) }
#    if(length($called) < 16) { $called .= " " x (16 - length($called)) }
    my $hdr = pack("ccNnna[16]a[16]",
       ref($this) eq "Dispatch::Dicom::AssocAc" ? 2 : 1, 0, $pdu_len,
       $this->{ver}, 0, $called, $calling);
    my $mess = $hdr . "\0" x 32 . $app_ctx_item . $pres_ctx_item . 
      $user_info_item;
    return $mess;
  }
}
{
  package Dispatch::Dicom::AssocParser;
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
        ($uid, $scu, $scp, $remain) = unpack("a${uid_len}CCa*", $left);
        $uid =~ s/\0$//;
        $this->{roles}->{$uid}->{scu} = $scu;
        $this->{roles}->{$uid}->{scp} = $scp;
        $remaining = $remain;
      } elsif ($item_type == 0x55){
        my($b, $remain) = unpack("a${item_len}a*", $left);
        $b =~ s/\0+$//;
        $this->{imp_version_name} = $b;
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
  sub new_from_pdu{
    my($class, $pdu) = @_;
    my $this = {
    };
    bless $this, $class;
    my $length = length($pdu);
    my($ver, $foo1, $called, $calling, $foo2, $remaining) =
      unpack("na[2]a[16]a[16]a[32]a*", $pdu);
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
        my($pc_id, $foo1, $rr, $foo3, $pc_content, $remain) = 
          unpack("CCCCa${content_len}a*", $left);
        my $len = length($pc_content);
        $this->parse_pres_cont_item($pc_id, $pc_content, $rr);
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
    if($ENV{POSDA_DEBUG}){
      print "NEW: $this\n";
    }
    return $this;
  }
  sub DESTROY{
    my($this) = @_;
    if($ENV{POSDA_DEBUG}){
      print "DESTROY: $this\n";
    }
  }
}
{
  package Dispatch::Dicom::AssocAc;
  use vars qw( @ISA );
  @ISA = ( "Dispatch::Dicom::AssocEncoder", "Dispatch::Dicom::AssocParser" );
  sub new {
    my $class = shift;
    my $this = {
    };
    bless $this, $class;
    if($ENV{POSDA_DEBUG}){
      print "NEW: $this\n";
    }
    return $this;
  }
  sub parse_pres_cont_item{
    my($this, $id, $string, $rr) = @_;
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
        $this->{presentation_contexts}->{$id} = $transfer_syntax;
        $remaining = $remain;
        if($rr){
          $this->{rejected_pc}->{$id} = $rr;
          if(exists $this->{presentation_contexts}->{$id}){
            print STDERR "Abstract Syntax: " .
              "$this->{presentation_contexts}->{$id} for " .
              "rejected presentation context\n";
            ###############
            #  This is a temp fix for Osirix
            #  Crap in this place SHOULD be ignored, not parsed
            #  fix this later...
            ###############
            $this->{presentation_contexts}->{$id} = "";
          }
        }
      } else {
        die sprintf "unknown item type 0x%x", $item_type;
      }
    }
  }
  sub encode_pres_ctx{
    my $this = shift;
    my $pl = $this->{presentation_contexts};
    my $pres_list = "";
    for my $id (sort { $a <=> $b } keys %$pl){
      my $result = 0;
      my $trans_syntax = "";
      if(defined($pl->{$id})){
        $trans_syntax = $pl->{$id};
      } else {
        if(exists($this->{rejected_pc}->{$id}) && $this->{rejected_pc}->{$id}){
          $result = $this->{rejected_pc}->{$id};
        } else {
          $result = 1;
        }
      }
      my $xfr_item .= $this->encode_var_field(0x40, $trans_syntax);
      my $pres_hdr = pack("CCCC", $id, 0, $result, 0);
      my $pres_item_data = $pres_hdr . $xfr_item;
      $pres_list .= $this->encode_var_field(0x21, $pres_item_data);
    }
    return $pres_list;
  }
  #encodes an a_assoc_rq into DICOM format
  sub new_from_rq_desc {
    my($class, $req, $desc) = @_;
    my $this = Dispatch::Dicom::AssocAc->new;
    $this->{ver} = $desc->{protocol_version};
    $this->{called} = $req->{called};
    $this->{calling} = $req->{calling};
    $this->{app_context} = $desc->{app_context};
    if(exists $req->{imp_class_uid}){
      $this->{imp_class_uid} = $desc->{imp_class_uid};
      $this->{imp_ver_name} = $desc->{imp_ver_name};
    }
    $this->{max_length} = $desc->{max_length};
    pc_id:
    for my $pc_id (keys %{$req->{presentation_contexts}}){
      my $config = $desc->{pres_contexts};
      my $pc = $req->{presentation_contexts}->{$pc_id};
      my $abs_stx = $pc->{abstract_syntax};
      $this->{presentation_contexts}->{$pc_id} = undef;
      unless(exists $config->{$abs_stx}){
        $this->{rejected_pc}->{$pc_id} = 3;
        next pc_id;
      }
      transfer_syntax:
      for my $ts (@{$pc->{transfer_syntaxes}}){
        if(exists $config->{$abs_stx}->{$ts}){
          $this->{presentation_contexts}->{$pc_id} = $ts;
          last transfer_syntax;
        }
        unless(defined $this->{presentation_contexts}->{$pc_id}){
          $this->{rejected_pc}->{$pc_id} = 4;
        }
      }
    }
    if(exists($req->{max_i})){
      if(exists($desc->{num_performed})){
        if($req->{max_i} == 0){
          $req->{max_i} = $desc->{num_performed};
        }
        $this->{max_p} = ($req->{max_i} < $desc->{num_performed}) ?
          $req->{max_i} : $desc->{num_performed};
      }
    }
    if(exists($req->{max_p})){
      if(exists($desc->{num_invoked})){
        if($req->{max_p} == 0){
          $req->{max_p} = $desc->{num_invoked};
        }
        $this->{max_i} = ($req->{max_p} < $desc->{num_invoked}) ?
          $req->{max_p} : $desc->{num_performed};
      }
    }
    bless $this, $class;
    if($ENV{POSDA_DEBUG}){
      print "NEW: $this\n";
    }
    return $this;
  }
  sub DESTROY{
    my($this) = @_;
    if($ENV{POSDA_DEBUG}){
      print "DESTROY: $this\n";
    }
  }
}
{
  package Dispatch::Dicom::AssocRj;
  sub new{
    my($class, $result, $source, $reason) = @_;
    my $this = {
      result => $result,
      source => $source,
      reason => $reason,
    };
    bless $this, $class;
    if($ENV{POSDA_DEBUG}){
      print "NEW: $this\n";
    }
    return $this;
  }
  sub new_from_pdu{
    my($class, $pdu) = @_;
    my($foo, $result, $source, $reason) = unpack("cccc", $pdu);
    my $this = {
      result => $result,
      source => $source,
      reason => $reason,
    };
    return bless $this, $class;
  }
  sub encode{
    my($this) = @_;
    my $string = pack("ccNN", 3, $this->{result}, $this->{source},
       $this->{reason});
    return $string;
  }
}
{
  package Dispatch::Dicom::ReleaseRq;
  sub new{
    my($class, $string) = @_;
    my $this = {
    };
    bless $this, $class;
    if($ENV{POSDA_DEBUG}){
      print "NEW: $this\n";
    }
    return $this;
  }
  sub encode{
    my($this) = @_;
    my $string = pack("ccNN", 5, 0, 4, 0);
    return $string;
  }
}
{
  package Dispatch::Dicom::ReleaseRp;
  sub new{
    my($class, $req) = @_;
    my $this = {
    };
    bless $this, $class;
    if($ENV{POSDA_DEBUG}){
      print "NEW: $this\n";
    }
    return $this;
  }
  sub encode{
    my($this) = @_;
    my $string = pack("ccNN", 6, 0, 4, 0);
    return $string;
  }
}
{
  package Dispatch::Dicom::Abort;
  sub new{
    my($class, $source, $reason) = @_;
    my $this = {
      source => $source,
      reason => $reason,
    };
    bless $this, $class;
    if($ENV{POSDA_DEBUG}){
      print "NEW: $this\n";
    }
    return $this;
  }
  sub encode{
    my($this) = @_;
    my $source = $this->{source};
    my $reason = 0;
    if($source == 2){
      $reason = $this->{reason};
    }
    my $string = pack("ccNcccc", 7, 0, 4, 0, 0, $source, $reason);
    return $string;
  }
}
{
  package Dispatch::Dicom::AssocRq;
  use vars qw( @ISA );
  @ISA = ( "Dispatch::Dicom::AssocEncoder", "Dispatch::Dicom::AssocParser" );
  sub new {
    my $class = shift;
    my $this = {
    };
    bless $this, $class;
    if($ENV{POSDA_DEBUG}){
      print "NEW: $this\n";
    }
    return $this;
  }
  sub new_from_descrip{
    my($class, $descrip) = @_;
    bless $descrip, $class;
    if($ENV{POSDA_DEBUG}){
      print "NEW: $descrip\n";
    }
    return $descrip;
  }
  sub new_from_file {
    my $class = shift;
    my $file = shift;
    my $dcm_conn = shift;
    my $overrides = shift;
    my $this = Dispatch::Dicom::AssocRq->new();
    open FILE, "<$file" or die "can't open $file";
    my $pc_id = 1;
    line:
    while(my $line = <FILE>){
      chomp $line;
      if($line =~ /^#/) { next line }
      unless($line =~ /^([a-z_]+):\s*(.*)\s*$/) { next line }
      my $type = $1;
      my $fields = $2;
      my @fields_array = split(/\|/, $fields);
      if($type eq "calling_ae_title"){
        $this->{calling} = $fields_array[0];
      } elsif($type eq "called_ae_title"){
        $this->{called} = $fields_array[0];
      } elsif($type eq "app_context"){
        $this->{app_context} = $fields_array[0];
      } elsif($type eq "imp_class_uid"){
        $this->{imp_class_uid} = $fields_array[0];
      } elsif($type eq "imp_ver_name"){
        $this->{imp_ver_name} = $fields_array[0];
      } elsif($type eq "protocol_version"){
        $this->{ver} = $fields_array[0];
      } elsif($type eq "max_length"){
        $this->{max_length} = $fields_array[0];
      } elsif($type eq "num_invoked"){
        $this->{max_i} = $fields_array[0];
      } elsif($type eq "num_performed"){
        $this->{max_p} = $fields_array[0];
      } elsif($type eq "storage_root"){
        $dcm_conn->{storage_root} = $fields_array[0];
      } elsif(
        $type eq "storage_pres_context" ||
        $type eq "verification_pres_context"
      ){
        my $pc_item = {
        };
        $pc_item->{abstract_syntax} =  $fields_array[0];
        for my $i (1 .. $#fields_array){
          push(@{$pc_item->{transfer_syntax}}, $fields_array[$i]);
        }
        $this->{presentation_contexts}->{$pc_id} = $pc_item;
        if($type eq "storage_pres_context"){
          $dcm_conn->{incoming_message_handler}->{$fields_array[0]} =
            "Dispatch::Dicom::Storage";
        } elsif($type eq "verification_pres_context"){
          $dcm_conn->{incoming_message_handler}->{$fields_array[0]} =
            "Dispatch::Dicom::Verification";
        }
        $pc_id += 2;
      }
    }
    close FILE;
    if($overrides && ref($overrides) eq "HASH"){
      for my $i (keys %$overrides){
        if(exists $this->{$i}) { $this->{$i} = $overrides->{$i} }
      }
    }
    bless $this, $class;
    if($ENV{POSDA_DEBUG}){
      print "NEW: $this\n";
    }
    return $this;
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
      for my $trans_syntax (@{$pl->{$id}->{transfer_syntax}}){
        my $xfr_item .= $this->encode_var_field(0x40, $trans_syntax);
        $abs_stx_item .= $xfr_item;
      }
      my $pres_hdr = pack("CCCC", $id, 0, 0, 0);
      my $pres_item_data = $pres_hdr . $abs_stx_item;
      $pres_list .= $this->encode_var_field(0x20, $pres_item_data);
    }
    return $pres_list;
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
  sub DESTROY{
    my($this) = @_;
    if($ENV{POSDA_DEBUG}){
      print "DESTROY: $this\n";
    }
  }
}
1;

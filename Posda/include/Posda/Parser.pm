#
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
package Posda::Parser;
use FileHandle;
my $native_moto = 
  (unpack("S", pack("C2", 1, 2)) == 0x0102) ? 1 : 0;

# $info = {
#    stream => $stream,                    #param (unchanging recursively)
#    xfrstx => <xfrstx>,                   #param (unchanging recursively)
#    seekable => <boolean>,                #param (unchanging recursively)
#    filename => <file_name>,              #param (unchanging recursively)
#                                          #       may be undef
#    skip_large => <n>,                    #param (only if filename and
#                                          #       seekable) n is size
#                                          #       above which to skip
#    length => <length_remain>,            #param (changing recursively)
#                                          #       may be undef (delimited)
#    delim => <boolean>,                   #param (changing recursively)
#    explicit => <boolean>,                #based on xfrstx
#    vax => <boolean>,                     #based on xfrstx
#    short_len => <boolean>,               #based on xfrstx
#    encap => <boolean>,                   #based on xfrstx
#    vm => <vm>                            #(changing - based on element)
#    vr => <vr>,                           #(changing - based on element)
#    grp => <grp>,                         #(changing - based on element)
#    ele => <ele>,                         #(changing - based on element)
#    ele_len => <len>,                     #(changing - based on element)
#    tag => "sig",                         #(changing - based on element)
#    ele_value => <ele_value>,             #(changing - based on element)
#    ele_offset => <ele_offset>,           #(changing - based on element)
#    parent_tag => "sig",                  #(initially null - built recursively)
#    errors => <accum_list>,               #where errors accumlate (list)
#    ele_handler => <\&fun>,               #pointer to function to handle an
#                                          #   element
#    extremely_verbose => 1,               #If you want EXTREMELY verbose
#                                          #  output on STDERR while parsing
#                                          #  (unchanging recursively)
#};
my $ParserCount = 0;

# Utilities
sub upd_len{
  my($this, $len) =@_;
  if(defined $this->{length}){
    $this->{length} -= $len;
  }
  $this->{length_read} += $len;
}
sub check_len{
  my($this, $len) = @_;
  if(defined $this->{length} && $len > $this->{length}) {return 0};
  return 1;
}

#
# ReadElementHeader($this)
#
# On entry (used only):
#$this = {
#   stream => <stream from which header is read>,
#   length => undef (in variable length read) | <length remaining in dataset>,
#   vax => 1 if little-endian; 0 if big-endian,
#   explicit => 1 if explicit xfrstx; 0 if implicit,
#   short_len => 1 if shortlen explict; 0 if not,
#};
# On exit (changed only):
#$info = {
#   length => undef (in variable length read) | 
#              <updated length remaining in dataset>,
#   grp => <group (integer)>,
#   ele => <ele (integer)>,
#   tag => <"(gggg,eeee)">,
#   ele_len => undef (if ffffffff); <ele_len> otherwise,
#   vr => <vr>,
#};
# 
sub ReadElementHeader {
  my $this = shift;
  my $length_read = 0;
  my $file_pos = $this->{stream}->tell;
  #############################################################
  ### experimental checkpointing for bad explicit length
  $this->{prev_checkpoint} = $this->{checkpoint};
  $this->{checkpoint} = {
    file_pos => $file_pos,
    length => $this->{length},
    length_read => $this->{length_read},
  };
  if($this->{in_checkpoint}){
    $this->{prev_in_checkpoint} = 1;
    delete $this->{in_checkpoint};
  } else {
    delete $this->{prev_in_checkpoint};
  }
  delete $this->{in_checkpoint};
  #############################################################
  unless(check_len($this, 6)) { 
    if($this->{tag} =~ /^\(0002,/){
      my $lacking = 6 - $this->{length};
      die "It looks like the meta header group length is at least $lacking " .
        "bytes too short.\n" .
        "Someday there may be an ugly hack here (and elsewhere) to try and " .
        "continue in\n" .
        "spite of this.\n\n" .
        "Today, however, is not that day.\n\n" .
        "FixMetaHeaderGroupLength.pl, may be of some use.\n\n" .
        "It has been used to repair files which fail in this way.\n\n" .
        "  --";
    }
    my $msg = "($this->{length})";
    if(defined $this->{tag}) { $msg .= " after $this->{tag}"; }
    die "not enough length to read element header $msg\n\n --" 
  }
  my $buf;
  my $len = read($this->{stream}, $buf, 4);
  unless(defined $len) { die "couldn't read from stream\n\n --" }
  unless($len == 4) { 
    die "couldn't read group, ele, len = $len " .
    "length = $this->{length}\n\n --"; 
  }
  upd_len($this, 4);
  my($group, $ele, $vr, $vm);
  $vm = 1;
  if($this->{vax}){
    ($group, $ele) = unpack("v2", $buf);
  } else {
    ($group, $ele) = unpack("n2", $buf);
  }
  $this->{grp} = $group;
  $this->{ele} = $ele;
  $this->{tag} = sprintf("(%04x,%04x)", $group, $ele);
  if($this->{extremely_verbose}){
    print STDERR "tag: $this->{parent_tag}$this->{tag}";
    print STDERR " at $file_pos ";
  }
  if($this->{explicit} && $group != 0xfffe){
    $len = read($this->{stream}, $vr, 2);
    unless($len == 2){ 
      die "unable to read explicit VR ($this->{length})\n\n --"
    }
    upd_len($this, 2);
    unless(exists $Posda::Dataset::DD->{VRDesc}->{$vr}){
      ##  Horrible kludge for trailing nulls
      if($group == 0 && $ele == 0){
        $this->{possible_trailing_nulls} = 1;
        return;
      }
      my $length = "";
      if(defined $this->{length}) {$length = $this->{length} }
      #############################################################
      ### experimental checkpoint invocation - bad explicit length??
      if(
        exists $this->{prev_checkpoint} &&
        !exists($this->{last_in_checkpoint})
      ){
        my $check_file_pos = $this->{prev_checkpoint}->{file_pos};
        $this->{length} = $this->{prev_checkpoint}->{length};
        $this->{length_read} = $this->{prev_checkpoint}->{length_read};
        $this->{in_checkpoint} = 1;
        unless(defined($this->{stream})){
          die "$this->{tag}: Stream undefined";
        }
        unless(defined($check_file_pos)){
          die "$this->{tag}: prev_checkpoint defined but no check_file_pos";
        }
        seek($this->{stream}, $check_file_pos, 0);
        $file_pos = $check_file_pos;
        if($this->{extremely_verbose}){
          print STDERR "Return to header here ($check_file_pos)\n";
        }
        my $buf;
        my $len = read($this->{stream}, $buf, 4);
        unless(defined $len) { die "couldn't read from stream\n\n --" }
        unless($len == 4) { 
          die "couldn't read group, ele, len = $len " .
          "length = $this->{length}\n\n --"; 
        }
        upd_len($this, 4);
        $vm = 1;
        if($this->{vax}){
          ($group, $ele) = unpack("v2", $buf);
        } else {
          ($group, $ele) = unpack("n2", $buf);
        }
        $this->{grp} = $group;
        $this->{ele} = $ele;
        $this->{tag} = sprintf("(%04x,%04x)", $group, $ele);
        if($this->{extremely_verbose}){
          print STDERR "tag: $this->{parent_tag}$this->{tag}";
          print " at $file_pos ";
        }
        push(@{$this->{errors}}, 
          "retrying tag $this->{parent_tag}$this->{tag} with length + 65536");
        $this->{in_checkpoint} = 1;
        $len = read($this->{stream}, $vr, 2);
        unless($len == 2){ 
          die "unable to read explicit VR ($this->{length})\n\n --"
        }
        upd_len($this, 2);
        $this->{vr} = $vr;
      } else {
        if($this->{extremely_verbose}){
          print STDERR "\n";
        }
        die sprintf "unknown explicit VR: '%s' (%04x, %04x) ($length)\n\n --", 
          $vr, $group, $ele;
      }
      #############################################################
      #die sprintf "unknown explicit VR: '%s' (%04x, %04x) ($length)\n\n --", 
    }
    if(
      exists($Posda::Dataset::DD->{Dict}->{$group}->{$ele}->{VR}) &&
      $Posda::Dataset::DD->{Dict}->{$group}->{$ele}->{VR} ne $vr
    ){
      unless(
#        $vr =~ /^O/ && 
        $Posda::Dataset::DD->{Dict}->{$group}->{$ele}->{VR} eq "OT"
      ){
        my $dd_vr = $Posda::Dataset::DD->{Dict}->{$group}->{$ele}->{VR};
        unless(defined $dd_vr) { $dd_vr = "<undefined>" }
        my $err_msg = "Explicit VR ($vr) for tag " .
          (defined $this->{parent_tag} ? 
            $this->{parent_tag} : "<Parent Tag Unknown>") .
          (defined $this->{tag} ? 
            $this->{tag} : "<Tag Unknown>") . 
          " doesn't match " .
          "DD ($dd_vr)" .
          " (coerced/recast ?)";
        print STDERR "Parser::ReadElementHeader: " . $err_msg . "\n";
        push(@{$this->{errors}}, $err_msg);
        unless($dd_vr eq "<undefined>"){
          $this->{vr_to_convert_to} = $dd_vr;
        }
      }
    }
  } elsif ($group != 0xfffe) {
    if(exists($Posda::Dataset::DD->{Dict}->{$group}->{$ele}->{VR})){
      $vr = $Posda::Dataset::DD->{Dict}->{$group}->{$ele}->{VR};
    } else {
      $vr = "UN";
    }
  }
  $this->{vr} = $vr;
  if($group != 0xfffe){
    if($vr && exists($Posda::Dataset::DD->{VRDesc}->{$vr}->{type})){
      $this->{type} = $Posda::Dataset::DD->{VRDesc}->{$vr}->{type};
    } else {
      die "Unknown type for VR: $vr $this->{tag}";
    }
    if(exists $Posda::Dataset::DD->{Dict}->{$group}->{$ele}->{VM}){
      $this->{vm} = $Posda::Dataset::DD->{Dict}->{$group}->{$ele}->{VM};
    } else {
      $this->{vm} = 1;
    }
  }
  my $elelen;
  if($this->{explicit} && $group != 0xfffe && 
    (
      (
        $vr eq "OB" ||
        $vr eq "OW" ||
        $vr eq "OF" ||
        $vr eq "SQ" ||
        $vr eq "UT" ||
        $vr eq "UN" 
      ) ||
      !$this->{short_len}
    )
  ){
    unless(check_len($this, 6)){
      die "not enough length ($this->{length}) to read element length";
    }
    $len = read($this->{stream}, $buf, 6);
    unless($len == 6){ die "unable to read element length ($this->{length})" };
    upd_len($this, 6);
    my $zr;
    if($this->{vax}){
      ($zr, $elelen) = unpack("vV", $buf);
    } else {
      ($zr, $elelen) = unpack("nN", $buf);
    }
  } elsif($this->{explicit} && $group == 0xfffe) {
    unless(check_len($this, 4)){
      die "not enough length ($this->{length}) to read element length";
    }
    $len = read($this->{stream}, $buf, 4);
    unless($len == 4){ die "unable to read element length ($this->{length})" };
    upd_len($this, 4);
    if($this->{vax}){
      ($elelen) = unpack("V", $buf);
    } else {
      ($elelen) = unpack("N", $buf);
    }
  } elsif($this->{explicit} && $this->{short_len}) {
    unless(check_len($this, 2)){
      die "not enough length ($this->{length}) to read element length";
    }
    $len = read($this->{stream}, $buf, 2);
    unless($len == 2){ die "unable to read element length ($this->{length})" };
    upd_len($this, 2);
    if($this->{vax}){
      ($elelen) = unpack("v", $buf);
    } else {
      ($elelen) = unpack("n", $buf);
    }
  } else {
    unless(check_len($this, 4)){
      die "not enough length ($this->{length}) to read element length";
    }
    $len = read($this->{stream}, $buf, 4);
    unless($len == 4){ die "unable to read element length ($this->{length})" };
    upd_len($this, 4);
    if($this->{vax}){
      ($elelen) = unpack("V", $buf);
    } else {
      ($elelen) = unpack("N", $buf);
    }
  }
  if($elelen == 0xffffffff){
    delete $this->{ele_len};
  } else {
    $this->{ele_len} = $elelen;
  }
  #############################################################
  ### experimental checkpoint invocation - bad explicit length??
  if($this->{in_checkpoint}){
    $elelen += 0x10000;
    $this->{ele_len} += 0x10000;
  }
  #############################################################
  if($this->{extremely_verbose}) {
    $file_pos = $this->{stream}->tell;
    print STDERR "value at $file_pos, len: $elelen\n"
  }
  if(exists $this->{ele_len} && $this->{ele_len} & 1){
    push(@{$this->{errors}}, "Odd length element: $this->{tag}");
  }
  return;
}

#
# ReadVariableLengthItemList($this)
#
sub  ReadVariableLengthItemList{
  my $this = shift;
  my @list;
  my $index = -1;
  my $parent_root = "$this->{parent_tag}$this->{tag}";
  my $tag = $this->{tag};
  my $vr = $this->{vr};
  my $vm = $this->{vm};
  my $grp = $this->{grp};
  my $ele = $this->{ele};
  my $type = $this->{type};
  my %pos_map;
  my %first_el_pos_map;
  my %end_pos_map;
  while (1){
    $index +=1;
    my $file_pos = tell($this->{stream});
    ReadElementHeader($this);
    unless($this->{grp} == 0xfffe){
      die "not a delimiter in ReadVariableLengthValue" .
        sprintf("group: %04x ele: %04x", $this->{grp}, $this->{ele});
    }
    if($this->{ele} == 0xe0dd){
      $this->{grp} = $grp;
      $this->{ele} = $ele;
      $this->{vr} = $vr;
      $this->{vm} = $vm;
      $this->{tag} = $tag;
      $this->{type} = $type;
      $this->{item_map} = \%pos_map;
      $this->{item_pos} = \%first_el_pos_map;
      $this->{item_end_pos} = \%end_pos_map;
      return(\@list);
    }
    $pos_map{$file_pos} = $index;
    if($this->{ele} == 0xe000){
      my $new_this = {
        stream => $this->{stream},
        xfrstx => $this->{xfrxtx},
        seekable => $this->{seekable},
        filename => $this->{filename},
        skip_large => $this->{skip_large},
        explicit => $this->{explicit},
        vax => $this->{vax},
        short_len => $this->{short_len},
        encap => $this->{encap},
        parent_tag => "$parent_root" . "[$index]",
        errors => $this->{errors},
        ele_handler => $this->{ele_handler},
      };
      if($this->{extremely_verbose}){
        $new_this->{extremely_verbose} = 1;
      }
      $file_pos = tell($this->{stream});
      $first_el_pos_map{$index} = $file_pos;
      bless $new_this, "Posda::Parser";
      #print "Created a new Parser\n";
      $ParserCount += 1;
      if(defined $this->{ele_len}){
        $new_this->{length} = $this->{ele_len};
        $new_this->{delim} = 0;
      } else {
        $new_this->{delim} = 1;
      }
      my $ds = ReadDataset($new_this);
      $file_pos = tell($this->{stream});
      $end_pos_map{$index} = $file_pos;
      upd_len($this, $new_this->{length_read});;
      push(@list, $ds);
    } else {
      die sprintf(
        "Unknown delimiter type (%04x) in ReadVariableLengthItemList",
        $this->{ele}
      );
    }
  }
}

#
# ReadFixedLengthItemList($this)
#
sub ReadFixedLengthItemList{
  my $this = shift;
  my @list;
  my $length_to_read = $this->{ele_len};
  my $index = -1;
  my $tag = $this->{tag};
  my $vr = $this->{vr};
  my $vm = $this->{vm};
  my $type = $this->{type};
  my $grp = $this->{grp};
  my $ele = $this->{ele};
  my $parent_root;
  my %pos_map;
  my %first_el_pos_map;
  my %end_pos_map;
  if(defined $this->{parent_tag}){
    $parent_root = "$this->{parent_tag}$this->{tag}";
  } else {
    $parent_root = "$this->{tag}";
  }
  while ($length_to_read > 0){
    $index += 1;
    my $file_pos = tell($this->{stream});
    $pos_map{$file_pos} = $index;
    ReadElementHeader($this);
    unless($this->{grp} == 0xfffe){
      die "not a delimiter in ReadFixedLengthItemList" .
        sprintf("group: %04x ele: %04x", $this->{grp}, $this->{ele});
    }
    $file_pos = tell($this->{stream});
    $first_el_pos_map{$index} = $file_pos;
    $length_to_read -= 8;
    if($this->{ele} == 0xe0dd){
      die "die here";
      ###  die here ? ###
      $this->{grp} = $grp;
      $this->{ele} = $ele;
      $this->{vr} = $vr;
      $this->{vm} = $vm;
      $this->{tag} = $tag;
      $this->{type} = $type;
      return(\@list);
    }
    if($this->{ele} == 0xe000){
      my $ds;
      my $new_this = {
        stream => $this->{stream},
        xfrstx => $this->{xfrxtx},
        seekable => $this->{seekable},
        filename => $this->{filename},
        skip_large => $this->{skip_large},
        explicit => $this->{explicit},
        vax => $this->{vax},
        short_len => $this->{short_len},
        encap => $this->{encap},
        parent_tag => "$parent_root" . "[$index]",
        errors => $this->{errors},
        ele_handler => $this->{ele_handler},
        length_read => 0,
      };
      if($this->{extremely_verbose}){
        $new_this->{extremely_verbose} = 1;
      }
      bless $new_this, "Posda::Parser";
      #print "Created a new Parser\n";
      $ParserCount += 1;
      if(defined $this->{ele_len}){
        $new_this->{delim} = 0;
        if($this->{ele_len} == 0){
          $ds = undef;
        } else {
          $new_this->{length} = $this->{ele_len};
          $ds = ReadDataset($new_this);
        }
      } else {
          $new_this->{delim} = 1;
          $ds = ReadDataset($new_this);
      }
      push(@list, $ds);
      upd_len($this, $new_this->{length_read});
      $length_to_read -= $new_this->{length_read};
      $file_pos = tell($this->{stream});
      $end_pos_map{$index} = $file_pos;
      if(exists($this->{length}) && $this->{length} < 0){
        die "read too far for len in ReadFixedLengthItemList";
      }
      if($length_to_read < 0){
        die "read too far for ele_len in ReadFixedLengthItemList";
      }
    }
  }
  $this->{grp} = $grp;
  $this->{ele} = $ele;
  $this->{vr} = $vr;
  $this->{vm} = $vm;
  $this->{tag} = $tag;
  $this->{item_map} = \%pos_map;
  $this->{item_pos} = \%first_el_pos_map;
  $this->{item_end_pos} = \%end_pos_map;
  return(\@list);
}

#
# ReadEncapsulatedPixelData($this)
#
sub ReadEncapsulatedPixelData{
  my $this = shift;
  my $group = $this->{grp};
  my $element = $this->{ele};
  my $tag = $this->{tag};
  my @list;
  while (1){
    ReadElementHeader($this);
    unless($this->{grp} == 0xfffe){
      #printf STDERR "group: %04x element: %04x\n", $group, $element;
      die "not a delimiter in ReadEncapsulatedPixelData" .
        sprintf("group: %04x ele: %04x", $this->{grp}, $this->{ele});
    }
    if($this->{ele} == 0xe0dd){
      $this->{grp} = $group;
      $this->{ele} = $element;
      $this->{tag} = $tag;
      return(\@list);
    }
    if($this->{ele} == 0xe000){
      my $value;
      if(defined $this->{ele_len}){
        $this->{vr} = "OW";
        $value = ReadElementValue($this);
      } else {
        die "variable length item in encapsulated pixel data";
      }
      push(@list, $value);
    }
  }
}

# DecodeElementValue

sub unpad{
  my($this, $value) = @_;
  if(exists($Posda::Dataset::DD->{VRDesc}->{$this->{vr}}->{padnull})){
    $value =~ s/\00$//;
    if($value =~ / $/){
      push(@{$this->{errors}}, 
        "$this->{vr} contains a trailing space (removed) tag: $this->{tag}");
      $value =~ s/ //g;
    }
  }
  if($value =~ /\00/){
    push(@{$this->{errors}}, 
      "$this->{vr} contains nulls (removed) tag: $this->{tag}");
    $value =~ s/\00//g;
  }
  if(exists($Posda::Dataset::DD->{VRDesc}->{$this->{vr}}->{striptrailing})){
    $value =~ s/ +$//g;
  }
  if(exists($Posda::Dataset::DD->{VRDesc}->{$this->{vr}}->{stripleading})){
    $value =~ s/^ +//g;
  }
  return $value;
}

sub DecodeElementValue {
  my($this, $value) = @_;
  my $vax = $this->{vax};
  if($this->{grp} & 1 && $this->{ele} != 0){
    my $pvt_idx = ($this->{ele} & 0xff00) >> 8;
    if($pvt_idx == 0 && $this->{ele} >= 0x10){
      $this->{vr} = "LO";
    } elsif (exists $this->{dataset}->{$this->{grp}}->{$pvt_idx}){
      my $private_id = $this->{dataset}->{$this->{grp}}->{$pvt_idx}->{value};
      my $pvt_ele = $this->{ele} & 0xff;
      $private_id =~ s/\s*$//;
      $private_id =~ s/^\s*//;
      if( exists $Posda::Dataset::DD->{PvtDict}->{$private_id}
          ->{$this->{grp}}->{$pvt_ele}
      ){
        my $ele_info = 
          $Posda::Dataset::DD->{PvtDict}->{$private_id}
            ->{$this->{grp}}->{$pvt_ele};
#########
#  Do we really want to do this:
#        if(defined $this->{vr} && $this->{vr} ne $ele_info->{VR}) {
#          $this->{vr_to_convert_to} = $ele_info->{VR};
#        }
# in addition to this: 
        $this->{vm} = $ele_info->{VM};
#????????
#  In effect, do we want to promote a tag VR mismatch with the private DD
#  to the same level as a tag mismatch with the public DD??
#########
      }
    }
  }
  my $VRDesc = $Posda::Dataset::DD->{VRDesc}->{$this->{vr}};
  unless(defined $VRDesc) { die "unknown VR: $this->{vr} ($this->{tag})" }
  if($this->{vr} eq "UN" && exists $this->{vr_to_convert_to}){
    push(@{$this->{errors}},
      "Recasting $this->{tag} from $this->{vr} to $this->{vr_to_convert_to}");
    $this->{vr} = $this->{vr_to_convert_to};
    delete $this->{vr_to_convert_to};
    $VRDesc = $Posda::Dataset::DD->{VRDesc}->{$this->{vr}};
  }
  if(defined $VRDesc->{type}){
    $this->{type} = $VRDesc->{type};
  } else {
    die "No type in VRDesc for $this->{vr}";
  }
  if($VRDesc->{type} eq "text"){
    my @values;
    unless(defined $this->{vm} && $this->{vm} eq 1){
      @values = split(/\\/, $value);
      for my $i (0 .. $#values){
        $values[$i] = unpad($this, $values[$i]);
      }
      return \@values;
    }
    $value = unpad($this, $value);
    return $value;
  } elsif ($VRDesc->{type} eq "ulong"){
    my @long;
    if($vax){
      @long = unpack("V*", $value);
    } else {
      @long = unpack("N*", $value);
    }
    if($this->{vm} eq "1"){
      if(scalar(@long) != 1){
        push(@{$this->{errors}}, "Warning apparent VM mismatch $this->{tag}");
        return \@long;
      }
      return($long[0]);
    } else {
      return(\@long);
    }
  } elsif ($VRDesc->{type} eq "ushort"){
    my @short;
    if($vax){
      @short = unpack("v*", $value);
    } else {
      @short = unpack("n*", $value);
    }
    if($this->{vm} eq "1"){
      if(scalar(@short) != 1){
        push(@{$this->{errors}}, "Warning apparent VM mismatch $this->{tag}");
        return \@short;
      }
      return($short[0]);
    } else {
      return(\@short);
    }
  } elsif ($VRDesc->{type} eq "tag"){
    my @long;
    if($vax){
      @long = unpack("V*", $value);
    } else {
      @long = unpack("N*", $value);
    }
    if($this->{vm} eq "1"){
      if(scalar(@long) != 1){
        push(@{$this->{errors}}, "Warning apparent VM mismatch $this->{tag}");
        return \@long;
      }
      return($long[0]);
    } else {
      return(\@long);
    }
  } elsif ($VRDesc->{type} eq "slong"){
    my @long;
    if($vax){
      @long = unpack("l*", pack("L*", unpack("V*", $value)));
    } else {
      @long = unpack("l*", pack("L*", unpack("N*", $value)));
    }
    if($this->{vm} eq "1"){
      if(scalar(@long) != 1){
        push(@{$this->{errors}}, "Warning apparent VM mismatch $this->{tag}");
        return \@long;
      }
      return($long[0]);
    } else {
      return(\@long);
    }
  } elsif ($VRDesc->{type} eq "float"){
    my @float;
    if($vax){
      @float = unpack("f*", pack("L*", unpack("V*", $value)));
    } else {
      @float = unpack("f*", pack("L*", unpack("N*", $value)));
    }
    if($this->{vm} eq "1"){
      if(scalar(@float) != 1){
        push(@{$this->{errors}}, "Warning apparent VM mismatch $this->{tag}");
        return \@float;
      }
      return($float[0]);
    } else {
      return(\@float);
    }
  } elsif ($VRDesc->{type} eq "double"){
    my @float;
    my $value_div = $value;
    while(length($value_div) >= 8){
      my @array = unpack("C*", $value_div);
      my(@this_one, @remain);
      for my $i (0 .. $#array){
        if($i < 8){
          push(@this_one, $array[$i]);
        } else {
          push(@remain, $array[$i]);
        }
      }
      $value = pack("C*", @this_one);
      $value_div = pack("C*", @remain);
      if(
        $vax && $native_moto ||
        (! $native_moto) && (! $vax)
      ){
        my($a, $b, $c, $d, $e, $f, $g, $h) = 
          unpack("C8", $value);
        my $swapped_value = pack("C8", $h, $g, $f, $e, $d, $c, $b, $a);
        my $float = unpack("d", $swapped_value);
        push @float, $float;
      } else {
        my $float = unpack("d", $value);
        push @float, $float;
      }
    }
    if($this->{vm} eq "1"){
      if(scalar(@float) != 1){
        push(@{$this->{errors}}, "Warning apparent VM mismatch $this->{tag}");
        return \@float;
      }
      return($float[0]);
    } else {
      return(\@float);
    }
  } elsif ($VRDesc->{type} eq "sshort"){
    my @short;
    if($vax){
      @short = unpack("s*", pack("S*", unpack("v*", $value)));
    } else {
      @short = unpack("s*", pack("S*", unpack("n*", $value)));
    }
    if($this->{vm} eq "1"){
      if(scalar(@short) != 1){
        push(@{$this->{errors}}, "Warning apparent VM mismatch $this->{tag}");
        return \@short;
      }
      return($short[0]);
    } else {
      return(\@short);
    }
  } elsif ($VRDesc->{type} eq "raw"){
    return $value;
  }
}

# ReadElementValue

sub ReadElementValue{
  my($this) = @_;
  my $file_pos = tell($this->{stream});
  $this->{file_pos} = $file_pos;
  $this->{ele_offset} = $file_pos;
  if(
    defined($this->{length}) &&
    defined($this->{ele_len}) &&
    $this->{ele_len} > $this->{length}
  ){
    my $err_tag;
    if(defined($this->{parent_tag})){
      $err_tag = "$this->{parent_tag}$this->{tag}";
    } else {
      $err_tag = "$this->{tag}";
    }
    die "Length of element $err_tag $this->{ele_len}" .
      " exceeds remaining length ($this->{length}";
  }
  if(!defined($this->{ele_len})){
    if($this->{tag} eq "(7fe0,0010)"  && $this->{encap}){
      my $save_vr = $this->{vr};
      my $value = ReadEncapsulatedPixelData($this);
      $this->{vr} = $save_vr;
      return $value;
    } else {
      unless(defined($this->{vr})){ $this->{vr} = 'UN' }
      unless($this->{vr} eq "SQ"){
        push(
          @{$this->{errors}},
          "$this->{parent_tag}$this->{tag} has" .
          " undefined length with VR of \"$this->{vr}\"" .
          " (treated as SQ)."
        );
        $this->{vr} = "SQ";
        $this->{type} = "seq";
      }
      return ReadVariableLengthItemList($this);
    }
  } elsif($this->{ele_len} == 0) {
    if(exists($this->{vr_to_convert_to})){
      my $VRDesc = $Posda::Dataset::DD->{VRDesc}->{$this->{vr}};
      unless(defined $VRDesc) { die "unknown VR: $this->{vr} ($this->{tag})" }
      if($this->{vr} eq "UN" && exists $this->{vr_to_convert_to}){
        push(@{$this->{errors}},
          "Recasting $this->{tag} (with null value) from $this->{vr} to " .
          "$this->{vr_to_convert_to}");
        $this->{vr} = $this->{vr_to_convert_to};
        delete $this->{vr_to_convert_to};
      }
    }
    ### to distinguish if present but empty
    return "";
    return undef;
  } elsif($this->{vr} eq "SQ") {
    $this->{type} = "seq";
    return ReadFixedLengthItemList($this);
  } else {
    if(
      $this->{seekable} &&
      defined($this->{ele_len}) &&
      defined($this->{filename}) &&
      -f $this->{filename} &&
      $this->{skip_large} &&
      $this->{vr} ne 'SQ' &&
      $this->{ele_len} > $this->{skip_large}
    ){
      seek($this->{stream}, $this->{ele_len}, 1);
      upd_len($this, $this->{ele_len});
      if(defined($this->{length}) && $this->{length} < 0){
        my $overage = - $this->{length};
        die "not enough bytes (lacking $overage) " .
          "for ele $this->{parent_tag}$this->{tag}";
      }
      return undef;
    } else {
      my $buff;
      my $len_read = read($this->{stream}, $buff, $this->{ele_len});
      upd_len($this, $this->{ele_len});
      unless($len_read == $this->{ele_len}){
        die "couldn't read value for $this->{tag} - " .
          "read $len_read for $this->{ele_len}\n\n --";
      }
      return DecodeElementValue($this, $buff);
    }
  }
}

# ReadFixedLengthDataset

sub ReadFixedLengthDataset{
  my($this) = @_;
  my $last_tag = "(0000,0000)";
  while($this->{length} > 0){
    #  Horrible kludge for reading trailing word of nulls
    if(
      $this->{length} < 6 &&
      defined($this->{tag}) &&
      $this->{tag} eq "(7fe0,0010)"
    ){
      push(@{$this->{errors}}, 
        "$this->{length} trailing bytes after pixel data"
      );
      return $this->{dataset};
    }
    ReadElementHeader($this);
    if($this->{grp} == 0xfffe){
      die "Encountered an unexpected item tag ($this->{length}) " .
        "offset: $this->{ele_offset}\n\n --";
    }
    unless($last_tag le $this->{tag}){
      if($this->{tag} eq "(0000,0000)"){
        push(@{$this->{errors}}, 
          "Extra data (probably null - (0000,0000)) " .
          "at ($this->{length} + header)");
        return $this->{dataset};
      }
      push @{$this->{errors}}, 
        "Tag out of order $this->{tag} follows $last_tag";
    }
    $last_tag = $this->{tag};
    unless(defined $this->{vr}){ 
      push(@{$this->{errors}}, 
        "undefined VR for $this->{parent_tag}$this->{tag}\n")
    }
    if(
      $this->{seekable} &&
      defined($this->{filename}) &&
      -f $this->{filename} &&
      $this->{skip_large} &&
      $this->{vr} ne 'SQ' &&
      $this->{ele_len} > $this->{skip_large}
    ){
      my $file_pos = tell($this->{stream});
      $this->{file_pos} = $file_pos;
      $this->{ele_offset} = $file_pos;
      seek($this->{stream}, $this->{ele_len}, 1);
      upd_len($this, $this->{ele_len});
      if(defined($this->{length}) && $this->{length} < 0){
        my $overage = - $this->{length};
        die "not enough bytes (lacking $overage) " .
          "for ele $this->{parent_tag}$this->{tag}";
      }
      delete $this->{ele_value};
    } else {
      my $value = eval {
        ReadElementValue($this);
      };
      if($@){
        my $err_tag;
        if(defined($this->{parent_tag})){
          $err_tag = "$this->{parent_tag}$this->{tag}";
        } else {
          $err_tag = "$this->{tag}";
        }
        die "$@ getting value of $err_tag\n\n --";
      }
      $this->{ele_value} = $value;
    }
    unless(
      defined($this->{ele_handler}) &&
      ref($this->{ele_handler}) eq "CODE"
    ){
      die "no element handler defined: $this->{parent_tag}$this->{tag}\n\n --";
    }
    &{$this->{ele_handler}}($this);
  }
  return $this->{dataset};
}
sub EleHandler{
  my($this) = @_;
  my $element = {
    value => $this->{ele_value},
    VR => $this->{vr},
    VM => $this->{vm},
    type => $this->{type},
    file_pos => $this->{file_pos},
  };
  ###  Very kludgey code here
  if(
    $this->{grp} == 0x7fe0 && $this->{ele} == 0x0010 &&
    exists($this->{dataset}->{0x28}->{0x100}->{value}) &&
    $this->{dataset}->{0x28}->{0x100}->{value} > 16
  ){
    if($element->{VR} eq "OT") { $element->{VR} = "OB" }
    $element->{vax} = $this->{vax};
    $element->{bits_alloc} = $this->{dataset}->{0x28}->{0x100}->{value};
    print STDERR "Wide dose ($element->{bits_alloc}) found in" .
      ($element->{vax} ? "intel" : "motorola") .
      " format.  VR = $element->{VR}\n";
  }
  ###  
  if($this->{grp} < 0x8 && $this->{grp} != 0x4){
    push(@{$this->{errors}}, "Element with group less than 0008 (!= 0004) " .
        " found" .
        " $this->{tag} at file position $this->{file_pos} (deleted)");
    return;
  }
  if($this->{ele_len}){
    $element->{ele_len_in_file} = $this->{ele_len};
  }
  if(exists $this->{vr_to_convert_to}){
    $element->{type_in_file} = $this->{type};
    $element->{value_in_file} = $this->{value};
    ($element->{type}, $element->{value}) = $this->CoerceBadVRs(
      $this->{vr}, $this->{vr_to_convert_to}, $this->{vm}, $this->{ele_value});
    if(defined($element->{type})){
      $element->{VR} = $this->{vr_to_convert_to};
      $this->{vr} = $element->{VR};
    } else {
      $element->{type} = $element->{type_in_file};
      $element->{value} = $element->{value_in_file};
      push(@{$this->{errors}}, "Failed to coerce $this->{vr} to " .
        "$this->{vr_to_convert_to} $this->{tag}");
      delete $element->{vr_to_convert_to};
    }
    #  Because of screwy sequencing, the following code unpads text
    #  (unpad has already not been called)
    if(
      $element->{type} eq "text" && exists($element->{value}) &&
      defined($element->{value})
    ){
      if(exists($Posda::Dataset::DD->{VRDesc}->{$this->{vr}}->{padnull})){
        $element->{value} =~ s/\00$//;
        if($element->{value} =~ / $/){
          push(@{$this->{errors}}, 
            "$this->{vr} contains a trailing space " .
            "(removed) tag: $this->{tag}");
          $element->{value} =~ s/ //g;
        }
      }
      if($element->{value} =~ /\00/){
        push(@{$this->{errors}}, 
          "$this->{vr} contains nulls (removed) tag: $this->{tag}");
        $element->{value} =~ s/\00//g;
      }
      if(exists($Posda::Dataset::DD->{VRDesc}->{$this->{vr}}->{striptrailing})){
        $element->{value} =~ s/ +$//g;
      }
      if(exists($Posda::Dataset::DD->{VRDesc}->{$this->{vr}}->{stripleading})){
        $element->{value} =~ s/^ +//g;
      }
    }
    delete $this->{vr_to_convert_to};
  }
  if(defined $this->{item_map}){
    $element->{item_map} = $this->{item_map};
    delete $this->{item_map};
  }
  if(defined $this->{item_pos}){
    $element->{item_pos} = $this->{item_pos};
    delete $this->{item_pos};
  }
  if(defined $this->{item_end_pos}){
    $element->{item_end_pos} = $this->{item_end_pos};
    delete $this->{item_end_pos};
  }
  $this->{dataset}->{$this->{grp}}->{$this->{ele}} = $element;
}

sub CoerceBadVRs{
  my($this, $from_vr, $to_vr, $vm, $value_s) = @_;
  if($from_vr eq $to_vr) { return $value_s }
  if($from_vr eq "DS" && $to_vr eq "FL"){
    # nothing to do here - perl does the coersion just fine all by itself
    return ("float", $value_s);
  }elsif($from_vr eq "OB" && $to_vr eq "FD"){
    return ("double", [unpack("d*", $value_s)]);
  }elsif($from_vr eq "OB" && $to_vr eq "FL"){
    return ("float", [unpack("f*", $value_s)]);
  }elsif($from_vr eq "DS" && $to_vr eq "FD"){
    return ("double", $value_s);
  } elsif($from_vr eq "SH" && $to_vr eq "CS"){
    return("text", $value_s);
  } elsif($from_vr eq "SH" && $to_vr eq "DT"){
    return("text", $value_s);
  } elsif($from_vr eq "LT" && $to_vr eq "LO" && length($value_s) < 65){
    return("text", $value_s);
  } elsif($from_vr eq "OB" && $to_vr eq "CS"){
    return("text", $value_s);
  } elsif($from_vr eq "CS" && $to_vr eq "SH"){
    return("text", $value_s);
  } elsif($from_vr eq "SS" && $to_vr eq "SH"){
    my $ref = ref($value_s);
    if($ref eq "ARRAY"){
      my $new_v = unpack("a*", pack("s*", @$value_s));
      push(@{$this->{errors}}, "Coerced $this->{tag} from " .
        "$from_vr to $to_vr, value = \"$new_v\"");
      return("text", $new_v);
    }
  } elsif($from_vr eq "CS" && $to_vr eq "UI"){
    $value_s =~ s/^\s*//;
    $value_s =~ s/\s*$//;
    my $length = length($value_s);
    if($length & 1){
      $value_s .= "\0";
    }
    return("text", $value_s);
  } else {
    return (undef, undef);
    print STDERR "Can't coerce a $from_vr to a $to_vr\n";
#    die "Can't coerce a $from_vr into a $to_vr";
  }
}

sub ReadVariableLengthDataset{
  my($this) = @_;
  my $last_tag = "(0000,0000)";
  while(1){
    ReadElementHeader($this);
    unless($last_tag le $this->{tag}){
      die "Tag out of order $this->{tag} follows $last_tag\n\n --";
    }
    $last_tag = $this->{tag};
    if($this->{grp} == 0xfffe){ last }
    if(
      $this->{seekable} &&
      defined($this->{filename}) &&
      -f $this->{filename} &&
      $this->{skip_large} &&
      $this->{ele_len} &&
      $this->{ele_len} > $this->{skip_large}
    ){
      my $file_pos = tell($this->{stream});
      $this->{file_pos} = $file_pos;
      $this->{ele_offset} = $file_pos;
      seek($this->{stream}, $this->{ele_len}, 1);
      upd_len($this, $this->{ele_len});
      if(defined($this->{length}) && $this->{length} < 0){
        my $overage = - $this->{length};
        die "not enough bytes (lacking $overage) " .
          "for ele $this->{parent_tag}$this->{tag}";
      }
      delete $this->{ele_value};
    } else {
      my $value = eval {
        ReadElementValue($this);
      };
      if($@){
        die "$@ getting value of $this->{parent_tag}$this->{tag}\n\n --";
      }
      $this->{ele_value} = $value;
    }
    unless(
      defined($this->{ele_handler}) &&
      ref($this->{ele_handler}) eq "CODE"
    ){
      die "no element handler defined: $this->{parent_tag}$this->{tag}\n\n --";
    }
    &{$this->{ele_handler}}($this);
  }
  return $this->{dataset};
}

sub ReadDataset{
  my($this) = @_;
  unless(defined $this->{parent_tag}){$this->{parent_tag} = ""}
  unless(defined $this->{length_read}){$this->{length_read} = 0}
  if(defined($this->{length})){
    my $value = ReadFixedLengthDataset($this);
    if(defined $value){
      my $ret = bless $value, "Posda::Dataset";
      #print "Dataset Count: $Posda::Dataset::DataSetCount\n";
      $ret->inc_count();
      #print "Created Dataset $Posda::Dataset::DataSetCount\n";
      my $errors = $ret->FixUpOt($this->{vax});
      for my $err (@$errors){
        push(@{$this->{errors}}, $err);
      }
      return $ret;
    } else {
      return undef;
    }
  } elsif($this->{delim}){
    my $value = ReadVariableLengthDataset($this);
    if(defined $value){
      my $ret = bless $value, "Posda::Dataset";
      #print "Dataset Count: $Posda::Dataset::DataSetCount\n";
      $ret->inc_count();
      #print "Created Dataset $Posda::Dataset::DataSetCount\n";
      my $errors = $ret->FixUpOt($this->{vax});
      for my $err (@$errors){
        push(@{$this->{errors}}, $err);
      }
      return $ret;
    } else {
      return undef;
    }
  } else {
    die "Undelimited variable length Datasets not supported\n\n --";
  }
}

sub ReadMetaHeader{
  my($fh) = @_;
  my($preamble, $buff);
  my @warnings;
  my @errors;
  read $fh, $preamble, 0x80;
  read $fh, $buff, 4;
  unless($buff eq "DICM"){
    die "Not a DICOM Part 10 format file\n\n --";
  }
  my $header_start = tell($fh);
  my $this = bless {
    stream => $fh,
  }, "Posda::Parser";
  #print "Created a new parser\n";
  $ParserCount += 1;
  $this->SetUpXfrStx('1.2.840.10008.1.2.1');
  eval{ $this->ReadElementHeader() };
  if($@){
    seek($fh, $header_start, 0);
    $this->SetUpXfrStx('1.2.840.10008.1.2');
    push(@errors, "Part 10 header appears to be implicit xfer syntax");
    $this->ReadElementHeader();
  }
  unless($this->{grp} == 2 && $this->{ele} == 0){
    die "First Element in name meta header isn't (0002,0000)\n\n --";
  }
  my $length_offset = $fh->tell;
  my $value = $this->ReadElementValue();
  my $length_to_end = $value;
  $this->{length} = $value;
  my $here = $fh->tell;
  my $apparent_start_of_dataset = $here + $value;
  my $last_tag = $this->{tag};
  my $metaheader = {
    $this->{tag} => $value,
  };
  while($this->{length} > 0){
    my $start_of_tag = $fh->tell;
    $this->ReadElementHeader();
    unless($this->{grp} == 2){
      my $diff = $apparent_start_of_dataset - $start_of_tag;
      my $real_length = $length_to_end - $diff;
      if($this->{grp} == 8 || $this->{grp} == 4){
        push(@errors, "Group $this->{grp} found in file metaheader " .
          "(offset $start_of_tag vs $apparent_start_of_dataset)\n" .
          "change dataset length at: $length_offset " .
          "from $length_to_end to $real_length ($diff)"
        );
        seek $fh, $start_of_tag, 0;
        last;
      } else {
        die "Group $this->{grp} found in file metaheader " .
          "(offset $start_of_tag vs $apparent_start_of_dataset)\n" .
          "change dataset length at: $length_offset\n" .
          "from $length_to_end to $real_length ($diff)\n" .
          "\n  --";
      }
    }
    unless($last_tag lt $this->{tag}){
      push(@warnings, "Tag order error: $this->{tag} follows $last_tag");
    }
    $last_tag = $this->{tag};
    if($this->{length} < $this->{ele_len}){
      push(@errors, "Last tag too long ($this->{ele_len} vs $this->{length})");
      $this->{length} = $this->{ele_len};
    }
    $value = $this->ReadElementValue();
    $metaheader->{$this->{tag}} = $value;
  }
  my $StartOfData = tell($fh);
  seek $fh, 0, 2;
  my $EndOfData = tell($fh);
  seek $fh, $StartOfData, 0;
  my $FileSize = $EndOfData - $StartOfData;
  unless(exists $metaheader->{"(0002,0010)"}){
    die "Metaheader contains no xfer syntax\n\n --";
  }
  my $ret = {};
  $ret->{xfrstx} = $metaheader->{"(0002,0010)"};
  $ret->{DataSetStart} = $StartOfData;
  $ret->{DataSetSize} = $FileSize;
  $ret->{metaheader} = $metaheader;
  $ret->{preamble} = $preamble;
  if($#errors >= 0){
    $ret->{warnings} = \@errors;
  }
  return $ret;
}
sub SetUpXfrStx {
  my($this, $xfrstx) = @_;
  unless(defined $Posda::Dataset::DD->{XferSyntax}->{$xfrstx}){
    die "$xfrstx not in dd XferSyntax\n\n --";
  }
  $this->{xfrstx} = $xfrstx;
  my $xfr_info = $Posda::Dataset::DD->{XferSyntax}->{$xfrstx};
  $this->{vax} = $xfr_info->{vax};
  $this->{explicit} = $xfr_info->{explicit};
  $this->{encap} = $xfr_info->{encap};
  $this->{short_len} = $xfr_info->{short_len};
}
sub DESTROY{
  $ParserCount -= 1;
  #print "Destroyed a Parser, count = $ParserCount\n";
};
sub new {
  my $class = shift @_;
  my %parms = @_;
  my $this = {};
  unless(defined $Posda::Dataset::DD) {Posda::Dataset::InitDD()}
  if(defined $parms{xfrstx}){ $this->{xfrstx} = $parms{xfrstx}; }
  if(
    defined $parms{from_file} &&
    defined $parms{xfr_stx}
  ){
    $this->{filename} = $parms{from_file};
    unless(-r $this->{filename}){ die "$this->{filename} is not readable\n\n --" }
    my $fh = new FileHandle ("<$this->{filename}") or
      die "couldn't open $this->{filename}\n\n --";
    binmode($fh);
    $this->{stream} = $fh;
    $this->{seekable} = 1;
    seek $fh, 0, 2;
    $this->{length} = tell($fh);
    $this->{file_length} = $this->{length};
    seek $fh, 0, 0;
    $this->{delim} = 0;
    SetUpXfrStx($this, $parms{xfr_stx});
  } elsif (defined $parms{from_file}){
    $this->{filename} = $parms{from_file};
    unless(-r $this->{filename}){ die "$this->{filename} is not readable\n\n --" }
    my $fh = new FileHandle ("<$this->{filename}") or
      die "couldn't open $this->{filename}\n\n --";
    binmode($fh);
    my $mh = ReadMetaHeader($fh);
    $this->{stream} = $fh;
    $this->{metaheader} = $mh;
    $this->{length} = $mh->{DataSetSize};
    $this->{dataset_length} = $mh->{DataSetSize};
    seek $fh, 0, 1;
    $this->{dataset_start_offset} = tell($fh);
    $this->{file_length} = $this->{length} + $this->{dataset_start_offset};
    $this->{seekable} = 1;
    SetUpXfrStx($this, $mh->{xfrstx});
  }
  if($parms{skip_large}){
    unless($this->{filename}){ die "Seekable only allowed for files\n\n --" }
    $this->{skip_large} = $parms{skip_large};
  }
  $this->{errors} = [];
  if(exists $parms{ele_handler}){
    unless(ref($parms{ele_handler}) eq "CODE"){
      die "ele handler is not a code ref\n\n --";
    }
    $this->{ele_handler} = $parms{ele_handler};
  } else {
    $this->{ele_handler} = \&EleHandler;
  }
  #print "Created a new parser\n";
  $ParserCount += 1;
  return bless $this, $class;
}
1;

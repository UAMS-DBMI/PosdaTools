#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
package Posda::Dataset;
use Posda::Parser;
use HexDump;
use Digest::MD5;
#use Debug;
#my $Debug = 0;
#my $dbg = sub {print STDERR @_};
#sub Debug{
# my($class) = @_;
# $Debug = 1;
#
#sub UnDebug{
#  my($class) = @_;
#  $Debug = 0;
#}
use vars qw( $DD );
my $native_moto =
  (unpack("S", pack("C2", 1, 2)) == 0x0102) ? 1 : 0;
sub NativeMoto{
  return $native_moto;
}
{
  package PseudoStream;
  sub new {
    my($class) = @_;
    my $value;
    return bless \$value, $class;
  }
  sub print {
    my($this, $string) = @_;
    $$this .= $string;
  }
  sub str {
    my($this) = @_;
    return $$this;
  }
}

sub InitDD {
  my($dd) = @_;
  if(defined $dd){
    if($dd->isa("Posda::DataDict")){
      $DD = $dd;
    } else {
      die "Posda::InitDD arg (if present) must be a Posda::DataDict";
    }
  } else {
    unless(defined $DD){
      require "Posda/DataDict.pm";
      $DD = Posda::DataDict->new();
    }
  }
}

our $DataSetCount = 0;

sub inc_count{
  $DataSetCount += 1;
}

sub new_blank{
  my($class) = @_;
  my $this = {};
  $DataSetCount += 1;
  #print "Created blank Dataset $DataSetCount\n";
  return (bless($this, $class));
};

sub TraceAndDie{
  my($mess) = @_;
  my $i = 0;
  while(caller($i)){
    my @foo = caller($i);
    $i++;
    print STDERR "At line $foo[2] of file $foo[1]\n";
  }
  die $mess;
}

sub DESTROY {
  $DataSetCount -= 1;
  #print "Destroyed Dataset, remaining: $DataSetCount\n";
};

sub RenderText{
  my($value, $max_len, $numeric, $sig) = @_;
  unless(defined($max_len)){
    return $value;
  }
  if(length($value) > $max_len){
    if($numeric){
      for my $i (0 .. $max_len - 1){
        my $try = $max_len - $i;
        if($value =~ /\\/){
          print STDERR "text contains backslash $sig\n";
        }
        my $val = sprintf("%${try}e", $value);
        if(length($val) < $max_len){
          $val =~ s/^\s+//g;
          $val =~ s/\s+$//g;
          return $val;
        }
      }
      die "unable to render $value";
    } else {
      if(length($value) < $max_len){
        return $value;
      }
      $value =~ /^(.{$max_len})/;
      my $new_value = $1;
      my $long = length($value);
      print STDERR "truncating text in $sig: " .
        "(max_len = $max_len, len = $long)\n" .
        " from \"$value\"\n" .
        " to   \"$new_value\"\n";
      return $new_value;
    }
  } else {
    return $value;
  }
}

sub EncodeTextEle{
  my($value, $pad, $max_len, $numeric, $sig) = @_;
  unless(defined $value){ return "" };
  my $all;
  if(ref($value) eq "ARRAY"){
    $all = "";
    for my $i (0 .. $#{$value}){
      if(defined($value->[$i])){
        $all .= RenderText($value->[$i], $max_len, $numeric, $sig);
        #$all .= $value->[$i];
      }
      unless($i == $#{$value}){
        $all .= "\\";
      }
    }
  } else {
    $all = RenderText($value, $max_len, $numeric, $sig);
  }
  if(length($all) % 2){
    $all .= $pad;
  }
#print "Encoded: \"$all\"\n";
  return $all;
}

sub EncodeEle{
  my($value, $packer) = @_;
  unless(defined $value) {
    return undef;
  }
  if($value eq ""){ return undef }
  unless(ref($value) eq "ARRAY"){
   $value = [$value];
  }
  my $ret = pack($packer, @$value);
  return $ret;
}


sub MapOtVR{
  my($ds, $sig, $errors) = @_;
  if(
    $sig eq "(0028,0106)" || # Smallest Image Pixel Value
    $sig eq "(0028,0107)" || # Largest Image Pixel Value
    $sig eq "(0028,0108)" || # Smallest Pixel Value in Series
    $sig eq "(0028,0109)" || # Largest Pixel Value in Series
    $sig eq "(0028,0110)" || # Smallest Pixel Value in Plane
    $sig eq "(0028,0111)" || # Largest Pixel Value in Plane
    $sig eq "(0028,0120)" || # Pixel Padding Value
    $sig eq "(0040,9211)" || # Real World Last Value Mapped
    $sig eq "(0040,9216)" || # Real World First Value Mapped
    $sig eq "(0060,3004)" || # Histogram First Bin Value
    $sig eq "(0060,3006)"    # Histogram Last Bin Value
  ){
    my $pix_rep = $ds->ExtractElementBySig("(0028,0103)");
    unless(defined $pix_rep){
      push(@$errors, "Assuming US for $sig when no pix_rep");
      return 'US';
    }
    if($pix_rep == 0){
      return 'US';
    } elsif($pix_rep == 1){
      return 'SS';
    } else {
      push(@$errors, 
        "Assuming US for $sig when no pix_rep = $pix_rep");
      return 'US';
    }
  } elsif($sig eq "(7fe0,0010)"){ # Pixel Data
    my $bits_alloc = $ds->ExtractElementBySig("(0028,0100)");
    unless(defined $bits_alloc){
      push(@$errors, "no bits alloc for pixel data");
      return 'OB';
    }
    if($bits_alloc == 8){
      return 'OB';
    } elsif($bits_alloc == 16){
      return 'OW';
    } else {
      # really should do something else here!
      push(@$errors, 
        "unsupported bits alloc ($bits_alloc) for pixel data");
      return 'OB';
    }
  } elsif(
    $sig eq "(5400,0110)" || # Channel Minimum Value
    $sig eq "(5400,0112)" || # Channel Maximum Value
    $sig eq "(5400,100a)" || # Waveform Padding Value
    $sig eq "(5400,1010)"    # Waveform Data
  ){ 
    my $bits_alloc = $ds->ExtractElementBySig("(0028,0100)");
    if($bits_alloc == 8){
      return 'OB';
    } elsif($bits_alloc == 16){
      return 'OW';
    } else {
      # really should do something else here!
      return 'OW';
    }
  } elsif($sig eq "(0028,1200)"){ # OW - Grey Lookup Table Data - RET
    return 'OW';
  } elsif($sig eq "(0028,1201)"){ # OW - Red Palette Color Lookup Table Data
    return 'OW';
  } elsif($sig eq "(0028,1202)"){ # OW - Green Palette Color Lookup Table Data
    return 'OW';
  } elsif($sig eq "(0028,1203)"){ # OW - Blue Palette Color Lookup Table Data
    return 'OW';
  } elsif($sig eq "(0028,1101)"){ # Red Palette Color Lookup Table Descriptor
    return 'OW';
  } elsif($sig eq "(0028,1102)"){ # Green Palette Color Lookup Table Descriptor
    return 'OW';
  } elsif($sig eq "(0028,1103)"){ # Blue Palette Color Lookup Table Descriptor
    return 'OW';
  }
  return 'OW';
}
sub RmGrpLen{
  my($this, $errors) = @_;
  for my $grp (keys %$this){
    for my $ele (keys %{$this->{$grp}}){
      if($ele == 0){
        if($errors && ref($errors) eq "ARRAY"){
          push(@$errors, 
            sprintf("deleted retired len (%04x,%04x)", $grp, $ele));
        }
        delete $this->{$grp}->{$ele};
      }
      if($ele == 1 && $grp == 8){
        if($errors && ref($errors) eq "ARRAY"){
          push(@$errors, 
            sprintf("deleted retired len (%04x,%04x)", $grp, $ele));
        }
        delete $this->{$grp}->{$ele};
      }
    }
  }
}
sub MapPvtForXml{
  my($ds, $ele_fun, $ele_seq_end, 
   $item_start_fun, $item_end_fun, $pvt_ele_fun, $depth) = @_;
  for my $grp (sort { $a <=> $b } keys %$ds ){
    if($grp & 1){
      unless(exists $ds->{$grp}->{private}){
         $ds->ConvertToPrivate($grp);
      }
      for my $owner (sort keys %{$ds->{$grp}->{private}}){
        for my $ele (
            sort { $a <=> $b} keys %{$ds->{$grp}->{private}->{$owner}}
        ){
          my $element = $ds->{$grp}->{private}->{$owner}->{$ele};
          &$pvt_ele_fun($element, $grp, $ele, $owner, $depth);
          if(
            exists($element->{VR}) &&
            $element->{VR} eq 'SQ' 
          ){
            if(
              exists($element->{value}) &&
              defined($element->{value}) &&
              ref($element->{value}) eq "ARRAY"
            ){
              for my $i (0 .. $#{$ds->{$grp}->{$ele}->{value}}){
                &$item_start_fun($grp, $ele, $depth + 1);
                MapPvtForXml($ds->{$grp}->{$ele}->{value}->[$i], 
                  $ele_fun, $ele_seq_end, $item_start_fun,
                  $item_end_fun, $pvt_ele_fun, $depth + 2);
                &$item_end_fun($grp, $ele, $depth + 1);
              }
            }
            &$ele_seq_end($grp, $ele, $depth);
          }
        }
      }
    } else {
      ele:
      for my $ele (sort { $a <=> $b } keys %{$ds->{$grp}}){
        my $element = $ds->{$grp}->{$ele};
        &$ele_fun($element, $grp, $ele, $depth);
        if(
          exists($element->{VR}) &&
          $element->{VR} eq 'SQ' 
        ){
          if(
            exists($element->{value}) &&
            defined($element->{value}) &&
            ref($element->{value}) eq "ARRAY"
          ){
            for my $i (0 .. $#{$ds->{$grp}->{$ele}->{value}}){
              &$item_start_fun($grp, $ele, $depth + 1);
              MapPvtForXml($ds->{$grp}->{$ele}->{value}->[$i], 
                $ele_fun, $ele_seq_end, $item_start_fun,
                $item_end_fun, $pvt_ele_fun, $depth + 2);
              &$item_end_fun($grp, $ele, $depth + 1);
            }
          }
          &$ele_seq_end($grp, $ele, $depth);
        }
      }
    }
  }
}

sub FixUpOt{
  my($this, $vax) = @_;
  my @errors;
  MapTop($this, sub {
    my($ds, $ele, $sig) = @_;
    unless(exists($ele->{VR}) && $ele->{VR}){
      push(@errors, "Ele $sig has no VR");
      $ele->{VR} = 'OT';
    }
    if(exists($ele->{VR}) && $ele->{VR} eq "OT"){
      $ele->{VR} = MapOtVR($ds, $sig);
      if(
        $ele->{VR} eq "US" && $ele->{type} eq "raw" &&
         exists($ele->{value}) && defined($ele->{value})
      ){
        if($vax){
          my @list = unpack("v*", $ele->{value});
          $ele->{value} = $list[0];
        } else {
          my @list = unpack("n*", $ele->{value});
          $ele->{value} = $list[0];
        }
        $ele->{type} = "ushort";
      } elsif(
        $ele->{VR} eq "SS" && $ele->{type} eq "raw" &&
        exists($ele->{value}) && defined($ele->{value})
      ){
        if($vax){
          my @list = unpack("s*", pack("S*", unpack("v*", $ele->{value})));
          $ele->{value} = $list[0];
        } else {
          my @list = unpack("s*", pack("S*", unpack("n*", $ele->{value})));
          $ele->{value} = $list[0];
        }
        $ele->{type} = "sshort";
      }
    }
  });
  RmGrpLen($this, \@errors);
  return \@errors;
}
sub MakeExpBeElementWriter{
  my($stream) = @_;
  return sub {
    my($ele, $root, $sig, $keys, $depth) = @_;
    my($Value, $type, $vr) =
      EncodeElementValue($ele, $root, $sig, $keys, $depth, 0);
    my $group = $keys->[0];
    my $element = $keys->[1];
    my @vr = unpack("cc", $vr);
    #### Here's where Jay Gaeta's hack goes
    if($vr eq "DS" && length($Value) > 65535) {
      print STDERR "length too long for Explicit (Old) Xfer Syntax, " .
        "$sig, VR: $vr - changed to UN\n";
      $vr = 'UN';
    }
    ####
    if($type eq 'seq'){
      my $SqStart = pack("nnccnN", $group, $element,  @vr, 0, 0xffffffff);
      print $stream $SqStart;
      return;
    }
    if($vr eq "OT") { 
      #$vr = MapOtVR($root, $sig);
      die "Need to handle this";
    };
    my $len = length($Value);
    my $Header;
    if(
      $vr eq "OB" ||
      $vr eq "OD" ||
      $vr eq "OF" ||
      $vr eq "OL" ||
      $vr eq "OW" ||
      $vr eq "SQ" ||
      $vr eq "UC" ||
      $vr eq "UR" ||
      $vr eq "UT" ||
      $vr eq "UN"
    ){
      $Header = pack("nnccnN", $group, $element, @vr, 0, $len);
    } else {
      if($len > 65535) {
        die "length too long for Explicit (Old) Xfer Syntax, $sig, VR: $vr"
      }
      $Header = pack("nnccn", $group, $element, @vr, $len);
    }
    print $stream $Header;
    print $stream $Value;
  };
}

sub MakeExpLeElementWriter{
  my($stream) = @_;
  return sub {
    my($ele, $root, $sig, $keys, $depth) = @_;
    if($sig eq "(7fe0,0010)" && ref($ele->{value}) eq "ARRAY"){
      ## here we encode segmented pixel data like a sequence
      my @vr = unpack("cc", $ele->{VR});
      my $SqStart = pack("vvccvV", 0x7fe0, 0x0010,  @vr, 0, 0xffffffff);
      print $stream $SqStart;
      for my $i (0 .. $#{$ele->{value}}){
        my $v = $ele->{value}->[$i];
        my $len = length($v);
        my $ItemStart = pack("vvV", 0xfffe, 0xe000, $len);
        print $stream $ItemStart;
        print $stream $v;
      }
      my $SqEnd = pack("vvV", 0xfffe, 0xe0dd, 0);
      print $stream $SqEnd;
      return;
    }
    my($Value, $type, $vr) =
      EncodeElementValue($ele, $root, $sig, $keys, $depth, 1);
    my $group = $keys->[0];
    my $element = $keys->[1];
    #### Here's where Jay Gaeta's hack goes
    if($vr eq "DS" && length($Value) > 65535) {
      print STDERR "length too long for Explicit (Old) Xfer Syntax, " .
        "$sig, VR: $vr - changed to UN\n";
      $vr = 'UN';
    }
    ####
    my @vr = unpack("cc", $vr);
    if($type eq 'seq'){
      my $SqStart = pack("vvccvV", $group, $element,  @vr, 0, 0xffffffff);
      print $stream $SqStart;
      return;
    }
    if($vr eq "OT") { 
      $vr = MapOtVR($root, $sig);
      #die "Need to handle this for $sig";
      @vr = unpack("cc", $vr);
      if($vr eq "SS"){
        $Value = pack("s", $Value);
      } elsif($vr eq "US"){
        $Value = pack("S", $Value);
      } elsif($vr eq "UL"){
        die "Need to handle this for $sig";
      } elsif($vr eq "SL"){
        die "Need to handle this for $sig";
      } 
    };
    my $len = length($Value);
    my $Header;
    if(
      $vr eq "OB" ||
      $vr eq "OD" ||
      $vr eq "OF" ||
      $vr eq "OL" ||
      $vr eq "OW" ||
      $vr eq "SQ" ||
      $vr eq "UC" ||
      $vr eq "UR" ||
      $vr eq "UT" ||
      $vr eq "UN"
    ){
      $Header = pack("vvccvV", $group, $element, @vr, 0, $len);
    } else {
      if($len > 65535) {
        die "length too long for Explicit (Old) Xfer Syntax, $sig, VR: $vr"
      }
      $Header = pack("vvccv", $group, $element, @vr, $len);
    }
    print $stream $Header;
    print $stream $Value;
  };
}

sub MakeExpLeLongElementWriter{
  my($stream) = @_;
  return sub {
    my($ele, $root, $sig, $keys, $depth) = @_;
    my($Value, $type, $vr) =
      EncodeElementValue($ele, $root, $sig, $keys, $depth, 1);
    my $group = $keys->[0];
    my $element = $keys->[1];
    my @vr = unpack("cc", $vr);
    if($type eq 'seq'){
      my $SqStart = pack("vvccvV", $group, $element, @vr, 0, 0xffffffff);
      print $stream $SqStart;
      return;
    }
    if($vr eq "OT") { 
      #$vr = MapOtVR($root, $sig);
      die "need to handle this";
    };
    my $len = length($Value);
    my $Header = pack("vvccvV", $group, $element, @vr, 0, $len);
    print $stream $Header;
    print $stream $Value;
  };
}

sub MakeExpLeLengthSeqElWriter{
  my($stream) = @_;
  return sub {
    my($ds, $ele, $sig, $group, $element) = @_;
    my($Value, $type, $vr) =
      EncodeElementValue($ele, $ds, $sig, "", "", 1);
    my @vr = unpack("cc", $vr);
    if($type eq 'seq'){
      my @values;
      my $len = 0;
      if(
        exists($ele->{value}) &&
        ref($ele->{value}) eq "ARRAY" &&
        $#{$ele->{value}} >= 0
      ){
        for my $i (@{$ele->{value}}){
          if(defined $i){
            my $sub_stream = PseudoStream->new();
            $i->WriteExpLeLengthSeqLe($sub_stream);
            push(@values, $sub_stream->str());
          } else {
            push(@values, "");
          }
        }
      }
      for my $i (@values){
        if(defined($i)){
          $len += 8 + length($i);
        } else {
          $len += 6;
        }
      }
      my $SqStart = pack("vvccvV", $group, $element,  @vr, 0, $len);
      if(ref($stream) eq "GLOB"){
        print $stream $SqStart;
      } else {
        $stream->print($SqStart);
      }
      for my $i (@values){
        if(ref($stream) eq "GLOB"){
          print $stream pack("vvV", 0xfffe, 0xe000, length($i));
          print $stream $i;
        } else {
          $stream->print(pack("vvV", 0xfffe, 0xe000, length($i)));
          $stream->print($i);
        }
      }
      return;
    }
    if($vr eq "OT") { 
      #$vr = MapOtVR($root, $sig); 
      die "Need to handle this";
    };
    my $len = length($Value);
    my $Header;
    if(
      $vr eq "OB" ||
      $vr eq "OD" ||
      $vr eq "OF" ||
      $vr eq "OL" ||
      $vr eq "OW" ||
      $vr eq "SQ" ||
      $vr eq "UC" ||
      $vr eq "UR" ||
      $vr eq "UT" ||
      $vr eq "UN"
    ){
      $Header = pack("vvccvV", $group, $element, @vr, 0, $len);
    } else {
      if($len > 65535) {
        die "length too long for Explicit (Old) Xfer Syntax, $sig, VR: $vr"
      }
      $Header = pack("vvccv", $group, $element, @vr, $len);
    }
    if(ref($stream) eq "GLOB"){
      print $stream $Header;
      print $stream $Value;
    } else {
      $stream->print($Header);
      $stream->print($Value);
    }
  };
}

sub WriteExpLeLengthSeqLe{
  my($this, $stream) = @_;
  MapTop($this, MakeExpLeLengthSeqElWriter($stream));
}

sub WriteExpBe{  # Explict Big Endian
  my($this, $stream) = @_;
  my $ItemStart = pack("nnN", 0xfffe, 0xe000, 0xffffffff);
  my $ItemEnd = pack("nnN", 0xfffe, 0xe00d, 0);    
  my $SqEnd = pack("nnN", 0xfffe, 0xe0dd, 0);
  Map($this, MakeExpBeElementWriter($stream),
    sub {         # Sequence End
      print $stream $SqEnd;
    },
    sub {         # Item Start
      print $stream $ItemStart;
    },
    sub {         # Item End
      print $stream $ItemEnd;
    },
  );
}

sub WriteExpLe{  # Explict Little Endian
  my($this, $stream) = @_;
  my $ItemStart = pack("vvV", 0xfffe, 0xe000, 0xffffffff);
  my $ItemEnd = pack("vvV", 0xfffe, 0xe00d, 0);    
  my $SqEnd = pack("vvV", 0xfffe, 0xe0dd, 0);
  Map($this, MakeExpLeElementWriter($stream),
    sub {         # Sequence End
      print $stream $SqEnd;
    },
    sub {         # Item Start
      print $stream $ItemStart;
    },
    sub {         # Item End
      print $stream $ItemEnd;
    },
  );
}

sub WriteExpLeLong{  # Explict Little Endian
  my($this, $stream) = @_;
  my $ItemStart = pack("vvV", 0xfffe, 0xe000, 0xffffffff);
  my $ItemEnd = pack("vvV", 0xfffe, 0xe00d, 0);    
  my $SqEnd = pack("vvV", 0xfffe, 0xe0dd, 0);
  Map($this, MakeExpLeLongElementWriter($stream),
    sub {         # Sequence End
      print $stream $SqEnd;
    },
    sub {         # Item Start
      print $stream $ItemStart;
    },
    sub {         # Item End
      print $stream $ItemEnd;
    },
  );
}
sub EncodeFloatEle{
  my($value, $packer) = @_;
  unless(ref($value) eq "ARRAY"){
   $value = [$value];
  }
  my $ret =  pack($packer, unpack("L*", pack("f*", @$value)));
  return $ret;
}
sub EncodeDoubleEle{
  my($value, $vax) = @_;
  my @packer;
  unless(ref($value) eq "ARRAY"){
    $value = [$value];
  }
  for my $v (@$value){
    my($a, $b, $c, $d, $e, $f, $g, $h) = unpack("C8", pack("d", $v));
    if(
      $vax && $native_moto ||
      (! $native_moto) && (! $vax)
    ){
      push(@packer, $h, $g, $f, $e, $d, $c, $b, $a);
    } else {
      push(@packer, $a, $b, $c, $d, $e, $f, $g, $h);
    }
  }
  return pack("C*", @packer);
}

#sub EncodeEle{
#  my($value, $packer) = @_;
#  unless(ref($value) eq "ARRAY"){
#   $value = [$value];
#  }
#  my $ret = pack($packer, @$value);
#  return $ret;
#}

sub EncodeElementValue{
    my($ele, $root, $sig, $keys, $depth, $vax) = @_;
    my $vr = 'UN';
#print "Encoding Element Value\n";
    if(defined $ele->{VR}){ $vr = $ele->{VR}; }
    my $type = 'raw';
    if(defined($ele->{type})){ $type = $ele->{type}; }
    my $Value;
    my $max_len = $DD->{VRDesc}->{$vr}->{len};
    my $numeric = 0;
    if($vr eq 'DS'){
      $numeric = 1;
    }
    if( $type eq 'text'){
      $Value = EncodeTextEle(
        $ele->{value},
        $vr eq 'UI' ? "\0" : ' ',
        $max_len,
        $numeric,
        $sig
      );
    } elsif($type eq 'ushort' || $type eq 'sshort'){
      if($vax){
        $Value = EncodeEle($ele->{value}, "v*");
      } else {
        $Value = EncodeEle($ele->{value}, "n*");
      }
    } elsif($type eq 'slong'){
      my $val = $ele->{value};
      if(defined $val){
        unless(ref($val) eq "ARRAY"){
         $val = [$val];
        }
        if($vax){
          $Value = pack("l*", unpack("L*", pack ("V*", @$val)));
        } else {
          $Value = pack("l*", unpack("L*", pack ("N*", @$val)));
        }
      }
    } elsif($type eq 'ulong' || $type eq "tag"){
      if(defined $ele->{value}){
        if($vax){
          $Value = EncodeEle($ele->{value}, "V*");
        } else {
          $Value = EncodeEle($ele->{value}, "N*");
        }
      }
    } elsif(defined ($ele->{value}) && $type eq 'double'){
      $Value = EncodeDoubleEle($ele->{value}, $vax);
    } elsif(defined ($ele->{value}) && $type eq 'float'){
      if($vax){
        $Value = EncodeFloatEle($ele->{value}, "V*");
      } else {
        $Value = EncodeFloatEle($ele->{value}, "N*");
      }
    } elsif($type eq 'raw'){
      # kludge for odd length owner tags
      if(length($ele->{value}) & 1){
        print STDERR "Warning $ele has odd value (padding with space)\n";
        $Value = "$ele->{value} ";
      } else {
        $Value = $ele->{value};
      }
    }
    unless(defined $Value) { $Value = ""; }
    return $Value, $type, $vr;
};

sub MakeImpLeElementWriter{
  my($stream) = @_;
  return sub {
    my($ele, $root, $sig, $keys, $depth) = @_;
    my($Value, $type, $vr) = 
      EncodeElementValue($ele, $root, $sig, $keys, $depth, 1);
    my $group = $keys->[0];
    my $element = $keys->[1];
    my @vr = unpack("cc", $vr);
    if($type eq 'seq'){
      my $SqStart = pack("vvV", $group, $element,  0xffffffff);
      print $stream $SqStart;
      return;
    }
    my $len = length($Value);
    my $Header;
    $Header = pack("vvV", $group, $element, $len);
    print $stream $Header;
    print $stream $Value;
  };
}

sub WriteImpLe{  # Implicit Little Endian
  my($this, $stream) = @_;
  my $ItemStart = pack("vvV", 0xfffe, 0xe000, 0xffffffff);
  my $ItemEnd = pack("vvV", 0xfffe, 0xe00d, 0);    
  my $SqEnd = pack("vvV", 0xfffe, 0xe0dd, 0);
  Map($this, 
    MakeImpLeElementWriter($stream),
    sub {         # Sequence End
      print $stream $SqEnd;
    },
    sub {         # Item Start
      print $stream $ItemStart;
    },
    sub {         # Item End
      print $stream $ItemEnd;
    },
  );
}

sub WriteRawDicom{
  my($ds, $file_name, $xfr_stx) = @_;
  open FILE, ">", "$file_name" or die "Can't open $file_name";
  binmode(FILE);
  unless(
     $xfr_stx eq "1.2.840.10008.1.2" ||
     $xfr_stx eq "1.3.6.1.4.1.22213.1.147" ||
     $xfr_stx eq "1.2.840.10008.1.2.1" ||
     $xfr_stx eq "1.2.840.10008.1.2.2"
  ){
    die "Xfr_stx $xfr_stx not currently supported for part Raw writes";
  }
  $ds->MapToConvertPvtBack();
  if($xfr_stx eq "1.2.840.10008.1.2"){
    WriteImpLe($ds, \*FILE);
  } elsif($xfr_stx eq "1.2.840.10008.1.2.1"){
    #WriteExpLeLengthSeqLe($ds, \*FILE);
    WriteExpLe($ds, \*FILE);
  } elsif($xfr_stx eq "1.2.840.10008.1.2.2"){
    WriteExpBe($ds, \*FILE);
  } elsif($xfr_stx eq "1.3.6.1.4.1.22213.1.147"){
    WriteExpLeLong($ds, \*FILE);
  } elsif($xfr_stx eq '1.2.840.10008.1.2.4.90'){
    WriteExpLe($ds, \*FILE);
  } else {
    die "unsupported transfer syntax $xfr_stx";
  }
  close FILE;
};
sub CanonicalFileName{
  my($ds) = @_;
  my $sop_inst_uid = $ds->Get("(0008,0018)");
  my $sop_class_uid = $ds->Get("(0008,0016)");
  my $SopClassPrefix = Posda::DataDict::GetSopClassPrefix($sop_class_uid);
  my $file_name = "${SopClassPrefix}_$sop_inst_uid.dcm";
  return $file_name;
}
sub WritePart10Fh{
  my($ds, $fh, $xfr_stx, $ae_title) = @_;
  my $pix_ref = $ds->Get("(7fe0,0010)");
  if(ref($pix_ref) eq "ARRAY"){
    unless($xfr_stx eq '1.2.840.10008.1.2.4.90'){
      die "Can't convert from compressed to non-compressed xfer_syntax";
    }
  } elsif (
     $xfr_stx ne "1.2.840.10008.1.2" &&
     $xfr_stx ne "1.3.6.1.4.1.22213.1.147" &&
     $xfr_stx ne "1.2.840.10008.1.2.1" &&
     $xfr_stx ne "1.2.840.10008.1.2.1" &&
     $xfr_stx ne "1.2.840.10008.1.2.2"
  ){
    die "Can't convert from compressed to non-compressed xfer_syntax";
  }
  # Preamble
  print $fh "\0" x 128;
  # Prefix
  print $fh "DICM";
  # Group Length (save where to update at end)
  print $fh pack("vv", 2, 0);
  print $fh 'UL';
  print $fh pack("v", 4);
  my $length_place = tell $fh;
  print $fh pack("V", 0);
  my $Writer = MakeExpLeElementWriter($fh);
  my $media_storage_class_id =
    $ds->ExtractElementBySig("(0008,0016)");
  my $media_storage_instance_id =
    $ds->ExtractElementBySig("(0008,0018)");
  unless($media_storage_instance_id){
    die "Dataset has no SOP instance UID";
  }
  my $implementation_class_uid = '1.3.6.1.4.1.22213.1.143';
  my $implementation_version_name = '0.5';
  # File Meta Information Version
  &$Writer({
     type => 'raw',
     VR => 'OB',
     VM => 1,
     value => pack("v", 0x0100),
  }, undef, "(0002,0001)", [2, 1], 1);
  # Media Storage SOP Class UID
  &$Writer({
     type => 'text',
     VR => 'UI',
     VM => 1,
     value => $media_storage_class_id,
  }, undef, "(0002,0002)", [2, 2], 1);
  # Media Storage SOP Instance UID
  &$Writer({
     type => 'text',
     VR => 'UI',
     VM => 1,
     value => $media_storage_instance_id,
  }, undef, "(0002,0003)", [2, 3], 1);
  # Transfer Syntax UID
  &$Writer({
     type => 'text',
     VR => 'UI',
     VM => 1,
     value => $xfr_stx,
  }, undef, "(0002,0010)", [2, 0x10], 1);
  # Implementation Class UID
  &$Writer({
     type => 'text',
     VR => 'UI',
     VM => 1,
     value => $implementation_class_uid,
  }, undef, "(0002,0012)", [2, 0x12], 1);
  # Implementation Version Name
  &$Writer({
     type => 'text',
     VR => 'SH',
     VM => 1,
     value => $implementation_version_name,
  }, undef, "(0002,0013)", [2, 0x13], 1);
  # AE Title
  &$Writer({
     type => 'text',
     VR => 'AE',
     VM => 1,
     value => $ae_title,
  }, undef, "(0002,0016)", [2, 0x16], 1);
  my $start_data = tell $fh;
  my $length = $start_data - ($length_place + 4);
  seek $fh, $length_place, 0;
  print $fh pack("V", $length);
  seek $fh, $start_data, 0;
  $ds->MapToConvertPvtBack();
  if($xfr_stx eq "1.2.840.10008.1.2"){
    WriteImpLe($ds, $fh);
  } elsif($xfr_stx eq "1.2.840.10008.1.2.1"){
    #WriteExpLeLengthSeqLe($ds, \*FILE);
    WriteExpLe($ds, $fh);
  } elsif($xfr_stx eq "1.2.840.10008.1.2.2"){
    WriteExpBe($ds, *fh);
  } elsif($xfr_stx eq "1.3.6.1.4.1.22213.1.147"){
    WriteExpLeLong($ds, *fh);
  } elsif($xfr_stx eq '1.2.840.10008.1.2.4.90'){
    WriteExpLe($ds, $fh);
  } else {
    die "unsupported transfer syntax $xfr_stx";
  }
  close $fh;
  return $start_data;
}
sub WritePart10{
  my($ds, $file_name, $xfr_stx, $ae_title, $private_uid, $private) = @_;
  my $pix_ref = $ds->Get("(7fe0,0010)");
  if(ref($pix_ref) eq "ARRAY"){
    unless($xfr_stx eq '1.2.840.10008.1.2.4.90'){
      die "Can't convert from compressed to non-compressed xfer_syntax";
    }
  } elsif (
     $xfr_stx ne "1.2.840.10008.1.2" &&
     $xfr_stx ne "1.3.6.1.4.1.22213.1.147" &&
     $xfr_stx ne "1.2.840.10008.1.2.1" &&
     $xfr_stx ne "1.2.840.10008.1.2.1" &&
     $xfr_stx ne "1.2.840.10008.1.2.2"
  ){
    die "Can't convert from compressed to non-compressed xfer_syntax";
  }
  unless(defined $file_name){
    my $sop_inst_uid = $ds->Get("(0008,0018)");
    my $sop_class_uid = $ds->Get("(0008,0016)");
    my $SopClassPrefix = Posda::DataDict::GetSopClassPrefix($sop_class_uid);
    $file_name = "${SopClassPrefix}_$sop_inst_uid.dcm";
  }
  if(length($ae_title) > 16) { die "ae_title is too long" }
  my $media_storage_class_id =
    $ds->ExtractElementBySig("(0008,0016)");
  unless($media_storage_class_id){
    die "Dataset ($media_storage_class_id) is not a storage object";
  }
  my $media_storage_instance_id =
    $ds->ExtractElementBySig("(0008,0018)");
  unless($media_storage_instance_id){
    die "Dataset has no SOP instance UID";
  }
  my $implementation_class_uid = '1.3.6.1.4.1.22213.1.143';
  my $implementation_version_name = '0.5';
  # Preamble
  open FILE, ">", "$file_name" or die "Can't open $file_name ($!)";
  binmode(FILE);
  print FILE "\0" x 128;
  # Prefix
  print FILE "DICM";
  # Group Length (save where to update at end)
  print FILE pack("vv", 2, 0);
  print FILE 'UL';
  print FILE pack("v", 4);
  my $length_place = tell FILE;
  print FILE pack("V", 0);
  my $Writer = MakeExpLeElementWriter(\*FILE);
  # File Meta Information Version
  &$Writer({
     type => 'raw',
     VR => 'OB',
     VM => 1,
     value => pack("v", 0x0100),
  }, undef, "(0002,0001)", [2, 1], 1);
  # Media Storage SOP Class UID
  &$Writer({
     type => 'text',
     VR => 'UI',
     VM => 1,
     value => $media_storage_class_id,
  }, undef, "(0002,0002)", [2, 2], 1);
  # Media Storage SOP Instance UID
  &$Writer({
     type => 'text',
     VR => 'UI',
     VM => 1,
     value => $media_storage_instance_id,
  }, undef, "(0002,0003)", [2, 3], 1);
  # Transfer Syntax UID
  &$Writer({
     type => 'text',
     VR => 'UI',
     VM => 1,
     value => $xfr_stx,
  }, undef, "(0002,0010)", [2, 0x10], 1);
  # Implementation Class UID
  &$Writer({
     type => 'text',
     VR => 'UI',
     VM => 1,
     value => $implementation_class_uid,
  }, undef, "(0002,0012)", [2, 0x12], 1);
  # Implementation Version Name
  &$Writer({
     type => 'text',
     VR => 'SH',
     VM => 1,
     value => $implementation_version_name,
  }, undef, "(0002,0013)", [2, 0x13], 1);
  # AE Title
  &$Writer({
     type => 'text',
     VR => 'AE',
     VM => 1,
     value => $ae_title,
  }, undef, "(0002,0016)", [2, 0x16], 1);
  # Privates
  if(defined($private_uid) && defined($private)){
    # Private Information Creator UID
    &$Writer({
       type => 'text',
       VR => 'UI',
       VM => 1,
       value => $private_uid,
    }, undef, "(0002,0100)", [2, 0x100], 1);
    # Private Information 
    &$Writer({
       type => 'text',
       VR => 'OB',
       VM => 1,
       value => $private,
    }, undef, "(0002,0102)", [2, 0x102], 1);
  }
  my $start_data = tell FILE;
  my $length = $start_data - ($length_place + 4);
  seek FILE, $length_place, 0;
  print FILE pack("V", $length);
  seek FILE, $start_data, 0;
  $ds->MapToConvertPvtBack();
  if($xfr_stx eq "1.2.840.10008.1.2"){
    WriteImpLe($ds, \*FILE);
  } elsif($xfr_stx eq "1.2.840.10008.1.2.1"){
    #WriteExpLeLengthSeqLe($ds, \*FILE);
    WriteExpLe($ds, \*FILE);
  } elsif($xfr_stx eq "1.2.840.10008.1.2.2"){
    WriteExpBe($ds, \*FILE);
  } elsif($xfr_stx eq "1.3.6.1.4.1.22213.1.147"){
    WriteExpLeLong($ds, \*FILE);
  } elsif($xfr_stx eq '1.2.840.10008.1.2.4.90'){
    WriteExpLe($ds, \*FILE);
  } else {
    die "unsupported transfer syntax $xfr_stx";
  }
  close FILE;
  return $start_data;
}
sub WriteDataset{
  my($ds, $stream, $xfr_stx) = @_;
  if($xfr_stx eq "1.2.840.10008.1.2"){
    WriteImpLe($ds, $stream);
  } elsif($xfr_stx eq "1.2.840.10008.1.2.1"){
    #WriteExpLeLengthSeqLe($ds, \*STREAM);
    WriteExpLe($ds, $stream);
  } elsif($xfr_stx eq "1.2.840.10008.1.2.2"){
    WriteExpBe($ds, $stream);
  } elsif($xfr_stx eq "1.3.6.1.4.1.22213.1.147"){
    WriteExpLeLong($ds, $stream);
  } elsif($xfr_stx eq '1.2.840.10008.1.2.4.90'){
    WriteExpLe($ds, $stream);
  } else {
    die "unsupported transfer syntax $xfr_stx";
  }
}
sub DumpUID{
  my($pr, $in_value) = @_;
  my $val = $in_value;
  unless(ref($val) eq "ARRAY"){ $val = [$val] }
  for my $i (0 .. $#{$val}){
    my $value = $val->[$i];
#    print $pr "\"$value\"";
    $pr->print("\"$value\"");
    if(exists $DD->{SopCl}->{$value}){
#      print $pr " ($DD->{SopCl}->{$value}->{sopcl_desc})";
      $pr->print(" ($DD->{SopCl}->{$value}->{sopcl_desc})");
    }
    unless($i == $#{$val}){
#      print $pr "\\";
      $pr->print("\\");
    }
  }
}
sub DumpOF{
  my($pr, $in_value) = @_;
  my $len = length($in_value);
  my $ctx = Digest::MD5->new;
  $ctx->add($in_value);
  my $dig = $ctx->hexdigest;
  my @floats = unpack("f*", pack("L*", unpack("V*", $in_value)));
  my $num_floats = @floats;
  $pr->print("<raw data: $len bytes $num_floats floats digest: $dig>");
  return;
  for my $i (0 .. $#floats){
    $pr->print($floats[$i]);
    unless($i == $#floats){
      $pr->print("\\");
    }
  }
};
sub DumpAT{
  my($pr, $in_value) = @_;
  unless(ref($in_value) eq "ARRAY"){ $in_value = [$in_value] }
  for my $i (0 .. $#{$in_value}){
    my $ele = ($in_value->[$i] & 0xffff0000) >> 16;
    my $grp = ($in_value->[$i] & 0xffff);
    $pr->print(sprintf("(%04x,%04x)", $grp, $ele));
    unless($i == $#{$in_value}){
      $pr->print("\\");
    }
  }
};

sub DumpCompressedPixelData {
  my($pr, $ele, $max_len1) = @_;
  my $v = $ele->{value};
  unless(ref($v) eq "ARRAY"){ die "Internal Error, ref of pixel data changed" }
  my $name;
  my $vr = $ele->{VR};
  my $vm = @$v;
  my $value_string;
  my $tag;
  for my $i (0 .. $#{$v}){
    $tag = "(7fe0,0010)[$i]";
    my $index = $i + 1;
    $name = "Pixel Data Segment $index";
    my $vi = $v->[$i];
    my $ctx = Digest::MD5->new;
    $ctx->add($vi);
    my $dig = $ctx->hexdigest;
    my $len = length($vi);
    $value_string = "<raw data $len bytes $dig>";
    $pr->print("$tag:($vr, $vm):$name:$value_string\n");
  }
}

sub DumpEle{
  my($pr, $ele, $max_len) = @_;
  unless(ref($ele) eq "HASH"){
    $pr->print("<undef>");
    return;
  }
  unless(defined $ele->{value}){
    unless(defined $ele->{VR} && $ele->{VR} eq "SQ"){
#      print $pr "<null>";
      if($ele->{ele_len_in_file}){
        $pr->print(
          "$ele->{ele_len_in_file} bytes at file_offset $ele->{file_pos}");
      } else {
        $pr->print("<null>");
      }
    }
    return;
  }
  if($ele->{type} eq "text" && $ele->{value} =~ /^\s*$/){
    $pr->print("<null>");
    return;
  }
  if(defined($ele->{VR}) && $ele->{VR} eq "UI"){
    DumpUID($pr, $ele->{value});
  } elsif(defined($ele->{VR}) && $ele->{VR} eq "OF"){
    DumpOF($pr, $ele->{value});
  } elsif(defined($ele->{VR}) && $ele->{VR} eq "AT"){
    DumpAT($pr, $ele->{value});
  } elsif(
    defined($ele->{type}) &&
    ( $ele->{type} eq "text" ||
      $ele->{type} eq "ushort" ||
      $ele->{type} eq "sshort" ||
      $ele->{type} eq "ulong" ||
      $ele->{type} eq "float" ||
      $ele->{type} eq "double" ||
      $ele->{type} eq "slong"
    )
  ){
    my $txt = $ele->{value};
    if(ref($ele->{value}) eq "ARRAY"){
      $txt = join("\\", @{$ele->{value}});
    }
    if(
      defined($max_len) &&
      defined($txt) &&
      $max_len < 32766 &&
      length($txt) > $max_len
    ){
      my $length_of_text = length($txt);
      my $ctx = Digest::MD5->new();
      $ctx->add($txt);
      my $dig = $ctx->hexdigest();
      my $h_max_len = $max_len/2;
      if($txt =~ /^(.{$h_max_len}).*(.{$h_max_len})$/m){
        $txt = $1 . " ... $2 ($length_of_text $dig)";
      }
    }
#    print $pr "\"$txt\"";
    if($txt =~ /^\s*$/){
      $pr->print("<null>");
    } else {
      $pr->print("\"$txt\"");
    }
  } elsif(
    defined($ele->{type}) &&
    $ele->{type} eq "raw"
  ){
    my $size = length($ele->{value});
    my $ctx = Digest::MD5->new;
    $ctx->add($ele->{value});
    my $digest = $ctx->hexdigest;
#    print $pr "<raw data: $size $digest>";
    $pr->print("<raw data: $size $digest>");
  }
}

sub DumpEleLen{
  my($pr, $ele) = @_;
  unless(defined $ele->{value}){
#    print $pr "0";
    $pr->print("0");
    return;
  }
  if(defined($ele->{type}) &&  $ele->{type} eq "text") {
    my $txt = $ele->{value};
    if(ref($ele->{value}) eq "ARRAY"){
      $txt = join("\\", @{$ele->{value}});
    }
    my $len = length($txt);
#    print $pr $len;
    $pr->print($len);
  } elsif(
    defined($ele->{type}) &&
    ( $ele->{type} eq "ushort" ||
      $ele->{type} eq "sshort"
    ) &&
    ref($ele->{value}) eq "ARRAY"
  ){
    my $len = ($#{$ele->{value}} + 1) * 2;
#    print $pr $len;
    $pr->print($len);
  } elsif(
    defined($ele->{type}) &&
    ( $ele->{type} eq "ushort" ||
      $ele->{type} eq "sshort"
    ) &&
    ref($ele->{value}) eq ""
  ){
    my $len = 2;
#    print $pr $len;
    $pr->print($len);
  } elsif(
    defined($ele->{type}) &&
    ( $ele->{type} eq "ulong" ||
      $ele->{type} eq "slong" ||
      $ele->{type} eq "tag"
    )
  ){
    if(ref($ele->{value}) eq "ARRAY"){
      my $len = ($#{$ele->{value}} + 1) * 4;
#      print $pr $len;
      $pr->print($len);
    } else {
      my $len = 4;
#      print $pr $len;
      $pr->print($len);
    }
  } elsif(
    defined($ele->{type}) &&
    $ele->{type} eq "raw"
  ){
    my $len = length($ele->{value});
#    print $pr $len;
    $pr->print($len);
  } else {
    TraceAndDie "can't figure length of element";
  }
}

sub ExplicitBroken{
  my($ds, $pr, $max_len1, $max_len2) = @_;
  my $max_len = 0;
  Map($ds, sub{
    my($ele, $root, $sig, $keys, $depth) = @_;
    if(
      $ele->{VR} ne "OB" &&
      $ele->{VR} ne "OD" &&
      $ele->{VR} ne "OF" &&
      $ele->{VR} ne "OL" &&
      $ele->{VR} ne "OW" &&
      $ele->{VR} ne "SQ" &&
      $ele->{VR} ne "UC" &&
      $ele->{VR} ne "UR" &&
      $ele->{VR} ne "UT" &&
      $ele->{VR} ne "UN"
    ){
      unless(ref($ele->{value}) eq "ARRAY"){ return }
    }
    my $sum = scalar @{$ele->{value}};
    map { $sum += length($_) } @{$ele->{value}};
   if($max_len < $sum) { $max_len = $sum };
  });
}

sub DumpEleName{
  my($grp, $ele, $pr) = @_;
    if(
      exists($DD->{Dict}->{$grp}) &&
      exists($DD->{Dict}->{$grp}->{$ele}) &&
      exists($DD->{Dict}->{$grp}->{$ele}->{Name})
    ){
#      print $pr ":$DD->{Dict}->{$grp}->{$ele}->{Name}:";
      $pr->print(":$DD->{Dict}->{$grp}->{$ele}->{Name}:");
    } else {
#      print $pr ":Unknown Element Name:";
      $pr->print(":Unknown Element Name:");
    }
}
sub DumpStyleNoUid{
  my($ds, $pr, $max_len1, $max_len2) = @_;
  MapPvt($ds, sub {
    my($ele, $sig) = @_;
    my $ele_info = $DD->get_ele_by_sig($sig);
    unless(defined($ele_info)){
      $ele_info = {
        Name => "<Unknown Priv Ele>",
        VR => 'UN',
        VM => 1,
      };
    }
    unless(defined($ele_info->{Name})){
       $ele_info->{Name} = "<Unknown (probably repeating) Ele>";
    }
    my $vr = $ele->{VR};
    my $vm = 1;
    if(ref($ele->{value}) eq "ARRAY"){
      $vm = @{$ele->{value}};
    }
#    print $pr "$sig:($vr, $vm):$ele_info->{Name}:";
    $pr->print("$sig:($vr, $vm):$ele_info->{Name}:");
    #print $pr "$ele->{file_pos}:$sig:($vr, $vm):$ele_info->{Name}:";
    if($vr eq 'UI'){
      my $ele_c;
      for my $i (keys %$ele){
        $ele_c->{$i} = $ele->{$i};
      }
      $ele_c->{value} = "-----";
      DumpEle($pr, $ele_c, $max_len1);
    } else {
      DumpEle($pr, $ele, $max_len1);
    }
#    print $pr "\n";
    $pr->print("\n");
    if(
      defined($ele->{type}) && 
      $ele->{type} eq "raw" &&
      defined $ele->{value} &&
      $ele->{VR} ne "OF"
    ){
      my $len = length($ele->{value});
      if($len < $max_len2){
        if(exists $ele->{big_endian}){
          HexDump::PrintBigEndian($pr, $ele->{value});
        } else {
          HexDump::PrintVax($pr, $ele->{value});
        }
      }
    }
  });
}
sub DumpStyle0{
  my($ds, $pr, $max_len1, $max_len2) = @_;
  MapPvt($ds, sub {
    my($ele, $sig) = @_;
    my $ele_info = $DD->get_ele_by_sig($sig);
    if($sig eq "(7fe0,0010)" && ref($ele->{value}) eq "ARRAY"){
      DumpCompressedPixelData($pr, $ele, $max_len1);
    } else {
      unless(defined($ele_info)){
        $ele_info = {
          Name => "<Unknown Priv Ele>",
          VR => 'UN',
          VM => 1,
        };
      }
      unless(defined($ele_info->{Name})){
         $ele_info->{Name} = "<Unknown (probably repeating) Ele>";
      }
      my $vr = $ele->{VR};
      unless(defined $vr) {
#Don't know why $vr would ever be undefined here
# (but it seems to be so for empty SQ's in private tags)
#Uncomment this print if you ever want to debug this...
#print STDERR "Sig: $sig\n";
        if(defined $ele_info->{VR}){
          $vr = $ele_info->{VR};
        } else {
          $vr = 'UN';
        }
      }
      my $vm = 1;
      if(ref($ele->{value}) eq "ARRAY"){
        $vm = @{$ele->{value}};
      }
      my $ele_name = defined($ele_info->{Name})? $ele_info->{Name} : "<undef>";
#      print $pr "$sig:($vr, $vm):$ele_info->{Name}:";
      $pr->print("$sig:($vr, $vm):$ele_name:");
      #print $pr "$ele->{file_pos}:$sig:($vr, $vm):$ele_info->{Name}:";
      DumpEle($pr, $ele, $max_len1);
#      print $pr "\n";
      $pr->print("\n");
      if(
        defined($ele->{type}) && 
        $ele->{type} eq "raw" &&
        defined $ele->{value} &&
        $ele->{VR} ne "OF"
      ){
        my $len = length($ele->{value});
        if($len < $max_len2){
          if(exists $ele->{big_endian}){
            HexDump::PrintBigEndian($pr, $ele->{value});
          } else {
            HexDump::PrintVax($pr, $ele->{value});
          }
        }
      }
    }
  });
}
sub DumpStyle1{
  my($ds, $pr, $max_len1, $max_len2) = @_;
  Map($ds, sub {
    my($ele, $root, $sig, $keys, $depth) = @_;
    my $ele_info = $DD->get_ele_by_sig($sig);
    unless(defined($ele_info)){
      $ele_info = {
        Name => "<Unknown Priv Ele>",
        VR => 'UN',
        VM => 1,
      };
    }
    unless(defined($ele_info->{Name})){
       $ele_info->{Name} = "<Unknown (probably repeating) Ele>";
    }
    my $vr = $ele_info->{VR};
    my $vm = 1;
    if(ref($ele->{value}) eq "ARRAY"){
      $vm = @{$ele->{value}};
    }
    print $pr "$sig:($vr, $vm):$ele_info->{Name}:";
    DumpEle($pr, $ele, $max_len1);
    print $pr "\n";
    if(
      defined($ele->{type}) && 
      $ele->{type} eq "raw" &&
      defined $ele->{value} &&
      $ele->{VR} ne "OF"
    ){
      my $len = length($ele->{value});
      if($len < $max_len2){
        if(exists $ele->{big_endian}){
          HexDump::PrintBigEndian($pr, $ele->{value});
        } else {
          HexDump::PrintVax($pr, $ele->{value});
        }
      }
    }
  });
}
sub DumpStyle2{
  my($ds, $pr, $max_len) = @_;
  Map($ds, sub {
    my($ele, $root, $sig, $keys, $depth) = @_;
    print $pr "$sig";
    my $grp = $keys->[0];
    my $elem = $keys->[1];
    DumpEleName($grp, $elem, $pr);
    DumpEle($pr, $ele, $max_len);
    print $pr "\n";
  });
}
sub DumpStyle3{
  my($ds, $pr, $max_len) = @_;
  Map($ds, sub {
    my($ele, $root, $sig, $keys, $depth) = @_;
    my $grp = $keys->[0];
    my $elem = $keys->[1];
    my $index = $keys->[2]->[3];
    my $ssig = (">" x $depth) . sprintf("(%04x,%04x)", $grp, $elem);
    if($depth > 0){
      print $pr "${ssig}[$index]";
    } else {
      print $pr "${ssig}";
    }
    DumpEleName($grp, $elem, $pr);
    DumpEle($pr, $ele, $max_len);
    print $pr "\n";
  });
}
sub DumpStyle4{
  my($ds, $pr, $max_len) = @_;
  Map($ds, sub {
    my($ele, $root, $sig, $keys, $depth) = @_;
    my $vr = $ele->{VR};
    my $vm = 1;
    if(ref($ele->{value}) eq "ARRAY"){
      $vm = @{$ele->{value}};
    }
#    printf $pr "%04x:",$ele->{file_pos};
    print $pr "$sig:($vr, $vm)";
    my $grp = $keys->[0];
    my $elem = $keys->[1];
    DumpEleName($grp, $elem, $pr);
    DumpEle($pr, $ele, $max_len);
    print $pr "\n";
  });
}
sub DumpStyle5{
  my($ds, $pr) = @_;
  Map($ds, sub {
    my($ele, $root, $sig, $keys, $depth) = @_;
    my $vr = $ele->{VR};
    my $vm = 1;
    if(ref($ele->{value}) eq "ARRAY"){
      $vm = @{$ele->{value}};
    }
    print $pr "$sig:($vr, $vm)";
    my $grp = $keys->[0];
    my $elem = $keys->[1];
    DumpEleName($grp, $elem, $pr);
    DumpEleLen($pr, $ele);
    print $pr "\n";
  });
}
sub DumpStyle6{
  my($ds, $pr, $max_len) = @_;
  Map($ds, sub {
    my($ele, $root, $sig, $keys, $depth) = @_;
    my $vr = $ele->{VR};
    my $vm = 1;
    if(ref($ele->{value}) eq "ARRAY"){
      $vm = @{$ele->{value}};
    }
#    printf $pr "%04x:",$ele->{file_pos};
    print $pr "$sig:($vr, $vm)";
    my $grp = $keys->[0];
    my $elem = $keys->[1];
    DumpEleName($grp, $elem, $pr);
    DumpEle($pr, $ele, $max_len);
    print $pr "\n";
    if($ele->{type} eq "raw" && defined $ele->{value}){
      my $len = length($ele->{value});
      if($len < 2049){
        if(exists $ele->{big_endian}){
          HexDump::PrintBigEndian($pr, $ele->{value});
        } else {
          HexDump::PrintVax($pr, $ele->{value});
        }
      }
    }
  });
}
sub MapTop{
  my($ds, $ele_fun) = @_;
  for my $grp (sort {$a <=> $b} keys %$ds){
    for my $ele (sort {$a <=> $b} keys %{$ds->{$grp}}){
      if($ele eq "private" || $ele eq "private_map"){
        next;
      }
      my $sig = sprintf("(%04x,%04x)", $grp, $ele);
      &$ele_fun($ds, $ds->{$grp}->{$ele}, $sig, $grp, $ele);
    }
  }
}
sub Map{
  my(
    $ds, $ele_fun, $ele_seq_end, $item_start_fun, $item_end_fun,
    $grp_start_fun, $grp_end_fun,
    $root, $sig, $key_list, $depth
  ) = @_;
  unless(defined $root) { $root = $ds }
  unless(defined $key_list) { $key_list = [] };
  unless(defined $sig) { $sig = "" };
  unless(defined $depth) { $depth = 0 };
  for my $grp (sort { $a <=> $b } keys %$ds ){
    if(defined $grp_start_fun && ref($grp_start_fun) eq "CODE"){
      &$grp_start_fun($root, $grp, $key_list, $depth);
    }
    if(exists $ds->{$grp}->{private}){
      $ds->ConvertFromPrivate($grp);
    }
    ele:
    for my $ele (sort { $a <=> $b } keys %{$ds->{$grp}}){
      if($ele eq "private" || $ele eq "private_map"){
        next;
      }
      my $n_sig = sprintf("%s(%04x,%04x)", $sig, $grp, $ele);
      my $element = $ds->{$grp}->{$ele};
      &$ele_fun($element, $root, $n_sig, [$grp, $ele, $key_list], $depth);
      if(
        exists($element->{VR}) &&
        $element->{VR} eq 'SQ' 
      ){
        if(
          exists($element->{value}) &&
          defined($element->{value}) &&
          ref($element->{value}) eq "ARRAY"
        ){
          for my $i (0 .. $#{$ds->{$grp}->{$ele}->{value}}){
            if(defined $item_start_fun && ref($item_start_fun) eq "CODE"){
              &$item_start_fun($root, [$grp, $ele, $key_list], $depth);
            }
            Map($ds->{$grp}->{$ele}->{value}->[$i],
              $ele_fun, $ele_seq_end, $item_start_fun, $item_end_fun,
              $grp_start_fun, $grp_end_fun,
              $root, "${n_sig}[$i]",
              [$grp, $ele, "value", $i, $key_list], $depth + 1
            );
            if(defined $item_end_fun && ref($item_end_fun) eq "CODE"){
              &$item_end_fun($root, [$grp, $ele, $key_list], $depth);
            }
          }
        }
        if(defined $ele_seq_end && ref($ele_seq_end) eq "CODE"){
          &$ele_seq_end($root, [$grp, $ele, $key_list], $depth);
        }
      }
    }
    if(defined $grp_end_fun && ref($grp_end_fun) eq "CODE"){
      &$grp_end_fun($root, $grp, $key_list, $depth);
    }
  }
}
sub unpad{
  my($vrdesc, $value) = @_;
  unless(defined $value) { return undef };
  if(exists($vrdesc->{padnull})){
    $value =~ s/\00//;
  }
  if($value =~ /\00/){
    $value =~ s/\00//g;
  }
  if(exists($vrdesc->{striptrailing})){
    $value =~ s/ +$//g;
  }
  if(exists($vrdesc->{stripleading})){
    $value =~ s/^ +//g;
  }
  return $value;
}
####!!!!!!!
#### This ugly piece of code may have additional bugs.
#### It needs to be checked/cleaned up.
#### Just a soon as a "Round Tuit" becomes available.
####
sub ConvertElementValue{
  my($before, $ele_info, $new_hash, $vax) = @_;
  unless(defined $ele_info->{VR}) { 
    die "VR undefined in ele_info";
  }
  my $vr = $ele_info->{VR};
  if(defined $before->{VR} && $before->{VR} ne "UN"){
    if($ele_info->{VR} ne "UN" && $ele_info->{VR} ne $before->{VR}){
      for my $key (keys %$ele_info){
        print STDERR "ele_info->{$key} = $ele_info->{$key}\n";
      }
      print STDERR "Explicit VR ($before->{VR}) doesn't match defined DD VR" .
      " ($ele_info->{VR})\n";
#      die "Explicit VR ($before->{VR}) doesn't match defined DD VR" .
#      " ($ele_info->{VR})";
    }
    $vr = $before->{VR};
  }
 
  my $VRDesc = $DD->{VRDesc}->{$vr};
  my $value = $before->{value};
  unless(defined $value) {
    $new_hash->{VM} = 0;
    $new_hash->{file_pos} = $before->{file_pos};
    $new_hash->{type} = $VRDesc->{type};
    $new_hash->{VR} = $ele_info->{VR};
    return;
  }
  unless(defined $VRDesc) { die "unknown VR: $vr" }
  unless(defined $VRDesc->{type}){
    die "type for $vr is undefined";
  }
  if($VRDesc->{type} eq "text"){
    my @values;
    unless(
      defined $ele_info->{VM} && $ele_info->{VM} eq 1
    ){
      if(ref($value) eq "ARRAY"){
        $new_hash->{VM} = $before->{VM};
        $new_hash->{value} = $value;
      } else {
        @values = split(/\\/, $value);
        for my $i (0 .. $#values){
          $values[$i] = unpad($VRDesc, $values[$i]);
        }
        $new_hash->{VM} = scalar @values;
        $new_hash->{value} = \@values;
      }
      $new_hash->{file_pos} = $before->{file_pos};
      $new_hash->{type} = $VRDesc->{type};
      $new_hash->{VR} = $vr;
      return;
    }
    $value = unpad($VRDesc, $value);
    $new_hash->{VM} =  1;
    $new_hash->{value} = $value;
    $new_hash->{file_pos} = $before->{file_pos};
    $new_hash->{type} = $VRDesc->{type};
    $new_hash->{VR} = $vr;
    return $new_hash;
  } elsif ($before->{type} ne "raw"){
    if(ref($before->{value}) eq "ARRAY"){
      $new_hash->{VM} =  scalar(@{$before->{value}});
      $new_hash->{value} = $before->{value};
      $new_hash->{file_pos} = $before->{file_pos};
      $new_hash->{type} = $before->{type};
      $new_hash->{VR} = $before->{VR};
      return;
    } else {
      $new_hash->{VM} =  1;
      $new_hash->{value} = $before->{value};
      $new_hash->{file_pos} = $before->{file_pos};
      $new_hash->{type} = $before->{type};
      $new_hash->{VR} = $before->{VR};
      return;
    }
  } elsif ($VRDesc->{type} eq "ulong" || $VRDesc->{type} eq "tag"){
    my @long;
    if($vax){
      @long = unpack("V*", $value);
    } else {
      @long = unpack("N*", $value);
    }
    if($ele_info->{VM} eq "1"){
      $new_hash->{VM} =  1;
      $new_hash->{value} = $long[0];
      $new_hash->{file_pos} = $before->{file_pos};
      $new_hash->{type} = $VRDesc->{type};
      $new_hash->{VR} = $vr;
      return;
    } else {
      $new_hash->{VM} =  scalar @long;
      $new_hash->{value} = \@long;
      $new_hash->{file_pos} = $before->{file_pos};
      $new_hash->{type} = $VRDesc->{type};
      $new_hash->{VR} = $vr;
      return;
    }
  } elsif ($VRDesc->{type} eq "float"){
    my @float;
    if($vax){
      @float = unpack("f*", pack("L*", unpack("V*", $value)));
    } else {
      @float = unpack("f*", pack("L*", unpack("N*", $value)));
    }
    if($ele_info->{VM} eq "1"){
      $new_hash->{VM} =  1;
      $new_hash->{value} = $float[0];
      $new_hash->{file_pos} = $before->{file_pos};
      $new_hash->{type} = $VRDesc->{type};
      $new_hash->{VR} = $vr;
      return;
    } else {
      $new_hash->{VM} =  scalar @float;
      $new_hash->{value} = \@float;
      $new_hash->{file_pos} = $before->{file_pos};
      $new_hash->{type} = $VRDesc->{type};
      $new_hash->{VR} = $vr;
      return;
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
    if($ele_info->{VM} eq "1"){
      $new_hash->{VM} =  1;
      $new_hash->{value} = $float[0];
      $new_hash->{file_pos} = $before->{file_pos};
      $new_hash->{type} = $VRDesc->{type};
      $new_hash->{VR} = $vr;
      return;
    } else {
      $new_hash->{VM} =  scalar @float;
      $new_hash->{value} = \@float;
      $new_hash->{file_pos} = $before->{file_pos};
      $new_hash->{type} = $VRDesc->{type};
      $new_hash->{VR} = $vr;
      return;
    }
  } elsif ($VRDesc->{type} eq "ushort"){
    my @short;
    if($vax){
      @short = unpack("v*", $value);
    } else {
      @short = unpack("n*", $value);
    }
    if($ele_info->{VM} eq "1"){
      $new_hash->{VM} =  1;
      $new_hash->{value} = $short[0];
      $new_hash->{file_pos} = $before->{file_pos};
      $new_hash->{type} = $VRDesc->{type};
      $new_hash->{VR} = $vr;
      return;
    } else {
      $new_hash->{VM} =  scalar @short;
      $new_hash->{value} = \@short;
      $new_hash->{file_pos} = $before->{file_pos};
      $new_hash->{type} = $VRDesc->{type};
      $new_hash->{VR} = $vr;
      return;
    }
  } elsif ($VRDesc->{type} eq "slong"){
    my @long;
    if($vax){
      @long = unpack("l*", pack("L*", unpack("V*", $value)));
    } else {
      @long = unpack("l*", pack("L*", unpack("N*", $value)));
    }
    if($ele_info->{VM} eq "1"){
      $new_hash->{VM} =  1;
      $new_hash->{value} = $long[0];
      $new_hash->{file_pos} = $before->{file_pos};
      $new_hash->{type} = $VRDesc->{type};
      $new_hash->{VR} = $vr;
      return;
    } else {
      $new_hash->{VM} =  scalar @long;
      $new_hash->{value} = \@long;
      $new_hash->{file_pos} = $before->{file_pos};
      $new_hash->{type} = $VRDesc->{type};
      $new_hash->{VR} = $vr;
      return;
    }
  } elsif ($VRDesc->{type} eq "sshort"){
    my @short;
    if($vax){
      @short = unpack("v*", $value);
    } else {
      @short = unpack("n*", $value);
    }
    if($ele_info->{VM} eq "1"){
      $new_hash->{VM} =  1;
      $new_hash->{value} = $short[0];
      $new_hash->{file_pos} = $before->{file_pos};
      $new_hash->{type} = $VRDesc->{type};
      $new_hash->{VR} = $vr;
      return;
    } else {
      $new_hash->{VM} =  scalar @short;
      $new_hash->{value} = \@short;
      $new_hash->{file_pos} = $before->{file_pos};
      $new_hash->{type} = $VRDesc->{type};
      $new_hash->{VR} = $vr;
      return;
    }
  } elsif ($VRDesc->{type} eq "raw"){
    $new_hash->{VM} =  1;
    $new_hash->{value} = $before->{value};
    $new_hash->{file_pos} = $before->{file_pos};
    $new_hash->{type} = $VRDesc->{type};
    $new_hash->{VR} = $vr;
    return;
  }
}
####!!!!!!!
sub ConvertToPrivate{
  my($ds, $grp) = @_;
  my %owners;
  my %r_owners;
  my %hash;
  for my $ele (sort { $a <=> $b} keys %{$ds->{$grp}}){
    my $before = $ds->{$grp}->{$ele};
    if($ele < 256){
      $ds->{$grp}->{$ele}->{value} =~ s/\0$//;
      my $owner = $ds->{$grp}->{$ele}->{value};
      $owners{$ele} = $owner;
      $r_owners{$owner} = $ele;
    } else {
      my $block = int($ele/256);
      my $pvt_ele = $ele % 256;
      unless(defined $owners{$block}){
        if(exists $DD->{ReverseDefaultPrivateGroupTags}->{$block}){
          my $owner = $DD->{ReverseDefaultPrivateGroupTags}->{$block};
          $r_owners{$owner} = $block;
          $owners{$block} = $owner;
        } else {
          my $owner = sprintf("Unnamed Private Block - %02x", $block);
          $r_owners{$owner} = $block;
          $owners{$block} = $owner;
        }
      }
      my $sig = sprintf("(%04x,\"%s\",%02x)", 
        $grp, $owners{$block}, $pvt_ele);
      my $ele_info = $DD->get_ele_by_sig($sig);
      unless(defined $ele_info){
        $ele_info = {
          VR => 'UN',
          VM => '1-n',
          Name => '<Unknown Private Element>',
        };
      }
      my %new_hash;
#      ConvertElementValue($before, $ele_info, \%new_hash, 1);
#      $hash{$owners{$block}}->{$pvt_ele} = \%new_hash;
      $hash{$owners{$block}}->{$pvt_ele} = $before;
    }
  }
  for my $i (keys %{$ds->{$grp}}){
    delete $ds->{$grp}->{$i};
  }
  $ds->{$grp}->{private} = \%hash;
  $ds->{$grp}->{private_map} = \%owners;
  $ds->{$grp}->{r_private_map} = \%r_owners;
}
sub ConvertFromPrivate{
  my($ds, $grp) = @_;
  my $private_map = $ds->{$grp}->{r_private_map};
  my $private = $ds->{$grp}->{private};
  my %r_private_map = reverse %$private_map;
  delete $ds->{$grp}->{private};
  delete $ds->{$grp}->{private_map};
  delete $ds->{$grp}->{r_private_map};
  for my $i (
    keys %$private_map
  ){
    $ds->{$grp}->{$private_map->{$i}} = {
      type => "text",
      VM => 1,
      VR => 'LO',
      value => $i,
    };
  }
  for my $i (sort { $a cmp $b } keys %$private){
    my $c_ele;
    if(exists $private_map->{$i}){
      $c_ele = $private_map->{$i};
    } else {
      my $t_ele = 0x10;
      ele:
      while(
        $t_ele < 0x100 &&
        !defined($c_ele)
      ){
        if(exists($private_map->{$t_ele})){
          $t_ele += 1;
          next ele;
        }
        $c_ele = $t_ele;
        $private_map->{$c_ele} = $i;
        $r_private_map{$i} = "Unnamed Private Block(1) - $c_ele";
      }
    }
    unless(defined $c_ele) { die "Ran out of private groups" }
    for my $l_ele (sort { $a <=> $b} keys %{$private->{$i}}){
      my $ele = ($c_ele * 256) + $l_ele;
      $ds->{$grp}->{$ele} = $private->{$i}->{$l_ele};
    }
  }
}
sub MapToConvertPvt{
  my($ds) = @_;
  for my $grp (sort { $a <=> $b } keys %$ds){
    if($grp & 1){
      unless(exists $ds->{$grp}->{private}){
        $ds->ConvertToPrivate($grp);
      }
      for my $owner (sort keys %{$ds->{$grp}->{private}}){
        for my $ele (
            sort { $a <=> $b} keys %{$ds->{$grp}->{private}->{$owner}}
        ){
          my $element = $ds->{$grp}->{private}->{$owner}->{$ele};
          if(
            exists($element->{VR}) &&
            $element->{VR} eq 'SQ' 
          ){
            if(
              exists($element->{value}) &&
              defined($element->{value}) &&
              ref($element->{value}) eq "ARRAY"
            ){
              for my $i (0 .. $#{$element->{value}}){
                my $item = $element->{value}->[$i];
                if(ref($item) && $item->can("MapToConvertPvt")){
                  $item->MapToConvertPvt();
                }
              }
            }
          }
        }
      }
    } else {
      for my $ele (sort {$a <=> $b} keys %{$ds->{$grp}}){
        if(
          $ds->{$grp}->{$ele}->{VR} eq "SQ" &&
          exists($ds->{$grp}->{$ele}->{value}) &&
          ref($ds->{$grp}->{$ele}->{value}) eq "ARRAY"
        ){
          for my $n_ds (@{$ds->{$grp}->{$ele}->{value}}){
            if(ref($n_ds) && $n_ds->can("MapToConvertPvt")){
              $n_ds->MapToConvertPvt();
            }
          }
        }
      }
    }
  }
}
sub MapToConvertPvtBack{
  my($ds) = @_;
  for my $grp (sort { $a <=> $b } keys %$ds){
    if($grp & 1){
      if(exists $ds->{$grp}->{private}){
        $ds->ConvertFromPrivate($grp);
      }
    }
    for my $ele (sort {$a <=> $b} keys %{$ds->{$grp}}){
      if(
        defined($ds->{$grp}->{$ele}->{VR}) &&
        $ds->{$grp}->{$ele}->{VR} eq "SQ" &&
        exists($ds->{$grp}->{$ele}->{value}) &&
        ref($ds->{$grp}->{$ele}->{value}) eq "ARRAY"
      ){
        for my $n_ds (@{$ds->{$grp}->{$ele}->{value}}){
          if(ref($n_ds) && $n_ds->can("MapToConvertPvtBack")){
            $n_ds->MapToConvertPvtBack();
          }
        }
      }
    }
  }
}
sub MapPvt{
  my($ds, $ele_fun, $sig) = @_;
  unless(defined $sig){ $sig = "" }
  for my $grp (sort { $a <=> $b } keys %$ds ){
    if($grp & 1){
      unless(exists $ds->{$grp}->{private}){
          $ds->ConvertToPrivate($grp);
      }
      for my $owner (sort keys %{$ds->{$grp}->{private}}){
        for my $ele (
            sort { $a <=> $b} keys %{$ds->{$grp}->{private}->{$owner}}
        ){
          my $n_sig = sprintf("%s(%04x,\"%s\",%02x)", $sig, $grp, $owner, $ele);
          my $element = $ds->{$grp}->{private}->{$owner}->{$ele};
          &$ele_fun($element, $n_sig);
          if(
            exists($element->{VR}) &&
            $element->{VR} eq 'SQ' 
          ){
            if(
              exists($element->{value}) &&
              defined($element->{value}) &&
              ref($element->{value}) eq "ARRAY"
            ){
              for my $i (0 .. $#{$element->{value}}){
                my $n_n_sig = $n_sig . "[$i]";
                MapPvt($element->{value}->[$i], 
                  $ele_fun, $n_n_sig);
              }
            }
          }
        }
      }
    } else {
      ele:
      for my $ele (sort { $a <=> $b } keys %{$ds->{$grp}}){
        my $n_sig = sprintf("%s(%04x,%04x)", $sig, $grp, $ele);
        my $element = $ds->{$grp}->{$ele};
        &$ele_fun($element, $n_sig);
        if(
          exists($element->{VR}) &&
          $element->{VR} eq 'SQ' 
        ){
          if(
            exists($element->{value}) &&
            defined($element->{value}) &&
            ref($element->{value}) eq "ARRAY"
          ){
            for my $i (0 .. $#{$ds->{$grp}->{$ele}->{value}}){
              MapPvt($ds->{$grp}->{$ele}->{value}->[$i], $ele_fun,
                "$n_sig" . "[$i]");
            }
          }
        }
      }
    }
  }
}
sub MapEle{
  my($ds, $ele_fun, $sig) = @_;
  unless(defined $sig){ $sig = "" }
  for my $grp (sort { $a <=> $b } keys %$ds ){
    if($grp & 1){
      unless(exists $ds->{$grp}->{private}){
        $ds->ConvertToPrivate($grp);
      }
      for my $owner (sort keys %{$ds->{$grp}->{private}}){
        for my $ele (
            sort { $a <=> $b} keys %{$ds->{$grp}->{private}->{$owner}}
        ){
          my $n_sig = sprintf("%s(%04x,\"%s\",%02x)", $sig, $grp, $owner, $ele);
          my $element = $ds->{$grp}->{private}->{$owner}->{$ele};
          &$ele_fun($element, $n_sig);
          if(
            exists($element->{VR}) &&
            $element->{VR} eq 'SQ' 
          ){
            if(
              exists($element->{value}) &&
              defined($element->{value}) &&
              ref($element->{value}) eq "ARRAY"
            ){
              for my $i (0 .. $#{$element->{value}}){
                my $n_n_sig = $n_sig . "[$i]";
                MapEle($element->{value}->[$i], 
                  $ele_fun, $n_n_sig);
              }
            }
          }
        }
      }
    } else {
      ele:
      for my $ele (sort { $a <=> $b } keys %{$ds->{$grp}}){
        my $n_sig = sprintf("%s(%04x,%04x)", $sig, $grp, $ele);
        my $element = $ds->{$grp}->{$ele};
        &$ele_fun($element, $n_sig);
        if(
          exists($element->{VR}) &&
          $element->{VR} eq 'SQ' 
        ){
          if(
            exists($element->{value}) &&
            defined($element->{value}) &&
            ref($element->{value}) eq "ARRAY"
          ){
            for my $i (0 .. $#{$ds->{$grp}->{$ele}->{value}}){
              MapEle($ds->{$grp}->{$ele}->{value}->[$i], $ele_fun,
                "$n_sig" . "[$i]");
            }
          }
        }
      }
    }
  }
}
sub MapDicomDir{
  my($this, $dir_fun) = @_;
  my $list = ExtractElementBySig($this, "(0004,1220)");
  my $first = ExtractElementBySig($this, "(0004,1200)");
  my $last = ExtractElementBySig($this, "(0004,1202)");
  my @stack;
  my $map = $this->{0x4}->{0x1220}->{item_map};
  my $start_map = $this->{0x4}->{0x1220}->{item_pos};
  my $end_map = $this->{0x4}->{0x1220}->{item_end_pos};
  my $level = 0;
  my $curr_loc = $first;
  node:
  while($curr_loc != 0 || $#stack >= 0){
    if($curr_loc == 0){
      $curr_loc = pop(@stack);
      my $ele_num = $map->{$curr_loc};
      my $ds = $list->[$ele_num];
      $curr_loc = $ds->ExtractElementBySig("(0004,1400)");
      $level -= 1;
      next node;
    }
    my $ele_num = $map->{$curr_loc};
    my $ds = $list->[$ele_num];
    my $offset = $start_map->{$ele_num};
    my $length = $end_map->{$ele_num} - $start_map->{$ele_num};
    &$dir_fun($ds, $curr_loc, $level, $ele_num, $offset, $length);
    my $child = $ds->ExtractElementBySig("(0004,1420)");
    if($child != 0){
      # push current, and go visit children
      push(@stack, $curr_loc);
      $level += 1;
      $curr_loc = $child;
      next node;
    }
    $curr_loc = $ds->ExtractElementBySig("(0004,1400)");
  }
}
sub Substitutions{
  my($this, $pat, $match, $list, $accum, $index_list, $depth, $full_pat) = @_;
  unless(defined $list) { $list = [] }
  unless(defined $accum) { $accum = [] }
  unless(defined $index_list) { $index_list = {} }
  unless(defined $depth) { $depth = 0 }
  unless(defined $full_pat) {$full_pat = ""}
  my $remain = $pat;
  if($pat =~ /^\((....),(....)\)\[([^\]]+)\](.*)$/){
    my $grp = hex($1);
    my $ele = hex($2);
    my $index = $3;
    $remain = $4;
    unless(defined $this->{$grp}->{$ele}){
      return {
        list =>$list,
        index_list => $index_list,
      };
    }
    if($index =~ /^\d+$/){
      unless($this->{$grp}->{$ele}->{VR} eq "SQ"){
        die "indexing a non seq VR";
      }
      $this = $this->{$grp}->{$ele}->{value}->[$index];
      unless(defined($this) && ref($this) eq "Posda::Dataset"){
        die "specified item of SQ is not a dataset";
      }
      return $this->Substitutions($remain, $match, $list, $accum, $index_list,
        $depth + 1, sprintf("$full_pat(%04x,%04x)[$index]", $grp, $ele));
    } elsif($index =~ /^<\d+>$/){
      my $which = scalar @$accum;
      $index_list->{$index} = $which;
      unless($this->{$grp}->{$ele}->{VR} eq "SQ"){
        die sprintf("indexing a non seq VR $full_pat(%04x,%04x)[$which]",
           $grp, $ele);
      }
      my $obj_list = $this->{$grp}->{$ele}->{value};
      for my $i (0 .. $#{$obj_list}){
        my $obj = $obj_list->[$i];
        if(defined $obj){
          unless(ref($obj) eq "Posda::Dataset"){
            die "item in a SQ is not a dataset";
          }
          if($remain){
            $obj->Substitutions($remain, 
              $match, $list, [@$accum, $i], $index_list,
              $depth+1, 
              sprintf("$full_pat(%04x,%04x)[$i]", $grp, $ele));
          } else {
            push(@$list, [@$accum, $i]);
          }
        }
      }
      return {
        list =>$list,
        index_list => $index_list,
      };
    } else {
      die "uncovered case";
    }
  } elsif($pat =~ /^\((....),(....)\)$/){
    my $grp = hex($1);
    my $ele = hex($2);
    if(exists $this->{$grp}->{$ele}){
      if(defined $match){
        if(ref($match) eq "CODE"){
          if(&$match($this->{$grp}->{$ele})){
            push(@$list, $accum);
          }
        } elsif($match eq $this->{$grp}->{$ele}->{value}){
          push(@$list, $accum);
        }
      } else {
        push(@$list, $accum);
      }
    }
    return {
      list =>$list,
      index_list => $index_list,
    };
  } else {
      die "bad pattern: $pat full_pat: $full_pat";
  }
}
sub MatchPat{
  my($this, $sig, $pat, $list) = @_;
  unless(defined $list) { $list = [] }
  unless(defined($sig) || defined($pat)){ return $list }
  if(defined($pat) && defined($sig) && $pat eq $sig) { return $list }
  unless(defined $pat) { return undef }
  unless(defined $sig) { return undef }
  if($pat =~ /^\((....),(....)\)\[([^\]]+)\](.*)$/){
    my $grp = $1;
    my $ele = $2;
    my $index = $3;
    my $remain_pat = $4;
    unless($sig =~ /^\($grp,$ele\)\[([^\]]+)\](.*)$/){
      return undef;
    }
    my $index_sig = $1;
    my $remain_sig = $2;
    if($index eq $index_sig){
      return MatchPat($this, $remain_sig, $remain_pat, $list);
    } elsif ($index =~ /^<\d+>$/) {
      return MatchPat($this, $remain_sig, $remain_pat, [@$list, $index_sig]);
    }
    return undef;
  } elsif ($pat =~ /^\((....),\"([^\"]+)\",(..)\)\[([^\]]+)\](.*)$/){
    my $grp = $1;
    my $owner = $2;
    my $ele = $3;
    my $index = $4;
    my $remain_pat = $5;
    unless($sig =~ /^\($grp,\"$owner\",$ele\)\[([^\]]+)\](.*)$/){ return undef }
    my $index_sig = $1;
    my $remain_sig = $2;
    if($index eq $index_sig){
      return MatchPat($this, $remain_sig, $remain_pat, $list);
    } elsif ($index =~ /^<\d+>$/) {
      return MatchPat($this, $remain_sig, $remain_pat, [@$list, $index_sig]);
    }
    return undef;
  }
  return undef;
}
####
# ?? Necessary ??
# or is this implicitly done?
# is that what we want?
####
sub RemoveUndefItems{
  my($this, $sig) = @_;
  my $value = $this->Get($sig);
  unless(defined $value){ return }
  unless(ref($value) eq "ARRAY"){
    return;
  }
  my @new_val;
  for my $i (@$value){
    if(defined $i) { push @new_val, $i }
  }
  $this->Insert($sig, \@new_val);
}
####
sub NextIndex{
  my($this, $sig) = @_;
  my $desc = $this->GetEle($sig);
  unless(defined $desc){ return undef; }
  unless($desc->{VR} eq "SQ"){ return undef; }
  unless(ref($desc->{value}) eq "ARRAY"){ return 0 }
  return(scalar @{$desc->{value}});
}
sub NewSearch{
  my($this, $pat, $match, $list, $accum, $index_list, $depth, $full_pat) = @_;
  unless(defined $list) { $list = [] }
  unless(defined $accum) { $accum = [] }
  unless(defined $index_list) { $index_list = {} }
  unless(defined $depth) { $depth = 0 }
  unless(defined $full_pat) {$full_pat = ""}
  my($grp, $ele, $owner, $index);
  my $remain = $pat;
  if($pat =~ /^\((....),(....)\)\[([^\]]+)\](.*)$/){
    $grp = hex($1);
    $ele = hex($2);
    $index = $3;
    $remain = $4;
    unless(defined $this->{$grp}->{$ele}){
      return $list;
    }
    if($index =~ /^\d+$/){
      unless($this->{$grp}->{$ele}->{VR} eq "SQ"){
        die "indexing a non seq VR";
      }
      $this = $this->{$grp}->{$ele}->{value}->[$index];
      unless(defined($this) && ref($this) eq "Posda::Dataset"){
        return $list;
      }
      return $this->NewSearch($remain, $match, $list, $accum, $index_list,
        $depth + 1, sprintf("$full_pat(%04x,%04x)[$index]", $grp, $ele));
    } elsif($index =~ /^<\d+>$/){
      my $which = scalar @$accum;
      $index_list->{$index} = $which;
      unless($this->{$grp}->{$ele}->{VR} eq "SQ"){
        die sprintf("indexing a non seq VR $full_pat(%04x,%04x)[$which]",
           $grp, $ele);
      }
      my $obj_list = $this->{$grp}->{$ele}->{value};
      unless(ref($obj_list) eq "ARRAY") { $obj_list = [] }
      for my $i (0 .. $#{$obj_list}){
        my $obj = $obj_list->[$i];
        if(defined $obj){
          unless(ref($obj) eq "Posda::Dataset"){
            die "item in a SQ is not a dataset";
          }
          if($remain){
            $obj->NewSearch($remain, 
              $match, $list, [@$accum, $i], $index_list,
              $depth+1, 
              sprintf("$full_pat(%04x,%04x)[$i]", $grp, $ele));
          } else {
            push(@$list, [@$accum, $i]);
          }
        }
      }
      return $list;
    } else {
      die "uncovered case";
    }
  } elsif ($pat=~ /^\((....),\"([^\"]*)\",(..)\)\[([^\]]+)\](.*)$/){
    $grp = hex($1);
    $owner = $2;
    $ele = hex($3);
    $index = $4;
    $remain = $5;
#print STDERR "Grp: $grp, Owner: $owner, Ele: $ele, Index: $index, remain: $remain\n";
    unless($grp & 1) { die "only private groups have owner: $pat" }
    unless(exists $this->{$grp}) { return undef }
    unless(exists $this->{$grp}->{private}){
        $this->ConvertToPrivate($grp);
    }
    unless(defined $this->{$grp}->{private}->{$owner}->{$ele}){
      return $list;
    }
    if($index =~ /^\d+$/){
      unless($this->{$grp}->{private}->{$owner}->{$ele}->{VR} eq "SQ"){
        die "indexing a non seq VR";
      }
      $this = $this->{$grp}->{private}->{$owner}->{$ele}->{value}->[$index];
      unless(defined($this) && ref($this) eq "Posda::Dataset"){
        return $list;
      }
      return $this->NewSearch($remain, $match, $list, $accum, $index_list,
        $depth + 1, 
        sprintf("$full_pat(%04x,\"$owner\",%02x)[$index]", $grp, $owner, $ele));
    } elsif($index =~ /^<\d+>$/){
      my $which = scalar @$accum;
      $index_list->{$index} = $which;
      unless($this->{$grp}->{private}->{$owner}->{$ele}->{VR} eq "SQ"){
        print STDERR  sprintf(
           "Warning: indexing a non seq VR $full_pat(%04x,\"$owner\",%02x)[$which]" .
           "  (%s)",
           $grp, $ele, $remain);
        #print STDERR "\n - ignoring this error.\n";
        return $list;
      }
      my $obj_list = $this->{$grp}->{private}->{$owner}->{$ele}->{value};
      for my $i (0 .. $#{$obj_list}){
        my $obj = $obj_list->[$i];
        if(defined $obj){
          unless(ref($obj) eq "Posda::Dataset"){
            die "item in a SQ is not a dataset";
          }
          if($remain){
            $obj->NewSearch($remain, 
              $match, $list, [@$accum, $i], $index_list,
              $depth+1, 
              sprintf("$full_pat(%04x,\"$owner\",%02x)[$i]", $grp, $ele));
          } else {
            push(@$list, [@$accum, $i]);
          }
        }
      }
      return $list;
    }
  } elsif($pat =~ /^\((....),(....)\)$/){
    my $grp = hex($1);
    my $ele = hex($2);
    if(exists $this->{$grp}->{$ele}){
      if(defined $match){
        if(ref($match) eq "CODE"){
          if(&$match($this->{$grp}->{$ele})){
            push(@$list, $accum);
          }
        } else{
          if($match eq $this->{$grp}->{$ele}->{value}){
            push(@$list, $accum);
          }
        }
      } else {
        push(@$list, $accum);
      }
    }
    return $list;
  } elsif ($pat=~ /^\((....),\"([^\"]*)\",(..)\)$/){
    $grp = hex($1);
    $owner = $2;
    $ele = hex($3);
#print STDERR "Grp: $grp, Owner: $owner, Ele: $ele\n";
    unless($grp & 1) { die "only private groups have owner: $pat" }
    unless(exists $this->{$grp}) { return undef }
    unless(exists $this->{$grp}->{private}){
        $this->ConvertToPrivate($grp);
    }
    unless(defined $this->{$grp}->{private}->{$owner}->{$ele}){
      return $list;
    }
    if(exists $this->{$grp}->{private}->{$owner}->{$ele}){
      if(defined $match){
        if(ref($match) eq "CODE"){
          if(&$match($this->{$grp}->{private}->{$owner}->{$ele})){
            push(@$list, $accum);
          }
        } else{
          if($match eq $this->{$grp}->{privater}->{$owner}->{$ele}->{value}){
            push(@$list, $accum);
          }
        }
      } else {
        push(@$list, $accum);
      }
    }
    return $list;
  } else {
    my $message = "Backtrace:\n";
    my $i = 0;
    while(caller($i)){
      my @foo = caller($i);
      $i++;
      my $file = $foo[1];
      my $line = $foo[2];
      $message .= "\tline $line of $file\n";
    }
    die $message . "bad pattern ($full_pat)";
  }
}
sub Search{
  my($this, $pat, $match, $list, $accum, $index_list, $depth, $full_pat) = @_;
  #if($pat =~ /A-F/) { $pat =~ tr/A-F/a-f/ }
  unless(defined $list) { $list = [] }
  unless(defined $accum) { $accum = [] }
  unless(defined $index_list) { $index_list = {} }
  unless(defined $depth) { $depth = 0 }
  unless(defined $full_pat) {$full_pat = ""}
  my $remain = $pat;
  if($pat =~ /^\((....),(....)\)\[([^\]]+)\](.*)$/){
    my $grp = hex($1);
    my $ele = hex($2);
    my $index = $3;
    $remain = $4;
    unless(defined $this->{$grp}->{$ele}){
      return $list;
#      return {
#        list =>$list,
#        index_list => $index_list,
#      };
    }
    if($index =~ /^\d+$/){
      unless($this->{$grp}->{$ele}->{VR} eq "SQ"){
        die "indexing a non seq VR";
      }
      $this = $this->{$grp}->{$ele}->{value}->[$index];
      unless(defined($this) && ref($this) eq "Posda::Dataset"){
#        print STDERR "specified item of SQ is not a dataset " .
#          sprintf("$full_pat(%04x,%04x)[$index]", $grp, $ele) . "\n";
        return $list;
      }
      return $this->Search($remain, $match, $list, $accum, $index_list,
        $depth + 1, sprintf("$full_pat(%04x,%04x)[$index]", $grp, $ele));
    } elsif($index =~ /^<\d+>$/){
      my $which = scalar @$accum;
      $index_list->{$index} = $which;
      unless($this->{$grp}->{$ele}->{VR} eq "SQ"){
        die sprintf("indexing a non seq VR $full_pat(%04x,%04x)[$which]",
           $grp, $ele);
      }
      my $obj_list = $this->{$grp}->{$ele}->{value};
      unless(ref($obj_list) eq "ARRAY"){ return $list }
      for my $i (0 .. $#{$obj_list}){
        my $obj = $obj_list->[$i];
        if(defined $obj){
          unless(ref($obj) eq "Posda::Dataset"){
            die "item in a SQ is not a dataset";
          }
          if($remain){
            $obj->Search($remain, 
              $match, $list, [@$accum, $i], $index_list,
              $depth+1, 
              sprintf("$full_pat(%04x,%04x)[$i]", $grp, $ele));
          } else {
            push(@$list, [@$accum, $i]);
          }
        }
      }
      return $list;
    } else {
      die "uncovered case";
    }
  } elsif($pat =~ /^\((....),(....)\)$/){
    my $grp = hex($1);
    my $ele = hex($2);
    if(exists $this->{$grp}->{$ele}){
      if(defined $match){
        if(ref($match) eq "CODE"){
          if(&$match($this->{$grp}->{$ele})){
            push(@$list, $accum);
          }
        } else{
          if($match eq $this->{$grp}->{$ele}->{value}){
            push(@$list, $accum);
          }
        }
      } else {
        push(@$list, $accum);
      }
    }
    return $list;
  } else {
    print STDERR "Backtrace:\n";
    my $i = 0;
    while(caller($i)){
      my @foo = caller($i);
      $i++;
      my $file = $foo[1];
      my $line = $foo[2];
      print STDERR "\tline $line of $file\n";
    }

    die "bad pattern ($pat)";
  }
}
sub Substitute{
  my($ds, $pat, $sub, $map) = @_;
  my $ret = $pat;
  for my $i (keys %$map){
    $ret =~ s/$i/$sub->[$map->{$i}]/eg;
  }
  return $ret;
}
sub DefaultSubstitute{
  my($ds, $pat, $sub) = @_;
  my %map;
  for my $i (0 .. $#{$sub}){
    $map{"<$i>"} = $i;
  }
  return Substitute($ds, $pat, $sub, \%map);
}
sub MakeMatchPat{
  my($class, $sig) = @_;
  my $remain = $sig;
  my $pat = "";
  my @indices;
  while($remain){
    if($remain =~ /^([^\[]*)\[(\d+)\](.*)$/){
      my $prefix = $1;
      my $index = $2;
      $remain = $3;
      my $cur = scalar @indices;
      $pat .= $prefix . "[<$cur>]";
      push(@indices, $index);
    } else {
      $pat .= $remain;
      $remain = "";
    }
  }
  return $pat, \@indices;
}
sub ExtractElementBySig{
  my($this, $sig) = @_;
  my($grp, $ele, $remain);
  if($sig =~ /^\((....),(....)\)(.*)$/){
    $grp = hex($1);
    $ele = hex($2);
    $remain = $3;
  } else {
    die "Sig ($sig) didn't match";
  }
  unless(
    exists($this->{$grp}->{$ele}) &&
    exists($this->{$grp}->{$ele}->{value})
  ){
    return undef;
  }
  my $value = $this->{$grp}->{$ele}->{value};
  if($remain ne ""){
    if($remain =~ /^\[(\d+)\]$/){
      my $index = $1;
      unless(ref($value) eq "ARRAY"){
        return undef;
      }
      return $value->[$index];
    } elsif($this->{$grp}->{$ele}->{VR} ne "SQ"){
      die "invalid remaining (\"$remain\") for non-seq (" .
        "$this->{$grp}->{$ele}->{VR}) element";
    } elsif(
      $remain =~ /^\[(\d+)\]>(.*)$/ or
      $remain =~ /^\[(\d+)\](.*)$/
    ){
      my $index = $1;
      my $new_sig = $2;
      unless(
        defined($value) &&
        ref($value) eq "ARRAY" &&
        exists $value->[$index] &&
        defined $value->[$index] &&
        ref($value->[$index]) ne "" &&
        $value->[$index]->isa("Posda::Dataset")
      ){
        return undef;
      }
      $value = $value->[$index]->ExtractElementBySig($new_sig);
    } else {
      TraceAndDie "can't make sense of \"$sig\"";
    }
  }
  return $value;
};
sub ExtractPvtElementBySig{
  my($this, $sig) = @_;
  my($grp, $ele, $owner, $remain);
  if($sig =~ /^\((....),(....)\)(.*)$/){
    $grp = hex($1);
    $ele = hex($2);
    $remain = $3;
  } elsif ($sig =~ /^\((....),\"([^\"]*)\",(..)\)(.*)$/){
    $grp = hex($1);
    $owner = $2;
    $ele = hex($3);
    $remain = $4;
    unless(exists $this->{$grp}->{private}){
      ($this->{$grp}->{private}, $this->{$grp}->{private_map}) = 
        $this->OldConvertToPrivate($grp);
    }
  } else {
    die "Sig ($sig) didn't match";
  }
  unless(
    (
      (! defined($owner)) &&
      exists($this->{$grp}->{$ele}) &&
      exists($this->{$grp}->{$ele}->{value})
    ) || (
      defined($owner) &&
      exists($this->{$grp}->{private}) &&
      exists($this->{$grp}->{private}->{$owner}) &&
      exists($this->{$grp}->{private}->{$owner}->{$ele}) &&
      exists($this->{$grp}->{private}->{$owner}->{$ele}->{value})
    )
  ){
    return undef;
  }
  my $descrip;
  if(defined($owner)){
    $descrip = $this->{$grp}->{private}->{$owner}->{$ele};
  } else {
    $descrip = $this->{$grp}->{$ele};
  }
  my $value = $descrip->{value};
  if($remain ne ""){
    if($remain =~ /^\[(\d+)\]$/){
      my $index = $1;
      unless(ref($value) eq "ARRAY"){
        return undef;
      }
      return $value->[$index];
    } elsif($descrip->{VR} ne "SQ"){
      die "invalid remaining (\"$remain\") for non-seq (" .
        "$descrip->{VR}) element";
    } elsif(
      $remain =~ /^\[(\d+)\]>(.*)$/ or
      $remain =~ /^\[(\d+)\](.*)$/
    ){
      my $index = $1;
      my $new_sig = $2;
      unless(
        defined($value) &&
        ref($value) eq "ARRAY" &&
        exists $value->[$index] &&
        defined $value->[$index] &&
        ref($value->[$index]) ne "" &&
        $value->[$index]->isa("Posda::Dataset")
      ){
        return undef;
      }
      $value = $value->[$index]->ExtractPvtElementBySig($new_sig);
    } else {
      TraceAndDie "can't make sense of \"$sig\"";
    }
  }
  return $value;
};
sub GetEle{
  my($this, $sig) = @_;
  #if($sig =~ /[A-F]/){ $sig =~ tr/A-F/a-f/ }
  my($grp, $ele, $owner, $remain);
  if($sig =~ /^\((....),(....)\)(.*)$/){
    $grp = hex($1);
    $ele = hex($2);
    $remain = $3;
    if(
      ($grp & 1) && 
      exists($this->{$grp}) && 
      exists($this->{$grp}->{private})
    ){
      $this->ConvertFromPrivate($grp);
    }
  } elsif ($sig =~ /^\((....),\"([^\"]*)\",(..)\)(.*)$/){
    $grp = hex($1);
    unless($grp & 1) { die "only private groups have owner: $sig" }
    $owner = $2;
    $ele = hex($3);
    $remain = $4;
    unless(exists $this->{$grp}) { return undef }
    unless(exists $this->{$grp}->{private}){
        $this->ConvertToPrivate($grp);
    }
  } else {
    die "Sig ($sig) didn't match";
  }
  unless(
    (
      (! defined($owner)) &&
        exists($this->{$grp}->{$ele}) # &&
#        exists($this->{$grp}->{$ele}->{value})
    ) || (
      defined($owner) &&
      exists($this->{$grp}->{private}) &&
      exists($this->{$grp}->{private}->{$owner}) &&
      exists($this->{$grp}->{private}->{$owner}->{$ele}) # &&
#      exists($this->{$grp}->{private}->{$owner}->{$ele}->{value})
    )
  ){
    return undef;
  }
  my $descrip;
  if(defined($owner)){
    $descrip = $this->{$grp}->{private}->{$owner}->{$ele};
  } else {
    $descrip = $this->{$grp}->{$ele};
  }
  if($remain eq ""){
    return $descrip;
  } else {
    if($remain =~ /^\[(\d+)\]$/){
      die "Can't have terminating index for GetEle";
    } elsif($descrip->{VR} ne "SQ"){
      die "invalid remaining (\"$remain\") for non-seq (" .
        "$descrip->{VR}) element";
    } elsif(
      $remain =~ /^\[(\d+)\]>(.*)$/ or
      $remain =~ /^\[(\d+)\](.*)$/
    ){
      my $index = $1;
      my $new_sig = $2;
      my $value = $descrip->{value};
      unless(
        defined($value) &&
        ref($value) eq "ARRAY" &&
        exists $value->[$index] &&
        defined $value->[$index] &&
        ref($value->[$index]) ne "" &&
        $value->[$index]->isa("Posda::Dataset")
      ){
        return undef;
      }
      return $value->[$index]->GetEle($new_sig);
    } else {
      TraceAndDie "can't make sense of \"$sig\"";
    }
  }
}
sub ValidateSig{
  my($this, $sig) = @_;
  my($grp, $ele, $owner, $remain);
  if($sig =~ /^\((....),(....)\)(.*)$/){
    $grp = $1; $ele = $2; $remain = $3;
  } elsif ($sig =~ /^\((....),\"([^\"]*)\",(..)\)(.*)$/){
    $grp = $1; $ele = $2; $owner = $3; $remain = $4;
  } else { return undef };
  unless($remain){ return 1 }
  my $index;
  if($remain =~ /^\[(\d+)\](.*)$/){
    $index = $1;
    $remain = $2;
    unless($remain) { return 1 }
  } else { return 0 }
  return ValidateSig($this, $remain);
}
sub ValidatePattern{
  my($this, $pat) = @_;
  my($grp, $ele, $owner, $remain);
  if($pat =~ /^\((....),(....)\)(.*)$/){
    $grp = $1; $ele = $2; $remain = $3;
  } elsif ($pat =~ /^\((....),\"([^\"]*)\",(..)\)(.*)$/){
    $grp = $1; $ele = $2; $owner = $3; $remain = $4;
  } else { return undef };
  unless($remain){ return 1 }
  my $index;
  if($remain =~ /^\[<(\d+)>\](.*)$/){
    $index = $1;
    $remain = $2;
    unless($remain) { return 1 }
  } else { return 0 }
  return ValidatePattern($this, $remain);
}

sub Get{
  my($this, $sig) = @_;
  #if($sig =~ /[A-F]/){ $sig =~ tr/A-F/a-f/ }
  my($grp, $ele, $owner, $remain);
  if($sig =~ /^\((....),(....)\)(.*)$/){
    $grp = hex($1);
    $ele = hex($2);
    $remain = $3;
    if(
      ($grp & 1) && 
      exists($this->{$grp}) && 
      exists($this->{$grp}->{private})
    ){
      $this->ConvertFromPrivate($grp);
    }
  } elsif ($sig =~ /^\((....),\"([^\"]*)\",(..)\)(.*)$/){
    $grp = hex($1);
    unless($grp & 1) { die "only private groups have owner: $sig" }
    $owner = $2;
    $ele = hex($3);
    $remain = $4;
    unless(exists $this->{$grp}) { return undef }
    unless(exists $this->{$grp}->{private}){
        $this->ConvertToPrivate($grp);
    }
  } else {
    die "Sig ($sig) didn't match";
  }
  unless(
    (
      (! defined($owner)) &&
      exists($this->{$grp}->{$ele}) &&
      exists($this->{$grp}->{$ele}->{value})
    ) || (
      defined($owner) &&
      exists($this->{$grp}->{private}) &&
      exists($this->{$grp}->{private}->{$owner}) &&
      exists($this->{$grp}->{private}->{$owner}->{$ele}) &&
      exists($this->{$grp}->{private}->{$owner}->{$ele}->{value})
    )
  ){
    return undef;
  }
  my $descrip;
  if(defined($owner)){
    $descrip = $this->{$grp}->{private}->{$owner}->{$ele};
  } else {
    $descrip = $this->{$grp}->{$ele};
  }
  my $value = $descrip->{value};
  if($remain ne ""){
    if($remain =~ /^\[(\d+)\]$/){
      my $index = $1;
      unless(ref($value) eq "ARRAY"){
        return undef;
      }
      return $value->[$index];
    } elsif($descrip->{VR} ne "SQ"){
      die "invalid remaining (\"$remain\") for non-seq (" .
        "$descrip->{VR}) element";
    } elsif(
      $remain =~ /^\[(\d+)\]>(.*)$/ or
      $remain =~ /^\[(\d+)\](.*)$/
    ){
      my $index = $1;
      my $new_sig = $2;
      unless(
        defined($value) &&
        ref($value) eq "ARRAY" &&
        exists $value->[$index] &&
        defined $value->[$index] &&
        ref($value->[$index]) ne "" &&
        $value->[$index]->isa("Posda::Dataset")
      ){
        return undef;
      }
      $value = $value->[$index]->Get($new_sig);
    } else {
      TraceAndDie "can't make sense of \"$sig\"";
    }
  }
  return $value;
};
sub ValueDigest{
  my($this, $sig, $value, $digest) = @_;
  unless(defined $digest) {
    $digest = Digest::MD5->new;
  }
  if(!ref($value)){
    unless(defined($value)) { $value = "<undef>" }
    $digest->add($sig);
    $digest->add($value);
    my $foo = $digest->hexdigest;
    return $foo;
  } elsif(ref($value) eq "ARRAY"){
    $digest->add($sig);
    for my $item_i (0 .. $#{$value}){
      my $item = $value->[$item_i];
      if(ref($item) eq "Posda::Dataset"){
        $item->MapEle(sub{
          my($ele, $sub_sig) = @_;
          my $ele_dig = $item->ValueDigest($sub_sig, $ele->{value}, $digest);
          $digest->add($ele_dig);
        });
        my $foo = $digest->hexdigest;
        return $foo;
      } elsif(ref($item) ne ""){
        my $foo = ref($item);
        die "In ValueDigest: item is $foo\n";
      } elsif(defined $item){
        $digest->add($item);
      } else {
        $digest->add("<undef>");
      }
    }
    my $foo = $digest->hexdigest;
    return $foo;
  } else {
    my $foo = ref($value);
    die "In ValueDigest: value is $foo\n";
  }
};
sub Insert{
  my($this, $sig, $value) = @_;
  my($grp, $ele, $remain, $owner);
  if($sig =~ /^\((....),(....)\)(.*)$/){
    $grp = hex($1);
    $ele = hex($2);
    $remain = $3;
    if($grp & 1 && exists ($this->{grp}) && exists $this->{grp}->{private}){
      $this->ConvertFromPrivate($grp);
    }
  } elsif ($sig =~ /^\((....),\"([^\"]*)\",(..)\)(.*)$/){
    $grp = hex($1);
    $owner = $2;
    $ele = hex($3);
    $remain = $4;
    unless($grp & 1) { die "must be odd group to have owner" }
    if(exists $this->{$grp}){
      unless(exists $this->{$grp}->{private}){
        $this->ConvertToPrivate($grp);
      }
    } else {
      $this->{$grp} = {
        private => {},
        private_map => {},
        r_private_map => {},
      };
    }
  } else {
    die "Sig \"$sig\" didn't match";
  }
  #  Here we have $grp, $owner, $ele set up
  if($remain eq ""){
    # We are at the element
    if(defined $owner){
#      if($Debug){
#        print STDERR "#################################\n";
#        print STDERR "Insert($sig) begin\nthis: ";
#        Debug::GenPrint($dbg, $this, 1, 5);
#        print STDERR "\n#################################\n";
#      }
      # the element is private, by owner
      unless(exists $this->{$grp}->{r_private_map}->{$owner}){
        # grab an block if not one
        my $block;
        if(exists $DD->{ReverseDefaultPrivateGroupTags}->{$owner}){
          $block = $DD->{ReverseDefaultPrivateGroupTags}->{$owner};
          if(
            exists $this->{$grp}->{r_private_map}->{$block} &&
            $owner ne $this->{$grp}->{r_private_map}->{$block}
          ){
            die "Default Block $block allocated for " .
             "$this->{$grp}->{r_private_map}->{$block} vs $owner";
          }
        } else {
          block:
          for my $i (0x10 .. 0xff){
            if(defined $this->{$grp}->{private_map}->{$i}){ next block }
            $block = $i;
            last block;
          }
          unless(defined $block) { die "unable to allocate private block" }
        }
        $this->{$grp}->{private_map}->{$block} = $owner;
        $this->{$grp}->{r_private_map}->{$owner} = $block;
      }
      if(exists $this->{$grp}->{private}->{$owner}->{$ele}->{type}){
        # set it if its there
        $this->{$grp}->{private}->{$owner}->{$ele}->{value} = $value;
      } else {
        $this->{$grp}->{private}->{$owner}->{$ele} = {
          VR => $DD->get_pvt_vr($grp, $owner, $ele),
          type => $DD->get_pvt_type($grp, $owner, $ele),
          value => $value,
        }
      }
    } else {
      # the element is standard, or private by element
      if(exists $this->{$grp}->{$ele}->{type}){
        # and its there
        $this->{$grp}->{$ele}->{value} = $value;
      } else {
        # else it needs to be created
        $this->{$grp}->{$ele} = {
          VR => $DD->get_vr($grp, $ele),
          type => $DD->get_type($grp, $ele),
          value => $value,
        };
      }
    }
  } elsif ($remain =~ /^\[(\d+)\]$/){
    # We are addressing an item in a sequence
    my $index = $1;
    if(defined $owner){
      # and its a private element by owner
      unless(exists $this->{$grp}->{private}->{$owner}->{$ele}){
        $this->{$grp}->{$ele} = {
          VR => $DD->get_pvt_vr($grp, $owner, $ele),
          type => $DD->get_pvt_type($grp, $owner, $ele),
          value => [],
        };
      }
      if(
        exists($this->{$grp}->{private}->{$owner}->{$ele}) &&
        exists($this->{$grp}->{private}->{$owner}->{$ele}->{value}) &&
        ref($this->{$grp}->{private}->{$owner}->{$ele}->{value}) eq "ARRAY"
      ){
        # store the value if its an array
        $this->{$grp}->{private}->{$owner}->{$ele}->{value}->[$index] = $value;
      }elsif(
        exists($this->{$grp}->{private}->{$owner}->{$ele}) &&
        exists($this->{$grp}->{private}->{$owner}->{$ele}->{value}) &&
        $this->{$grp}->{private}->{$owner}->{$ele}->{value} eq ""
      ){
        # create array and store value if its blank
        $this->{$grp}->{private}->{$owner}->{$ele}->{value} = [];
        $this->{$grp}->{private}->{$owner}->{$ele}->{value}->[$index] = $value;
      } else {
        # or error off
        die "insert into non-array";
      } 
    } else {
      # and its a standard (or private by element)
      unless(exists $this->{$grp}->{$ele}){
        # create the array if not present
        $this->{$grp}->{$ele} = {
          VR => $DD->get_vr($grp, $ele),
          type => $DD->get_type($grp, $ele),
          value => [],
        };
      }
      if(
        exists($this->{$grp}->{$ele}) &&
        exists($this->{$grp}->{$ele}->{value}) &&
        ref($this->{$grp}->{$ele}->{value}) eq "ARRAY"
      ){
        # store the value if its an array
        $this->{$grp}->{$ele}->{value}->[$index] = $value;
      } elsif(
        # create array if element present and blank
        exists($this->{$grp}->{$ele}) &&
        exists($this->{$grp}->{$ele}->{value}) &&
        $this->{$grp}->{$ele}->{value} eq ""
      ){
        # store the value if its an array
        $this->{$grp}->{$ele}->{value} = [];
        $this->{$grp}->{$ele}->{value}->[$index] = $value;
      } else {
        # or error off
        die "insert into non-array";
      }
    }
  } elsif (
    $remain =~ /^\[(\d+)\]>(.*)$/ or
    $remain =~ /^\[(\d+)\]\.(.*)$/ or
    $remain =~ /^\[(\d+)\](.*)$/
  ){
    my $index = $1;
    my $new_sig = $2;
    if(defined $owner){
      unless(exists $this->{$grp}->{r_private_map}->{$owner}){
        # grab an owner block if not one
        my $block;
        if(exists $DD->{DefaultPrivateGroupTags}->{$owner}){
          $block = $DD->{DefaultPrivateGroupTags}->{$owner};
          if(exists $this->{$grp}->{private_map}->{$block}){
            die "Default Block $block allocated for " .
             "$this->{$grp}->{private_map}->{$block} vs $owner";
          }
        } else {
          block:
          for my $i (0x10 .. 255){
            if(defined $this->{$grp}->{private_map}->{$i}){ next block }
            $block = $i;
            last block;
          }
          unless(defined $block) { die "unable to allocate private block" }
        }
        $this->{$grp}->{r_private_map}->{$owner} = $block;
        $this->{$grp}->{private_map}->{$block} = $owner;
      }
      unless(exists $this->{$grp}->{private}->{$owner}->{$ele}){
        $this->{$grp}->{private}->{$owner}->{$ele} = {
          VR => 'SQ',
          VM => 0,
          value => [],
          type => 'seq',
        };
      }
    } else {
      unless(exists $this->{$grp}->{$ele}){
        $this->{$grp}->{$ele} = {
          VR => 'SQ',
          VM => 0,
          value => [],
          type => 'seq',
        };
      }
    }
    my $new_ds;
    if(defined $owner){
      if($this->{$grp}->{private}->{$owner}->{$ele}->{VR} ne "SQ"){
        die "invalid remaining (\"$remain\") for non-seq (" .
          "$this->{$grp}->{private}->{$owner}->{$ele}->{VR}) element";
      }
      if(
        exists($this->{$grp}->{private}->{$owner}->{$ele}->{value}) &&
        defined($this->{$grp}->{private}->{$owner}->{$ele}->{value}) &&
        ref($this->{$grp}->{private}->{$owner}->{$ele}->{value}) eq "ARRAY" &&
        exists $this->{$grp}->{private}->{$owner}->{$ele}->{value}->[$index]
      ){
        if(
          ref($this->{$grp}->{private}->{$owner}->{$ele}->{value}->[$index])
          eq "Posda::Dataset"
        ){
          $new_ds = 
            $this->{$grp}->{private}->{$owner}->{$ele}->{value}->[$index];
        } else {
          die "Sequence item is not a dataset, $sig";
        }
      } else {
        $new_ds = Posda::Dataset->new_blank();
        $this->{$grp}->{private}->{$owner}->{$ele}->{value}->[$index] = $new_ds;
      }
    } else {
      if($this->{$grp}->{$ele}->{VR} ne "SQ"){
        die "invalid remaining (\"$remain\") for non-seq (" .
          "$this->{$grp}->{$ele}->{VR}) element";
      }
      if(
        exists($this->{$grp}->{$ele}->{value}) &&
        defined($this->{$grp}->{$ele}->{value}) &&
        ref($this->{$grp}->{$ele}->{value}) eq "ARRAY" &&
        exists $this->{$grp}->{$ele}->{value}->[$index]
      ){
        if(ref($this->{$grp}->{$ele}->{value}->[$index]) eq "Posda::Dataset"){
          $new_ds = $this->{$grp}->{$ele}->{value}->[$index];
        } else {
          die "Sequence item is not a dataset, $sig";
        }
      } else {
        $new_ds = Posda::Dataset->new_blank();
        $this->{$grp}->{$ele}->{value}->[$index] = $new_ds;
      }
    }
    $new_ds->Insert($new_sig, $value);
  } else {
    die "non-matching sig: $sig\n";
  }
};
sub InsertElementBySig{
  my($this, $sig, $value) = @_;
  my($grp, $ele, $remain);
  if($sig =~ /^\((....),(....)\)(.*)$/){
    $grp = hex($1);
    $ele = hex($2);
    $remain = $3;
  } else {
    die "Sig ($sig) didn't match";
  }
  if($remain eq ""){
    if(exists $this->{$grp}->{$ele}->{type}){
      $this->{$grp}->{$ele}->{value} = $value;
    } else {
      $this->{$grp}->{$ele} = {
         VR => $DD->get_vr($grp, $ele),
         type => $DD->get_type($grp, $ele),
         value => $value,
      };
    }
  } elsif ($remain =~ /^\[(\d+)\]$/){
      my $index = $1;
      unless(exists $this->{$grp}->{$ele}){
        $this->{$grp}->{$ele} = {
          VR => $DD->get_vr($grp, $ele),
          type => $DD->get_type($grp, $ele),
          value => [],
        };
      }

      if(
        exists($this->{$grp}->{$ele}) &&
        exists($this->{$grp}->{$ele}->{value}) &&
        ref($this->{$grp}->{$ele}->{value}) eq "ARRAY"
      ){
        $this->{$grp}->{$ele}->{value}->[$index] = $value;
      } else {
        die "insert into non-array";
      }
  } elsif (
    $remain =~ /^\[(\d+)\]>(.*)$/ or
    $remain =~ /^\[(\d+)\](.*)$/
  ){
    my $index = $1;
    my $new_sig = $2;
    unless(exists $this->{$grp}->{$ele}){
      $this->{$grp}->{$ele} = {
        VR => 'SQ',
        VM => 0,
        value => [],
        type => 'seq',
      };
    }
    if($this->{$grp}->{$ele}->{VR} ne "SQ"){
      die "invalid remaining (\"$remain\") for non-seq (" .
        "$this->{$grp}->{$ele}->{VR}) element";
    }
    my $new_ds;
    if(
      exists($this->{$grp}->{$ele}->{value}) &&
      defined($this->{$grp}->{$ele}->{value}) &&
      ref($this->{$grp}->{$ele}->{value}) eq "ARRAY" &&
      exists $this->{$grp}->{$ele}->{value}->[$index]
    ){
      if(ref($this->{$grp}->{$ele}->{value}->[$index]) eq "Posda::Dataset"){
        $new_ds = $this->{$grp}->{$ele}->{value}->[$index];
      } else {
        die "Sequence item is not a dataset, $sig";
      }
    } else {
      $new_ds = Posda::Dataset->new_blank();
      $this->{$grp}->{$ele}->{value}->[$index] = $new_ds;
    }
    $new_ds->InsertElementBySig($new_sig, $value);
  } else {
    die "non-matching sig: $sig\n";
  }
};
sub DeleteElementBySig{
  my($this, $sig) = @_;
  my($grp, $ele, $remain);
  if($sig =~ /^\((....),(....)\)(.*)$/){
    $grp = hex($1);
    $ele = hex($2);
    $remain = $3;
  } else {
    die "Sig ($sig) didn't match";
  }
  if($remain eq ""){
    delete $this->{$grp}->{$ele};
  } elsif ($remain =~ /^\[(\d+)\]$/){
      my $index = $1;
      unless(exists $this->{$grp}->{$ele}){
        $this->{$grp}->{$ele} = {
          VR => $DD->get_vr($grp, $ele),
          type => $DD->get_type($grp, $ele),
          value => [],
        };
      }

      if(
        exists($this->{$grp}->{$ele}) &&
        exists($this->{$grp}->{$ele}->{value}) &&
        ref($this->{$grp}->{$ele}->{value}) eq "ARRAY"
      ){
        $this->{$grp}->{$ele}->{value}->[$index] = undef;
      } else {
        die "delete from non-array";
      }
  } elsif (
    $remain =~ /^\[(\d+)\]>(.*)$/ or
    $remain =~ /^\[(\d+)\](.*)$/
  ){
    my $index = $1;
    my $new_sig = $2;
    unless(exists $this->{$grp}->{$ele}){
      $this->{$grp}->{$ele} = {
        VR => 'SQ',
        VM => 0,
        value => [],
        type => 'seq',
      };
    }
    if($this->{$grp}->{$ele}->{VR} ne "SQ"){
      die "invalid remaining (\"$remain\") for non-seq (" .
        "$this->{$grp}->{$ele}->{VR}) element";
    }
    my $new_ds;
    if( exists $this->{$grp}->{$ele}->{value}->[$index]){
      if(ref($this->{$grp}->{$ele}->{value}->[$index]) eq "Posda::Dataset"){
        $new_ds = $this->{$grp}->{$ele}->{value}->[$index];
      } else {
        die "Sequence item is not a dataset, $sig";
      }
    } else {
      $new_ds = Posda::Dataset->new_blank();
      $this->{$grp}->{$ele}->{value}->[$index] = $new_ds;
    }
    $new_ds->DeleteElementBySig($new_sig);
  } else {
    die "non-matching sig: $sig\n";
  }
};
sub Delete{
  my($this, $sig) = @_;
  my($grp, $ele, $owner, $remain);
  if($sig =~ /^\((....),(....)\)(.*)$/){
    $grp = hex($1);
    $ele = hex($2);
    $remain = $3;
    if(
      ($grp & 1) &&
      exists($this->{$grp}) &&
      exists($this->{$grp}->{private})
    ){
      $this->ConvertFromPrivate($grp);
    }
  } elsif ($sig =~ /^\((....),\"([^\"]*)\",(..)\)(.*)$/){
    $grp = hex($1);
    unless($grp & 1) { die "only private groups have owner: $sig" }
    $owner = $2;
    $ele = hex($3);
    $remain = $4;
    unless(exists $this->{$grp}) { return undef }
    unless(exists $this->{$grp}->{private}){
        $this->ConvertToPrivate($grp);
    }
  } else {
    die "Sig ($sig) didn't match";
  }
  unless(
    (
      (! defined($owner)) &&
      exists($this->{$grp}->{$ele})
    ) || (
      defined($owner) &&
      exists($this->{$grp}->{private}) &&
      exists($this->{$grp}->{private}->{$owner}) &&
      exists($this->{$grp}->{private}->{$owner}->{$ele})
    )
  ){
    return undef;
  }
  if($remain eq ""){
    if(defined($owner)){
      delete($this->{$grp}->{private}->{$owner}->{$ele});
    } else {
      delete($this->{$grp}->{$ele});
    }
    return 1;
  }
  if($remain =~ /^\[(\d+)\]$/){
    my $item_index = $1;
    if(
      defined($owner) &&
      exists($this->{$grp}->{private}->{$owner}->{$ele}->{value}) &&
      ref($this->{$grp}->{private}->{$owner}->{$ele}->{value}) eq "ARRAY" &&
      defined(
        $this->{$grp}->{private}->{$owner}->{$ele}->{value}->[$item_index]
      )
    ){
      splice(@{$this->{$grp}->{private}->{$owner}->{$ele}->{value}},
        $item_index, 1);
#      $this->{$grp}->{private}->{$owner}->{$ele}->{value}->[$item_index] = 
#        undef;
    } elsif(
      exists($this->{$grp}->{$ele}->{value}) &&
      ref($this->{$grp}->{$ele}->{value}) eq "ARRAY" &&
      defined(
        $this->{$grp}->{$ele}->{value}->[$item_index]
      )
    ){
      splice(@{$this->{$grp}->{$ele}->{value}}, $item_index, 1);
#      $this->{$grp}->{$ele}->{value}->[$item_index] = undef;
    } else {
      print "$this->{$grp}\n";
      print "$this->{$grp}->{$ele}\n";
      print "$this->{$grp}->{$ele}->{value}\n";
      print "$this->{$grp}->{$ele}->{value}->[$item_index]\n";
    }
#    die "Can't delete an item in a sequence - not well defined";
    return 1;
  }
  if(
     $remain =~ /^\[(\d+)\]>(.*)$/ ||
     $remain =~ /^\[(\d+)\](.*)$/ 
  ){
    my $index = $1;
    my $new_sig = $2;
    my $value;
    if(defined $owner){
      $value = $this->{$grp}->{private}->{$owner}->{$ele}->{value};
    } else {
      $value = $this->{$grp}->{$ele}->{value};
    }
    unless(
      ref($value) eq "ARRAY" &&
      exists $value->[$index] &&
      defined $value->[$index] &&
      ref($value->[$index]) ne "" &&
      $value->[$index]->isa("Posda::Dataset")
    ){
      return undef;
    }
    return $value->[$index]->Delete($new_sig);
  }
};

################################################################
#Try - see if a file is a Dicom File
#
#  my($df, $ds, $size, $xfer_syntax) = Try($path);
#
#  $df is Dicom File (Part 10) header if file is Part 10
#         undef if not Part 10 format
#  $ds is Dicom Dataset
#         undef if not Dicom File
#
sub Try{
  my($infile) = @_;
  my $df;
  my $ds;
  my $size;
  my $len;
  my $xfr_stx;
  my @errors;
  
  my $parser;
  eval {
    $parser = Posda::Parser->new(
      dd => $DD,
      from_file => $infile,
    );
    $ds = $parser->ReadDataset();
  };
  if($@){
    if($parser->{metaheader}){
      push(@errors, "Part 10 file with bad dataset: $@");
      return (undef, undef, undef, undef, \@errors);
    }
    push @errors, $@;
    my @to_try = (
      "1.2.840.10008.1.2",
      "1.2.840.10008.1.2.1",
      "1.2.840.10008.1.2.2",
      "1.2.826.0.1.3680043.2.494.1.1",
      "1.3.6.1.4.1.22213.1.147"
    );
    my $found_one;
    for my $x (@to_try){
      $parser = Posda::Parser->new(
        dd => $DD,
        from_file => $infile,
        xfr_stx => $x,
      );
      eval { $ds = $parser->ReadDataset() };
      if($@){
        push @errors, "($x): $@";
        next;
      }
      $found_one = 1;
      $size = $parser->{file_length};
      $xfr_stx = $parser->{xfrstx};

      last;
    }
    unless($found_one){
      return (undef, undef, undef, undef, \@errors);
    }
    unless($xfr_stx eq "1.2.840.10008.1.2"){
      my $xf_name = $DD->{XferSyntax}->{$xfr_stx}->{name};
      push(@{$parser->{errors}}, 
        "No metaheader with xfr_stx: $xfr_stx ($xf_name)");
    }
  } else {
    $size = $parser->{file_length};
    $df = $parser->{metaheader};
    $xfr_stx = $parser->{metaheader}->{xfrstx};
  }
  return($df, $ds, $size, $xfr_stx, [@{$parser->{errors}}]);
}

sub FilePos{
  my($this, $sig) = @_;
  my $descrip = $this->GetEle($sig);
  return $descrip->{file_pos};
}
sub EleLenInFile{
  my($this, $sig) = @_;
  my $descrip = $this->GetEle($sig);
  return $descrip->{ele_len_in_file};
}
sub file_pos{
  my($this, $sig) = @_;
  unless($sig =~ /^\((....),(....)\)$/){
    die "not currently supported for multilevel elements";
  }
  my $grp = hex($1);
  my $ele = hex($2);
  return $this->{$grp}->{$ele}->{file_pos};
}
sub ele_len_in_file{
  my($this, $sig) = @_;
  unless($sig =~ /^\((....),(....)\)$/){
    die "not currently supported for multilevel elements";
  }
  my $grp = hex($1);
  my $ele = hex($2);
  return $this->{$grp}->{$ele}->{ele_len_in_file};
}
InitDD();
1;

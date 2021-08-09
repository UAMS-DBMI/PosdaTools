#!/usr/bin/perl -w
use strict;
use Digest::MD5;
package Nifti::Create;
use HexDump;

my $spec = {
  sizeof_hdr =>{
    type => "long",
    offset => 0,
    length => 4,
    desc => "Size of the header. Must be 348 (bytes)",
  },
  data_type =>{
    type => "string",
    offset => 4,
    length => 10,
    desc => "Not used; compatibility with analyze.",
  },
  db_name => {
    type => "string",
    offset =>14,
    length => 18,
    desc => "Not used; compatibility with analyze.",
  },
  extents =>{
    type => 'long',
    offset => 32,
    length => 4,
    desc => "Not used; compatibility with analyze.",
  },
  session_error => {
    type => 'short',
    offset =>  36,
    length => 2,
    desc => 'Not used; compatibility with analyze.',
  },
  regular =>{
    type => 'string',
    offset => 8,
    length => 1,
    desc => 'Not used; compatibility with analyze.',
  },
  dim_info => {
    type => 'string',
    offset => 39,
    length => 1,
    desc => "Encoding directions (phase, frequency, slice).",
  },
  dim => {
    type => 'short',
    offset => 40,
    length => 16,
    desc => "Data array dimensions.",
  },
  intent_p1 => {
    type => 'float',
    offset => 56,
    length => 4,
    desc => "1st intent parameter.",
  },
  intent_p2 => {
    type => 'float',
    offset => 60,
    length => 4,
    desc => "2nd intent parameter.",
  },
  intent_p3 => {
    type => 'float',
    offset => 64,
    length => 4,
    desc => "3rd intent parameter.",
  },
  intent_code => {
    type => 'short',
    offset => 68,
    length => 2,
    desc => "nifti intent.",
  },
  datatype => {
    type => 'short',
    offset => 70,
    length => 2,
    desc => "Data type.",
  },
  bitpix => {
    type => "short",
    offset => 72,
    length => 2,
    desc => "Number of bits per voxel.",
  },
  slice_start => {
    type => "short",
    offset => 74,
    length => 2,
    desc => "First slice index.",
  },
  pixdim => {
    type => 'float',
    offset => 76,
    length => 32,
    desc => "Grid spacings (unit per dimension).",
  },
  vox_offset => {
    type => 'float',
    offset => 108,
    length => 4,
    desc => "Offset into a .nii file.",
  },
  scl_slope => {
    type => 'float',
    offset => 112,
    length => 4,
    desc => "Data scaling, slope.",
  },
  scl_inter => {
    type => 'float',
    offset => 116,
    length => 4,
    desc => "Data scaling, offset.",
  },
  slice_end => {
    type => 'short',
    offset => 120,
    length => 2,
    desc => "Last slice index.",
  },
  slice_code => {
    type => 'char',
    offset => 122,
    length => 1,
    desc => "Slice timing order.",
  },
  xyzt_units => {
    type => 'char',
    offset => 123,
    length => 1,
    desc => "Units of pixdim[1..4].",
  },
  cal_max => {
    type => 'float',
    offset => 124,
    length => 4,
    desc => "Maximum display intensity.",
  },
  cal_min => {
    type => 'float',
    offset => 128,
    length => 4,
    desc => "Minimum display intensity.",
  },
  slice_duration => {
    type => 'float',
    offset => 132,
    length => 4,
    desc => "Time for one slice.",
  },
  toffset => {
    type => 'float',
    offset => 136,
    length => 4,
    desc => "Time axis shift.",
  },
  glmax => {
    type => 'long',
    offset => 140,
    length => 4,
    desc => "Not used; compatibility with analyze.",
  },
  glmin => {
    type => 'long',
    offset => 144,
    length => 4,
    desc => "Not used; compatibility with analyze.",
  },
  descrip => {
    type => 'string',
    offset => 148,
    length => 80,
    desc => "Any text.",
  },
  aux_file => {
    type => 'string',
    offset => 228,
    length => 24,
    desc => "Auxiliary filename.",
  },
  qform_code => {
    type => 'short',
    offset => 252,
    length => 2,
    desc => "Use the quaternion fields.",
  },
  sform_code => {
    type => 'short',
    offset => 254,
    length => 2,
    desc => "Use of the affine fields.",
  },
  quatern_b => {
    type => 'float',
    offset => 256,
    length => 4,
    desc => "Quaternion b parameter.",
  },
  quatern_c => {
    type => 'float',
    offset => 260,
    length => 4,
    desc => "Quaternion c parameter.",
  },
  quatern_d => {
    type => 'float',
    offset => 264,
    length => 4,
    desc => "Quaternion d parameter.",
  },
  qoffset_x => {
    type => 'float',
    offset => 268,
    length => 4,
    desc => "Quaternion x shift.",
  },
  qoffset_y => {
    type => 'float',
    offset => 272,
    length => 4,
    desc => "Quaternion y shift.",
  },
  qoffset_z => {
    type => 'float',
    offset => 276,
    length => 4,
    desc => "Quaternion z shift.",
  },
  srow_x=> {
    type => 'float',
    offset => 280,
    length => 16,
    desc => "1st row affine transform",
  },
  srow_y => {
    type => 'float',
    offset => 296,
    length => 16,
    desc => "2nd row affine transform.",
  },
  srow_z => {
    type => 'float',
    offset => 312,
    length => 16,
    desc => "3rd row affine transform.",
  },
  intent_name => {
    type => 'string',
    offset => 328,
    length => 16,
    desc => "Name or meaning of the data.",
  },
  magic => {
    type => 'string',
    offset => 344,
    length => 4,
    desc => "Magic string.",
  },
};

sub new{
  my($class, $file_name) = @_;
  my $self = {
    file_name => $file_name,
  };
  bless $self, $class;
  return $self;
}

sub AddSlice{
  my($self, $slice, $slice_num) = @_;
  if($slice_num > $self->{slices} - 1){
    die "Trying to insert slice $slice_num into array of $self->{num_slices}";
  }
  my $slice_len = length($slice);
  unless($slice_len == $self->{slice_size}){
    die "Trying to insert slice of size $slice_len " .
      "($self->{slice_size} is proper";
  }
  my $slice_offset = $self->{vox_offset} + ($slice_num * $self->{slice_size});
  my $fh;
  open $fh, ">>$self->{file_name}" or die "can't open $self->{file_name} ($!)";
  my $loc = tell $fh;
  unless($loc == $slice_offset){
    die "slice $slice_num: slice_offset ($slice_offset) != Eof ($loc)\n";
  }
  print $fh $slice;
  close $fh;
}

sub PopulateHeader{
  my($self, $header) = @_;
  $self->{header} = $header;
  $self->{num_dim} = $header->{dim}->[0];
  $self->{rows} = $header->{dim}->[1];
  $self->{cols} = $header->{dim}->[2];
  $self->{slices} = $header->{dim}->[3];
  $self->{vols} = $header->{dim}->[3];
  $self->{bitpix} = $header->{bitpix};
  $self->{bytesperpix} = $self->{bitpix} / 8;
  $self->{vox_offset} = $header->{vox_offset};
  $self->{slice_size} = $self->{rows} * $self->{cols} * $self->{bytesperpix};
  my $fh;
  open $fh, ">$self->{file_name}" or die "Can't open $self->{file_name} " .
    "($!)";
  for my $i (
    sort { $spec->{$a}->{offset} <=> $spec->{$b}->{offset} }
    keys %$spec
  ){
    my $s = $spec->{$i};
    my $loc = tell $fh;
    if($loc != $s->{offset}){
      if($loc > $s->{offset}){
         die "$i: current file position ($loc) > $s->{offset}"
      }
      my $pad = "\0" x ($s->{offset} - $loc);
      print $fh $pad;
      $loc = tell($fh);
    }
    my $value;
    if(defined $header->{$i}){
      $value = $self->Encode($s, $header->{$i}, $i);
    } else {
      print "\$header->{$i} is not defined\n";
      $value = "\0" x $s->{length};
    }
    my $vlen = length($value);
    print $fh $value;
  }
  my $loc = tell($fh);
  if($loc > $self->{vox_offset}){
    die "Header extends beyond vox_offset ($loc vs $self->{vox_offset})";
  }
  if($loc < $self->{vox_offset}){
      my $pad = "\0" x ($self->{vox_offset} - $loc);
      print $fh $pad;
  }
  close $fh;
}

sub Encode{
  my($self, $s, $val, $name) = @_;
  my $lengths = {
    long => 4,
    char => 1,
    short => 2,
    float => 4,
    string => 0,
  };
  my $type = $s->{type};
  unless(exists $lengths->{$type}){
    die "Trying to encode unknown type: $type";
  }
  if($type eq "string"){
    my $space = $s->{length};
    my $len = length($val);
    if($len == $space) { return $val }
    my $value;
    if($len > $space){
      $value = substr $val, 0, $space;
    } else {
      $value = $val . ("\0" . ($space - $len));
    }
    return $value;
  }
  my $typelen = $lengths->{$type};
  my $len = $s->{length};
  my $value;
  if($typelen == $len){
    #not an array
    my $ps;
    if($type eq "float"){
      $ps = "f";
    }elsif($type eq "char"){
      $ps = "c";
    }elsif($type eq "long"){
      $ps = "L";
    }elsif($type eq "short"){
      $ps = "S";
    }
    {
      no warnings;
      $value = pack($ps, $val);
    }
  } else {
    #an array
    my $ps;
    if($type eq "float"){
      $ps = "f*";
    }elsif($type eq "char"){
      $ps = "c*";
    }elsif($type eq "long"){
      $ps = "L*";
    }elsif($type eq "short"){
      $ps = "S*";
    }
    unless(ref($val) eq "ARRAY"){
      die "Trying to enter scalar value into array field $name";
    }
    my $arraybounds = int($len / $typelen);
    my $arraylen = @$val;
    if($arraylen > $arraybounds){
      die "Trying to enter array of length $arraylen " .
        "into field $name" . "[$arraybounds]";
    }
    while($arraylen < $arraybounds){
      push @$val, 0;
      $arraylen = @$val;
    }
    {
      no warnings;
      $value = pack($ps, @$val);
    }
  }
  return $value;
}

sub DESTROY{
  my($self) = @_;
  if(exists $self->{fh}){
    close $self->{fh};
    delete $self->{fh};
  }
}

sub types{
  my %types;
  for my $i (keys %$spec){
    my $type = $spec->{$i}->{type};
    $types{$type} = 1;
  }
  print "types:\n";
  for my $i (keys %types){
    print "\t$i\n";
  }
}

sub fields{
  my $lengths = {
    long => 4,
    char => 1,
    short => 2,
    float => 4,
    string => 0,
  };
  print "fields:\n";
  for my $field (
    sort { $spec->{$a}->{offset} <=> $spec->{$b}->{offset} }
    keys %$spec
  ){
    my $s = $spec->{$field};
    my $len =  $s->{length};
    my $type = $s->{type};
    if($type eq "string"){
      print "\t$field scalar $type (max $len)\n";
      next;
    }
    my $typelen = $lengths->{$type};
    if($len == $typelen){
      print "\t$field scalar $type ($len)\n";
      next;
    }
    my $mod = $len % $typelen;
    unless($mod == 0){
      die "$len doesn't divide $typelen: remainder: $mod";
    }
    my $dim = $len / $typelen;
    print "\t$field array $type" . "[$dim] ($len)\n";
  }
}

1;

#!/usr/bin/perl -w
use strict;
use Digest::MD5;
package Nifti::Parser;
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
  my($class, $file_name, $file_id) = @_;
  my $fh;
  unless(open $fh, "<$file_name"){
    die "Can't open file $file_name";
  }
  my $self = {
    fh => $fh,
    file_name => $file_name,
  };
  if(defined $file_id) { $self->{file_id} = $file_id }
  bless $self, $class;
  $self->ReadHeader;
  if($self->{parsed}->{magic} eq "n+1"){
    return $self;
  } else {
    return undef;
  }
}
sub CopyHeaderToFile{
  my($self, $file) = @_;
  $self->Open;
  seek $self->{fh}, 0, 0;
  my $buff;
  my $len = read($self->{fh}, $buff, $self->{parsed}->{vox_offset});
  unless($len == $self->{parsed}->{vox_offset}){
    die "non matching length reading nifti header ($len vs " .
      "$self->{parsed}->{vox_offset})";
  }
  open HEADER, ">$file" or die "Can't open $file for writing header";
  print HEADER $buff;
  close HEADER;
}
sub new_from_zip{
  my($class, $file_name, $file_id, $tmp_dir) = @_;
  my $uncompressed_file_name = "$tmp_dir/nifti_$file_id.nii";
#print STDERR "In $class" . "::new_from_zip:\n" ,
#" file_name: $file_name\n" .
#" file_id: $file_id\n" .
#" temp_dir: $tmp_dir\n" .
#" uncompressed_file_name: $uncompressed_file_name\n";
unless(-d $tmp_dir) { die "$tmp_dir is not a directory" }
  my $fh;
  `gunzip -c $file_name >$uncompressed_file_name`;
  unless(open $fh, "<$uncompressed_file_name"){
    die "Can't open file $uncompressed_file_name (unzipped from $file_name)";
  }
  my $self = {
    file_id => $file_id,
    fh => $fh,
    is_from_zip => 1,
    compressed_file_name => $file_name,
    file_name => $uncompressed_file_name,
    tmp_dir => $tmp_dir,
  };
  bless $self, $class;
  $self->ReadHeader;
  if($self->{parsed}->{magic} eq "n+1"){
    return $self;
  } else {
    unlink($uncompressed_file_name);
    return undef;
  }
}
sub Open {
  my($self) = @_;
  if (defined $self->{fh}) { return }
  my $fh;
  if($self->{is_from_zip}){
    my $uncompressed_file_name = "$self->{tmp_dir}/" .
      "nifti_$self->{file_id}.nii";
#print STDERR "In Open\n" ,
#" file_name: $self->{file_name}\n" .
#" commpressed_file_name: $self->{compressed_file_name}\n" .
#" file_id: $self->{file_id}\n" .
#" temp_dir: $self->{tmp_dir}\n" .
#" uncompressed_file_name: $uncompressed_file_name\n";
    if(exists($self->{file_name}) && -r $self->{file_name}){
#print STDERR "Opening $self->{file_name}\n";
      open $fh, $self->{file_name} or die "Can't open $self->{file_name}";
    } else {
      if(
        exists($self->{compressed_file_name}) &&
        -r $self->{compressed_file_name}
      ){
        my $cmd = 
          "gunzip -c $self->{compressed_file_name} >$uncompressed_file_name";
#print STDERR "Command: $cmd\n";
        `$cmd`;
        $self->{file_name} = $uncompressed_file_name;
        open $fh, $uncompressed_file_name or
          die "Can't open $self->{file_name} " .
            "(from zip of $self->{compressed_file_name}";
      } else {
        die "No compressed file name to decompress";
      }
    }
  } else {
    open $fh, $self->{file_name} or die "Can't open $self->{file_name}";
  }
  $self->{fh} = $fh;
}

sub Close {
  my($self) = @_;
#print STDERR "In Close\n" ,
#" file_name: $self->{file_name}\n" .
#" commpressed_file_name: $self->{compressed_file_name}\n" .
#" file_id: $self->{file_id}\n" .
#" temp_dir: $self->{tmp_dir}\n";
  unless (defined $self->{fh}) { return }
  close ($self->{fh});
  delete $self->{fh};
  if($self->{is_from_zip}){
    if(
      exists $self->{compressed_file_name} &&
      -f $self->{compressed_file_name}
    ){
      unlink $self->{file_name};
      delete $self->{file_name};
    }
  }
}

sub HalfClose {
  my($self) = @_;
  unless (defined $self->{fh}) { return }
  close ($self->{fh});
  delete $self->{fh};
}
sub ReadHeader{
  my($self) = @_;
  for my $field (keys %$spec){
    seek $self->{fh}, $spec->{$field}->{offset}, 0;
    my $buff;
    my @v;
    read $self->{fh}, $buff, $spec->{$field}->{length};
    if($spec->{$field}->{type} eq "float"){
      my @float;
      @float = unpack('f*', pack('L*', unpack('V*', $buff)));
      if($#float == 0){
        $self->{parsed}->{$field} = $float[0];
      } elsif($#float > 0){
        $self->{parsed}->{$field} = \@float;
      }
    } elsif($spec->{$field}->{type} eq 'char'){
      @v = unpack('c*', $buff);
      if($#v == 0){
        $self->{parsed}->{$field} = $v[0];
      } else {
        $self->{parsed}->{$field} = \@v;
      }
    } elsif($spec->{$field}->{type} eq 'string'){
      my $str = $buff;
      $str =~ s/\0//g;
      if(defined $str){
        $self->{parsed}->{$field} = $str;
      }
    } elsif($spec->{$field}->{type} eq 'short'){
      my @short = unpack('S*', $buff);
      if($#short == 0){
        $self->{parsed}->{$field} = $short[0];
      } else {
        $self->{parsed}->{$field} = \@short;
      }
    } elsif($spec->{$field}->{type} eq 'long'){
      my @long = unpack('L*', $buff);
      if($#long == 0){
        $self->{parsed}->{$field} = $long[0];
      } else {
        $self->{parsed}->{$field} = \@long;
      }
    } else {
      print "unhandled type $spec->{$field}->{type}\n";
    }
  }
  unless($self->{parsed}->{magic} eq "n+1"){
    return undef;
  }
  return $self;
}


sub NumSlicesAndVols{
  my($self) = @_;
  return($self->{parsed}->{dim}->[3], $self->{parsed}->{dim}->[4]);
}

sub RowsColsAndBytes{
  my($self) = @_;
  return($self->{parsed}->{dim}->[2], $self->{parsed}->{dim}->[1],
    $self->{parsed}->{bitpix}/8);
}

sub GetSliceOffsetLengthAndRowLength{
  my($self, $vol_num, $frame_num) = @_;
  my $pix_start = $self->{parsed}->{vox_offset};
  my $num_cols = $self->{parsed}->{dim}->[1];
  my $num_rows = $self->{parsed}->{dim}->[2];
  my $slices_per_volume = $self->{parsed}->{dim}->[3];
  my $num_volumes = $self->{parsed}->{dim}->[4];
  my $bytes_per_pix = $self->{parsed}->{bitpix}/8;
  my $row_size = $num_cols * $bytes_per_pix;
  my $slice_size = $row_size * $num_rows;
  my $vol_size = $slice_size * $slices_per_volume;
  my $tot_pix_size = $vol_size * $num_volumes;
  my $vol_start_off = $vol_num * $vol_size;
  my $slice_start_off = $vol_start_off +($frame_num * $slice_size);
  my $slice_start = $pix_start + $slice_start_off;
  return($slice_start, $slice_size, $row_size);
}

sub SliceDigest{
  my($self, $v, $s) = @_;
  my $ctx = Digest::MD5->new;
  my($offset, $length, $row_size) =
    $self->GetSliceOffsetLengthAndRowLength($v, $s);
  $self->Open;
  seek $self->{fh}, $offset, 0;
  my $buff;
  my $len  = read $self->{fh}, $buff, $length;
  unless($len == $length) { die "Read $len vs $length" }
  $ctx->add($buff);
  my $dig = $ctx->hexdigest();
  my $max = 0;
  my $min =0xffff;
  for my $i(0 .. ($length/2)-1){
    my $v = unpack('S', substr($buff, $i *2, 2));
    if($v > $max){ $max = $v }
    if($v < $min){ $min = $v }
  }
  return $dig,$max,$min;;
}

sub FlippedSliceDigest{
  my($self, $v, $s) = @_;
  my($offset, $length, $row_size) =
    $self->GetSliceOffsetLengthAndRowLength($v, $s);
  my $ctx = Digest::MD5->new;
  my $num_rows = $self->{parsed}->{dim}->[2];
  $self->Open;
  for my $r (1 .. $num_rows){
    my $offset_r = $offset + (($num_rows - $r) * $row_size);
    seek $self->{fh}, $offset_r, 0;
    my $buff;
    my $len  = read $self->{fh}, $buff, $row_size;
    unless($len == $row_size) { die "Read $len vs $row_size" }
    $ctx->add($buff);
  }
  my $dig = $ctx->hexdigest();
  return $dig;
}

sub PrintSlice{
  my($self, $v, $s, $fh) = @_;
  my($offset, $length, $row_size) =
    $self->GetSliceOffsetLengthAndRowLength($v, $s);
  $self->Open;
  seek $self->{fh}, $offset, 0;
  my $buff;
  my $len  = read $self->{fh}, $buff, $length;
  unless($len == $length) { die "Read $len vs $length" }
  print $fh $buff;
}

sub PrintRgbSliceFlipped{
  my($self, $v, $s, $fh) = @_;
  my($offset, $length, $row_size) =
    $self->GetSliceOffsetLengthAndRowLength($v, $s);
  unless(seek $self->{fh}, $offset, 0){
    die "seek $self->{fh}, $offset, 0) ($!)";
  }
  my @Val;
  my $buff;
  my $num_rows = $length/$row_size;
  if($self->{parsed}->{datatype} == 128){
    for my $r (1 .. $num_rows){
      my $offset_r = $offset + (($num_rows - $r) * $row_size);
      seek $self->{fh}, $offset_r, 0;
      my $buff;
      my $len  = read $self->{fh}, $buff, $row_size;
      unless($len == $row_size) { die "Read $len vs $row_size" }
      print $fh $buff;
    }
  } else {
    die "Called PrintSliceRgb on non RGB image";
  }
}

sub PrintRgbSlice{
  my($self, $v, $s, $fh) = @_;
  my($offset, $length, $row_size) =
    $self->GetSliceOffsetLengthAndRowLength($v, $s);
  unless(seek $self->{fh}, $offset, 0){
    die "seek $self->{fh}, $offset, 0) ($!)";
  }
  my @Val;
  my $buff;
  my $len  = read $self->{fh}, $buff, $length;
  if($self->{parsed}->{datatype} == 128){
    unless($len == $length) { die "Read $len vs $length" }
    print $fh $buff;
  } else {
    die "Called PrintSliceRgb on non RGB image";
  }
}

sub PrintSliceScaled{
  my($self, $v, $s, $fh) = @_;
  my($offset, $length, $row_size) =
    $self->GetSliceOffsetLengthAndRowLength($v, $s);
  unless(seek $self->{fh}, $offset, 0){
    die "seek $self->{fh}, $offset, 0) ($!)";
  }
  my @Val;
  my $buff;
  my $num_pix = $length/($self->{parsed}->{bitpix}/8);
  my $sbuff = '\0' x $num_pix;
  my $len  = read $self->{fh}, $buff, $length;
  my $ps;
  my $datlen;
  if($self->{parsed}->{datatype} == 4){
    $ps = "s";
    $datlen = 2;
  } elsif($self->{parsed}->{datatype} == 512){
    $ps = "S";
    $datlen = 2;
  } elsif($self->{parsed}->{datatype} == 16){
    $ps = "f";
    $datlen = 4;
  } elsif($self->{parsed}->{datatype} == 2){
    $ps = "C";
    $datlen = 1;
  } elsif($self->{parsed}->{datatype} == 128){
    $ps = "CCC";
    $datlen = 3;
  }
  unless($len == $length) { die "Read $len vs $length" }
  for my $i(0 .. ($length/$datlen)-1){
    my $val = unpack($ps, substr($buff, $i * $datlen,  $datlen));
    $Val[$i] = $val;
  }
  my $num_val = @Val;
  $self->Normalize(\@Val, ($length/$datlen)-1);
  my $new_slice;
  for my $i (0 .. ($num_pix - 1)){
    no warnings;
    substr($new_slice, $i, 1) = pack 'C', $Val[$i];
  }
  my $nslen = length($new_slice);
  print $fh $new_slice;
}

sub PrintSliceFlipped {
  my($self, $v, $s, $fh) = @_;
  my($offset, $length, $row_size) =
    $self->GetSliceOffsetLengthAndRowLength($v, $s);
  my $num_rows = $self->{parsed}->{dim}->[2];
  $self->Open;
  for my $r (1 .. $num_rows){
    my $offset_r = $offset + (($num_rows - $r) * $row_size);
    seek $self->{fh}, $offset_r, 0;
    my $buff;
    my $len  = read $self->{fh}, $buff, $row_size;
    unless($len == $row_size) { die "Read $len vs $row_size" }
    print $fh $buff;
  }
}

sub GetSliceFlipped{
  my($self, $v, $s) = @_;
  my($offset, $length, $row_size) =
    $self->GetSliceOffsetLengthAndRowLength($v, $s);
  my $num_rows = $self->{parsed}->{dim}->[2];
  my $val = "";
  $self->Open;
  for my $r (1 .. $num_rows){
    my $offset_r = $offset + (($num_rows - $r) * $row_size);
    seek $self->{fh}, $offset_r, 0;
    my $buff;
    my $len  = read $self->{fh}, $buff, $row_size;
    unless($len == $row_size) { die "Read $len vs $row_size" }
    $val .= $buff;
  }
  return $val;
}

sub PrintSliceFlippedScaled{
  my($self, $v, $s, $fh) = @_;
  my($offset, $length, $row_size) =
    $self->GetSliceOffsetLengthAndRowLength($v, $s);
  my $row_num_pix = $row_size/($self->{parsed}->{bitpix}/8);
  my $num_rows = $self->{parsed}->{dim}->[2];
  my $num_pix = $length/($self->{parsed}->{bitpix}/8);
  my $bytes_per_pix = $self->{parsed}->{bitpix}/8;
  $self->Open;
  my @Val;
  my $buff;
  my $sbuff = '\0' x $num_pix;
  my $len  = read $self->{fh}, $buff, $length;
  my $ps;
  if($self->{parsed}->{datatype} == 4){
    $ps = "s";
  } elsif($self->{parsed}->{datatype} == 512){
    $ps = "S";
  } elsif($self->{parsed}->{datatype} == 16){
    $ps = "f";
  } elsif($self->{parsed}->{datatype} == 2){
    $ps = "C";
  }
  unless($len == $length) { die "Read $len vs $length" }
  for my $r (1 .. $num_rows){
    my $offset_r = $offset + (($num_rows - $r) * $row_size);
    seek $self->{fh}, $offset_r, 0;
    my $buff;
    my $len  = read $self->{fh}, $buff, $row_size;
    unless($len == $row_size) { die "Read $len vs $row_size" }
    for my $i (0 .. $row_num_pix - 1){
      my $row_offset = ($r - 1) * ($row_size / $bytes_per_pix);
      $Val[$i + $row_offset] = unpack($ps, substr($buff, $i * $bytes_per_pix, 2));
    }
  }
  my $num_val = @Val;
  $self->Normalize(\@Val, ($length/2)-1);
  my $new_slice;
  for my $i (0 .. ($num_pix - 1)){
    no warnings;
    substr($new_slice, $i, 1) = pack 'C', $Val[$i];
  }
  my $nslen = length($new_slice);
  print $fh $new_slice;
}

sub PrintSliceFlippedScaledOld{
  my($self, $v, $s, $fh) = @_;
  my($offset, $length, $row_size) =
    $self->GetSliceOffsetLengthAndRowLength($v, $s);
  my $row_num_pix = $row_size/($self->{parsed}->{bitpix}/8);
  my $num_rows = $self->{parsed}->{dim}->[2];
  my $num_pix = $length/($self->{parsed}->{bitpix}/8);
  $self->Open;
  my @Val;
  for my $r (1 .. $num_rows){
    my $offset_r = $offset + (($num_rows - $r) * $row_size);
    seek $self->{fh}, $offset_r, 0;
    my $buff;
    my $len  = read $self->{fh}, $buff, $row_size;
    unless($len == $row_size) { die "Read $len vs $row_size" }
    for my $i (0 .. $row_num_pix - 1){
      my $row_offset = ($r - 1) * ($row_size / 2);
      $Val[$i + $row_offset] = unpack('S', substr($buff, $i *2, 2));
    }
  }
  $self->Normalize(\@Val, $num_pix - 1);
  my $new_slice;
  for my $i (0 .. ($num_pix - 1)){
    no warnings;
    substr($new_slice, $i, 1) = pack 'C', $Val[$i];
  }
  print $fh $new_slice;
}

sub PrintNormalizedVolumeProjections{
  my($self, $v, $fh_avg, $fh_min, $fh_max) = @_;
  $self->Open;
  my @Val;
  my @Avg;
  my @Min;
  my @Max;
  my $rows = $self->{parsed}->{dim}->[1];
  my $cols = $self->{parsed}->{dim}->[2];
  for my $i (0 .. $rows * $cols){
    $Val[$i] = 0;
    $Min[$i] = 0xffff;
    $Max[$i] = 0;
  }
  my($offset, $length, $row_size) =
    $self->GetSliceOffsetLengthAndRowLength($v, 0);
  my $num_pix = $length/2;
  my $num_slices = $self->{parsed}->{dim}->[3];
  my $slice;
  for my $i (0 .. $num_slices - 1){
    my $offset_r = $offset + ($i * $length);
    unless(seek $self->{fh}, $offset_r, 0){
      die "seek ($!)";
    }
    my $len = read $self->{fh}, $slice, $length;
    unless($len == $length){
      die ("Read $len vs $length");
    }
    for my $j (0 .. ($num_pix - 1)){
      my $val = unpack('S', substr($slice, $j * 2, 2));
      $Val[$j] += $val;
      if($val < $Min[$j]){ $Min[$j] = $val }
      if($val > $Max[$j]){ $Max[$j] = $val }
    }
  }
  for my $i (0 .. ($num_pix - 1)){
    my $avg = $Val[$i] / $num_slices;
    $Avg[$i] = $avg;
  }
  $self->Normalize(\@Avg, $num_pix);
  $self->Normalize(\@Min, $num_pix);
  $self->Normalize(\@Max, $num_pix);
  my $new_slice_avg = "\0" x $num_pix;
  my $new_slice_min = "\0" x $num_pix;
  my $new_slice_max = "\0" x $num_pix;
  for my $i (0 .. ($num_pix - 1)){
    no warnings;
    substr($new_slice_avg, $i, 1) = pack 'C', $Avg[$i];
  }
  print $fh_avg $new_slice_avg;
  for my $i (0 .. ($num_pix - 1)){
    no warnings;
    substr($new_slice_min, $i, 1) = pack 'C', $Min[$i];
  }
  print $fh_min $new_slice_min;
  for my $i (0 .. ($num_pix - 1)){
    no warnings;
    substr($new_slice_max, $i, 1) = pack 'C', $Max[$i];
  }
  print $fh_max $new_slice_max;
}
sub PrintNormalizedFileProjections{
  my($self, $fh_avg, $fh_min, $fh_max) = @_;
  $self->Open;
  my @Val;
  my @Avg;
  my @Min;
  my @Max;
  my $rows = $self->{parsed}->{dim}->[1];
  my $cols = $self->{parsed}->{dim}->[2];
  my $num_slices = $self->{parsed}->{dim}->[3];
  my $num_vols = $self->{parsed}->{dim}->[4];
  my $bytes_per_pix = $self->{parsed}->{bitpix}/8;
  for my $i (0 .. $rows * $cols){
    $Val[$i] = undef;
    $Min[$i] = undef;
    $Max[$i] = undef;
  }
  my($offset, $length, $row_size) =
    $self->GetSliceOffsetLengthAndRowLength(0, 0);
  my $num_pix = $rows * $cols;
  my $is_fl = $self->{parsed}->{datatype} == 16;
  my $is_short = $self->{parsed}->{datatype} == 512 ||
    $self->{parsed}->{datatype} == 4;
  my $is_char = $self->{parsed}->{datatype} == 2;
  my $slice;
  for my $i (0 .. ($num_slices * $num_vols) - 1){
    my $offset_r = $offset + ($i * $length);
    unless(seek $self->{fh}, $offset_r, 0){
      die "seek ($!)";
    }
    my $len = read $self->{fh}, $slice, $length;
    unless($len == $length){
      die ("Read $len vs $length");
    }
    for my $j (0 .. ($num_pix - 1)){
      my $val;
      if($is_fl){
        $val = unpack('f', substr($slice, $j * 4, 4));
      }elsif($is_short){
        $val = unpack('S', substr($slice, $j * 2, 2));
      }elsif($is_char){
        $val = unpack('C', substr($slice, $j, 2));
      } else {
        die "Unknown datatype $self->{parsed}->{datatype}";
      }
      $Val[$j] += $val;
      unless(defined($Min[$j])){ $Min[$j] = $val }
      unless(defined($Max[$j])){ $Max[$j] = $val }
      if($val < $Min[$j]){ $Min[$j] = $val }
      if($val > $Max[$j]){ $Max[$j] = $val }
    }
  }
  for my $i (0 .. ($num_pix - 1)){
    my $avg = $Val[$i] / $num_slices;
    $Avg[$i] = $avg;
  }
  $self->Normalize(\@Avg, $num_pix);
  $self->Normalize(\@Min, $num_pix);
  $self->Normalize(\@Max, $num_pix);
  my $new_slice_avg = "\0" x $num_pix;
  my $new_slice_min = "\0" x $num_pix;
  my $new_slice_max = "\0" x $num_pix;
  for my $i (0 .. ($num_pix - 1)){
    no warnings;
    substr($new_slice_avg, $i, 1) = pack 'C', $Avg[$i];
  }
  print $fh_avg $new_slice_avg;
  for my $i (0 .. ($num_pix - 1)){
    no warnings;
    substr($new_slice_min, $i, 1) = pack 'C', $Min[$i];
  }
  print $fh_min $new_slice_min;
  for my $i (0 .. ($num_pix - 1)){
    no warnings;
    substr($new_slice_max, $i, 1) = pack 'C', $Max[$i];
  }
  print $fh_max $new_slice_max;
}
sub ProjectionAnalysis{
  my($self, $array, $len) = @_;
  my $total_zero = 0;
  my $total_nan = 0;
  my $total_inf = 0;
  my($AbsMin, $AbsMax, $AbsNzMin);
  my @Val;
  my @NanCounts;
  my @InfCounts;
  my @Avg;
  my @Min;
  my @Max;
  my $rows = $self->{parsed}->{dim}->[1];
  my $cols = $self->{parsed}->{dim}->[2];
  my $num_slices = $self->{parsed}->{dim}->[3];
  my $num_vols = $self->{parsed}->{dim}->[4];
  my $bytes_per_pix = $self->{parsed}->{bitpix}/8;
  for my $i (0 .. $rows * $cols){
    $Val[$i] = undef;
    $Min[$i] = undef;
    $Max[$i] = undef;
    $NanCounts[$i] = undef;
    $InfCounts[$i] = undef;
  }
  my($offset, $length, $row_size) =
    $self->GetSliceOffsetLengthAndRowLength(0, 0);
  my $num_pix = $rows * $cols;
  my $slice;
  for my $i (0 .. ($num_slices * $num_vols) - 1){
    my $offset_r = $offset + ($i * $length);
    unless(seek $self->{fh}, $offset_r, 0){
      die "seek ($!)";
    }
    my $len = read $self->{fh}, $slice, $length;
    unless($len == $length){
      die ("Read $len vs $length");
    }
    my $is_fl = $self->{parsed}->{datatype} == 16;
    my $is_short = $self->{parsed}->{datatype} == 512 ||
      $self->{parsed}->{datatype} == 4;
    my $is_char = $self->{parsed}->{datatype} == 2;
    pix:
    for my $j (0 .. ($num_pix - 1)){
      my $val;
      if($is_fl){
        $val = unpack('f', substr($slice, $j * 4, 4));
      }elsif($is_short){
        $val = unpack('S', substr($slice, $j * 2, 2));
      }elsif($is_char){
        $val = unpack('C', substr($slice, $j, 2));
      } else {
        die "Unknown datatype $self->{parsed}->{datatype}";
      }
      if($val eq "nan"){
        $total_nan += 1;
        $NanCounts[$i] += 1;
        next pix;
      }
      if($val =~ /inf/){
        $total_inf += 1;
        $InfCounts[$i] += 1;
        next pix;
      }
      if($val == 0){ $total_zero += 1 }
      $Val[$j] += $val;
      unless(defined $AbsMin) { $AbsMin = $val }
      unless(defined $AbsMax) { $AbsMax = $val }
      if($val < $AbsMin) { $AbsMin = $val }
      if($val > $AbsMax) { $AbsMax = $val }
      unless(defined($AbsNzMin)){
        if($val > 0){
          $AbsNzMin = $val;
        }
      }
      if($val > 0 && $val < $AbsNzMin){
        $AbsNzMin = $val;
      }
      unless(defined $Min[$j]) { $Min[$j] = $val }
      unless(defined $Max[$j]) { $Max[$j] = $val }
      if($val < $Min[$j]){ $Min[$j] = $val }
      if($val > $Max[$j]){ $Max[$j] = $val }
    }
  }
  for my $i (0 .. ($num_pix - 1)){
    my $avg = $Val[$i] / $num_slices;
    $Avg[$i] = $avg;
  }
  my $tot_pix = $num_pix * $num_slices * $num_vols;
  if($self->{parsed}->{datatype} == 16){
    my $range = sprintf("%5.3e to %5.3e", $AbsNzMin, $AbsMax);
    print "file $self->{file_id} (FP) has $tot_pix values, " .
      "$total_zero zeros, $total_nan NaN, $total_inf infinities, " .
      "non_zero values range from $range\n";
  } elsif (
    $self->{parsed}->{datatype} == 4 ||
    $self->{parsed}->{datatype} == 512
  ){
    print "file $self->{file_id} (short) has $tot_pix values, " .
      "$total_zero zeros, non_zero values range from " .
      "$AbsNzMin to $AbsMax\n";
  } else {
    print "file $self->{file_id} unknown data type: " .
      "$self->{parsed}->{datatype}\n";
  } 
}
sub Normalize{
  my($self, $array, $len) = @_;
  my $max;
  my $min;
  for my $i (0 .. $len - 1){
    unless(defined($max) && $array->[$i] ne "nan"){ $max = $array->[$i] }
    unless(defined($min) && $array->[$i] ne "nan"){ $min = $array->[$i] }
    if($array->[$i] > $max) { $max = $array->[$i] }
    if($array->[$i] < $min) { $min = $array->[$i] }
  }
  unless($max > $min) {return}
  for my $i (0 .. $len - 1){
      my $v = $array->[$i];
      my $scale = $max - $min;
      my $dist = $v - $min;
      my $sv = int(($dist * 255)/$scale);
      $array->[$i] = $sv;
  }
}

sub DESTROY{
  my($self) = @_;
  if($self->{is_from_zip}){
    if(
      exists $self->{compressed_file_name} &&
      defined $self->{compressed_file_name} &&
      exists $self->{file_name} &&
      defined $self->{file_name} &&
      -f $self->{compressed_file_name} &&
      -f $self->{file_name}
    ){
      unlink $self->{file_name};
      delete $self->{file_name};
    }
  }
}

1;

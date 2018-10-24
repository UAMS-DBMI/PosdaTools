#!/usr/bin/perl -w
#
use strict;
use Storable qw( store_fd fd_retrieve );
use Posda::FlipRotate;
use VectorMath;
use PipeChildren;
use Dispatch::Select;
use Dispatch::EventHandler;
use Debug;
my $dbg = sub {print STDERR @_ };
my $usage =
    "Usage:\n" .
    "IsoDoseExtraction.pl -h\n" .
    "  or\n" .
    "IsoDoseExtraction.pl\n\n" .
    "The first form (-h) prints these instructions\n" .
    "The second form (no command line parameters) receives its\n" .
    "instructions from STDIN as a serialized Perl hash:\n" .
    "\$hash = {\n" .
    "  slice_iop = [\n" .
    "    [ <x>, <y>, <z> ],  # direction cosine of rows\n" .
    "    [ <x>, <y>, <z> ],  # direction cosine of columns\n" .
    "  ],\n" .
    "  slice_ipp = [\n" .
    "    <x>, <y>, <z>   # position of upper left hand corner of slice\n" .
    "  ],\n" .
    "  slice_rows = <num_slice_rows>,\n" .
    "  slice_cols = <num_slice_cols>,\n" .
    "  slice_pix_sp = [\n" .
    "    <width_of_row>,\n" .
    "    <width_of_col>,\n" .
    "  ],\n" .
    "  dose_file_name = <dose_file_name>,\n" .
    "  dose_iop = [\n" .
    "    [ <x>, <y>, <z> ],  # direction cosine of rows\n" .
    "    [ <x>, <y>, <z> ],  # direction cosine of columns\n" .
    "  ],\n" .
    "  dose_ipp = [\n" .
    "    <x>, <y>, <z>   # position of upper left hand corner of slice\n" .
    "  ],\n" .
    "  dose_pix_offset = <offset_of_dose_array>,\n" .
    "  dose_pix_length = <length_of_dose_array>,\n" .
    "  dose_gfov_offset => <offset_of_grid_frame_offset_vector>,\n" .
    "  dose_gfov_length => <length_of_grid_frame_offset_vector>,\n" .
    "  dose_rows => <rows>,\n" .
    "  dose_cols => <cols>,\n" .
    "  dose_bytes => <num_bytes_per_pixel>,\n" .
    "  dose_pix_sp => [\n" .
    "    <width_of_row>,\n" .
    "    <width_of_col>,\n" .
    "  ],\n" .
    "  dose_scaling => <dose_scaling>,\n" .
    "  dose_units => <dose_units>,\n" .
    "  base_isodose_file_name => <base_file_name_for_isodoses>,\n" .
    "  levels => [\n" .
    "    <cGy level 1>,\n" .
    "    ...,\n" .
    "    <cGy level n>,\n" .
    "  ],\n" .
    "};\n\n" . 
    "";
if($#ARGV == 0){
  print $usage;
  exit;
}
my $args = fd_retrieve(\*STDIN);
#print STDERR "args: ";
#Debug::GenPrint($dbg, $args, 1);
#print "\n";
unless($#ARGV == -1){ die $usage }
unless(CompatableIops($args)){
  die "dose IOP not compatable with image IOP\n";
}
sub MakeStarter{
  my $start = sub {
    my($bk) = @_;
    my $bits_alloc = ComputeDoseBitsAlloc($args);
    my($num_rows, $num_cols, $spacing) = ComputeResamplingSpacing($args);
    my($resamp_ulx, $resamp_uly, $resamp_ulz) = ComputeResamplingOrigin($args);
    my $rs_args = {
      source_dose_file_name => $args->{dose_file_name},
      source_rows => $args->{dose_rows},
      source_cols => $args->{dose_cols},
      source_rowspc => $args->{dose_pix_sp}->[0],
      source_colspc => $args->{dose_pix_sp}->[1],
      source_pixel_offset => $args->{dose_pix_offset},
      source_bits_alloc => $bits_alloc,
      source_gfov_offset => $args->{dose_gfov_offset},
      source_gfov_length => $args->{dose_gfov_length},
      source_bits_alloc => $bits_alloc,
      source_dose_scaling => $args->{dose_scaling},
      source_dose_units => $args->{dose_units},
      resamp_ulx => $resamp_ulx,
      resamp_uly => $resamp_uly,
      resamp_ulz => $resamp_ulz,
      resamp_rows => $num_rows,
      resamp_cols => $num_cols,
      resamp_frames => 1,
      resamp_spc => $spacing,
      r_spc_x => $spacing,
      r_spc_y => $spacing,
      r_spc_z => $spacing,
      resamp_bits_alloc => 32,
      resamp_dose_units => "CGRAY",
      resamp_dose_scaling => .1,
    };
#print STDERR "rs_args: ";
#Debug::GenPrint($dbg, $rs_args, 1);
#print "\n";
    my $rs_stat = PipeChildren::GetSocketPair(my $from_p_1, my $to_p_1);
    my $rs_out = PipeChildren::GetSocketPair(my $from_p_2, my $to_p_2);
#    open my $dbg_fh, ">$args->{base_isodose_file_name}_test" or die
#      "can't #open $args->{base_isodose_file_name}_test";
    my $rs_fd_map = {
      status => $rs_stat->{to},
      out => $rs_out->{to},
      #out => $dbg_fh,
    };
    my $dr_pid = PipeChildren::Spawn("DoseResampler", $rs_fd_map, $rs_args);
    Dispatch::Select::Socket->new(
      WaitStatus($dr_pid, "DoseResampler"),
      $rs_stat->{from}
    )->Add("reader");
#print STDERR "rs_out: ";
#Debug::GenPrint($dbg, $rs_out, 1);
#print STDERR "\n";
#    return;
    my @levels;
    for my $i (@{$args->{levels}}){
      my $h = {};
      $h->{base_file_name} = "$args->{base_isodose_file_name}_$i";
      $h->{level} = $i;
      $h->{ms_stat} = PipeChildren::GetSocketPair(my $from_p_3, my $to_p_3);
      $h->{lv_ms_p} = PipeChildren::GetSocketPair(my $from_p_4, my $to_p_4);
      $h->{ms_sc_p} = PipeChildren::GetSocketPair(my $fp_4_5, my $to_p_4_5);
      $h->{sc_stat} = PipeChildren::GetSocketPair(my $fp_4_6, my $to_p_4_6);
      push(@levels, $h);
    }
#print STDERR "levels: ";
#Debug::GenPrint($dbg, \@levels, 1);
#print STDERR "\n";
    # Leveler and Marching Sq
    my $l_stat = PipeChildren::GetSocketPair(my $from_p_5, my $to_p_5);
    my $l_args = {
      bytes => 4,
    };
    my @l_sock_args;
    push(@l_sock_args, { key => "in", fh => $rs_out->{from}, args => [] });
    for my $i (@levels){
      push(@l_sock_args, {
         key => "out", fh => $i->{lv_ms_p}->{to}, args => [ $i->{level} ]
      });
#      open my $ms_fh, ">$i->{base_file_name}" 
#        or die "Can't open $i->{base_file_name} for writing";
      my $sc_fd_map = {
        status => $i->{sc_stat}->{to},
        in => $i->{ms_sc_p}->{from}
      };
      my $sc_args = { base_file_name => $i->{base_file_name} };
      my $sc_pid = PipeChildren::Spawn("SplitIsoDoseContours.pl",
        $sc_fd_map, $sc_args);
      Dispatch::Select::Socket->new(
        WaitStatus($sc_pid, "SplitIsoDoseContours[$i->{level}]"),
        $i->{sc_stat}->{from}
      )->Add("reader");
      
      my $mfd_map = {
        status => $i->{ms_stat}->{to},
        in => $i->{lv_ms_p}->{from},
        out => $i->{ms_sc_p}->{to},
      };
      my $ms_args = {
#        x => $rs_args->{resamp_ulx},
#	y => $rs_args->{resamp_uly},
        x => 0,
        y => 0,
        rows => $rs_args->{resamp_rows},
        cols => $rs_args->{resamp_cols},
#        x_spc => $rs_args->{resamp_spc},
#        y_spc => $rs_args->{resamp_spc},
        x_spc => 1,
        y_spc => 1,
        slice_index => 0,
      };
#print STDERR "ms_args: ";
#Debug::GenPrint($dbg, $ms_args, 1);
#print STDERR "\n";
      my $ms_pid = PipeChildren::Spawn("CompressedPixBitMapToContour",
        $mfd_map, $ms_args);
      Dispatch::Select::Socket->new(
        WaitStatus($ms_pid, "PixBitMapToContour[$i->{level}]"),
        $i->{ms_stat}->{from}
      )->Add("reader");
    }
#print STDERR "l_sock_args: ";
#Debug::GenPrint($dbg, \@l_sock_args, 1);
#print STDERR "\nl_args: ";
#Debug::GenPrint($dbg, $l_args, 1);
#print STDERR "\n";
    my $lv_pid = PipeChildren::SpawnSockWithParms("MultiIsoDose.pl",
      \@l_sock_args, $l_stat->{to}, $l_args);
    Dispatch::Select::Socket->new(
      WaitStatus($lv_pid, "MultiIsoDose.pl"),
      $l_stat->{from}
    )->Add("reader");
  };
  return $start;
}
sub CompatableIops{
  my($args) = @_;
  my $dist_r = 
    VectorMath::Dist($args->{slice_iop}->[0], $args->{dose_iop}->[0]);
  if($dist_r >.0000001) { return undef }
  my $dist_c = 
    VectorMath::Dist($args->{slice_iop}->[1], $args->{dose_iop}->[1]);
  if($dist_c >.0000001) { return undef }
  return 1;
}
sub ComputeDoseBytes{
  my($args) = @_;
  return $args->{dose_bytes};
}
sub ComputeDoseBitsAlloc{
  my($args) = @_;
  if($args->{dose_bytes} == 2) { return 16 }
  return 32;
}
#my($num_rows, $num_cols, $spacing) = ComputeResamplingSpacing($args);
sub ComputeResamplingSpacing{
  my($args) = @_;
  if($args->{slice_pix_sp}->[0] == $args->{slice_pix_sp}->[1]){
    return
      ($args->{slice_rows}, $args->{slice_cols}, $args->{slice_pix_sp}->[0]);
  }
  die "not ready for this";
#  if($args->{slice_pix_sp}->[0] > $args->{slice_pix_sp]->[1]){
#  } else {
#  }
}
#my($resamp_ulx, $resamp_uly, $resamp_ulz) = ComputeResamplingOrigin($args);
sub ComputeResamplingOrigin{
  my($args) = @_;
###  here we need to check for negative gfov entries and adjust dose ipp
  open DOSE, "<$args->{dose_file_name}"
    or die "can't open $args->{dose_file_name}";
  seek(DOSE, $args->{dose_gfov_offset}, 0);
  my $buff;
  my $count = read(DOSE, $buff, $args->{dose_gfov_length});
  unless($count == $args->{dose_gfov_length}) { die "couldn't read gfov" }
  close DOSE;
  my @gfov = split(/\\/, $buff);
  my $d_p = [$args->{dose_ipp}->[0], $args->{dose_ipp}->[1],
    $args->{dose_ipp}->[2]];
  if($gfov[$#gfov] < 0){
    my $norm = VectorMath::cross(
      $args->{dose_iop}->[0], $args->{dose_iop}->[1]);
    my $n_d_p = VectorMath::Add($d_p,
      VectorMath::Scale($gfov[$#gfov], $norm)
    );
   $d_p = $n_d_p;
  }
  my $ul_x = $args->{slice_ipp}->[0] - $d_p->[0];
  my $ul_y = $args->{slice_ipp}->[1] - $d_p->[1];
  my $ul_z = $args->{slice_ipp}->[2] - $d_p->[2];
  return ($ul_x, $ul_y, $ul_z);
}
sub WaitStatus{
  my($pid, $name) = @_;
  my $text = "";
  my $sub = sub{
    my($disp, $socket) = @_;
    my $count = sysread($socket, $text, 1024, length($text));
    if($count == 0){
      waitpid($pid, 0);
      $disp->Remove;
      chomp $text;
      if($text =~ /^OK/){
        my $rows = $1;
        my $cols = $2;
        my $frames = $3;
#        print STDERR "$name completed OK\n";
      } else {
        print STDERR "$name status error: \"$text\"\n";
      }
    }
  };
  return $sub;
}
{
  Dispatch::Select::Background->new(MakeStarter())->queue;
}
Dispatch::Select::Dispatch();

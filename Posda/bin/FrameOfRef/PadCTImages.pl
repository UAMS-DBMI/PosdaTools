#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

use strict;
use VectorMath;
use Posda::Find;
use Posda::UID;
use Debug;
my $dbg = sub {print @_};

my $usage = "usage: $0 <source> <target>";
unless($#ARGV == 1) {die $usage}

my $from = $ARGV[0];
my $to = $ARGV[1];
my($batch_rows, $batch_cols, $batch_iop, $batch_pix_spacing);
my %FileByOffset;
my $Normal;

my $search = sub {
  my($path, $df, $ds, $size, $xfr_stx, $errors) = @_;
  unless($ds->Get("(0008,0060)") eq "CT") { return }
  my $rows = $ds->ExtractElementBySig("(0028,0010)");
  my $cols = $ds->ExtractElementBySig("(0028,0011)");
  my $iop = $ds->ExtractElementBySig("(0020,0037)");
  my $ipp = $ds->ExtractElementBySig("(0020,0032)");
  my $pix_spacing = $ds->ExtractElementBySig("(0028,0030)");
  my $bits_alloc = $ds->ExtractElementBySig("(0028,0100)");
  my $file_pos = $ds->file_pos("(7fe0,0010)");
  my $pix_length = length($ds->Get("(7fe0,0010)"));
  my $intercept = $ds->ExtractElementBySig("(0028,1052)");
  my $pad_value = -1000 - $intercept;
  my $normal = VectorMath::cross([$iop->[0], $iop->[1], $iop->[2]],
    [$iop->[3], $iop->[4], $iop->[5]]);
  if(defined $Normal){
  } else {
    $Normal = $normal;
  }
  unless(defined $batch_rows) { $batch_rows = $rows }
  unless(defined $batch_cols) { $batch_cols = $cols }
  unless(defined $batch_iop) { $batch_iop = $iop }
  unless(defined $batch_pix_spacing) { $batch_pix_spacing  = $pix_spacing }

  unless($batch_rows == $rows) { die "Inconsistent rows" }
  unless($batch_cols == $cols) { die "Inconsistent cols" }
  unless($bits_alloc == 16 || $bits_alloc == 8) {
    die "bits_alloc: $bits_alloc"
  }
  my $bytes = ($bits_alloc == 16) ? 2 : 1;
  unless(abs(VectorMath::Abs([$iop->[0], $iop->[1], $iop->[2]]) - 1) < .0001){
    die "IOP is not unit vector";
  }
  unless(abs(VectorMath::Abs([$iop->[3], $iop->[4], $iop->[5]]) - 1) < .0001){
    die "IOP is not unit vector";
  }
  unless(
    abs (
      VectorMath::Dot(
        [$batch_iop->[0], $batch_iop->[1], $batch_iop->[2]],
        [$iop->[0], $iop->[1], $iop->[2]]
      )  - 1
    ) < 0.0001
  ) { die "Inconsistent IOP" }
  unless(
    abs (
      VectorMath::Dot(
        [$batch_iop->[3], $batch_iop->[4], $batch_iop->[5]],
        [$iop->[3], $iop->[4], $iop->[5]]
      )  - 1
    ) < 0.0001
  ) { die "Inconsistent IOP" }

  unless(
    $batch_pix_spacing->[0] == $pix_spacing->[0] &&
    $batch_pix_spacing->[1] == $pix_spacing->[1]
  ) {
    die "Inconsistent pixel spacing"
  }

  my $offset = VectorMath::Dot($normal, $ipp);
  $FileByOffset{$offset} = {
    xfr_stx => $xfr_stx,
    iop => $iop,
    ipp => $ipp,
    rows => $rows,
    cols => $cols,
    pix_spc => $pix_spacing,
    file_name => $path,
    bytes => $bytes,
    file_pos => $file_pos,
    pix_length => $pix_length,
    pad => $pad_value,
  };
};
Posda::Find::SearchDir($from, $search);

my @FileInfo;
for my $i (sort {$a <=> $b} keys %FileByOffset){
  push(@FileInfo, $FileByOffset{$i});
}
my $user = `whoami`;
my $host = `hostname`;
chomp $user;
chomp $host;
my $new_root = Posda::UID::GetPosdaRoot({
  program => "Posda/bin/FrameOfRef/MakeOrthoNormalReg.pl",
  user => $user,
  host => $host,
  purpose => "Get new Frame of Reference UID",
});
my $uid_index = 1;
my $max_addrows;
for my $i (1 .. ($#FileInfo)){
  my $from = $FileInfo[0];
  my $to = $FileInfo[$i];
  my $from_ipp = $from->{ipp};
  my $to_ipp = $to->{ipp};
  my $diff = VectorMath::Sub($to_ipp, $from_ipp);
  my $proj = VectorMath::Scale(VectorMath::Dot($diff, $Normal), $Normal);
  my $new_ipp = VectorMath::Add($from->{ipp}, $proj);
  my $dist = VectorMath::Dist($new_ipp, $to->{ipp});
  my $ar = $dist / $to->{pix_spc}->[1];
  my $add_rows = int($ar + .5 * ($ar <=> 0));
  if($ar < 0) { $add_rows = -$add_rows }
  $to->{add_rows} = $add_rows;
  unless(
    defined $max_addrows && $add_rows <= $max_addrows
  ){ $max_addrows = $add_rows }
}
print "Max_addrows: $max_addrows\n";
$FileInfo[0]->{add_rows} = 0;
for my $i (@FileInfo){
print "add_rows: $i->{add_rows}\n";
  my $remove = (int($max_addrows/2)) - $i->{add_rows};
  if($remove >= 0){
    $i->{remove_begining} = $remove;
    $i->{new_ipp} = VectorMath::Add($i->{ipp},
      VectorMath::Scale(- $i->{remove_begining} * $i->{pix_spc}->[1], 
        [$i->{iop}->[3], $i->{iop}->[4], $i->{iop}->[5]]
       )
    );
  } else {
    $i->{remove_end} = abs($remove);
    $i->{new_ipp} = VectorMath::Add($i->{ipp},
      VectorMath::Scale($i->{remove_end} * $i->{pix_spc}->[1], 
        [$i->{iop}->[3], $i->{iop}->[4], $i->{iop}->[5]]
       )
    );
  }
}
for my $i (@FileInfo){
  print "File Name $i->{file_name}:\n";
  if(exists $i->{remove_begining}){
    print "Remove $i->{remove_begining} lines from beginning; pad end\n";
  } else {
    print "Remove $i->{remove_end} lines from end; pad beginning\n";
  }
  my($df, $ds, $size, $xfr_stx, $errors) = Posda::Dataset::Try($i->{file_name});
  unless(defined $ds) { die "$i->{file_name} didn't parse a second time" }
  print "\tipp: ($i->{ipp}->[0], $i->{ipp}->[1], $i->{ipp}->[2]) => " .
    "($i->{new_ipp}->[0], $i->{new_ipp}->[1], $i->{new_ipp}->[2])\n";
  $ds->Insert("(0020,000e)", $new_root);
  $ds->Insert("(0008,0018)", "$new_root.$uid_index");
  my $dest_file = "$to/CT_$new_root.$uid_index.dcm";
  $uid_index += 1;
  $ds->Insert("(0020,0011)", "");
  $ds->Insert("(0008,0008)[0]", "DERIVED");
  $ds->Insert("(0008,0008)[1]", "SECONDARY");
  $ds->Insert("(7fe0,0010)", PadPixelData($i));
  $ds->Insert("(0020,0032)", $i->{new_ipp});
  print "#########\nTranslating:\n$i->{file_name}\nto$dest_file\n";
  $ds->WritePart10($dest_file, $xfr_stx, "POSDA_SCRIPT", undef, undef);
}

sub PadPixelData{
  my($info) = @_;
  my $rows_to_pad;
  my $at_end = 0;
  if(exists $info->{remove_begining}){
    $at_end = 1;
    $rows_to_pad = $info->{remove_begining};
  } elsif(exists $info->{remove_end}){
    $rows_to_pad = $info->{remove_end};
  } else {
    die "no pad spec for $info->{file_name}"
  }
  my $pad_count = $info->{cols} * $rows_to_pad;
  my $pad_len = $pad_count * $info->{bytes};
  my $pad_value;
  if($info->{bytes} == 2){
    my @pad_word;
    for my $i (0 .. $pad_count - 1){
      $pad_word[$i] = $info->{pad};
    }
    $pad_value = pack("s*", @pad_word);
  } elsif($info->{bytes} == 1){
    my @pad_byte;
    for my $i (0 .. $pad_count - 1){
      $pad_byte[$i] = $info->{pad};
    }
    $pad_value = pack("C*", @pad_byte);
  } else {
    die "no bytes spec for $info->{file_name}"
  }
  my $pix_size = $info->{rows} * $info->{cols} * $info->{bytes};
  my $read_len = $pix_size - $pad_len;
  my $read_start = $info->{file_pos};
  if($at_end){
    $read_start += $pad_len;
  }
  open FILE, "<$info->{file_name}" or die "can't open $info->{file_name}";
  seek FILE, $read_start, 0;
  my $pix;
  my $count = read(FILE, $pix, $read_len);
  unless($count == $read_len) { 
    die "partial read $count vs $read_len at $read_start for $info-{file_name}";
  }
  if($at_end){
    return $pix . $pad_value;
  } else {
    return $pad_value . $pix;
  }
}

#print "Results: ";
#Debug::GenPrint($dbg, \%FileByOffset, 1);
#print "\n";

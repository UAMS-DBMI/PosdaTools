#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/Anonymizer.pm,v $
#$Date: 2013/03/29 20:03:52 $
#$Revision: 1.32 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
package Posda::Anonymizer;
use strict;
use Posda::UUID;
use Posda::Dataset;
use Posda::FlipRotate;
use Math::Trig;
use Posda::PixArray;
use Posda::Find;

sub MakeFinder{
  my($this, $dir) = @_;
  my $foo = sub {
    my($try) = @_;
    unless(exists $try->{dataset}){ return }
    $this->history_builder($try->{dataset});
  };
  return $foo;
}

my $PixManips = {
  "ROT_90" => sub {
    my($ds) = @_;
    my $iop = $ds->ExtractElementBySig("(0020,0037)");
    my $ipp = $ds->ExtractElementBySig("(0020,0032)");
    my $bits_alloc = $ds->ExtractElementBySig("(0028,0100)");
    my $rows = $ds->ExtractElementBySig("(0028,0010)");
    my $cols = $ds->ExtractElementBySig("(0028,0011)");
    my $pix_sp = $ds->ExtractElementBySig("(0028,0030)");
    my($n_iop, $n_ipp, $n_rows, $n_cols, $n_pix_sp) =
      Posda::FlipRotate::RotIopIpp90($iop, $ipp, $rows, $cols, $pix_sp);
    $ds->InsertElementBySig("(0020,0037)", $n_iop);
    $ds->InsertElementBySig("(0020,0032)", $n_ipp);
    $ds->InsertElementBySig("(0028,0010)", $n_rows);
    $ds->InsertElementBySig("(0028,0011)", $n_cols);
    $ds->InsertElementBySig("(0028,0030)", $n_pix_sp);
    my $pix_array = $ds->ExtractElementBySig("(7fe0,0010)");
    my $n_pix_array = 
      Posda::FlipRotate::RotArray90($pix_array, $rows, $cols, $bits_alloc);
    $ds->InsertElementBySig("(7fe0,0010)", $n_pix_array);
  },
  "ROT_180" => sub {
    my($ds) = @_;
    my $iop = $ds->ExtractElementBySig("(0020,0037)");
    my $ipp = $ds->ExtractElementBySig("(0020,0032)");
    my $bits_alloc = $ds->ExtractElementBySig("(0028,0100)");
    my $rows = $ds->ExtractElementBySig("(0028,0010)");
    my $cols = $ds->ExtractElementBySig("(0028,0011)");
    my $pix_sp = $ds->ExtractElementBySig("(0028,0030)");
    my($n_iop, $n_ipp, $n_rows, $n_cols, $n_pix_sp) =
      Posda::FlipRotate::RotIopIpp90(
        Posda::FlipRotate::RotIopIpp90($iop, $ipp, $rows, $cols, $pix_sp)
      );
    $ds->InsertElementBySig("(0020,0037)", $n_iop);
    $ds->InsertElementBySig("(0020,0032)", $n_ipp);
    $ds->InsertElementBySig("(0028,0010)", $n_rows);
    $ds->InsertElementBySig("(0028,0011)", $n_cols);
    $ds->InsertElementBySig("(0028,0030)", $n_pix_sp);
    my $pix_array = $ds->ExtractElementBySig("(7fe0,0010)");
    my $n_pix_array = Posda::FlipRotate::RotArray90(
      Posda::FlipRotate::RotArray90($pix_array, $rows, $cols, $bits_alloc),
      $cols, $rows, $bits_alloc
    );
    $ds->InsertElementBySig("(7fe0,0010)", $n_pix_array);
  },
  "ROT_270" => sub {
    my($ds) = @_;
    my $iop = $ds->ExtractElementBySig("(0020,0037)");
    my $ipp = $ds->ExtractElementBySig("(0020,0032)");
    my $bits_alloc = $ds->ExtractElementBySig("(0028,0100)");
    my $rows = $ds->ExtractElementBySig("(0028,0010)");
    my $cols = $ds->ExtractElementBySig("(0028,0011)");
    my $pix_sp = $ds->ExtractElementBySig("(0028,0030)");
    my($n_iop, $n_ipp, $n_rows, $n_cols, $n_pix_sp) =
      Posda::FlipRotate::RotIopIpp90(
        Posda::FlipRotate::RotIopIpp90(
          Posda::FlipRotate::RotIopIpp90($iop, $ipp, $rows, $cols, $pix_sp)
        )
      );
    $ds->InsertElementBySig("(0020,0037)", $n_iop);
    $ds->InsertElementBySig("(0020,0032)", $n_ipp);
    $ds->InsertElementBySig("(0028,0010)", $n_rows);
    $ds->InsertElementBySig("(0028,0011)", $n_cols);
    $ds->InsertElementBySig("(0028,0030)", $n_pix_sp);
    my $pix_array = $ds->ExtractElementBySig("(7fe0,0010)");
    my $n_pix_array = Posda::FlipRotate::RotArray90(
      Posda::FlipRotate::RotArray90(
        Posda::FlipRotate::RotArray90($pix_array, $rows, $cols, $bits_alloc),
        $cols, $rows, $bits_alloc
      ),
      $rows, $cols, $bits_alloc
    );
    $ds->InsertElementBySig("(7fe0,0010)", $n_pix_array);
  },
  "FLIP_HORIZ" => sub {
    my($ds) = @_;
    my $iop = $ds->ExtractElementBySig("(0020,0037)");
    my $ipp = $ds->ExtractElementBySig("(0020,0032)");
    my $bits_alloc = $ds->ExtractElementBySig("(0028,0100)");
    my $rows = $ds->ExtractElementBySig("(0028,0010)");
    my $cols = $ds->ExtractElementBySig("(0028,0011)");
    my $pix_sp = $ds->ExtractElementBySig("(0028,0030)");
    my($n_iop, $n_ipp, $n_rows, $n_cols, $n_pix_sp) =
      Posda::FlipRotate::FlipIopIppHorizontal(
        $iop, $ipp, $rows, $cols, $pix_sp
      );
    $ds->InsertElementBySig("(0020,0037)", $n_iop);
    $ds->InsertElementBySig("(0020,0032)", $n_ipp);
    $ds->InsertElementBySig("(0028,0010)", $n_rows);
    $ds->InsertElementBySig("(0028,0011)", $n_cols);
    $ds->InsertElementBySig("(0028,0030)", $n_pix_sp);
    my $pix_array = $ds->ExtractElementBySig("(7fe0,0010)");
    my $n_pix_array = Posda::FlipRotate::FlipArrayHorizontal(
      $pix_array, $rows, $cols, $bits_alloc
    );
    $ds->InsertElementBySig("(7fe0,0010)", $n_pix_array);
  },
  "FLIP_VERT" => sub {
    my($ds) = @_;
    my $iop = $ds->ExtractElementBySig("(0020,0037)");
    my $ipp = $ds->ExtractElementBySig("(0020,0032)");
    my $bits_alloc = $ds->ExtractElementBySig("(0028,0100)");
    my $rows = $ds->ExtractElementBySig("(0028,0010)");
    my $cols = $ds->ExtractElementBySig("(0028,0011)");
    my $pix_sp = $ds->ExtractElementBySig("(0028,0030)");
    my($n_iop, $n_ipp, $n_rows, $n_cols, $n_pix_sp) =
      Posda::FlipRotate::FlipIopIppVertical(
        $iop, $ipp, $rows, $cols, $pix_sp
      );
    $ds->InsertElementBySig("(0020,0037)", $n_iop);
    $ds->InsertElementBySig("(0020,0032)", $n_ipp);
    $ds->InsertElementBySig("(0028,0010)", $n_rows);
    $ds->InsertElementBySig("(0028,0011)", $n_cols);
    $ds->InsertElementBySig("(0028,0030)", $n_pix_sp);
    my $pix_array = $ds->ExtractElementBySig("(7fe0,0010)");
    my $n_pix_array = Posda::FlipRotate::FlipArrayVertical(
      $pix_array, $rows, $cols, $bits_alloc
    );
    $ds->InsertElementBySig("(7fe0,0010)", $n_pix_array);
  },
  RESAMPLE => sub {
    my($ds) = @_;
    my $rows = $ds->ExtractElementBySig("(0028,0010)");
    my $cols = $ds->ExtractElementBySig("(0028,0011)");
    my $iop = $ds->ExtractElementBySig("(0020,0037)");
    my $ipp = $ds->ExtractElementBySig("(0020,0032)");
    my $pix_sp = $ds->ExtractElementBySig("(0028,0030)");
    my $pix_rep = $ds->ExtractElementBySig("(0028,0103)");
    my $array = $ds->ExtractElementBySig("(7fe0,0010)");
    my $bits_alloc = $ds->ExtractElementBySig("(0028,0100)");

    my $angle = acos($iop->[0]);
    my($new_iop, $new_ipp, $new_rows, $new_cols) =
       Posda::FlipRotate::ResamplingParams
        ($rows, $cols, $iop, $ipp, $pix_sp, $pix_sp);

    my $byte_count;
    if($bits_alloc == 8){
      $byte_count = 1;
    } elsif($bits_alloc == 16){
      $byte_count = 2;
    } elsif($bits_alloc == 32){
      $byte_count = 4;
    } else {
      die "bits alloc: $bits_alloc???";
    }
    my $new_array = "\0" x ($new_rows * $new_cols * $byte_count);
    my $from_array = Posda::PixArray->new(
      $rows, $cols, $bits_alloc, $pix_rep, $array);
    my $to_array = Posda::PixArray->new(
      $new_rows, $new_cols, $bits_alloc, $pix_rep, $new_array);

    for my $row (0 .. $new_rows - 1){
      for my $col (0 .. $new_cols - 1){
        my $p = Posda::FlipRotate::FromPixCoords(
          $new_iop, $new_ipp, $new_rows, $new_cols, $pix_sp, [$row, $col]);
        my $p_p = Posda::FlipRotate::ToPixCoords(
          $iop, $ipp, $rows, $cols, $pix_sp, $p);
        my $value = $from_array->interp_pixel($p_p->[0], $p_p->[1]);
        $to_array->set_pixel($row, $col, int $value);
      }
    }
    $ds->InsertElementBySig("(7fe0,0010)", $to_array->{array});
    $ds->InsertElementBySig("(0028,0010)", $new_rows);
    $ds->InsertElementBySig("(0028,0011)", $new_cols);
    $ds->InsertElementBySig("(0020,0037)", $new_iop);
    $ds->InsertElementBySig("(0020,0032)", $new_ipp);

  },
  STRIP_5_PIXELS_RIGHT_AND_BOTTOM => sub {
    my($ds) = @_;
    my $rows = $ds->ExtractElementBySig("(0028,0010)");
    my $cols = $ds->ExtractElementBySig("(0028,0011)");
    my $iop = $ds->ExtractElementBySig("(0020,0037)");
    my $ipp = $ds->ExtractElementBySig("(0020,0032)");
    my $pix_sp = $ds->ExtractElementBySig("(0028,0030)");
    my $pix_rep = $ds->ExtractElementBySig("(0028,0103)");
    my $array = $ds->ExtractElementBySig("(7fe0,0010)");
    my $bits_alloc = $ds->ExtractElementBySig("(0028,0100)");
    my $new_rows = $rows - 5;
    my $new_cols = $cols - 5;
    my $byte_count;
    if($bits_alloc == 8){
      $byte_count = 1;
    } elsif($bits_alloc == 16){
      $byte_count = 2;
    } elsif($bits_alloc == 32){
      $byte_count = 4;
    } else {
      die "bits alloc: $bits_alloc???";
    }
    my $new_array = "\0" x ($new_rows * $new_cols * $byte_count);
    my $from_array = Posda::PixArray->new(
      $rows, $cols, $bits_alloc, $pix_rep, $array);
    my $to_array = Posda::PixArray->new(
      $new_rows, $new_cols, $bits_alloc, $pix_rep, $new_array);
    for my $row (0 .. $new_rows - 1){
      for my $col (0 .. $new_cols - 1){
        my $value = $from_array->get_pixel($row, $col);
        $to_array->set_pixel($row, $col, $value);
      }
    }
    $ds->InsertElementBySig("(7fe0,0010)", $to_array->{array});
    $ds->InsertElementBySig("(0028,0010)", $new_rows);
    $ds->InsertElementBySig("(0028,0011)", $new_cols);
  },
};
{
  package Posda::Anonymizer::Raw;
  use vars qw( @ISA );
  @ISA = ("Posda::Anonymizer");
  sub new_from_dir{
    my($class, $dir_name) = @_;
    unless(-d $dir_name) { die "not a directory" };
    my $this = {};
    bless $this, $class;
    my $foo = $this->MakeFinder();
    Posda::Find::DicomOnly($dir_name, $foo);
    return $this;
  }
  sub new_blank{
    my($class) = @_;
    my $this = {};
    return bless $this, $class;
  }
}
sub new_from_raw{
  my($class, $raw, $uid_root) = @_;
  my $this = {};
  for my $i (keys %{$raw->{sub}}){
    for my $j (keys %{$raw->{sub}->{$i}->{values}}){
      my $text = $raw->{sub}->{$i}->{values}->{$j};
      $text =~ s/%(..)/pack("c",hex($1))/ge;
      $j =~ s/%(..)/pack("c",hex($1))/ge;
      $this->{map}->{$i}->{$j} = $text;
    }
  }
  for my $i (keys %{$raw->{date}->{dates}}){
    $this->{date_map}->{$i} = $raw->{date}->{dates}->{$i};
  }
  $this->{uid_xlate} = {};
  $this->{dd} = $Posda::Dataset::DD;
  if(defined $uid_root){
    $this->{uid_root} = $uid_root;
  } else {
    $this->{uid_root} = Posda::UUID::GetUUID();
  }
  $this->{uid_seq} = 1;
  return bless $this, $class;
}
sub new_from_file{
  my($class, $file_name) = @_;
  my $uid;
  my %mapped_elements;
  my %mapped_dates;
  my %overrides;
  my %deletes;
  my %text_substitutions;
  my $pixel_manipulation = "NONE";
  my %add_to_new;
  open FILE, "<", "$file_name" or die "Can't open $file_name (map file)";
  while(my $line = <FILE>){
    chomp $line;
    $line =~ s/\s*$//;
    my @values = split(/\|/, $line);
    if ($values[0] eq "map"){
      unless($values[3] =~ /\"([^\"]*)\"\s*=>\s*\"([^\"]*)\"/){
        die "bad line in map file: $line ($values[3])";
      }
      my $from = $1;
      my $to = $2;
      $from =~ s/%(..)/pack("c",hex($1))/ge;
      $mapped_elements{$values[1]}->{$from} = $to;
    } elsif ($values[0] eq "date_map"){
      unless($values[1] =~ /\"([^\"]*)\"\s*=>\s*\"([^\"]*)\"/){
        die "bad line in map file: $line ($values[3])";
      }
      my $from = $1;
      my $to = $2;
      $mapped_dates{$from} = $to;
    } elsif ($values[0] eq "set"){
      $overrides{$values[1]} = $values[3];
    } elsif ($values[0] eq "text_sub"){
      unless($values[3] =~ /\"([^\"]*)\"\s*=>\s*\"([^\"]*)\"/){
        die "bad line in map file: $line ($values[3])";
      }
      my $from = $1;
      my $to = $2;
      push(@{$text_substitutions{$values[1]}}, [$from, $to]);
    } elsif ($values[0] eq "delete"){
      $deletes{$values[1]} = 1;
    } elsif ($values[0] eq "pixel_manip"){
      my $arg = $values[1];
      if(exists $PixManips->{$arg}){
        $pixel_manipulation = $arg;
      } else {
        print "unknown pixel manipulation: $arg\n";
      }
    } elsif ($values[0] eq "add_to_new"){
      $add_to_new{$values[1]} = $values[2];
    } else {
      print "bad line in map file: '$line'\n";
    }
  }
  my $ret = {
    map => \%mapped_elements,
    date_map => \%mapped_dates,
    overrides => \%overrides,
    deletes => \%deletes,
    uid_xlate => {
    },
    dd => $Posda::Dataset::DD,
    text_substitutions => \%text_substitutions,
    pixel_manipulation => $pixel_manipulation,
    add_to_new => \%add_to_new,
  };
  my $user = `whoami`;
  chomp $user;
  my $host = `hostname`;
  chomp $host;
  $ret->{uid_root} = Posda::UUID::GetUUID();
  $ret->{uid_seq} = 1;
  return bless $ret, $class;
}

sub new_uid{
  my($this) = @_;
  my $new_uid = "$this->{uid_root}.$this->{uid_seq}";
  $this->{uid_seq} = $this->{uid_seq} + 1;
  return $new_uid;
}

sub pass_one{
  my($this, $ds) = @_;
  $ds->Map(sub {
    my($element, $root, $sig, $keys, $depth) = @_;
    unless(exists($element->{VR}) && $element->{VR} eq 'UI') {return}
    my $value = $element->{value};
    unless(defined($value)){ return }
    if(exists $this->{dd}->{SopCl}->{$value}){return}
    if(exists $this->{uid_xlate}->{$value}){return}
    my $new_uid = "$this->{uid_root}.$this->{uid_seq}";
    $this->{uid_seq} += 1;
    $this->{uid_xlate}->{$value} = $new_uid;
  });
}
sub db_pass_one{
  my($this, $db, $ds) = @_;
  $ds->Map(sub {
    my($element, $root, $sig, $keys, $depth) = @_;
    unless(exists($element->{VR}) && $element->{VR} eq 'UI') {return}
    my $value = $element->{value};
    unless(defined($value)){ return }
    if(exists $this->{dd}->{SopCl}->{$value}){return}
    my $q = $db->prepare(
      "select to_uid from uid_mapping where from_uid = ?"
    );
    $q->execute($value);
    my $h = $q->fetchrow_hashref();
    $q->finish();
    if($h && ref($h) eq "HASH"){
      if(
        exists($this->{uid_xlate}->{$value})
      ){
        unless($this->{uid_xlate}->{$value} eq $h->{to_uid}){
          print STDERR "Different Mappings for $value:\n";
          print STDERR "\t$h->{to_uid}\n";
          print STDERR "vs\n";
          print STDERR "\t$this->{uid_xlate}->{$value}\n";
        }
        return;
      }
      $this->{uid_xlate}->{$value} = $h->{to_uid};
      return;
    }
    my $new_uid = "$this->{uid_root}.$this->{uid_seq}";
    $this->{uid_seq} += 1;
    $this->{uid_xlate}->{$value} = $new_uid;
    $q = $db->prepare(
      "insert into uid_mapping(from_uid, to_uid) values (?, ?)"
    );
    $q->execute($value, $new_uid);
  });
}
sub pass_two{
  my($this, $ds) = @_;
  $ds->Map(sub {
    my($element, $root, $sig, $keys, $depth) = @_;
    unless(exists $element->{value}){ return }
    my $value = $element->{value};
    my $grp = $keys->[0];
    my $ele = $keys->[1];
    my $short_sig = sprintf("(%04x,%04x)", $grp, $ele);
    unless(defined $value) { $value = "" }
    if(
      exists($this->{map}) && ref($this->{map}) eq "HASH" &&
      exists($this->{map}->{$short_sig}) 
    ){
      if(ref($value) eq "ARRAY"){
        for my $i (0 .. $#{$element->{value}}){
          my $val = $element->{value}->[$i];
          unless(defined $val) {$val = ""}
          $val =~ s/%(..)/pack("c",hex($1))/ge;
          if(exists $this->{map}->{$short_sig}->{$val}){
            $element->{value}->[$i] =
              $this->{map}->{$short_sig}->{$val};
          }
        }
      } else {
        $value =~ s/%(..)/pack("c",hex($1))/ge;
        if(
          exists($this->{map}->{$short_sig}->{$value})
        ){
          $element->{value} = $this->{map}->{$short_sig}->{$value};
        }
      }
      return;
    } elsif (
      $element->{VR} eq "DA" && 
      exists($this->{date_map}->{$value})
    ){
      if(ref($element->{value}) eq "ARRAY"){
        for my $i (0 .. $#{$element->{value}}){
          if(exists $this->{date_map}->{$element->{value}->[$i]}){
            $element->{value}->[$i] =
              $this->{date_map}->{$element->{value}->[$i]};
          }
        }
      } else {
        $element->{value} = $this->{date_map}->{$value};
      }
      return;
    }
    unless(exists($element->{VR}) && $element->{VR} eq 'UI' && defined($value)
    ) {return}
    if(exists $this->{uid_xlate}->{$value}){
      $element->{value} = $this->{uid_xlate}->{$value};
    }
  });
}
sub AddToNew{
  my($this, $ds) = @_;
  for my $i (keys %{$this->{add_to_new}}){
    $ds->InsertElementBySig($i, $this->{add_to_new}->{$i});
  }
}
sub TextSubstitutions {
  my($this, $ds) = @_;
  $ds->MapPvt(
    sub {
      my($ele, $sig) = @_;
      if(exists $this->{text_substitutions}->{$sig}){
        my $new_value = $ele->{value};
        for my $pair (@{$this->{text_substitutions}->{$sig}}){
          $new_value =~ s/$pair->[0]/$pair->[1]/g;
        }
        $ele->{value} = $new_value;
      }
    }
  );
}
sub PassTwo{
  my($this, $ds) = @_;
  $ds->Map(sub {
    my($element, $root, $sig, $keys, $depth) = @_;
    unless(exists $element->{value}){ return }
    my $value = $element->{value};
    unless(
      exists($element->{VR}) && $element->{VR} eq 'UI' && defined($value)
    ){return}
    if(exists $this->{uid_xlate}->{$value}){
      $element->{value} = $this->{uid_xlate}->{$value};
    }
  });
}
sub Maps{
  my($this, $ds) = @_;
  $ds->Map(sub {
    my($element, $root, $sig, $keys, $depth) = @_;
    unless(exists $element->{value}){ return }
    my $value = $element->{value};
    my $grp = $keys->[0];
    my $ele = $keys->[1];
    my $short_sig = sprintf("(%04x,%04x)", $grp, $ele);
    unless(defined $value) { $value = "" }
    if(exists $this->{map}->{$short_sig}){
      if(ref($element->{value}) eq "ARRAY"){
        for my $i (0 .. $#{$element->{value}}){
          $i =~ s/%(..)/pack("c",hex($1))/ge;
          if(exists $this->{map}->{$short_sig}->{$element->{value}->[$i]}){
            $element->{value}->[$i] =
              $this->{map}->{$short_sig}->{$element->{value}->[$i]};
          }
        }
      } else {
        $value =~ s/%(..)/pack("c",hex($1))/ge;
        if(
          exists $this->{map}->{$short_sig}->{$value}
        ){
          $element->{value} = $this->{map}->{$short_sig}->{$value};
        }
      }
      return;
    }
  });
}
sub DateMaps{
  my($this, $ds) = @_;
  $ds->Map(sub {
    my($element, $root, $sig, $keys, $depth) = @_;
    unless(exists $element->{value}){ return }
    my $value = $element->{value};
    unless(defined $value) { $value = "" }
    if ($element->{VR} eq "DA"){
      if(ref($element->{value}) eq "ARRAY"){
        for my $i (0 .. $#{$element->{value}}){
          if(exists $this->{date_map}->{$element->{value}->[$i]}){
            $element->{value}->[$i] =
              $this->{date_map}->{$element->{value}->[$i]};
          }
        }
      } else {
        if(exists $this->{date_map}->{$value}){
          $element->{value} = $this->{date_map}->{$value};
        }
      }
      return;
    }
  });
}
sub Overrides{
  my($this, $ds) = @_;
  for my $sig (keys %{$this->{overrides}}){
    $ds->InsertElementBySig($sig, $this->{overrides}->{$sig}, $this->{dd});
  }
}
sub Deletes{
  my($this, $ds) = @_;
  for my $sig (keys %{$this->{deletes}}){
    $ds->Delete($sig, $this->{overrides}->{$sig}, $this->{dd});
  }
}
sub PixManip{
  my($this, $ds) = @_;
  unless($this->{pixel_manipulation} ne "NONE") { return }
  unless(exists $PixManips->{$this->{pixel_manipulation}}){
    die "Undefined pix manip: $this->{pixel_manipulation}";
  }
  unless(defined $ds->{0x7fe0}) {return};
  &{$PixManips->{$this->{pixel_manipulation}}}($ds);
}

my $DefaultList = 
[ "(0008,0014)", "(0008,0018)", "(0008,0050)", "(0008,0080)",
  "(0008,0081)", "(0008,0090)", "(0008,0092)", "(0008,0094)",
  "(0008,1010)", "(0008,1030)", "(0008,103e)", "(0008,1040)",
  "(0008,1048)", "(0008,1050)", "(0008,1060)", "(0008,1070)",
  "(0008,1080)", "(0008,1155)", "(0008,2111)", "(0010,0010)",
  "(0010,0020)", "(0010,0030)", "(0010,0032)", "(0010,0040)",
  "(0010,1000)", "(0010,1001)", "(0010,1010)", "(0010,1020)",
  "(0010,1030)", "(0010,1090)", "(0010,2160)", "(0010,2180)",
  "(0010,21b0)", "(0010,4000)", "(0018,1000)", "(0018,1030)",
  "(0020,000d)", "(0020,000e)", "(0020,0010)", "(0020,0052)",
  "(0020,0200)", "(0020,4000)", "(0040,0244)", "(0040,0244)",
  "(0040,0253)", "(0040,a124)", "(0040,a730)", "(0088,0140)",
  "(3006,0024)", "(3006,00c2)",
]; 
sub history_builder{
  my($hash, $ds, $AddlMap) = @_;
  my $List;
  for my $tag (@$DefaultList){
    my $vr = $Posda::Dataset::DD->get_ele_by_sig($tag)->{VR};
    if(defined($vr)){
      if($vr ne "UI"){
        $List->{$tag} = 1;
      }
    } else {
      print STDERR "No VR defined for tag: $tag\n";
    }
  }
  if($AddlMap && ref($AddlMap) eq "ARRAY"){
    for my $tag (@$AddlMap){
      my $vr = $Posda::Dataset::DD->get_ele_by_sig($tag)->{VR};
      if(defined($vr)){
        if($vr ne "UI"){
          $List->{$tag} = "";
        }
      } else {
        print STDERR "No VR defined for tag: $tag\n";
      }
    }
  }
  $ds->Map(sub {
    my($element, $root, $sig, $keys, $depth) = @_;
    
    my $grp = $keys->[0];
    my $ele = $keys->[1];
    my $short_sig = sprintf("(%04x,%04x)", $grp, $ele);
    my $ele_name = "<unknown>";
    if(exists $Posda::Dataset::DD->{Dict}->{$grp}->{$ele}->{Name}){
      $ele_name = $Posda::Dataset::DD->{Dict}->{$grp}->{$ele}->{Name};
    }
    if ($element->{VR} eq "DA"){
      my $text;
      if(ref($element->{value}) eq "ARRAY"){
        $text = join("\\", @{$element->{value}});
      } elsif(defined $element->{value}) {
        $text = $element->{value}
      } else {
        $text = "";
      }
      $hash->{date}->{dates}->{$text} = "";
      $hash->{date}->{occurances}->{$text} += 1;
    } elsif(
      $List->{$short_sig} && $element->{type} eq "text" ||
      $element->{VR} eq "PN"
    ){
      my $text;
      if(ref($element->{value}) eq "ARRAY"){
        $text = join("\\", @{$element->{value}});
      } elsif(defined $element->{value}) {
        $text = $element->{value}
      } else {
        $text = "";
      }
      $text =~ s/(\n)/"%" . unpack("H2", $1)/eg;
      $hash->{sub}->{$short_sig}->{name} = $ele_name;
      $hash->{sub}->{$short_sig}->{values}->{$text} = "";
      $hash->{sub}->{$short_sig}->{occurances}->{$text} += 1
    } else {
    }
  });
}
sub text_searcher{
  my($hash, $ds, $List, $text_strings) = @_;
  $ds->Map(sub {
    my($element, $root, $sig, $keys, $depth) = @_;
    
    my $grp = $keys->[0];
    my $ele = $keys->[1];
    my $short_sig = sprintf("(%04x,%04x)", $grp, $ele);
    my $ele_name = "<unknown>";
    if(exists $Posda::Dataset::DD->{Dict}->{$grp}->{$ele}->{Name}){
      $ele_name = $Posda::Dataset::DD->{Dict}->{$grp}->{$ele}->{Name};
    }
    if($List->{$short_sig}){
      return;
    } elsif($element->{type} eq "text" || $element->{type} eq "raw"){
      my $text;
      if(ref($element->{value}) eq "ARRAY"){
        $text = join("\\", @{$element->{value}});
      } elsif(defined $element->{value}) {
        $text = $element->{value}
      } else {
        $text = "";
      }
      for my $p (@$text_strings){
        if($text =~ /$p/i){
          print "$sig contains $p\n";
        }
      }
    }
  });
  sub rename_rois{
    my($this, $ds, $roi_renamer, $file) = @_;
    roi_num:
    for my $roi_num (keys %$roi_renamer) {
      if($roi_renamer->{$roi_num}->{from} eq $roi_renamer->{$roi_num}->{to}){
        next roi_num;
      }
      if($roi_renamer->{$roi_num}->{to} eq "<delete>"){
        my $m = $ds->Search("(3006,0020)[<0>](3006,0022)", $roi_num);
        for my $s (@$m){
          $ds->Delete("(3006,0020)[$s->[0]]");
        }
        $m = $ds->Search("(3006,0039)[<0>](3006,0084)", $roi_num);
        for my $s (@$m){
          $ds->Delete("(3006,0039)[$s->[0]]");
        }
        $m = $ds->Search("(3006,0080)[<0>](3006,0084)", $roi_num);
        for my $s (@$m){
          $ds->Delete("(3006,0080)[$s->[0]]");
        }
        next roi_num;
      }
      my $m = $ds->Search("(3006,0020)[<0>](3006,0022)", $roi_num);
      unless($m && ref($m) eq "ARRAY"){
        print STDERR "No roi_num: $roi_num found in $file\n";
        next roi_num;
      }
      unless($#{$m} == 0){
        print STDERR "Multiple roi_num $roi_num in $file\n";
        next roi_num;
      }
      my $name = $ds->Get("(3006,0020)[$m->[0]->[0]](3006,0026)");
      unless($name eq $roi_renamer->{$roi_num}->{from}){
        print STDERR "Non matching name ($name vs " .
          "$roi_renamer->{$roi_num}->{from}) in roi_num $roi_num in $file\n";
        next roi_num;
      }
      $ds->Insert("(3006,0020)[$m->[0]->[0]](3006,0026)",
        $roi_renamer->{$roi_num}->{to});
    }
  };
}
1;

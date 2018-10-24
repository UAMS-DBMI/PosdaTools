#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

use strict;
package Posda::PseudoPhantom;
use VectorMath;
use Posda::Dataset;
use Posda::FlipRotate;
use Posda::UID;
use Posda::Solids;
use Posda::Interpolator;
use Posda::PixelPlaneGenerator;
use Posda::DensityGenerator;

Posda::Dataset::InitDD;

{
  package Posda::PseudoPhantom;
  my $get_point = sub {
    my($text, $line) = @_;
    unless($text =~ /^\((.*),(.*),(.*)\)$/){ 
      die "\"$text\" not point in line: \"$line\"";
    }
    my $point = [$1, $2, $3];
    return $point;
  };
  my $get_range = sub {
    my($text, $line) = @_;
    unless($text =~ /^\((.*),(.*)\)$/){ 
      die "\"$text\" not range in line: \"$line\"";
    }
    my $range = [$1, $2];
    return $range;
  };
  my $process_config = sub {
    my($this, $config_file, $config) = @_;
    open CONFIG, "<", "$config_file" or die "can't open $config_file";
    line:
    while(my $line = <CONFIG>){
      chomp $line;
      if($line =~ /^#/) { next line }
      my($sig, $name, $value) = split(/\|/, $line);
      my $vm = $Posda::Dataset::DD->get_ele_by_sig($sig)->{VM};
      if(!defined($vm) || $vm eq 1){
        $config->{$sig} = $value;
      } else {
        my @value = split(/\\/, $value);
        $config->{$sig} = \@value;
      }
    }
    close CONFIG;
  };
  my $dispatch_command =  {
    base_uid => sub {
      my($this, $args, $line) = @_;
      $this->{base_uid} = shift(@$args);
    },
    base_for => sub {
      my($this, $args, $line) = @_;
      $this->{frames}->{$args->[0]} = {
        base => 1,
      }
    },
    base_dir => sub {
      my($this, $args, $line) = @_;
      unless(-d $args->[0]){
        die "base_dir ($args->[0]) is not a directory";
      }
      $this->{base_directory} = $args->[0];
    },
    named_obj => sub {
      my($this, $args, $line) = @_;
      my $dispatch_obj_type = {
        sphere => sub {
          my($args, $line) = @_;
          my $center = &$get_point($args->[0], $line);
          my $radius = $args->[1];
          return Posda::Solids::Sphere->new($center, $radius);
        },
        cylinder => sub {
          my($args, $for, $line) = @_;
          my $point1 = &$get_point($args->[0], $line);
          my $point2 = &$get_point($args->[1], $line);
          my $radius = $args->[2];
          return Posda::Solids::Cylinder->new($point1, $point2, $radius);
        },
        ellipsoid => sub {
          my($args, $for, $line) = @_;
          my $point1 = &$get_point($args->[0], $line);
          my $point2 = &$get_point($args->[1], $line);
          my $radius = $args->[2];
          return Posda::Solids::Ellipsoid->new($point1, $point2, $radius);
        },
        cone => sub {
          my($args, $for, $line) = @_;
          my $point1 = &$get_point($args->[0], $line);
          my $point2 = &$get_point($args->[1], $line);
          my $radius = $args->[2];
          return Posda::Solids::Cone->new($point1, $point2, $radius);
        },
        rectangular_solid => sub {
          my($args, $for, $line) = @_;
          my $center = &$get_point($args->[0], $line);
          my $height = $args->[1];
          my $width = $args->[2];
          my $length = $args->[3];
          my $rot_x = $args->[4];
          my $rot_y = $args->[5];
          my $rot_z = $args->[6];
          return Posda::Solids::Rectangular->new($center, $height, 
            $width, $length, $rot_x, $rot_y, $rot_z);
        },
        union => sub {
          my($args, $for, $line) = @_;
          my @arglist;
          for my $obj_name (@$args){
            unless(
              exists($this->{frames}->{$for}->{objs}->{$obj_name}) &&
              $this->{frames}->{$for}->{objs}->{$obj_name}->isa("Posda::Solids")
            ){
              die "$obj_name doesn't designate an object in $for " .
              "at config:\n\"$line\"";
            }
            push(@arglist, $this->{frames}->{$for}->{objs}->{$obj_name});
          }
          return Posda::Solids::Union->new(@arglist);
        },
        intersection => sub {
          my($args, $for, $line) = @_;
          my @arglist;
          for my $obj_name (@$args){
            unless(
              exists($this->{frames}->{$for}->{objs}->{$obj_name}) &&
              $this->{frames}->{$for}->{objs}->{$obj_name}->isa("Posda::Solids")
            ){
              die "$obj_name doesn't designate an object in $for " .
              "at config:\n\"$line\"";
            }
            push(@arglist, $this->{frames}->{$for}->{objs}->{$obj_name});
          }
          return Posda::Solids::Intersection->new(@arglist);
        },
        complement => sub {
          my($args, $for, $line) = @_;
          unless($#{$args} == 1){
            die "wrong number of args in config line:\n\"$line\"";
          }
          my $outer_name = $args->[0];
          my $inner_name = $args->[1];
          unless(
            exists($this->{frames}->{$for}->{objs}->{$inner_name}) &&
            $this->{frames}->{$for}->{objs}->{$inner_name}->isa("Posda::Solids")
          ){
              die "$inner_name doesn't designate an object in $for " .
              "at config:\n\"$line\"";
          }
          my $inner_obj = $this->{frames}->{$for}->{objs}->{$inner_name};
          unless(
            exists($this->{frames}->{$for}->{objs}->{$outer_name}) &&
            $this->{frames}->{$for}->{objs}->{$outer_name}->isa("Posda::Solids")
          ){
              die "$outer_name doesn't designate an object in $for " .
              "at config:\n\"$line\"";
          }
          my $outer_obj = $this->{frames}->{$for}->{objs}->{$outer_name};
          return Posda::Solids::Complement->new($outer_obj, $inner_obj);
        },
        static_beam => sub {
          my($args, $for, $line) = @_;
          unless($#{$args} == 8){ 
           my $count = scalar @$args;
           die "bad static beam configuration (needs 9 args has $count):" .
               " $line";
          }
          my($pos, $isot, $x_jawst, $y_jawst, $blda, $ga, $gpa, $psda, $sad) =
            @$args;
          my $iso = &$get_point($isot, $line);
          my $xjaws = &$get_range($x_jawst, $line);
          my $yjaws = &$get_range($y_jawst, $line);
          return Posda::Solids::Beam->new(
            $pos, $iso, $xjaws, $yjaws, $blda, $ga, $gpa, $psda, $sad);
        },
      };
      my $name = shift(@$args);
      my $type = shift(@$args);
      my $for = shift(@$args);
      unless(
        exists($dispatch_obj_type->{$type}) &&
        ref($dispatch_obj_type->{$type}) eq "CODE"
      ){  die "unknown obj_type: $type in \"$line\""};
      my $obj = &{$dispatch_obj_type->{$type}}($args, $for, $line);
      $this->{frames}->{$for}->{objs}->{$name} = $obj;
    },
    obj_list => sub{
      my($this, $args, $line) = @_;
      my $name = shift(@$args);
      $this->{obj_list}->{$name} = $args;
    },
    posda_arg => sub {
      my($this, $args, $line) = @_;
      my $name = shift(@$args);
      my $value = shift(@$args);
      $this->{posda_args}->{$name} = $value;
    },
    combined_obj_list => sub{
      my($this, $args, $line) = @_;
      my $name = shift(@$args);
      for my $list(@$args){
        for my $obj (@{$this->{obj_list}->{$list}}){
          push(@{$this->{obj_list}->{$name}}, $obj);
        }
      }
    },
    set_obj_prop => sub {
      my($this, $args, $line) = @_;
      my $for = shift(@$args);
      my $prop_name = shift(@$args);
      my $value = shift(@$args);
      my $obj_list = $this->{obj_list}->{$args->[0]};
      for my $obj_name (@$obj_list){
        my $obj = $this->{frames}->{$for}->{objs}->{$obj_name};
        unless(ref($obj)){
          die "$for, $obj_name designates unblessed object in $line";
        }
        $obj->{properties}->{$prop_name} = $value;
      }
    },
    transformed_for => sub {
      my($this, $args, $line) = @_;
      my $name = shift(@$args);
      my $base = shift(@$args);
        my @cmd_list;
        for my $i (0 .. $#{$args}){
          unless ($args->[$i] =~ /(.*)=(.*)/){
            print STDERR "illegal arg: $line ($args->[$i])\n";
            next line;
          }
          my $cmd = $1;
          my $op = $2;
          push(@cmd_list, [$cmd, $op]);
        } 
        unless(exists $this->{frames}->{$base}){
           die "No from frame of refence ($base) \"$line\"";
           next line;
        }
        my($xf, $r_xf) = Posda::Transforms::MakeTransformPair(\@cmd_list);
        $this->{frames}->{$base}->{to_xforms}->{$name} = $xf;
        $this->{frames}->{$base}->{from_xforms}->{$name} = $r_xf;
        $this->{frames}->{$name}->{to_xforms}->{$base} = $r_xf;
        $this->{frames}->{$name}->{from_xforms}->{$base} = $xf;
    },
    xform_obj_list => sub {
      my($this, $args, $line) = @_;
      my $x_spec = shift(@$args);
      unless($x_spec =~ /^(.*)=>(.*)$/){
        die "bad xform spec in \"$line\"";
      }
      my $from = $1;
      my $to = $2;
      unless(exists $this->{frames}->{$from}->{to_xforms}->{$to}){
        die "no xform ($from=>$to)in \"$line\"";
      }
      my $xform = $this->{frames}->{$from}->{to_xforms}->{$to};
      my $obj_list_name = shift(@$args);
      my $obj_list = $this->{obj_list}->{$obj_list_name};
      for my $obj_name (@$obj_list){
        unless(ref($this->{frames}->{$from}->{objs}->{$obj_name})){
          die "no object named $obj_name in for $from: \"$line\"";
        }
        $this->{frames}->{$to}->{objs}->{$obj_name} =
          $this->{frames}->{$from}->{objs}->{$obj_name}->XformCopy($xform);
      }
    },
    xform_roi_list => sub {
      my($this, $args, $line) = @_;
      my $x_spec = shift(@$args);
      unless($x_spec =~ /^(.*)=>(.*)$/){
        die "bad xform spec in \"$line\"";
      }
      my $from = $1;
      my $to = $2;
      unless(exists $this->{frames}->{$from}->{to_xforms}->{$to}){
        die "no xform ($from=>$to)in \"$line\"";
      }
      my $xform = $this->{frames}->{$from}->{to_xforms}->{$to};
      for my $roi_xform_spec (@$args){
        unless($roi_xform_spec =~ /^(.*)=>(.*)$/){
          die "bad roi xform spec in \"$line\"";
        }
        my $from_roi_num = $1;
        my $to_roi_num = $1;
        my $next_obs_num = 1;
        unless(exists $this->{frames}->{$from}->{roi}->{$from_roi_num}){
          die "no roi $from_roi_num in for $from: \"$line\"";
        }
        $this->{frames}->{$to}->{roi}->{$to_roi_num} = 
          $this->{frames}->{$from}->{roi}->{$from_roi_num};
        for my $i (sort keys %{$this->{$from}->{roi_obs}}){
          if(
            $this->{frames}->{$from}->{roi_obs}->{$i}->{roi_num} eq
            $from_roi_num
          ){
           my $from_obs = $this->{frame}->{$from}->{roi_obs}->{$i};
           my $to_obs = {
             roi_num => $to_roi_num
           };
           for my $j (sort keys %$from_obs){
             unless($j eq "roi_num"){
               $to_obs->{$j} = $from_obs->{$j};
             }
           }
           $this->{frame}->{$from}->{roi_obs}->{$next_obs_num} = $to_obs;
           $next_obs_num += 1;
          }
        }
      }
    },
    study => sub {
      my($this, $args, $line) = @_;
      my $study_id = shift(@$args);
      my $for_name = shift(@$args);
      my $study_config = shift(@$args);
      my $study_dir = shift(@$args);
      my $study_desc = shift(@$args);
      unless(-d "$this->{destination}/$study_dir"){
        mkdir "$this->{destination}/$study_dir";
      }
      $this->{studies}->{$study_id} = {
         for => $for_name,
         study_config => "$this->{base_directory}/$study_config",
         study_dir => "$this->{destination}/$study_dir",
         study_desc => $study_desc,
      };
    },
    series => sub {
      my($this, $args, $line) = @_;
      my $study_id = shift(@$args);
      my $series_id = shift(@$args);
      my $for = shift(@$args);
      my $series_config = shift(@$args);
      my $series_rel_dir = shift(@$args);
      my $type_args = shift(@$args);
      my $obj_list = shift(@$args);
      unless($type_args =~ /^(.*)\((.*)\)$/){
        die "Bad Series: $line\n";
      }
      my $type = $1;
      my $arg_str = $2;
      my $study_dir = $this->{studies}->{$study_id}->{study_dir};
      my $series_dir = "$study_dir/$series_rel_dir";
      unless(-d $series_dir) {
        mkdir $series_dir;
      }
      $this->{studies}->{$study_id}->{series}->{$series_id} = {
        study_id => $study_id,
        series_config => $series_config,
        series_dir => $series_dir,
        type => $type,
        args => $arg_str,
        obj_list => $obj_list
      };
      my $config = {};
      &$process_config(
        $this, 
        $this->{studies}->{$study_id}->{study_config},
        $config);
      &$process_config(
        $this, 
        "$this->{base_directory}/$series_config",
         $config);
      $this->{studies}->{$study_id}->{series}->{$series_id}->{config} = $config;
    },
    roi => sub {
      my($this, $args, $line) = @_;
      my $for_name = shift(@$args);
      my $name = shift(@$args);
      my $roi_num = shift(@$args);
      my $level = shift(@$args);
      my $gen_alg = shift(@$args);
      my $obj_list = shift(@$args);
      $this->{frames}->{$for_name}->{roi}->{$roi_num} = {
        name => $name,
        level => $level,
        gen_alg => $gen_alg,
        obj_list => $obj_list,
      };
    },
    roi_color => sub {
      my($this, $args, $line) = @_;
      my $for_name = shift(@$args);
      my $roi_num = shift(@$args);
      my $color = shift(@$args);
      $this->{frames}->{$for_name}->{roi}->{$roi_num}->{color} = $color;
    },
    roi_obs => sub {
      my($this, $args, $line) = @_;
      my $for_name = shift(@$args);
      my $roi_num = shift(@$args);
      my $obs_num = shift(@$args);
      my $name = shift(@$args);
      my $value = shift(@$args);
      my $h = {};
      if(exists $this->{frames}->{$for_name}->{roi_obs}->{$obs_num}){
        $h = $this->{frames}->{$for_name}->{roi_obs}->{$obs_num};
      } else {
        $this->{frames}->{$for_name}->{roi_obs}->{$obs_num} = $h;
      }
      if(exists($h->{roi_num})){
        unless(
          $h->{roi_num} ne $roi_num || $h->{roi_num} == $roi_num
        ){
          die "matching roi_obs_num ($obs_num) for " .
              "roi's $h->{roi_num} and $roi_num";
        }
      } else {
        $h->{roi_num} = $roi_num;
      }
      $h->{$name} = $value;
    },
    dynamic_beam_dose => sub{
      my($this, $args, $line) = @_;
      my $for = shift(@$args);
      my $targ = shift(@$args);
      my $dose_inside_targ = shift(@$args);
      my $dose_outside_targ = shift(@$args);
      $this->{dynamic_beam}->{for} = $for;
      $this->{dynamic_beam}->{targ} = $targ;
      $this->{dynamic_beam}->{dose_inside} = $dose_inside_targ;
      $this->{dynamic_beam}->{dose_outside} = $dose_outside_targ;
    },
    semi_dynamic_beam_dose => sub{
      my($this, $args, $line) = @_;
      my $bn = shift(@$args);
      my $for = shift(@$args);
      my $bm = shift(@$args);
      my $targ = shift(@$args);
      my $pos = shift(@$args);
      my $dose_inside_targ = shift(@$args);
      my $dose_outside_targ = shift(@$args);
      $this->{semi_dynamic_beam}->{$bn}->{for} = $for;
      $this->{semi_dynamic_beam}->{$bn}->{bm} = $bm;
      $this->{semi_dynamic_beam}->{$bn}->{targ} = $targ;
      $this->{semi_dynamic_beam}->{$bn}->{pos} = $pos;
      $this->{semi_dynamic_beam}->{$bn}->{dose_inside} = $dose_inside_targ;
      $this->{semi_dynamic_beam}->{$bn}->{dose_outside} = $dose_outside_targ;
    },
    beam_dose => sub{
      my($this, $args, $line) = @_;
      my $name = shift(@$args);
      my $for_name = shift(@$args);
      my $beam_name = shift(@$args);
      unless(exists $this->{frames}->{$for_name}->{objs}->{$beam_name}){
        die "beam $beam_name is undefined in \"$line\"";
      }
      my $beam = $this->{frames}->{$for_name}->{objs}->{$beam_name};
      my $target_name = shift(@$args);
      unless(exists $this->{frames}->{$for_name}->{objs}->{$target_name}){
        die "target $target_name is undefined in \"$line\"";
      }
      my $target = $this->{frames}->{$for_name}->{objs}->{$target_name};
      my $in_target = shift(@$args);
      my $out_target = shift(@$args);
      $this->{frames}->{$for_name}->{beam_doses}->{$name} = 
        {
           beam_name => $beam_name,
           beam => $beam,
           target_name => $target_name,
           target => $target,
           dose_inside_target => $in_target,
           dose_outside_target => $out_target,
        };
    },
    plan_dose => sub{
      my($this, $args, $line) = @_;
      my $name = shift(@$args);
      my $for_name = shift(@$args);
      $this->{frames}->{$for_name}->{plan_doses}->{$name} = $args;
    },
  };
  sub HasObjNamed{
    my($this, $name) = @_;
    for my $frame (keys %{$this->{frames}}){
      if(exists $this->{frames}->{$frame}->{objs}->{$name}) { return 1 }
    }
    return 0;
  }
  sub new{
    my($class, $config_file, $dest_dir) = @_;
    my %this;
    $this{destination} = $dest_dir;
    $this{config_file_name} = $config_file;
    if($config_file =~ /^(.*)\/[^\/]*$/){
      $this{base_directory} = $1;
    }
    open FILE, "<", "$config_file" or die "can't open $config_file";
    line:
    while(my $line = <FILE>){
      if($line =~ /^#/){ next line }
      if($line =~ /^$/){ next line }
      chomp $line;
      my @fields = split(/\|/, $line);
      for my $i (0 .. $#fields){
        $fields[$i] =~ s/^\s*//;
        $fields[$i] =~ s/\s*$//;
      }
      my $command = shift(@fields);
      if(
        exists($dispatch_command->{$command}) &&
        ref($dispatch_command->{$command}) eq "CODE"
      ){
        &{$dispatch_command->{$command}}(\%this, \@fields, $line);
      } else {
        die "unparsable line: $line";
      }
    }
    if(exists $this{base_uid}){
      delete $this{posda_args};
    } else {
      my $user;
      if(exists $ENV{USER}){
        $user = $ENV{USER};
      } elsif (exists $ENV{USERNAME}){
        $user = $ENV{USERNAME};
      } else {
        $user = "<unknown>";
      }
      my $host = `hostname`;
      chomp $host;
      my $arg = {
        package => "Posda::PseudoPhantom",
        user => $user,
        host => $host,
        purpose => "Initialize Phantom Generator",
      };
      for my $name (keys %{$this{posda_args}}){
        $arg->{$name} = $this{posda_args}->{$name};
      }
      $this{base_uid} = Posda::UID::GetUID($arg);
      $this{posda_args} = $arg;
    }
    my $for_i = 0;
    for my $for (sort keys %{$this{frames}}){
      $for_i += 1;
      my $uid = "$this{base_uid}.1.$for_i";
      $this{frames}->{$for}->{for_uid} = $uid;
    }
    my $sti = 0;
    for my $study (sort keys %{$this{studies}}){
      $sti += 1;
      my $study_uid = "$this{base_uid}.2.$sti";
      $this{studies}->{$study}->{study_uid} = $study_uid;
      my $sri = 0;
      for my $series (keys %{$this{studies}->{$study}->{series}}){
        $sri += 1;
        my $series_uid = "$study_uid.$sri";
        $this{studies}->{$study}->{series}->{$series}->{series_uid} =
          $series_uid;
      }
    }
    return bless \%this, $class;
  }
  my $parse_vol_of_slices = sub {
    my($text) = @_;
    unless($text =~ /^(.*),(.*),(\[.*\])$/){
      die "Can't make sense of ct_parms: $text";
    }
    my $hash = {
      slice_spacing => $1,
      num_slices => $2,
      center_of_volume => $3,
    };
    return $hash;
  };
  my $ParmParsers = {
    CT => $parse_vol_of_slices,
    PT => $parse_vol_of_slices,
    MR => $parse_vol_of_slices,
    REG => sub {
      my($text) = @_;
      my @array = split(/,/, $text);
      return \@array;
    },
    RTS => sub {
      my($text) = @_;
      my @array = split(/,/, $text);
      my $ref_study = shift(@array);
      my $ref_series = shift(@array);
      my $hash = {
        ref_study => $ref_study,
        ref_series => $ref_series,
        roi_num => \@array,
      };
      return $hash;
    },
    RTP => sub {
      my($text) = @_;
      my @parms = split(/,/, $text);
      my $ss_study = shift(@parms);
      my $ss_series = shift(@parms);
      my $plan_name = shift(@parms);
      my $hash = {
        ss_study => $ss_study,
        ss_series => $ss_series,
        plan_name => $plan_name,
      };
      for my $i (0 .. $#parms){
        my $p = $parms[$i];
        unless($p =~ /^(.*)=(.*)$/){
          die "Can't make sense of plan arg: $text";
        }
        my $beam_name = $1;
        my $beam_no = $2;
        $hash->{beams}->{$beam_name}->{beam_no} = $beam_no;
      }
      return $hash;
    },
    RTD => sub {
      my($text) = @_;
      unless($text =~ /^(.*),(.*),(\[.*\]),(.*)$/){
        die "Can't make sense of dose_parms: $text";
      }
      my $hash = {
        slice_spacing => $1,
        num_slices => $2,
        center_of_volume => $3,
      };
      my $remaining = $4;
      my @parms = split(/,/, $remaining);
      $hash->{doses} = \@parms;
      return $hash;
    },
  };
  sub DumpGuts{
    my($this) = @_;
    print "Posda::PseudoPhantom:\n";
    if(exists $this->{posda_args}){
      print "UID root ($this->{base_uid}) " .
        "obtained from posda.com - args:\n";
      for my $name (sort keys %{$this->{posda_args}}){
        print "\t$name => $this->{posda_args}->{$name}\n";
      }
    } else {
      print "UID root: $this->{base_uid}\n";
    }
    for my $for_id (sort keys %{$this->{frames}}){
      my $for_uid = $this->{frames}->{$for_id}->{for_uid};
      print "Frame of reference ($for_id): $for_uid\n";
      print "\tObjects:\n";
      for my $obj_name (sort keys %{$this->{frames}->{$for_id}->{objs}}){
        my $obj = $this->{frames}->{$for_id}->{objs}->{$obj_name};
        print "\t\t$obj_name - ";
        $obj->DumpGuts("\t\t");
      }
      print "\tFrom transforms:\n";
      for my $i (keys %{$this->{frames}->{$for_id}->{to_xforms}}){
        my $to_for_uid = $this->{frames}->{$i}->{for_uid};
        print "\t\t$for_uid ($for_id)\n\t\t\t=>\n\t\t$to_for_uid ($i)\n";
        my $x_form = $this->{frames}->{$for_id}->{to_xforms}->{$i};
        Posda::Transforms::PrintTransform($x_form);
      }
      print "\tTo transforms:\n";
      for my $i (keys %{$this->{frames}->{$for_id}->{from_xforms}}){
        my $from_for_uid = $this->{frames}->{$i}->{for_uid};
        my $to_for_uid = $this->{frames}->{$for_id}->{for_uid};
        print "\t\t$from_for_uid ($i)\n\t\t\t=>\n\t\t$for_uid ($for_id)\n";
        my $x_form = $this->{frames}->{$for_id}->{from_xforms}->{$i};
        Posda::Transforms::PrintTransform($x_form);
      }
      print "\tRoi's:\n";
      for my $i (keys %{$this->{frames}->{$for_id}->{roi}}){
        my $h = $this->{frames}->{$for_id}->{roi}->{$i};
        print "\t\troi{$i}:\n";
        print "\t\t\tname: $h->{name}\n";
        print "\t\t\tlevel: $h->{level}\n";
        print "\t\t\tgen_alg: $h->{gen_alg}\n";
        print "\t\t\tobj_list: $h->{obj_list}\n";
        unless(exists($this->{obj_list}->{$h->{obj_list}})){
          die "ROI referenced undefined obj_list $h->{obj_list}";
        }
      }
      print "\tRoi Observations:\n";
      for my $i (keys %{$this->{frames}->{$for_id}->{roi_obs}}){
        for my $k (keys %{$this->{frames}->{$for_id}->{roi_obs}->{$i}}){
          if(defined $this->{frames}->{$for_id}->{roi_obs}->{$i}->{$k}){
            print "\t\t$i: $k = " .
              "$this->{frames}->{$for_id}->{roi_obs}->{$i}->{$k}\n";
          } else {
            print "\t\t$i: $k = <null>\n";
          }
        }
      }
      print "\tBeam Doses:\n";
      for my $i (sort keys %{$this->{frames}->{$for_id}->{beam_doses}}){
        my $h = $this->{frames}->{$for_id}->{beam_doses}->{$i};
        print "\t\t$i:\n";
        for my $j (sort keys %$h){
          print "\t\t\t$j: $h->{$j}\n";
        }
      }
      print "\tPlan Doses:\n";
      for my $i (sort keys %{$this->{frames}->{$for_id}->{plan_doses}}){
        my $l = $this->{frames}->{$for_id}->{plan_doses}->{$i};
        print "\t\t$i:";
        for my $j (@$l){
          print " $j";
        }
        print "\n";
      }
    }
    print "Object lists:\n";
    for my $i (sort keys %{$this->{obj_list}}){
      print "\t$i:\n";
      for my $j (@{$this->{obj_list}->{$i}}){
        print "\t\t$j\n";
        unless($this->HasObjNamed($j)){
          die "Object $j is in obj_list, but not defined";
        }
      }
    }
    print "Studies:\n";
    for my $study_id (keys %{$this->{studies}}){
      my $study_hash = $this->{studies}->{$study_id};
      my $frame_of_reference =
         $this->{frames}->{$study_hash->{for}}->{for_uid};
      my $study_desc = $study_hash->{study_desc};
      my $study_uid = $study_hash->{study_uid};
      print "\tStudy id: $study_id\n";
      print "\t\tFrame of Reference: $frame_of_reference\n";
      print "\t\tStudy Description: $study_desc\n";
      print "\t\tStudy UID: $study_uid\n";
      print "\t\tSeries:\n";
      for my $series_num (sort {$a <=> $b} keys %{$study_hash->{series}}){
        my $series_hash = $study_hash->{series}->{$series_num};
        my $type = $series_hash->{type};
        unless(exists $ParmParsers->{$type}){
          die "Unknown series type $type";
        }
        my $args = &{$ParmParsers->{$type}}($series_hash->{args});
        my $dir = $series_hash->{series_dir};
        my $config = $series_hash->{series_config};
        my $uid = $series_hash->{series_uid};
        my $obj_list = $series_hash->{obj_list};
        print "\t\t\t$series_num: $type\n";
        if(ref($args) eq "HASH"){
          for my $arg (sort keys %$args){
            if(ref($args->{$arg}) eq "ARRAY"){
              for my $argi (0 .. $#{$args->{$arg}}){
                print "\t\t\t\t${arg}[$argi] - $args->{$arg}->[$argi]\n";
              }
            } else {
              print "\t\t\t\t$arg - $args->{$arg}\n";
            }
          }
        } elsif(ref($args) eq "ARRAY"){
          for my $arg (0 .. $#{$args}){
            print "\t\t\t\targ[$arg] - $args->[$arg]\n";
          }
        } else {
        }
        print "\t\t\t\tuid: $uid\n";
        print "\t\t\t\tconfig: $config\n";
        print "\t\t\t\tdir: $dir\n";
        print "\t\t\t\tobj_list: $obj_list\n";
      }
    }
  }
  my $GenerateSeriesOfImages = sub{
    my($this, $study_id, $series_id) = @_;
    my $series_start = time();
    my $study = $this->{studies}->{$study_id};
    my $series = $study->{series}->{$series_id};
    my $obj_list_name = $series->{obj_list};
    my $obj_list = $this->{obj_list}->{$obj_list_name};
    my $config = $series->{config};
    my $for_id = $study->{for};
    my $for_uid = $this->{frames}->{$for_id}->{for_uid};
    my $dest_dir = $series->{series_dir};
    my $series_uid = $series->{series_uid};
    my $study_uid = $study->{study_uid};
    my $study_description = $study->{study_desc};
    my $type = $series->{type};
    my $args = &{$ParmParsers->{$type}}($series->{args});
    my $center_of_volume = $args->{center_of_volume};
    my $ppg = Posda::PixelPlaneGenerator->new($type, 
      $this->make_for_obj_list($for_id, $obj_list));
    unless($center_of_volume =~ /^\[(.*),(.*),(.*)\]$/){
      die "bad center of volume string: $center_of_volume";
    }
    my $center_of_vol = [$1, $2, $3];
    my $slice_spacing = $args->{slice_spacing};
    my $num_slices = $args->{num_slices};
    my $cur_instance_num = 0;
    my($rows, $cols, $iop) = (
      $config->{"(0028,0010)"},
      $config->{"(0028,0011)"},
      $config->{"(0020,0037)"},
    );
    my $sop_class = $config->{"(0008,0016)"};
    my $modality = $config->{"(0008,0060)"};
    my $dxdc = $iop->[0];       # dx/dr
    my $dydc = $iop->[1];       # dy/dr
    my $dzdc = $iop->[2];       # dz/dr 
    my $dxdr = $iop->[3];       # dx/dc
    my $dydr = $iop->[4];       # dy/dc
    my $dzdr = $iop->[5];       # dz/dc
    my $pix_sp = $config->{"(0028,0030)"};
    $ppg->CCodeGen($rows, $cols, $iop, $pix_sp);
    my ($p_x, $p_y) = @$pix_sp;       # pixel_spacing
    my $normal = VectorMath::cross(
      [$dxdc, $dydc, $dzdc], [$dxdr, $dydr, $dzdr]
    );
    my($dxdp, $dydp, $dzdp) = @$normal;
    my $length = $slice_spacing * ($num_slices - 1);
    my $width = $pix_sp->[0] * ($cols - 1);
    my $height = $pix_sp->[1] * ($rows - 1);
  
    my $init_ipp = [
      $center_of_vol->[0] - ($dxdc *  $width/2) 
                          - ($dxdr * $height/2)
                          - ($dxdp * $length/2),
      $center_of_vol->[1] - ($dydc *  $width/2)
                          - ($dydr * $height/2)
                          - ($dydp * $length/2),
      $center_of_vol->[2] - ($dzdc *  $width/2)
                          - ($dzdr * $height/2)
                          - ($dzdp * $length/2),
    ];
    my $current_instance_no = 0;
    for my $slice_no (1 .. $num_slices){
      my $start_time = time();
      $current_instance_no += 1;
      my $sop_instance = "$series_uid.$current_instance_no";
      my $current_ipp = [
        $init_ipp->[0] + ($dxdp * ($slice_no - 1) * $slice_spacing),
        $init_ipp->[1] + ($dydp * ($slice_no - 1) * $slice_spacing),
        $init_ipp->[2] + ($dzdp * ($slice_no - 1) * $slice_spacing),
      ];
      print "Generating image $current_instance_no of $num_slices\n";
      print "\tipp: ($current_ipp->[0], " .
        "$current_ipp->[1], $current_ipp->[2])\n";
      my $ds = Posda::Dataset->new_blank();
      for my $i (keys %$config){
        $ds->Insert($i, $config->{$i});
      }
      $ds->Insert("(0008,1030)", $study_description);
      $ds->Insert("(0020,0052)", $for_uid);
      $ds->Insert("(0020,000d)", $study_uid);
      $ds->Insert("(0020,000e)", $series_uid);
      $ds->Insert("(0020,0011)", $series_id);
      $ds->Insert("(0020,0010)", $study_id);
      $ds->Insert("(0008,0018)", $sop_instance);
      $ds->Insert("(0020,0013)", $current_instance_no);
      $ds->Insert("(0020,0032)", $current_ipp);
#      unless(exists $PixelPlaneGenerator->{$type}){
#        die "no PixelPlaneGenerator for series of $type";
#      }
      my($pixel_data, $pixel_representation, $slope, $intercept) = 
        $ppg->gen_plane($rows, $cols, $iop, $current_ipp, $pix_sp);
#        &{$PixelPlaneGenerator->{$type}}(
#          $this, $rows, $cols, $iop, $current_ipp, $pix_sp, $for_id, $obj_list);
      $ds->Insert("(7fe0,0010)", $pixel_data);
      $ds->Insert("(0028,0103)", $pixel_representation);
      if(defined $slope){
        $ds->Insert("(0028,1053)", $slope);
        $ds->Insert("(0028,1052)", $intercept);
      }
      my $file_name = "$dest_dir/${modality}_$sop_instance.dcm";
print "File_name: $file_name\n";
      $ds->WritePart10(
        $file_name, '1.2.840.10008.1.2.1', 'POSDA_PHNTM', undef, undef
      );
      my $elapsed = time() - $start_time;
      print "\tTook $elapsed seconds preparing this image\n";
    }
    my $elapsed_series = time() - $series_start;
      print "Took $elapsed_series seconds preparing this series\n";
  };
  my $GenerateRegSeries = sub{
    my($this, $study_id, $series_id) = @_;
    my $start_time = time();
    my $study = $this->{studies}->{$study_id};
    my $series = $study->{series}->{$series_id};
    my $obj_list_name = $series->{obj_list};
    my $obj_list = $this->{obj_list}->{$obj_list_name};
    my $config = $series->{config};
    my $for_id = $study->{for};
    my $dest_dir = $series->{series_dir};
    my $series_uid = $series->{series_uid};
    my $study_uid = $study->{study_uid};
    my $study_description = $study->{study_desc};
    my $type = $series->{type};
    my $args = &{$ParmParsers->{$type}}($series->{args});
    my $inst = 0;
    arg:
    for my $arg (@$args){
      $inst += 1;
      unless($arg =~ /^(\S+)=>(\S+)$/){
      print STDERR "Bad REG arg ($args->[0])" .
        " ($study_id, $series_id)\n";
        next arg;
      }
      my $from = $1;
      my $to = $2;
      my $from_uid = $this->{frames}->{$from}->{for_uid};
      my $to_uid = $this->{frames}->{$to}->{for_uid};
      my $xform_s = $this->{frames}->{$to}->{from_xforms}->{$from};
      my $xform;
      for my $i (0 .. 3){
        for my $j (0 .. 3){
          push(@$xform, $xform_s->[$i]->[$j]);
        }
      }
  
      my $ds = Posda::Dataset->new_blank();
      for my $i (keys %$config){
        $ds->Insert($i, $config->{$i});
      }
      my $sop_instance = "$series_uid.$inst";
      $ds->Insert("(0008,1030)", $study_description);
      $ds->Insert("(0020,0052)", $to_uid);
      $ds->Insert("(0020,000d)", $study_uid);
      $ds->Insert("(0020,000e)", $series_uid);
      $ds->Insert("(0020,0011)", $series_id);
      $ds->Insert("(0020,0010)", $study_id);
      $ds->Insert("(0008,0018)", $sop_instance);
      $ds->Insert("(0020,0013)", 1);

      $ds->Insert("(0070,0308)[0](0020,0052)", $to_uid);
      $ds->Insert("(0070,0308)[1](0020,0052)", $from_uid);
      $ds->Insert(
        "(0070,0308)[1](0070,0309)[0](0070,030a)[0](0070,030c)",
        "RIGID");
      $ds->Insert(
        "(0070,0308)[1](0070,0309)[0](0070,030a)[0](3006,00c6)",
        $xform);
      $ds->Insert(
        "(0070,0308)[1](0070,0309)[0](0070,030d)[0](0008,0100)",
        125023);
      $ds->Insert(
        "(0070,0308)[1](0070,0309)[0](0070,030d)[0](0008,0102)",
        "DCM");
      $ds->Insert(
        "(0070,0308)[1](0070,0309)[0](0070,030d)[0](0008,0103)",
        20040115);
      $ds->Insert(
        "(0070,0308)[1](0070,0309)[0](0070,030d)[0](0008,0104)",
        "Acquistition Equipment Alignment");

      my $modality = $config->{"(0008,0060)"};
      my $file_name = "$dest_dir/${modality}_$sop_instance.dcm";
print "File_name: $file_name\n";
      $ds->WritePart10(
        $file_name, '1.2.840.10008.1.2.1', 'POSDA_PHNTM', undef, undef
      );
      my $elapsed = time() - $start_time;
      print "\tTook $elapsed seconds preparing this Spatial Registration\n";
    }
  };
  my $TypeToSop = {
    CT => "1.2.840.10008.5.1.4.1.1.2",
    MR => "1.2.840.10008.5.1.4.1.1.4",
    PT => "1.2.840.10008.5.1.4.1.1.128",
    RTS => "1.2.840.10008.5.1.4.1.1.481.3",
    REG => "1.2.840.10008.5.1.4.1.1.66.1",
    RTP => "1.2.840.10008.5.1.4.1.1.481.5",
    RTD => "1.2.840.10008.5.1.4.1.1.481.2",
  };
  my $GenerateStructSeries = sub{
    my($this, $study_id, $series_id) = @_;
    my $start_time = time();
    my $study = $this->{studies}->{$study_id};
    my $series = $study->{series}->{$series_id};
    my $obj_list_name = $series->{obj_list};
    my $config = $series->{config};
    my $for_id = $study->{for};
    my $dest_dir = $series->{series_dir};
    my $series_uid = $series->{series_uid};
    my $study_uid = $study->{study_uid};
    my $study_description = $study->{study_desc};
    my $type = $series->{type};
    my $args = &{$ParmParsers->{$type}}($series->{args});
    my $inst = 1;
    my $ds = Posda::Dataset->new_blank();
    for my $i (keys %$config){
      $ds->Insert($i, $config->{$i});
    }
    my $sop_instance = "$series_uid.$inst";
    $ds->Insert("(0008,1030)", $study_description);
    $ds->Insert("(0020,000d)", $study_uid);
    $ds->Insert("(0020,000e)", $series_uid);
    $ds->Insert("(0020,0011)", $series_id);
    $ds->Insert("(0020,0010)", $study_id);
    $ds->Insert("(0008,0018)", $sop_instance);
    $ds->Insert("(0020,0013)", 1);
    #
    #  Here's where we generate the ref_frame_of_ref seq
    #
    my $ref_study_id = $args->{ref_study};
    my $ref_study = $this->{studies}->{$args->{ref_study}};
    my $ref_for = $this->{frames}->{$ref_study->{for}}->{for_uid};
    my $ref_study_uid = $ref_study->{study_uid};
    $ds->Insert("(3006,0010)[0](0020,0052)", $ref_for);
    $ds->Insert("(3006,0010)[0](3006,0012)[0](0008,1150)",
       "1.2.840.10008.3.1.2.3.1");
    $ds->Insert("(3006,0010)[0](3006,0012)[0](0008,1155)",
       $ref_study_uid);
    my $ref_series_id = $args->{ref_series};
    my $ref_series = $ref_study->{series}->{$ref_series_id};
    my $ref_series_uid = $ref_series->{series_uid};
    my $ref_series_type = $ref_series->{type};
    my $ref_series_sop_cl = $TypeToSop->{$ref_series_type};
    my $ref_series_config = $ref_series->{config};
    unless(exists $ParmParsers->{$ref_series_type}){
      die "Unknown series referenced series type $ref_series_type";
    }
    my $ref_series_args = &{$ParmParsers->{$ref_series_type}}(
      $ref_series->{args});
    my $num_slices = $ref_series_args->{num_slices};
    $ds->Insert(
      "(3006,0010)[0](3006,0012)[0](3006,0014)[0](0020,000e)",
      $ref_series_uid);
    my $si = 0;
    for my $i (1 .. $num_slices){
      my $ref_sop_inst_uid = "$ref_series_uid.$i";
      $ds->Insert(
       "(3006,0010)[0](3006,0012)[0](3006,0014)[0](3006,0016)[$si](0008,1150)",
       $ref_series_sop_cl);
      $ds->Insert(
       "(3006,0010)[0](3006,0012)[0](3006,0014)[0](3006,0016)[$si](0008,1155)",
       $ref_sop_inst_uid);
      $si += 1;
    }
    #
    #  And then the roi seq and roi_obs seq
    #
    my $i = 0;
    my $roi_hash = $this->{frames}->{$for_id}->{roi};
    for my $roi_num (sort {$a <=> $b} keys %$roi_hash){
      $ds->Insert("(3006,0020)[$i](3006,0022)", $roi_num);
      $ds->Insert("(3006,0020)[$i](3006,0026)",
         $roi_hash->{$roi_num}->{name});
      $ds->Insert("(3006,0020)[$i](3006,0036)",
         $roi_hash->{$roi_num}->{gen_alg});
      $ds->Insert("(3006,0020)[$i](3006,0024)",
         $ref_for);
      if(defined $roi_hash->{$roi_num}->{color}){
        $ds->Insert(
          "(3006,0039)[$i](3006,002a)", $roi_hash->{$roi_num}->{color});
      }
      $ds->Insert(
        "(3006,0039)[$i](3006,0084)", $roi_num);
      $i++;
    }
    $i = 0;
    my $roi_obs_hash = $this->{frames}->{$for_id}->{roi_obs};
    for my $obs_num (sort {$a <=> $b} keys %$roi_obs_hash){
      $ds->Insert(
        "(3006,0080)[$i](3006,0082)", $obs_num
      );
      $ds->Insert(
        "(3006,0080)[$i](3006,0084)", $roi_obs_hash->{$obs_num}->{roi_num}
      );
      $ds->Insert(
        "(3006,0080)[$i](3006,0085)",
#        $roi_obs_hash->{$obs_num}->{observation_label}
         $roi_hash->{$roi_obs_hash->{$obs_num}->{roi_num}}->{name}
      );
      $ds->Insert(
        "(3006,0080)[$i](3006,00a4)",
        $roi_obs_hash->{$obs_num}->{interpreted_type}
      );
      $ds->Insert(
        "(3006,0080)[$i](3006,00a6)", $roi_obs_hash->{$obs_num}->{interpreter}
      );
      $i++;
    }
    #
    #  And then the roi_contour seq
    #
    my($rows, $cols, $iop) = (
      $ref_series_config->{"(0028,0010)"},
      $ref_series_config->{"(0028,0011)"},
      $ref_series_config->{"(0020,0037)"},
    );
   my $center_of_volume = $ref_series_args->{center_of_volume};
    unless($center_of_volume =~ /^\[(.*),(.*),(.*)\]$/){
      die "bad center of volume string: $center_of_volume";
    }
   my $center_of_vol = [$1, $2, $3];
   my $slice_spacing = $ref_series_args->{slice_spacing};
   my $dxdc = $iop->[0];       # dx/dr
   my $dydc = $iop->[1];       # dy/dr
   my $dzdc = $iop->[2];       # dz/dr 
   my $dxdr = $iop->[3];       # dx/dc
   my $dydr = $iop->[4];       # dy/dc
   my $dzdr = $iop->[5];       # dz/dc
   my $pix_sp = $ref_series_config->{"(0028,0030)"};
   my ($p_x, $p_y) = @$pix_sp;       # pixel_spacing
   my $normal = VectorMath::cross(
     [$dxdc, $dydc, $dzdc], [$dxdr, $dydr, $dzdr]
   );
   my($dxdp, $dydp, $dzdp) = @$normal;
   my $length = $slice_spacing * ($num_slices - 1);
   my $width = $pix_sp->[0] * ($cols - 1);
   my $height = $pix_sp->[1] * ($rows - 1);
    my $init_ipp = [
      $center_of_vol->[0] - ($dxdc *  $width/2) 
                          - ($dxdr * $height/2)
                          - ($dxdp * $length/2),
      $center_of_vol->[1] - ($dydc *  $width/2)
                          - ($dydr * $height/2)
                          - ($dydp * $length/2),
      $center_of_vol->[2] - ($dzdc *  $width/2)
                          - ($dzdr * $height/2)
                          - ($dzdp * $length/2),
    ];

    my $roi_index = 0;
    for my $roi_num (
      sort { $a <=> $b }keys %{$this->{frames}->{$for_id}->{roi}}
    ){
      my $roi_start = time();
      my $roi = $this->{frames}->{$for_id}->{roi}->{$roi_num};
      my $obj_list = $this->{obj_list}->{$roi->{obj_list}};
      my $ppg = Posda::PixelPlaneGenerator->new($type, 
        $this->make_for_obj_list($for_id, $obj_list));
      $ppg->CCodeGen($rows, $cols, $iop, $pix_sp);
      my $current_instance_no = 0;
      for my $slice_no (1 .. $num_slices){
        $current_instance_no += 1;
        my $sop_instance = "$series_uid.$current_instance_no";
        my $current_ipp = [
          $init_ipp->[0] + ($dxdp * ($slice_no - 1) * $slice_spacing),
          $init_ipp->[1] + ($dydp * ($slice_no - 1) * $slice_spacing),
          $init_ipp->[2] + ($dzdp * ($slice_no - 1) * $slice_spacing),
        ];
        print "Generating contours for $current_instance_no " .
          "of $num_slices (roi $roi_num)\n";
        my $contour_start = time();
        my($pixel_data, $pixel_representation, $slope, $intercept) = 
          $ppg->gen_plane($rows, $cols, $iop, $current_ipp, $pix_sp);
        #  &{$PixelPlaneGenerator->{RTS}}(
        #    $this, $rows, $cols, $iop, $current_ipp, 
        #    $pix_sp, $for_id, $obj_list);
        # get contours from marching squares
        my $id = [
          $current_ipp,
          $iop,
          $pix_sp
        ];
        my $contours = Posda::Interpolator::MarchingSquares(
          $id, $rows, $cols, $pixel_data, 16, 250);
        my $contour_count = scalar @$contours;
        my $contour_elapsed = time() - $contour_start;
        print "rendered $contour_count contours in $contour_elapsed secs\n";
        if($contour_count > 0){
          #  This loop creates entries in contour sequence
          #  Inside ROI contour sequence
          #  ROI contour sequence index is $roi_index
          #  $contour_number increments for this sequence
          for my $i (1 .. $contour_count){
            my $cont = $contours->[$i - 1];
            my $num_count = scalar @$cont;
            print "contour[$i] has $num_count items\n";
            my @contour_data;
            for my $j (0 .. $#{$cont} - 1){
              my @point = split(/\\/, $cont->[$j]);
              unless($#point == 2){
                die "bad point $cont->[$j] ($j)";
              }
              for my $n (@point){
                push(@contour_data, $n);
              }
            }
            my $num_contour_points = $num_count - 1;
            my $geo_type = "CLOSED_PLANAR";
            my $foo = $ds->Get(
              "(3006,0039)[$roi_index](3006,0040)");
            my $ci = 0;
            if(defined $foo){
              unless(ref($foo) eq "ARRAY"){
                die "Contour seq not an array";
              }
              $ci = scalar(@$foo);
            }
            my $contour_number = $ci + 1;
            my $roi_entry = "(3006,0039)[$roi_index](3006,0040)[$ci]";
            $ds->Insert(
              "$roi_entry(3006,0048)",
              $contour_number);
            $ds->Insert(
              "$roi_entry(3006,0016)[0](0008,1150)",
              $ref_series_sop_cl);
            my $ref_sop_inst_uid = "$ref_series_uid.$current_instance_no";
            $ds->Insert(
              "$roi_entry(3006,0016)[0](0008,1155)",
              $ref_sop_inst_uid);
            $ds->Insert(
              "$roi_entry(3006,0042)",
              $geo_type);
            $ds->Insert(
              "$roi_entry(3006,0046)",
              $num_contour_points);
            $ds->Insert(
              "$roi_entry(3006,0050)",
              \@contour_data);

            # last line in loop (nexts not allowed here)
            #   Yikes!! - this is bad (refactor later, please)
            $contour_number += 1;
          }
        }
        # for each contour
        #  add roi num to roi_contour_seq
        #  create item in contour_seq for contour
      }
      my $elapsed_roi = time() - $roi_start;
      print "\tTook $elapsed_roi seconds preparing this ROI\n";
      $roi_index += 1;
    }

    #
    # Write the file
    #

    my $modality = $config->{"(0008,0060)"};
    my $file_name = "$dest_dir/${modality}_$sop_instance.dcm";
    $ds->WritePart10(
      $file_name, '1.2.840.10008.1.2.1', 'POSDA_PHNTM', undef, undef
    );
    my $elapsed = time() - $start_time;
    print "\tTook $elapsed seconds preparing this RTSTRUCT\n";
  };
  my $GeneratePlanSeries = sub {
    my($this, $study_id, $series_id) = @_;
    my $start_time = time();
    my $study = $this->{studies}->{$study_id};
    my $series = $study->{series}->{$series_id};
    my $obj_list_name = $series->{obj_list};
    my $config = $series->{config};
    my $for_id = $study->{for};
    my $dest_dir = $series->{series_dir};
    my $series_uid = $series->{series_uid};
    my $study_uid = $study->{study_uid};
    my $study_description = $study->{study_desc};
    my $type = $series->{type};
    my $args = &{$ParmParsers->{$type}}($series->{args});
    my $inst = 1;
    my $ds = Posda::Dataset->new_blank();
    for my $i (keys %$config){
      $ds->Insert($i, $config->{$i});
    }
    my $sop_instance = "$series_uid.$inst";
    $this->{plan_name_to_uid}->{$args->{plan_name}} = $sop_instance;
    for my $bn (keys %{$args->{beams}}){
      $this->{beams_to_plan}->{$bn} = {
        plan_uid => $sop_instance,
        beam_no => $args->{beams}->{$bn}->{beam_no},
        beam_name => $bn,
      };
    }
    my $num_beams = scalar keys %{$args->{beams}};
    $ds->Insert("(0008,1030)", $study_description);
    $ds->Insert("(0020,000d)", $study_uid);
    $ds->Insert("(0020,000e)", $series_uid);
    $ds->Insert("(0020,0011)", $series_id);
    $ds->Insert("(0020,0010)", $study_id);
    $ds->Insert("(0008,0018)", $sop_instance);
    $ds->Insert("(0020,0013)", 1);
    my $ref_ss_study = $args->{ss_study};
    my $ref_ss_series = $args->{ss_series};
    my $ss_series = 
      $this->{studies}->{$ref_ss_study}->{series}->{$ref_ss_series};
    my $ss_uid = "$ss_series->{series_uid}.1";
    $ds->Insert("(300c,0060)[0]>(0008,1150)", $TypeToSop->{RTS});
    $ds->Insert("(300c,0060)[0]>(0008,1155)", $ss_uid);
    ##
    #  Create Setup Info
    ##
    my %BeamSetup;
    my @beams = sort
      {
        $args->{beams}->{$a}->{beam_no} <=> $args->{beams}->{$b}->{beam_no}
      }
    keys %{$args->{beams}};
    my $NextSetup = 0;
    my $NextBeam = 0;
    my $NextFG = 0;
    $ds->Insert("(300a,0070)[0](300a,0071)", 1);
    $ds->Insert("(300a,0070)[0](300a,0078)", 1);
    $ds->Insert("(300a,0070)[0](300a,0080)", $num_beams);
    $ds->Insert("(300a,0070)[0](300a,00a0)", 0);
    for my $beam_i (0 .. $#beams){
      $ds->Insert("(300a,0070)[0](300c,0004)[$beam_i](300a,0084)", 123);
      $ds->Insert("(300a,0070)[0](300c,0004)[$beam_i](300a,0086)", 92);
      $ds->Insert("(300a,0070)[0](300c,0004)[$beam_i](300c,0006)", ($beam_i+1));
    }
    for my $beam_i (0 .. $#beams){
      my $beam_name = $beams[$beam_i];
      my $beam_no = $args->{beams}->{$beam_name}->{beam_no};
      my $beam = $this->{frames}->{$for_id}->{beam_doses}->{$beam_name};
      my $treatment_pos = $beam->{beam}->{treatment_pos};
      my $this_setup = $NextSetup;
      if(exists $BeamSetup{$treatment_pos}){
        $this_setup = $NextSetup;
        $BeamSetup{$treatment_pos} = $this_setup;
        $NextSetup++;
      }
      $ds->Insert("(300a,0180)[$this_setup](0018,5100)", $treatment_pos);
      $ds->Insert("(300a,0180)[$this_setup](300a,0182)", 1);
      $ds->Insert("(300a,0180)[$this_setup](300a,01b0)", "ISOCENTRIC");
      ########
      my $beam_info = {
        "(300a,00b0)[$beam_i](0008,1040)" => "Bogus dept name",
        "(300a,00b0)[$beam_i](300a,00b3)" => 'MU',
        "(300a,00b0)[$beam_i](300a,00b4)" => $beam->{beam}->{sad},
        "(300a,00b0)[$beam_i](300a,00b6)[0](300a,00b8)" => 'X',
        "(300a,00b0)[$beam_i](300a,00b6)[0](300a,00bc)" => 1,
        "(300a,00b0)[$beam_i](300a,00b6)[1](300a,00b8)" => 'Y',
        "(300a,00b0)[$beam_i](300a,00b6)[1](300a,00bc)" => 1,
        "(300a,00b0)[$beam_i](300a,00c0)" => $beam_no,
        "(300a,00b0)[$beam_i](300a,00c2)" => $beam_name,
        "(300a,00b0)[$beam_i](300a,00c3)" => "Static Beam from config",
        "(300a,00b0)[$beam_i](300a,00c4)" => "STATIC",
        "(300a,00b0)[$beam_i](300a,00c6)" => "Unknown",
        "(300a,00b0)[$beam_i](300a,00ce)" => 'TREATMENT',
        "(300a,00b0)[$beam_i](300a,00d0)" => 0,
        "(300a,00b0)[$beam_i](300a,00e0)" => 0,
        "(300a,00b0)[$beam_i](300a,00ed)" => 0,
        "(300a,00b0)[$beam_i](300a,00f0)" => 0,
        "(300a,00b0)[$beam_i](300a,010e)" => 1.0,
        "(300a,00b0)[$beam_i](300a,0110)" => 2,
        "(300a,00b0)[$beam_i](300a,0111)[0](300a,0112)" => 0,
        "(300a,00b0)[$beam_i](300a,0111)[0](300a,0114)" => 0,
        "(300a,00b0)[$beam_i](300a,0111)[0](300a,011a)[0](300a,00b8)" => 'X',
        "(300a,00b0)[$beam_i](300a,0111)[0](300a,011a)[0](300a,011c)" => 
          [$beam->{beam}->{min_x}, $beam->{beam}->{max_x}],
        "(300a,00b0)[$beam_i](300a,0111)[0](300a,011a)[1](300a,00b8)" => 'Y',
        "(300a,00b0)[$beam_i](300a,0111)[0](300a,011a)[1](300a,011c)" => 
          [$beam->{beam}->{min_z}, $beam->{beam}->{max_z}],
        "(300a,00b0)[$beam_i](300a,0111)[0](300a,011e)" => $beam->{beam}->{ga},
        "(300a,00b0)[$beam_i](300a,0111)[0](300a,011f)" => "CW",
        "(300a,00b0)[$beam_i](300a,0111)[0](300a,0122)" => 
          $beam->{beam}->{psda},
        "(300a,00b0)[$beam_i](300a,0111)[0](300a,0123)" => "CW",
        "(300a,00b0)[$beam_i](300a,0111)[0](300a,014a)" => 
          $beam->{beam}->{gpa},
        "(300a,00b0)[$beam_i](300a,0111)[0](300a,014c)" => "CW",
        "(300a,00b0)[$beam_i](300a,0111)[0](300a,0120)" => 
          $beam->{beam}->{blda},
        "(300a,00b0)[$beam_i](300a,0111)[0](300a,0121)" => "CW",
        "(300a,00b0)[$beam_i](300a,0111)[0](300a,012c)" =>
          $beam->{beam}->{iso},
        "(300a,00b0)[$beam_i](300a,0111)[0](300a,0134)" => 0.0,
        "(300a,00b0)[$beam_i](300a,0111)[1](300a,0112)" => 1,
        "(300a,00b0)[$beam_i](300a,0111)[1](300a,0134)" => 1.0,
      };
      for my $key(keys %$beam_info){
        $ds->Insert($key, $beam_info->{$key});
      }
      ########
    }
    my $modality = $config->{"(0008,0060)"};
    my $file_name = "$dest_dir/${modality}_$sop_instance.dcm";
    $ds->WritePart10(
      $file_name, '1.2.840.10008.1.2.1', 'POSDA_PHNTM', undef, undef
    );
    my $elapsed = time() - $start_time;
    print "\tTook $elapsed seconds preparing this plan\n";
  };
  my $GenerateDoseSeries = sub {
    my($this, $study_id, $series_id) = @_;
    my $study = $this->{studies}->{$study_id};
    my $series = $study->{series}->{$series_id};
    my $config = $series->{config};
    my $for_id = $study->{for};
    my $for_uid = $this->{frames}->{$for_id}->{for_uid};
    my $dest_dir = $series->{series_dir};
    my $series_uid = $series->{series_uid};
    my $study_uid = $study->{study_uid};
    my $study_description = $study->{study_desc};
    my $type = $series->{type};
    my $args = &{$ParmParsers->{$type}}($series->{args});
    my $center_of_volume = $args->{center_of_volume};
    unless($center_of_volume =~ /^\[(.*),(.*),(.*)\]$/){
      die "bad center of volume string: $center_of_volume";
    }
    my $center_of_vol = [$1, $2, $3];
    my $slice_spacing = $args->{slice_spacing};
    my $num_slices = $args->{num_slices};
    my $cur_instance_num = 0;
    my($rows, $cols, $iop) = (
      $config->{"(0028,0010)"},
      $config->{"(0028,0011)"},
      $config->{"(0020,0037)"},
    );
    my $sop_class = $config->{"(0008,0016)"};
    my $modality = $config->{"(0008,0060)"};
    my $dxdc = $iop->[0];       # dx/dr
    my $dydc = $iop->[1];       # dy/dr
    my $dzdc = $iop->[2];       # dz/dr 
    my $dxdr = $iop->[3];       # dx/dc
    my $dydr = $iop->[4];       # dy/dc
    my $dzdr = $iop->[5];       # dz/dc
    my $pix_sp = $config->{"(0028,0030)"};
    my ($p_x, $p_y) = @$pix_sp;       # pixel_spacing
    my $normal = VectorMath::cross(
      [$dxdc, $dydc, $dzdc], [$dxdr, $dydr, $dzdr]
    );
    my($dxdp, $dydp, $dzdp) = @$normal;
    my $length = $slice_spacing * ($num_slices - 1);
    my $width = $pix_sp->[0] * ($cols - 1);
    my $height = $pix_sp->[1] * ($rows - 1);
  
    my $init_ipp = [
      $center_of_vol->[0] - ($dxdc *  $width/2) 
                          - ($dxdr * $height/2)
                          - ($dxdp * $length/2),
      $center_of_vol->[1] - ($dydc *  $width/2)
                          - ($dydr * $height/2)
                          - ($dydp * $length/2),
      $center_of_vol->[2] - ($dzdc *  $width/2)
                          - ($dzdr * $height/2)
                          - ($dzdp * $length/2),
    ];
    my $current_instance = 0;
    for my $i (@{$args->{doses}}){
      my $start_time = time();
      unless($i =~ /^(.*)=(.*)$/){ die "can't make sense of dose arg: $i" }
      my $type = $1;
      my $att = $2;
      my($ref_plan_uid, $ref_beam_no);
      if($type eq "beam"){
        $ref_plan_uid = $this->{beams_to_plan}->{$att}->{plan_uid};
        $ref_beam_no = $this->{beams_to_plan}->{$att}->{beam_no};
      } elsif($type eq 'plan'){
        $ref_plan_uid = $this->{plan_name_to_uid}->{$att};
      }
      my $ds = Posda::Dataset->new_blank();
      $ds->Insert("(300c,0002)[0]>(0008,1150)", $TypeToSop->{RTP});
      $ds->Insert("(300c,0002)[0]>(0008,1155)", $ref_plan_uid);
      if(defined $ref_beam_no){
        $ds->Insert("(300c,0006)", $ref_beam_no);
      }
      for my $i (keys %$config){
        $ds->Insert($i, $config->{$i});
      }
      $current_instance += 1;
      my $sop_instance = "$series_uid.$current_instance";
      $ds->Insert("(0008,1030)", $study_description);
      $ds->Insert("(0020,0052)", $for_uid);
      $ds->Insert("(0020,000d)", $study_uid);
      $ds->Insert("(0020,000e)", $series_uid);
      $ds->Insert("(0020,0011)", $series_id);
      $ds->Insert("(0020,0010)", $study_id);
      $ds->Insert("(0008,0018)", $sop_instance);
      $ds->Insert("(0028,0008)", $num_slices);
      $ds->Insert("(0028,0009)", 0x0c3004);
      my @gfov;
      my $offset = 0;
      for my $i (1 .. $num_slices){
         push(@gfov, $offset);
         $offset += $slice_spacing;
      }
      $ds->Insert("(3004,000c)", \@gfov);
      my $dose_summation_type;
      my @bd_list;
      if($type eq "beam"){
        $dose_summation_type = "BEAM";
        unless(exists $this->{frames}->{$for_id}->{beam_doses}->{$att}){
          die "undefined beam_dose $att in plan series";
        }
        push @bd_list, $this->{frames}->{$for_id}->{beam_doses}->{$att};
      } elsif($type eq "plan"){
        $dose_summation_type = "PLAN";
        unless(exists $this->{frames}->{$for_id}->{plan_doses}->{$att}){
          die "undefined plan_dose $att in plan series";
        }
        for my $i (@{$this->{frames}->{$for_id}->{plan_doses}->{$att}}){
          unless(exists $this->{frames}->{$for_id}->{beam_doses}->{$i}){
            die "undefined beam_dose $i in plan dose $att in plan series";
          }
          push @bd_list, $this->{frames}->{$for_id}->{beam_doses}->{$i};
        }
      } else {
         die "unsupported dose type: $type";
      }
      $ds->Insert("(3004,000a)", $dose_summation_type);
      my $pixels = "";
      my $ppg = Posda::PixelPlaneGenerator->new("RTD", \@bd_list);
      $ppg->CCodeGen($rows, $cols, $iop, $pix_sp);
      for my $fi (0 .. $#gfov){
        my $p_dist = $gfov[$fi];
        my $x = $init_ipp->[0] + ($dxdp * $p_dist);
        my $y = $init_ipp->[1] + ($dydp * $p_dist);
        my $z = $init_ipp->[2] + ($dzdp * $p_dist);
        my($plane, $pixel_representation, $slope, $intercept) = 
          $ppg->gen_plane($rows, $cols, $iop, [$x, $y, $z], $pix_sp);
        unless(defined $plane){ die "plane didn't render" }
        $pixels .= $plane;
      } 
      $ds->Insert("(0020,0032)", $init_ipp);
      $ds->Insert("(7fe0,0010)", $pixels);
      my $modality = $config->{"(0008,0060)"};
      my $file_name = "$dest_dir/${modality}_$sop_instance.dcm";
      $ds->WritePart10(
        $file_name, '1.2.840.10008.1.2.1', 'POSDA_PHNTM', undef, undef
      );
      my $elapsed = time() - $start_time;
      print "\tTook $elapsed seconds preparing this dose\n";
    }
  };
  my $SeriesGenerators = {
    CT => $GenerateSeriesOfImages,
    PT => $GenerateSeriesOfImages,
    MR => $GenerateSeriesOfImages,
    REG => $GenerateRegSeries,
    RTS => $GenerateStructSeries,
    RTP => $GeneratePlanSeries,
    RTD => $GenerateDoseSeries,
  };
  sub GenerateStudies{
    my($this) = @_;
    study:
    for my $study_id (
      sort {$a <=> $b} keys %{$this->{studies}}
    ){
      series:
      for my $series_id (
        sort {$a <=> $b} keys %{$this->{studies}->{$study_id}->{series}}
      ){
        my $study = $this->{studies}->{$study_id};
        my $series = $study->{series}->{$series_id};
        my $type = $series->{type};
        unless(exists $SeriesGenerators->{$type}){
          die "no generator for series of type $type";
        }
        &{$SeriesGenerators->{$type}}($this, $study_id, $series_id);
      }
    }
  }
  sub make_for_obj_list{
    my($this, $for, $obj_list) = @_;
    my @obj_list;
    for my $obj_name(@$obj_list){
      unless(
        exists($this->{frames}->{$for}->{objs}->{$obj_name}) &&
        ref($this->{frames}->{$for}->{objs}->{$obj_name}) &&
        $this->{frames}->{$for}->{objs}->{$obj_name}->isa("Posda::Solids")
      ){
        die "no solid $obj_name in $for";
      }
      push(@obj_list, $this->{frames}->{$for}->{objs}->{$obj_name});
    }
    return \@obj_list;
  }
  sub make_bd_list{
  }
  my $CCodeGenSeriesOfImages = sub {
    my($this, $study_id, $series_id) = @_;
    my $study = $this->{studies}->{$study_id};
    my $series = $study->{series}->{$series_id};
    my $obj_list_name = $series->{obj_list};
    my $obj_list = $this->{obj_list}->{$obj_list_name};
    my $config = $series->{config};
    my $for_id = $study->{for};
    my $for_uid = $this->{frames}->{$for_id}->{for_uid};
    my $dest_dir = $series->{series_dir};
    my $series_uid = $series->{series_uid};
    my $study_uid = $study->{study_uid};
    my $study_description = $study->{study_desc};
    my $type = $series->{type};
    my $args = &{$ParmParsers->{$type}}($series->{args});
    my $center_of_volume = $args->{center_of_volume};
    my $ppg = Posda::PixelPlaneGenerator->new($type, 
      $this->make_for_obj_list($for_id, $obj_list));
    my($rows, $cols, $iop) = (
      $config->{"(0028,0010)"},
      $config->{"(0028,0011)"},
      $config->{"(0020,0037)"},
    );
    my $pix_sp = $config->{"(0028,0030)"};
    my $cc = $ppg->CCodeGen($rows, $cols, $iop, $pix_sp);
    print "##############################\nCC $type:\n";
    my $code = $cc->render();
    print "$code\n\n";
  };
  my $CCodeGenStruct = sub {
    my($this, $study_id, $series_id) = @_;
  };
  my $CCodeGenDose = sub {
    my($this, $study_id, $series_id) = @_;
  };
  my $SeriesCCodeGenerators = {
    CT => $CCodeGenSeriesOfImages,
    PT => $CCodeGenSeriesOfImages,
    MR => $CCodeGenSeriesOfImages,
    RTS => $CCodeGenStruct,
    RTD => $CCodeGenDose,
  };
  sub GenerateSeriesCCode{
    my($this) = @_;
    study:
    for my $study_id (sort keys %{$this->{studies}}){
      series:
      for my $series_id (sort keys %{$this->{studies}}){
        my $study = $this->{studies}->{$study_id};
        my $series = $study->{series}->{$series_id};
        my $type = $series->{type};
        print "Series of type: $type\n";
        print STDERR "Series of type: $type\n";
        flush STDERR;
        unless(exists $SeriesCCodeGenerators->{$type}){
          print STDERR "no generator for series of type $type\n";
          next series;
        }
        &{$SeriesCCodeGenerators->{$type}}($this, $study_id, $series_id);
      }
    }
  }
  sub ParseParms{
    my($this, $type, $parms) = @_;
    unless(exists $ParmParsers->{$type}){
      die "Unknown series type $type";
    }
    my $args = &{$ParmParsers->{$type}}($parms);
    return $args;
  }
}
1;

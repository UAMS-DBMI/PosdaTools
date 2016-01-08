#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/DensityGenerator.pm,v $
#$Date: 2008/12/10 17:08:55 $
#$Revision: 1.9 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
package Posda::DensityGenerator;
my $DensityGenerators = {
  RTS => sub {
    my($obj_list, $point) = @_;
    for my $obj (@$obj_list){
      if($obj->In($point)){
        return 500;
      }
    }
    return 0;
  },
  RTD => sub {
    my($bm_list, $point) = @_;
    my $value = 0;
    for my $bd (@$bm_list){
      if($bd->{beam}->In($point)){
        if($bd->{target}->In($point)){
          $value += $bd->{dose_inside_target};
        } else {
          $value += $bd->{dose_outside_target};
        }
      }
    }
    return $value;
  },
  CT => sub {
    my($obj_list, $point) = @_;
    for my $obj (@$obj_list){
      unless(exists $obj->{properties}->{ct_density}){
        next;
      }
      if($obj->In($point)){
        return $obj->{properties}->{ct_density};
      }
    }
    return -1000;
  },
  MR => sub {
    my($obj_list, $point) = @_;
    for my $obj (@$obj_list){
      unless(exists $obj->{properties}->{mr_density}){
        return 0;
      }
      if($obj->In($point)){
        return $obj->{properties}->{mr_density};
      }
    }
    return 0;
  },
  PT => sub {
    my($obj_list, $point) = @_;
    my $counts = 0;
    obj_name:
    for my $obj (@$obj_list){
      unless(exists $obj->{properties}->{pet_count_center}){
        next obj_name;
      }
      if($obj->In($point)){
        if(
          $obj->{properties}->{pet_count_inner_attenuation_type} eq "square"
        ){
          my $dist = $obj->Dist($point);
          my $atten = $obj->{properties}->{pet_count_inner_attenuation} *
            ($dist ** 2);
          my $count_inc = $obj->{properties}->{pet_count_center};
          if($count_inc > $atten){
            $counts += $count_inc - $atten;
          }
        }elsif(
          $obj->{properties}->{pet_count_inner_attenuation_type} eq "linear"
        ){
          my $dist = $obj->Dist($point);
          my $atten = $obj->{properties}->{pet_count_inner_attenuation} * $dist;
          my $count_inc = $obj->{properties}->{pet_count_center};
          if($count_inc > $atten){
            $counts += $count_inc - $atten;
          }
        }
      } else {
        if(
          $obj->{properties}->{pet_count_outer_attenuation_type} eq "square"
        ){
          my $dist = $obj->Dist($point);
          my $atten = $obj->{properties}->{pet_count_outer_attenuation} * 
            ($dist ** 2 );
          my $count_inc = $obj->{properties}->{pet_count_outside};
          if($count_inc > $atten){
            $counts += $count_inc - $atten;
          }
        }elsif(
          $obj->{properties}->{pet_count_outer_attenuation_type} eq "linear"
        ){
          my $dist = $obj->Dist($point);
          my $atten = $obj->{properties}->{pet_count_outer_attenuation} * $dist;
          my $count_inc = $obj->{properties}->{pet_count_outside};
          if($count_inc > $atten){
            $counts += $count_inc - $atten;
          }
        }
      }
    }
    return $counts;
  },
};
my $CC_DensityGenerators = {
  RTS => sub {
    my($obj_list, $ccg) = @_;
    if($#{$obj_list} < 0){
      die "no objects in obj_list";
    }
    for my $i (0 .. $#{$obj_list}){
      my $obj = $obj_list->[$i];
      if($i == 0){
        $ccg->add_body("if(\n");
      }
      $ccg->add_indent("  ");
      $ccg->add_body("/* Generate In Code */\n");
      $obj->In_CCode($ccg);
      $ccg->sub_indent("  ");
      $ccg->add_body("){\n");
      $ccg->add_indent("  ");
      $ccg->add_body("density = 500;\n");
      $ccg->sub_indent("  ");
      if($i != $#{$obj_list}){
        $ccg->add_body("} else if(\n");
      } else {
        $ccg->add_body("} else {\n");
      }
    }
    $ccg->add_indent("  ");
    $ccg->add_body("density = 0;\n");
    $ccg->sub_indent("  ");
    $ccg->add_body("}\n");
  },
  RTD => sub {
    my($bm_list, $ccg) = @_;
    my $value = 0;
    $ccg->add_body("density = 0;\n");
    for my $bd (@$bm_list){
      $ccg->add_body("if(\n");
      $ccg->add_indent("  ");
      $bd->{beam}->In_CCode($ccg);
      $ccg->sub_indent("  ");
      $ccg->add_body("){\n");
      $ccg->add_indent("  ");
      $ccg->add_body("if(\n");
      $bd->{target}->In_CCode($ccg);
      $ccg->add_body("){\n");
      $ccg->add_indent("  ");
      $ccg->add_body("density += $bd->{dose_inside_target};\n");
      $ccg->sub_indent("  ");
      $ccg->add_body("} else {\n");
      $ccg->add_indent("  ");
      $ccg->add_body("density += $bd->{dose_outside_target};\n");
      $ccg->sub_indent("  ");
      $ccg->add_body("}\n");
      $ccg->sub_indent("  ");
      $ccg->add_body("}\n");
    }
    return $value;
  },
  CT => sub {
    my($obj_list,  $ccg) = @_;
    if($#{$obj_list} < 0){
      die "no objects in obj_list";
    }
    for my $i (0 .. $#{$obj_list}){
      my $obj = $obj_list->[$i];
      if($i == 0){
        $ccg->add_body("if(\n");
      }
      $ccg->add_indent("  ");
      $ccg->add_body("/* Generate In Code */\n");
      $obj->In_CCode($ccg);
      $ccg->sub_indent("  ");
      $ccg->add_body("){\n");
      $ccg->add_indent("  ");
      $ccg->add_body("/* Generate value code */\n");
      unless(exists $obj->{properties}->{ct_density}){
        die "no CT density for obj";
      }
      my $value = $obj->{properties}->{ct_density};
      $ccg->add_body("density = $value;\n");
      $ccg->sub_indent("  ");
      if($i != $#{$obj_list}){
        $ccg->add_body("} else if(\n");
      } else {
        $ccg->add_body("} else {\n");
      }
    }
    $ccg->add_indent("  ");
    $ccg->add_body("/* Generate value code */\n");
    $ccg->add_body("density = -1000;\n");
    $ccg->sub_indent("  ");
    $ccg->add_body("}\n");
  },
  MR => sub {
    my($obj_list, $ccg) = @_;
    if($#{$obj_list} < 0){
      die "no objects in obj_list";
    }
    for my $i (0 .. $#{$obj_list}){
      my $obj = $obj_list->[$i];
      if($i == 0){
        $ccg->add_body("if(\n");
      }
      $ccg->add_indent("  ");
      $ccg->add_body("/* Generate In Code */\n");
      $obj->In_CCode($ccg);
      $ccg->sub_indent("  ");
      $ccg->add_body("){\n");
      $ccg->add_indent("  ");
      $ccg->add_body("/* Generate value code */\n");
      $ccg->add_body("density = ($obj->{properties}->{mr_density});\n");
      $ccg->sub_indent("  ");
      if($i != $#{$obj_list}){
        $ccg->add_body("} else if(\n");
      } else {
        $ccg->add_body("} else {\n");
      }
    }
    $ccg->add_indent("  ");
    $ccg->add_body("/* Generate value code */\n");
    $ccg->add_body("density = 0;\n");
    $ccg->sub_indent("  ");
    $ccg->add_body("}\n");
  },
  PT => sub {
    my($obj_list, $ccg) = @_;
    if($#{$obj_list} < 0){
      die "no objects in obj_list";
    }
    my $counts = $ccg->gimme_f();
    $ccg->add_body("$counts = 0;\n");
    obj_name:
    for my $i (0 .. $#{$obj_list}){
      my $obj = $obj_list->[$i];
      unless(exists $obj->{properties}->{pet_count_center}){
        next obj_name;
      }
      $ccg->add_body("if(\n");
      $ccg->add_indent("  ");
      $ccg->add_body("/* Generate In Code */\n");
      $obj->In_CCode($ccg);
      $ccg->sub_indent("  ");
      $ccg->add_body("){\n");
      $ccg->add_indent("  ");
      if(
        $obj->{properties}->{pet_count_inner_attenuation_type} eq "square"
      ){
        $ccg->add_body("/* inner - square */\n");
        my $count_inc = $obj->{properties}->{pet_count_center};
        my $dist = $ccg->gimme_f();
        $obj->CC_Dist($dist, $ccg);
        $ccg->add_body("if(\n");
        $ccg->add_indent("  ");
        my $pcia = $obj->{properties}->{pet_count_inner_attenuation};
        unless(defined $pcia) {
          print STDERR "no pet_count_inner_attenuation\n";
          $pcia = "0";
        };
        $ccg->add_body("$count_inc > (($pcia) * $dist * $dist)\n");
        $ccg->sub_indent("  ");
        $ccg->add_body("){\n");
        $ccg->add_indent("  ");
        $ccg->add_body("$counts += $count_inc - (($pcia) * $dist * $dist);\n");
        $ccg->sub_indent("  ");
        $ccg->add_body("}\n");
      }elsif(
          $obj->{properties}->{pet_count_inner_attenuation_type} eq "linear"
      ){
        $ccg->add_body("/* inner - linear */\n");
        my $count_inc = $obj->{properties}->{pet_count_center};
        my $dist = $ccg->gimme_f();
        $obj->CC_Dist($dist, $ccg);
        $ccg->add_body("if(\n");
        $ccg->add_indent("  ");
        my $pcia = $obj->{properties}->{pet_count_inner_attenuation};
        unless(defined $pcia) {
          print STDERR "no pet_count_inner_attenuation\n";
          $pcia = "0";
        };
        $ccg->add_body("$count_inc > (($pcia) * $dist)\n");
        $ccg->sub_indent("  ");
        $ccg->add_body("){\n");
        $ccg->add_indent("  ");
        $ccg->add_body("$counts += $count_inc - (($pcia) * $dist);\n");
        $ccg->sub_indent("  ");
        $ccg->add_body("}\n");
      }
      $ccg->sub_indent("  ");
      $ccg->add_body("} else {\n");
      $ccg->add_indent("  ");
      if(
        $obj->{properties}->{pet_count_outer_attenuation_type} eq "square"
      ){
        $ccg->add_body("/* outer - square */\n");
        my $dist = $ccg->gimme_f();
        my $count_inc = $obj->{properties}->{pet_count_outside};
        $obj->CC_Dist($dist, $ccg);
        $ccg->add_body("if(\n");
        $ccg->add_indent("  ");
        my $pcoa = $obj->{properties}->{pet_count_outer_attenutation};
        unless(defined $pcoa) {
          print STDERR "no pet_count_outer_attenuation\n";
          $pcoa = "0";
        };
        $ccg->add_body("$count_inc > (($pcoa) * $dist * $dist)\n");
        $ccg->sub_indent("  ");
        $ccg->add_body("){\n");
        $ccg->add_indent("  ");
        $ccg->add_body("$counts += $count_inc - (($pcoa) * $dist * $dist);\n");
        $ccg->sub_indent("  ");
        $ccg->add_body("}\n");
      }elsif(
        $obj->{properties}->{pet_count_outer_attenuation_type} eq "linear"
      ){
        $ccg->add_body("/* outer - linear */\n");
        my $count_inc = $obj->{properties}->{pet_count_outside};
        my $dist = $ccg->gimme_f();
        $obj->CC_Dist($dist, $ccg);
        $ccg->add_body("if(\n");
        $ccg->add_indent("  ");
        my $pcoa = $obj->{properties}->{pet_count_outer_attenuation};
        unless(defined $pcoa) {
          print STDERR "no pet_count_outer_attenuation\n";
          $pcoa = "0";
        };
        $ccg->add_body("$count_inc > (($pcoa) * $dist)\n");
        $ccg->sub_indent("  ");
        $ccg->add_body("){\n");
        $ccg->add_indent("  ");
        $ccg->add_body("$counts += $count_inc - (($pcoa) * $dist);\n");
        $ccg->sub_indent("  ");
        $ccg->add_body("}\n");
      }
      $ccg->sub_indent("  ");
      $ccg->add_body("}\n");
    }
    $ccg->add_body("density = $counts;\n");
  },
};
sub new {
  my($class, $type) = @_;
  unless(exists $DensityGenerators->{$type}){
    die "unknown density type: $type";
  }
  unless(exists $CC_DensityGenerators->{$type}){
    print STDERR "no Code Generatory for $type\n";
  }
  my $this = {
    type => $type,
    generator => $DensityGenerators->{$type},
    cc_generator => $CC_DensityGenerators->{$type},
  };
  return bless $this, $class;
}
sub Density{
  my($this, $obj_list, $point) = @_;
  return &{$this->{generator}}($obj_list, $point);
}
sub CodeGen{
  my($this, $obj_list, $ccg) = @_;
  return &{$this->{cc_generator}}($obj_list, $ccg);
}
1;

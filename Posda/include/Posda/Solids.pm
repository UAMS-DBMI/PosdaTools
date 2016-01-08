#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/Solids.pm,v $
#$Date: 2009/04/27 14:22:34 $
#$Revision: 1.29 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

package Posda::Solids;
use VectorMath;
sub new {
  die "Posda::Solids is virtual class only";
}
sub In {
  die "Posda::Solids is virtual class only";
}
sub Dist {
  die "Posda::Solids is virtual class only";
}
sub XformCopy {
  die "Posda::Solids is virtual class only";
}
sub DumpGuts {
  die "Posda::Solids is virtual class only";
}
{
  package Posda::Solids::Sphere;
  use vars qw( @ISA );
  @ISA = ("Posda::Solids");
  sub new {
    my($class, $point, $radius) = @_;
    my $obj = {
      type => "sphere",
      center => $point,
      radius => $radius,
      properties => {
      },
    };
    return bless $obj, $class;
  }
  sub In {
    my($this, $point) = @_;
    my $dist = VectorMath::Dist($point, $this->{center});
    if($dist < $this->{radius}){
      return 1;
    }
    return 0;
  }
  sub In_CCode{
    my($this, $ccg) = @_;
    $ccg->add_body("(\n");
    $ccg->add_indent("  ");
    my $dist = VectorMath::CC_Dist("x", "y", "z", 
      $this->{center}->[0], $this->{center}->[1], $this->{center}->[2]);
    $ccg->add_body("$dist\n");
    $ccg->sub_indent("  ");
    $ccg->add_body("<\n");
    $ccg->add_indent("  ");
    $ccg->add_body("$this->{radius}\n");
    $ccg->sub_indent("  ");
    $ccg->add_body(")\n");
  }
  sub Dist{
    my($this, $point) = @_;
    return VectorMath::Dist($point, $this->{center});
  };
  sub CC_Dist{
    my($this, $dist, $ccg) = @_;
    my $dist_code = VectorMath::CC_Dist("x", "y", "z", 
      $this->{center}->[0], $this->{center}->[1], $this->{center}->[2]);
    $ccg->add_body("$dist = $dist_code;\n");
  };
  sub XformCopy {
    my($this, $xform) = @_;
    my $class = ref($this);
    my $new = {
      center => Posda::Transforms::ApplyTransform($xform, $this->{center}),
      radius => $this->{radius},
      properties => {
      },
    };
    for my $name (keys %{$this->{properties}}){
      $new->{properties}->{$name} = $this->{properties}->{$name};
    }
    return bless $new, $class;
  }
  sub DumpGuts{
    my($this, $indent) = @_;
    unless(defined $indent){ $indent = "" }
    print "sphere:\n" .
      "${indent}\tcenter = ($this->{center}->[0], $this->{center}->[1], " .
      "$this->{center}->[2])\n" .
      "${indent}\tradius - $this->{radius}\n";
    for my $name (sort keys %{$this->{properties}}){
      print "${indent}\t$name - $this->{properties}->{$name}\n";
    }
  }
}
{
  package Posda::Solids::Ellipsoid;
  use vars qw( @ISA );
  @ISA = ("Posda::Solids");
  sub new {
    my($class, $point1, $point2, $radius) = @_;
    my $center = [
      ($point1->[0] + $point2->[0]) / 2,
      ($point1->[1] + $point2->[1]) / 2,
      ($point1->[2] + $point2->[2]) / 2,
    ];
    my $obj = {
      type => "ellipsoid",
      point1 => $point1,
      point2 => $point2,
      center => $center,
      radius => $radius,
      properties => {
      },
    };
    return bless $obj, $class
  }
  sub In {
    my($this, $point) = @_;
    if(
      (VectorMath::Dist($point, $this->{point1})  +
      VectorMath::Dist($point, $this->{point2})) < $this->{radius}
    ){
      return 1;
    }
    return 0;
  }
  sub In_CCode{
    my($this, $ccg) = @_;
    my $dist1 = VectorMath::CC_Dist("x", "y", "z", 
      $this->{point1}->[0], $this->{point1}->[1], $this->{point1}->[2]);
    my $dist2 = VectorMath::CC_Dist("x", "y", "z", 
      $this->{point2}->[0], $this->{point2}->[1], $this->{point2}->[2]);
    $ccg->add_body("((($dist1) + ($dist2)) < ($this->{radius}))\n");
  }
  sub Dist{
    my($this, $point) = @_;
    return VectorMath::Dist($point, $this->{center});
  };
  sub CC_Dist{
    my($this, $dist, $ccg) = @_;
    my $dist_code = VectorMath::CC_Dist("x", "y", "z", 
      $this->{center}->[0], $this->{center}->[1], $this->{center}->[2]);
    $ccg->add_body("$dist = $dist_code;\n");
  };
  sub XformCopy {
    my($this, $xform) = @_;
    my $class = ref($this);
    my $new = {
      point1 => Posda::Transforms::ApplyTransform($xform, $this->{point1}),
      point2 => Posda::Transforms::ApplyTransform($xform, $this->{point2}),
      center => Posda::Transforms::ApplyTransform($xform, $this->{center}),
      radius => $this->{radius},
      properties => {
      },
    };
    for my $name (keys %{$this->{properties}}){
      $new->{properties}->{$name} = $this->{properties}->{$name};
    }
    return bless $new, $class;
  }
  sub DumpGuts{
    my($this, $indent) = @_;
    unless(defined $indent){ $indent = "" }
    print "ellipsoid:\n" .
      "${indent}\tpoint1 = ($this->{point1}->[0], $this->{point1}->[1], " .
      "$this->{point1}->[2])\n" .
      "${indent}\tpoint2 = ($this->{point2}->[0], $this->{point2}->[1], " .
      "$this->{point2}->[2])\n" .
      "${indent}\tradius - $this->{radius}\n";
    for my $name (sort keys %{$this->{properties}}){
      print "${indent}\t$name - $this->{properties}->{$name}\n";
    }
  }
}
{
  package Posda::Solids::Cylinder;
  use vars qw( @ISA );
  @ISA = ("Posda::Solids");
  sub new {
    my($class, $point1, $point2, $radius) = @_;
    my $center = [
      ($point1->[0] + $point2->[0]) / 2,
      ($point1->[1] + $point2->[1]) / 2,
      ($point1->[2] + $point2->[2]) / 2,
    ];
    my $obj = {
      type => "cylinder",
      point1 => $point1,
      point2 => $point2,
      center => $center,
      radius => $radius,
      properties => {
      },
    };
    return bless $obj, $class
  }
  sub In {
    my($this, $point) = @_;
    my $pp = VectorMath::ProjPointToLine($point, 
      $this->{point1}, $this->{point2});
    if(VectorMath::Between($pp, $this->{point1}, $this->{point2})){
      if(
         VectorMath::DistPointToLine(
           $point, $this->{point1}, $this->{point2}
         ) < $this->{radius}
      ){
         return 1;
      }
    }
    return 0;
  }
  sub In_CCode{
    my($this, $ccg) = @_;
    my $pp_x = VectorMath::CC_ProjPointToLineX(
      "x", "y", "z", 
      $this->{point1}->[0], $this->{point1}->[1], $this->{point1}->[2],
      $this->{point2}->[0], $this->{point2}->[1], $this->{point2}->[2]
    );
    my $pp_y = VectorMath::CC_ProjPointToLineY(
      "x", "y", "z", 
      $this->{point1}->[0], $this->{point1}->[1], $this->{point1}->[2],
      $this->{point2}->[0], $this->{point2}->[1], $this->{point2}->[2]
    );
    my $pp_z = VectorMath::CC_ProjPointToLineZ(
      "x", "y", "z", 
      $this->{point1}->[0], $this->{point1}->[1], $this->{point1}->[2],
      $this->{point2}->[0], $this->{point2}->[1], $this->{point2}->[2]
    );
    my $between = VectorMath::CC_Between(
      $pp_x, $pp_y, $pp_z,
      $this->{point1}->[0], $this->{point1}->[1], $this->{point1}->[2],
      $this->{point2}->[0], $this->{point2}->[1], $this->{point2}->[2],
    );
    my $dist = VectorMath::CC_DistPointToLine(
      "x", "y", "z",
      $this->{point1}->[0], $this->{point1}->[1], $this->{point1}->[2],
      $this->{point2}->[0], $this->{point2}->[1], $this->{point2}->[2]
    );
    $ccg->add_body("(\n");
    $ccg->add_indent("  ");
    $ccg->add_body("$between\n");
    $ccg->sub_indent("  ");
    $ccg->add_body("&&\n");
    $ccg->add_indent("  ");
    $ccg->add_body("(\n");
    $ccg->add_indent("  ");
    $ccg->add_body("($dist)\n");
    $ccg->sub_indent("  ");
    $ccg->add_body("<\n");
    $ccg->add_indent("  ");
    $ccg->add_body("($this->{radius})\n");
    $ccg->sub_indent("  ");
    $ccg->add_body(")\n");
    $ccg->sub_indent("  ");
    $ccg->add_body(")\n");
  }
  sub Dist{
    my($this, $point) = @_;
    return VectorMath::Dist($point, $this->{center});
  };
  sub CC_Dist{
    my($this, $dist, $ccg) = @_;
    my $dist_code = VectorMath::CC_Dist("x", "y", "z", 
      $this->{center}->[0], $this->{center}->[1], $this->{center}->[2]);
    $ccg->add_body("$dist = $dist_code;\n");
  };
  sub XformCopy {
    my($this, $xform) = @_;
    my $class = ref($this);
    my $new = {
      point1 => Posda::Transforms::ApplyTransform($xform, $this->{point1}),
      point2 => Posda::Transforms::ApplyTransform($xform, $this->{point2}),
      center => Posda::Transforms::ApplyTransform($xform, $this->{center}),
      radius => $this->{radius},
      properties => {
      },
    };
    for my $name (keys %{$this->{properties}}){
      $new->{properties}->{$name} = $this->{properties}->{$name};
    }
    return bless $new, $class;
  }
  sub DumpGuts{
    my($this, $indent) = @_;
    unless(defined $indent){ $indent = "" }
    print "cylinder:\n" .
      "${indent}\tpoint1 = ($this->{point1}->[0], $this->{point1}->[1], " .
      "$this->{point1}->[2])\n" .
      "${indent}\tpoint2 = ($this->{point2}->[0], $this->{point2}->[1], " .
      "$this->{point2}->[2])\n" .
      "${indent}\tradius - $this->{radius}\n";
    for my $name (sort keys %{$this->{properties}}){
      print "${indent}\t$name - $this->{properties}->{$name}\n";
    }
  }
}
{
  package Posda::Solids::Rectangular;
  use vars qw( @ISA );
  @ISA = ("Posda::Solids");
  sub new{
    my($class, $center, $height, $width, $length, $x_rot, $y_rot, $z_rot) = @_;
    # height = y; length = z; width = x;
    my $tfrhc = [$center->[0] + $width / 2, 
                 $center->[1] + $height / 2, 
                 $center->[2] + $length / 2 
                ];
    my $bblhc = [$center->[0] - $width  / 2, 
                 $center->[1] - $height  / 2, 
                 $center->[2] - $length  / 2 
                ];
    my $obj = {
      type => "rectangular solid",
      tfrhc => $tfrhc,
      bblhc => $bblhc,
      center => $center,
      properties => {
      },
    };
    if(defined($x_rot) || defined($y_rot) || defined($z_rot)){
      unless(defined $x_rot){
        $x_rot = 0;
      }
      unless(defined $y_rot){
        $y_rot = 0;
      }
      unless(defined $z_rot){
        $z_rot = 0;
      }
      my @commands;
      my $to_center = [-$center->[0],-$center->[1],-$center->[2]];
      push(@commands, ["shift", 
       "($to_center->[0],$to_center->[1],$to_center->[2])"]);
      push(@commands, ["rx", $x_rot]);
      push(@commands, ["ry", $y_rot]);
      push(@commands, ["rz", $z_rot]);
      push(@commands, ["shift", "($center->[0],$center->[1],$center->[2])"]);
      
      ($obj->{xform}, $obj->{f_xform}) =
        Posda::Transforms::MakeTransformPair(\@commands);
    }
    return bless $obj, $class;
  }
  sub In {
    my($this, $point) = @_;
    my $new_point = $point;
    if(exists $this->{xform}){
      $new_point = Posda::Transforms::ApplyTransform($this->{xform}, $point),
    }
    if(
      $new_point->[0] < $this->{tfrhc}->[0] &&
      $new_point->[0] > $this->{bblhc}->[0] &&
      $new_point->[1] < $this->{tfrhc}->[1] &&
      $new_point->[1] > $this->{bblhc}->[1] &&
      $new_point->[2] < $this->{tfrhc}->[2] &&
      $new_point->[2] > $this->{bblhc}->[2]
    ){
      return 1;
    }
    return 0;
  }
  sub In_CCode{
    my($this, $ccg) = @_;
    my $pp_x= "x";
    my $pp_y= "y";
    my $pp_z= "z";
    if(exists $this->{xform}){
      $pp_x = VectorMath::CC_ApplyTransformX($this->{xform});
      $pp_y = VectorMath::CC_ApplyTransformY($this->{xform});
      $pp_z = VectorMath::CC_ApplyTransformZ($this->{xform});
    }
    $ccg->add_body("(\n");
    $ccg->add_indent("  ");
    $ccg->add_body("(($pp_x) < ($this->{tfrhc}->[0]))\n");
    $ccg->sub_indent("  ");
    $ccg->add_body("&&\n");
    $ccg->add_indent("  ");
    $ccg->add_body("(($pp_x) > ($this->{bblhc}->[0]))\n");
    $ccg->sub_indent("  ");
    $ccg->add_body("&&\n");
    $ccg->add_indent("  ");
    $ccg->add_body("(($pp_y) < ($this->{tfrhc}->[1]))\n");
    $ccg->sub_indent("  ");
    $ccg->add_body("&&\n");
    $ccg->add_indent("  ");
    $ccg->add_body("(($pp_y) > ($this->{bblhc}->[1]))\n");
    $ccg->sub_indent("  ");
    $ccg->add_body("&&\n");
    $ccg->add_indent("  ");
    $ccg->add_body("(($pp_z) < ($this->{tfrhc}->[2]))\n");
    $ccg->sub_indent("  ");
    $ccg->add_body("&&\n");
    $ccg->add_indent("  ");
    $ccg->add_body("(($pp_z) > ($this->{bblhc}->[2]))\n");
    $ccg->sub_indent("  ");
    $ccg->add_body(")\n");
  }
  sub Dist{
    my($this, $point) = @_;
    return VectorMath::Dist($point, $this->{center});
  };
  sub CC_Dist{
    my($this, $dist, $ccg) = @_;
    my $dist_code = VectorMath::CC_Dist("x", "y", "z", 
      $this->{center}->[0], $this->{center}->[1], $this->{center}->[2]);
    $ccg->add_body("$dist = $dist_code;\n");
  };
  sub XformCopy {
    my($this, $xform) = @_;
    die "currently broken";
    my $class = ref($this);
    my $new = {
      tfrhc => Posda::Transforms::ApplyTransform($xform, $this->{tfrhc}),
      bblhc => Posda::Transforms::ApplyTransform($xform, $this->{bblhc}),
      center => Posda::Transforms::ApplyTransform($xform, $this->{center}),
      properties => {
      },
    };
    for my $name (keys %{$this->{properties}}){
      $new->{properties}->{$name} = $this->{properties}->{$name};
    }
    return bless $new, $class;
  }
  sub DumpGuts{
    my($this, $indent) = @_;
    unless(defined $indent){ $indent = "" }
    print "rectangular solid:\n" .
      "${indent}\ttfrhc = ($this->{tfrhc}->[0], $this->{tfrhc}->[1], " .
      "$this->{tfrhc}->[2])\n" .
      "${indent}\tbblhc = ($this->{bblhc}->[0], $this->{bblhc}->[1], " .
      "$this->{bblhc}->[2])\n";
    for my $name (sort keys %{$this->{properties}}){
      print "${indent}\t$name - $this->{properties}->{$name}\n";
    }
  }
}
{
  package Posda::Solids::Cone;
  use vars qw( @ISA );
  @ISA = ("Posda::Solids");
  sub new{
    my($class, $point1, $point2,  $slope) = @_;
    my $center = [
      ($point1->[0] + $point2->[0]) / 2,
      ($point1->[1] + $point2->[1]) / 2,
      ($point1->[2] + $point2->[2]) / 2,
    ];
    my $obj = {
      type => "cone",
      point1 => $point1,
      point2 => $point2,
      center => $center,
      slope => $slope,
      properties => {
      },
    };
    return bless $obj, $class;
  }
  sub In {
    my($this, $point) = @_;
    my $pp = VectorMath::ProjPointToLine($point, 
      $this->{point1}, $this->{point2});
    if(VectorMath::Between($pp, $this->{point1}, $this->{point2})){
      my $radius =  $this->{slope} *
        abs(VectorMath::Dist($this->{point1}, $pp));
      if(
         VectorMath::DistPointToLine(
           $point, $this->{point1}, $this->{point2}
         ) < $radius
      ){
         return 1;
      }
    }
    return 0;
  }
  sub In_CCode{
    my($this, $ccg) = @_;
    my $radius = "(($this->{slope}) * fabs(";
    my $pp_x = VectorMath::CC_ProjPointToLineX(
      "x", "y", "z", 
      $this->{point1}->[0], $this->{point1}->[1], $this->{point1}->[2],
      $this->{point2}->[0], $this->{point2}->[1], $this->{point2}->[2]
    );
    my $pp_y = VectorMath::CC_ProjPointToLineY(
      "x", "y", "z", 
      $this->{point1}->[0], $this->{point1}->[1], $this->{point1}->[2],
      $this->{point2}->[0], $this->{point2}->[1], $this->{point2}->[2]
    );
    my $pp_z = VectorMath::CC_ProjPointToLineZ(
      "x", "y", "z", 
      $this->{point1}->[0], $this->{point1}->[1], $this->{point1}->[2],
      $this->{point2}->[0], $this->{point2}->[1], $this->{point2}->[2]
    );
    $radius .= VectorMath::CC_Dist(
      $pp_x, $pp_y, $pp_z,
      $this->{point1}->[0], $this->{point1}->[1], $this->{point1}->[2]
    );
    $radius .= "))";
    my $between = VectorMath::CC_Between(
      $pp_x, $pp_y, $pp_z,
      $this->{point1}->[0], $this->{point1}->[1], $this->{point1}->[2],
      $this->{point2}->[0], $this->{point2}->[1], $this->{point2}->[2],
    );
    my $dist = VectorMath::CC_DistPointToLine(
      "x", "y", "z",
      $this->{point1}->[0], $this->{point1}->[1], $this->{point1}->[2],
      $this->{point2}->[0], $this->{point2}->[1], $this->{point2}->[2]
    );
    $ccg->add_body("(\n");
    $ccg->add_indent("  ");
    $ccg->add_body("$between\n");
    $ccg->sub_indent("  ");
    $ccg->add_body("&&\n");
    $ccg->add_indent("  ");
    $ccg->add_body("(\n");
    $ccg->add_indent("  ");
    $ccg->add_body("($dist)\n");
    $ccg->sub_indent("  ");
    $ccg->add_body("<\n");
    $ccg->add_indent("  ");
    $ccg->add_body("$radius\n");
    $ccg->sub_indent("  ");
    $ccg->add_body(")\n");
    $ccg->sub_indent("  ");
    $ccg->add_body(")\n");
  }
  sub Dist{
    my($this, $point) = @_;
    return VectorMath::Dist($point, $this->{center});
  };
  sub CC_Dist{
    my($this, $dist, $ccg) = @_;
    my $dist_code = VectorMath::CC_Dist("x", "y", "z", 
      $this->{center}->[0], $this->{center}->[1], $this->{center}->[2]);
    $ccg->add_body("$dist = $dist_code;\n");
  };
  sub XformCopy {
    my($this, $xform) = @_;
    my $class = ref($this);
    my $new = {
      point1 => Posda::Transforms::ApplyTransform($xform, $this->{point1}),
      point2 => Posda::Transforms::ApplyTransform($xform, $this->{point2}),
      center => Posda::Transforms::ApplyTransform($xform, $this->{center}),
      radius => $this->{radius},
      slope => $this->{slope},
      properties => {
      },
    };
    for my $name (keys %{$this->{properties}}){
      $new->{properties}->{$name} = $this->{properties}->{$name};
    }
    return bless $new, $class;
  }
  sub DumpGuts{
    my($this, $indent) = @_;
    unless(defined $indent){ $indent = "" }
    print "cone:\n" .
      "${indent}\tpoint1 = ($this->{point1}->[0], $this->{point1}->[1], " .
      "$this->{point1}->[2])\n" .
      "${indent}\tpoint2 = ($this->{point2}->[0], $this->{point2}->[1], " .
      "$this->{point2}->[2])\n" .
      "${indent}\tslope - $this->{slope}\n";
    for my $name (sort keys %{$this->{properties}}){
      print "${indent}\t$name - $this->{properties}->{$name}\n";
    }
  }
}
{
  package Posda::Solids::Union;
  use vars qw( @ISA );
  @ISA = ("Posda::Solids");
  sub new {
    my $class  = shift;
    my @obj_list = @_;
    my $this = {};
    my $sum_x;
    my $sum_y;
    my $sum_z;
    my $num_o = 0;
    for my $obj (@obj_list){
      $num_o += 1;
      unless($obj->isa("Posda::Solids")){
        die "Posda::Solids::Union needs a list of Posda::Solids";
      }
      push(@{$this->{list}}, $obj);
      $av_x += $obj->{center}->[0];
      $av_y += $obj->{center}->[1];
      $av_z += $obj->{center}->[2];
    }
    $this->{center} = [$av_x/$num_o, $av_y/$num_o, $av_z/$num_o];
    unless(ref($this->{list}) eq "ARRAY" && $#{$this->{list}} >= 0){
      die "Posda::Solids::Union needs at least one sub-object";
    }
    return bless $this, $class;
  }
  sub In{
    my($this, $point) = @_;
    for my $obj (@{$this->{list}}){
      if($obj->In($point)) { return 1 };
    }
    return 0;
  }
  sub In_CCode{
    my($this, $ccg) = @_;
    $ccg->add_body("(\n");
    unless($#{$this->{list}} > 0){ die "Union must have more than one object" }
    for my $obj_ind (0 .. $#{$this->{list}}){
      my $obj = $this->{list}->[$obj_ind];
      $ccg->add_indent("  ");
      $obj->In_CCode($ccg);
      $ccg->sub_indent("  ");
      unless($obj_ind == $#{$this->{list}}){
        $ccg->sub_indent("  ");
        $ccg->add_body("||\n");
        $ccg->add_indent("  ");
      }
    }
    $ccg->add_body(")\n");
  }
  sub Dist{
    my($this, $point) = @_;
    my $dist;
    for my $obj (@{$this->{list}}){
      my $odist = $obj->Dist($point);
      unless(defined $dist){ $dist = $odist }
      if($dist < $odist) { $dist = $odist }
    }
    return $dist;
  }
  sub CC_Dist{
    my($this, $dist, $ccg) = @_;
    my $odist = $ccg->gimme_f();
    my $tdist = $ccg->gimme_f();
    $ccg->add_body("$odist = 10000;\n");
    for my $obj (@{$this->{list}}){
      $obj->CC_Dist($tdist, $ccg);
      $ccg->add_body("if($tdist < $odist) { $odist = $tdist; }\n");
    }
    $ccg->add_body("$dist = $tdist;\n");
  };
  sub XformCopy {
    my($this, $xform) = @_;
    my $class = ref($this);
    my $new = {
      center => Posda::Transforms::ApplyTransform($xform, $this->{center}),
    };
    for my $obj (@{$this->{list}}){
      my $n_obj = $obj->XformCopy($xform);
      push(@{$new->{list}}, $n_obj);
    }
    for my $name (keys %{$this->{properties}}){
      $new->{properties}->{$name} = $this->{properties}->{$name};
    }
    return bless $new, $class;
  }
  sub DumpGuts {
    my($this, $indent) = @_;
    print "Union of:\n";
    for my $obj (@{$this->{list}}){
      print $indent . "\t";
      $obj->DumpGuts($indent . "\t\t");
    }
    for my $name (sort keys %{$this->{properties}}){
      print "${indent}\t$name - $this->{properties}->{$name}\n";
    }
  }
}
{
  package Posda::Solids::Intersection;
  use vars qw( @ISA );
  @ISA = ("Posda::Solids");
  sub new {
    my $class  = shift;
    my @obj_list = @_;
    my $this = {};
    my $sum_x;
    my $sum_y;
    my $sum_z;
    my $num_o = 0;
    for my $obj (@obj_list){
      unless($obj->isa("Posda::Solids")){
        die "Posda::Solids::Intersection needs a list of Posda::Solids";
      }
      push(@{$this->{list}}, $obj);
      $av_x += $obj->{center}->[0];
      $av_y += $obj->{center}->[1];
      $av_z += $obj->{center}->[2];
    }
    $this->{center} = [$av_x/$num_o, $av_y/$num_o, $av_z/$num_o];
    unless(ref($this->{list}) eq "ARRAY" && $#{$this->{list}} >= 0){
      die "Posda::Solids::Intersection needs at least one sub-object";
    }
    return bless $this, $class;
  }
  sub In{
    my($this, $point) = @_;
    for my $obj (@{$this->{list}}){
      unless($obj->In($point)) { return 0 };
    }
    return 1;
  }
  sub In_CCode{
    my($this, $ccg) = @_;
    $ccg->add_body("(\n");
    unless($#{$this->{list}} > 0){ die "Union must have more than one object" }
    for my $obj_ind (0 .. $#{$this->{list}}){
      my $obj = $this->{list}->[$obj_ind];
      $ccg->add_indent("  ");
      $obj->In_CCode($ccg);
      $ccg->sub_indent("  ");
      unless($obj_ind == $#{$this->{list}}){
        $ccg->sub_indent("  ");
        $ccg->add_body("&&\n");
        $ccg->add_indent("  ");
      }
    }
    $ccg->add_body(")\n");
  }
  sub Dist{
    my($this, $point) = @_;
    my $dist;
    for my $obj (@{$this->{list}}){
      my $odist = $obj->Dist($point);
      unless(defined $dist){ $dist = $odist }
      if($dist > $odist) { $dist = $odist }
    }
    return $dist;
  }
  sub CC_Dist{
    my($this, $dist, $ccg) = @_;
    my $odist = $ccg->gimme_f();
    my $tdist = $ccg->gimme_f();
    $ccg->add_body("$odist = 0;\n");
    for my $obj (@{$this->{list}}){
      $obj->CC_Dist($tdist, $ccg);
      $ccg->add_body("if($tdist > $odist) { $odist = $tdist; }\n");
    }
    $ccg->add_body("$dist = $tdist;\n");
  };
  sub XformCopy {
    my($this, $xform) = @_;
    my $class = ref($this);
    my $new = {
      center => Posda::Transforms::ApplyTransform($xform, $this->{center}),
    };
    for my $obj (@{$this->{list}}){
      my $n_obj = $obj->XformCopy($xform);
      push(@{$new->{list}}, $n_obj);
    }
    for my $name (keys %{$this->{properties}}){
      $new->{properties}->{$name} = $this->{properties}->{$name};
    }
    return bless $new, $class;
  }
  sub DumpGuts {
    my($this, $indent) = @_;
    print "Intersection of:\n";
    for my $obj (@{$this->{list}}){
      print $indent . "\t";
      $obj->DumpGuts($indent . "\t\t");
    }
    for my $name (sort keys %{$this->{properties}}){
      print "${indent}\t$name - $this->{properties}->{$name}\n";
    }
  }
}
{
  package Posda::Solids::Complement;
  use vars qw( @ISA );
  @ISA = ("Posda::Solids");
  sub new {
    my $class  = shift;
    my $outer  = shift;
    my $inner  = shift;
    my $this = {};
    unless($outer->isa("Posda::Solids")){
      die "Outer region is not a Posda::Solids";
    }
    unless($outer->isa("Posda::Solids")){
      die "Outer region is not a Posda::Solids";
    }
    $this->{outer} = $outer;
    $this->{inner} = $inner;
    $this->{center} = [@{$inner->{center}}];
    return bless $this, $class;
  }
  sub In{
    my($this, $point) = @_;
    unless($this->{outer}->In($point)) { return 0 };
    if($this->{inner}->In($point)) { return 0 };
    return 1;
  }
  sub In_CCode{
    my($this, $ccg) = @_;
    $ccg->add_body("(\n");
    $ccg->add_indent("  ");
    $ccg->add_body("!\n");
    $this->{inner}->In_CCode($ccg);
    $ccg->sub_indent("  ");
    $ccg->add_body("&&\n");
    $ccg->add_indent("  ");
    $this->{outer}->In_CCode($ccg);
    $ccg->sub_indent("  ");
    $ccg->add_body(")\n");
  }
  sub Dist{
    my($this, $point) = @_;
    my $idist = $this->{inner}->Dist($point);
    my $odist = $this->{inner}->Dist($point);
    my $dist = $idist < $odist ? $idist : $odist;
    return $dist;
  }
  sub CC_Dist{
    my($this, $dist, $ccg) = @_;
    my $odist = $ccg->gimme_f();
    my $idist = $ccg->gimme_f();
    $this->{outer}->CC_Dist($odist, $ccg);
    $this->{inner}->CC_Dist($idist, $ccg);
    $ccg->add_body("$idist < $odist ? $idist : $odist;\n");
  };
  sub XformCopy {
    my($this, $xform) = @_;
    my $class = ref($this);
    my $new = {
      center => Posda::Transforms::ApplyTransform($xform, $this->{center}),
    };
    $new->{outer} = $this->{outer}->XformCopy($xform);
    $new->{inner} = $this->{inner}->XformCopy($xform);
    for my $name (keys %{$this->{properties}}){
      $new->{properties}->{$name} = $this->{properties}->{$name};
    }
    return bless $new, $class;
  }
  sub DumpGuts {
    my($this, $indent) = @_;
    print "Points in first, but not in second:\n";
    print $indent . "\t";
    $this->{outer}->DumpGuts($indent . "\t\t");
    print $indent . "\t";
    $this->{inner}->DumpGuts($indent . "\t\t");
    for my $name (sort keys %{$this->{properties}}){
      print "${indent}\t$name - $this->{properties}->{$name}\n";
    }
  }
}
{
  package Posda::Solids::Beam;
  use vars qw( @ISA );
  @ISA = ("Posda::Solids");
  sub new{
    my($class, $pos, $iso, $xjaws,  $yjaws, $blda, $ga, $gpa, $psda, $sad) = @_;
    my $this = {
      type => "beam",
      treatment_pos => $pos,
      iso => $iso,
      x_jaws => $xjaws,
      y_jaws => $yjaws,
      blda => $blda,
      ga => $ga,
      gpa => $gpa,
      psda => $psda,
      sad => $sad,
    };
    my @commands;
    my $xs = - $this->{iso}->[0];
    my $ys = - $this->{iso}->[1];
    my $zs = - $this->{iso}->[2];
    push(@commands, ["shift", "($xs,$ys,$zs)"]);
    if($pos =~ /F../){
      push(@commands, ["ry", 180]);
    }
    if($pos =~ /..P/){
      push(@commands, ["rz", 180]);
    }
    if($this->{psda} != 0){
      push(@commands, ["ry", -$this->{psda}]);
    }
    if($this->{gpa} != 0){
      push(@commands, ["rx", -$this->{gpa}]);
    }
    if($this->{ga} != 0){
      push(@commands, ["rz", -$this->{ga}]);
    }
    if($this->{blda} != 0){
      push(@commands, ["ry", $this->{blda}]);
    }
    ($this->{t_xform}, $this->{f_xform}) =
      Posda::Transforms::MakeTransformPair(\@commands);
    $this->{max_x} =  $this->{x_jaws}->[1];
    $this->{min_x} =  $this->{x_jaws}->[0];
    $this->{max_z} =  $this->{y_jaws}->[1];
    $this->{min_z} =  $this->{y_jaws}->[0];
    return bless $this, $class;
  }
  sub In{
    my($this, $point) = @_;
    my $xfp = Posda::Transforms::ApplyTransform(
      $this->{t_xform}, $point);
    if($xfp->[1] >= $this->{sad}){ return 0 }
    my $px = ($xfp->[0] * (- $this->{sad})) / ($xfp->[1] + $this->{sad});
    my $pz = ($xfp->[2] * (- $this->{sad})) / ($xfp->[1] + $this->{sad});
    if(
      $px < $this->{max_x} && $px > $this->{min_x} &&
      $pz < $this->{max_z} && $pz > $this->{min_z}
    ){ return 1 }
    return 0;
  }
  sub In_CCode{
    my($this, $ccg) = @_;
    my $pp_x = VectorMath::CC_ApplyTransformX($this->{t_xform});
    my $pp_y = VectorMath::CC_ApplyTransformY($this->{t_xform});
    my $pp_z = VectorMath::CC_ApplyTransformZ($this->{t_xform});
    $ccg->add_body("(($pp_x >= $this->{sad}) ? 0 : (\n");
    my $px = "(($pp_x * (- ($this->{sad}))) / ($pp_y + ($this->{sad})))\n";
    my $pz = "(($pp_z * (- ($this->{sad}))) / ($pp_y + ($this->{sad})))\n";
    $ccg->add_body("($px < ($this->{max_x}) &&\n");
    $ccg->add_body("$px > ($this->{min_x}) &&\n");
    $ccg->add_body("$pz < ($this->{max_z}) &&\n");
    $ccg->add_body("$pz > ($this->{min_z})) ? 1 : 0");
    $ccg->add_body("))\n");
  }
  sub Dist{
    my($this, $point) = @_;
    return VectorMath::Dist($point, $this->{iso});
  }
#  sub CC_Dist{
#    my($this, $dist, $ccg);
#    
#  }
  sub XformCopy{
    my($this, $xform) = @_;
    die "illegal to transform beams";
  }
  sub DumpGuts{
    my($this, $indent) = @_;
    unless(defined $indent){ $indent = "" }
    print "beam:\n" .
      "${indent}\tiso_center: ($this->{iso}->[0], $this->{iso}->[1], " .
      "$this->{iso}->[2])\n" .
      "${indent}\tx_jaws: $this->{x_jaws}->[0], $this->{x_jaws}->[1]\n" .
      "${indent}\ty_jaws: $this->{y_jaws}->[0], $this->{y_jaws}->[1]\n" .
      "${indent}\ttreatment_pos: $this->{treatment_pos}\n" .
      "${indent}\tblda: $this->{blda}\n" .
      "${indent}\tga: $this->{ga}\n" .
      "${indent}\tgpa: $this->{gpa}\n" .
      "${indent}\tpsda: $this->{psda}\n" .
      "${indent}\tmax_x: $this->{max_x}\n" .
      "${indent}\tmin_x: $this->{min_x}\n" .
      "${indent}\tmax_z: $this->{max_z}\n" .
      "${indent}\tmin_z: $this->{min_z}\n" .
      "${indent}\tTo transform:\n";
    Posda::Transforms::PrintTransform($this->{t_xform});
    print "${indent}\tFrom transform:\n";
    Posda::Transforms::PrintTransform($this->{f_xform});
    for my $name (sort keys %{$this->{properties}}){
      print "${indent}\t$name - $this->{properties}->{$name}\n";
    }
  }
}
1;

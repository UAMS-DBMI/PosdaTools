#!/usr/bin/perl -w
use strict;
#
my $foo = <<EOF;
# Pipe the following comand to this script
echo "select '|' ||
tag || '|' ||
name || '|' ||
keyword || '|' ||
vr || '|' ||
vm || '|' ||
retired || '|' ||
comment || '|'
from dicom_element
order by tag;"|psql dicom_dd|grep '|'
EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$foo\n";
}

my $render_repeating = $ARGV[0];
my $grp;
my $in_retired;
my $first_retired;
my $last_retired;
my $ret_count;
my $title;
my($pre, $sig,$name,$keyword,$vr,$vm,$is_retired, $comment);
while(my $line = <STDIN>){
  chomp $line;
  ($pre, $sig,$name,$keyword,$vr,$vm,$is_retired, $comment) = 
    split(/\|/, $line);
  my $is_repeating = 0;
  if($sig =~ /x/){
    $is_repeating = 1;
    if($sig =~ /^([^x]*)(x+)(.*)$/){
      my($left, $middle, $right) = ($1, $2, $3);
      my $grp_mask;
      my $grp_match;
      my $ele_mask;
      my $ele_match;
      my $num_index;
      my $index_inc;
      my $new_ele;
      my $index;
      my $index_in;
      if(length($left) == 3 && length($middle) == 2){
        if($render_repeating){
          for my $i (0 .. 0x7e){
            my $mid = sprintf("%02x",$i*2);
            $new_ele = "$left$mid$right";
            $index = $i;
            $title = "$sig ($index): $new_ele";
            HandleElement($title, $new_ele, $name, $keyword, $vr, $vm, 
              $is_retired eq "true" ? 1 : 0, $comment, $index, $sig, 1);
          }
        } else {
          $grp_mask = "ff00";
          $grp_match = substr($left,1,2);
          $grp_match = $grp_match . "00";
          $ele_match = substr($right, 1, 4);
          $index_inc = "0002";
          $num_index = "007f";
          $index_in = "group";
        }
      } elsif (length($left) == 8 && length($middle) == 2){
        if($render_repeating){
          for my $i (0 .. 0xff){
            my $mid = sprintf("%02x", $i);
            $new_ele = "$left$mid$right";
            $index = $i;
            $title = "$sig ($index): $new_ele";
            HandleElement($title, $new_ele, $name, $keyword, $vr, $vm, 
              $is_retired eq "true" ? 1 : 0, $comment, $index, $sig, 1);
          }
        } else {
          $ele_mask = "ff00";
          $ele_match = substr($left,6,2);
          $ele_match = $ele_match . "00";
          $grp_match = substr($left,1, 4);
          $index_inc = "0001";
          $num_index = "00ff";
          $index_in = "element";
        }
      } elsif (length($left) == 8 && length($middle) == 1){
        if($render_repeating){
          for my $i (0 .. 0xf){
            my $mid = sprintf("%01x", $i);
            $new_ele = "$left$mid$right";
            $index = $i;
            $title = "$sig ($index): $new_ele";
            HandleElement($title, $new_ele, $name, $keyword, $vr, $vm, 
              $is_retired eq "true" ? 1 : 0, $comment, $index, $sig, 1);
          }
        } else {
          $ele_mask = "ff0f";
          $grp_match = substr($left,1,4);
          $ele_match = substr($left,6,2);
          my $ele_match1 = substr($right,0,1);
          $ele_match = $ele_match . "0" . $ele_match1;
          $index_inc = "0010";
          $num_index = "00f";
          $index_in = "element";
        }
      } elsif (length($left) == 6 && length($middle) == 3){
        if($render_repeating){
          for my $i (0 .. 0xfff){
            my $mid = sprintf("%03x", $i);
            $new_ele = "$left$mid$right";
            $index = $i;
            $title = "$sig ($index): $new_ele";
            HandleElement($title, $new_ele, $name, $keyword, $vr, $vm, 
              $is_retired eq "true" ? 1 : 0, $comment, $index, $sig, 1);
          }
        } else {
          $ele_mask = "0000f";
          $ele_match = substr($right, 0, 1);
          $ele_match = "000" . $ele_match;
          $grp_match = substr($left, 1, 4);
          $index_inc = "0010";
          $num_index = "0fff";
          $index_in = "element";
        }
      } elsif (length($left) == 6 && length($middle) == 4){
        if($render_repeating){
          for my $i (0 .. 0xffff){
            my $mid = sprintf("%04x", $i);
            $new_ele = "$left$mid$right";
            $index = $i;
            $title = "$sig ($index): $new_ele";
            HandleElement($title, $new_ele, $name, $keyword, $vr, $vm,
              $is_retired eq "true" ? 1 : 0, $comment, $index, $sig, 1);
          }
        } else {
          $ele_mask = "ffff";
          $grp_match = substr($left, 1, 4);
          $index_inc = "0001";
          $num_index = "ffff";
          $index_in = "element";
        }
      } else {
        print "Couldn't make sense of repeating ele: $sig\n";
      }
      unless($render_repeating){
        print "#### Repeating Element: $sig ####\n";
        print "push \@{Posda::DataDict::RepeatingEle}, {\n";
        if(defined $grp_mask){
          print "  grp_mask => \"$grp_mask\",\n";
        }
        if(defined $grp_match){
          print "  grp_match => \"$grp_match\",\n";
        }
        if(defined $ele_mask){
          print "  ele_mask => \"$ele_mask\",\n";
        }
        if(defined $ele_match){
          print "  ele_match => \"$ele_match\",\n";
        }
        if(defined $index_inc){
          print "  index_inc => \"$index_inc\",\n";
        }
        if(defined $num_index){
          print "  num_index => \"$num_index\",\n";
        }
        if(defined $index_in){
          print "  index_in => \"$index_in\",\n";
        }
        if($is_retired eq "true"){
          print "  RET => \"1\",\n";
        }
        print "  Name => \"$name\",\n";
        print "  Keyword => \"$keyword\",\n";
        print "  VR => \"$vr\",\n";
        print "  VM => \"$vm\",\n";
        print "};\n";
      }
    }
  } elsif ($sig =~ /\((....),(....)\)/) {
    $title = "$sig";
    HandleElement($title, $sig, $name, $keyword, $vr, $vm,
      $is_retired eq "true" ? 1 : 0, $comment, undef, $sig, 0);
  } else {
    print "Unknown sig: $sig\n";
  }
}
print "1;\n";
sub HandleElement{
  my( $title, $sig, $name, $kw, $vr, $vm, 
    $is_ret, $com, $index, $ret_base, $is_rpt) = @_;
  print "#####$title#####\n";
  my($grp, $ele);
  if($sig =~ /^\((....),(....)\)$/){
    $grp = $1;
    $ele = $2;
  }
  my $group = hex($grp);
  my $element = hex($ele);
  print("\$Posda::DataDict::Dict->{$group}->{$element} = {\n");
  print("    group => \"$grp\",\n");
  print("    ele => \"$ele\",\n");
  print("    VM => \"$vm\",\n");
  print("    VR => \"$vr\",\n");
  print("    Name => \"$name\",\n");
  print("    Keyword => \"$kw\",\n");
  if($is_ret){
    print("    RET => \"1\",\n");
  }
  if(defined($index)){
    print("    index => \"$index\",\n");
    print("    is_repeating => \"1\",  $is_ret, $is_rpt\n");
    print("    sig => \"$ret_base\",\n");
  }
  print("};\n");
}

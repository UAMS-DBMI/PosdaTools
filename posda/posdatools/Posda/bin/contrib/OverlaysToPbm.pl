#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Dataset;

Posda::Dataset::InitDD;

#  Get the name of the file from which to extract overlays
my $file = $ARGV[0];

#  This has defines the data types for each element in the overlay repeating
#  group.  This is needed because POSDA doesn't handle repeating groups very
#  well (it doesn't recognize the elements).
my $ele_lookup = {
  "0010" => {
     name => "rows",
     type => 'short',
  }, 
  "0011" => {
     name => "cols",
     type => 'short',
  }, 
  "0022" => {
     name => "description",
     type => 'text',
  }, 
  "0040" => {
     name => "type",
     type => 'text',
  }, 
  "0050" => {
     name => "origin",
     type => 'short',
  }, 
  "0100" => {
     name => "bits_allocated",
     type => 'short',
  }, 
  "0102" => {
     name => "bit_position",
     type => 'short',
  }, 
  "1500" => {
     name => "overlay_label",
     type => 'text',
  }, 
  "3000" => {
     name => "overlay_data",
     type => 'OB',
  }, 
};

# Read the file
my($df, $ds, $size, $xfr_stx, $errors)  = Posda::Dataset::Try($file);
# The function $foo will be mapped over all of the elements, and will
# populate the %Overlays hash for each overlay it finds:
#
#$Overlays{$ov_num} = {
#   <ele_num> => <value>
# };
#  This loop has to handle unpacking of shorts into perl scalars if the VR is
#  'UN'
#
my %Overlays;
my $foo = sub {
  my($ele, $sig) = @_;
  # only look at the overlay repeating group
  if($sig =~ /^\(60(..),(....)\)$/){
    # extract the overlay number and element number
    my $ov_no = hex($1)/2;
    my $el = $2;
    # do conversion if Posda hasn't already done it (i.e. VR is 'UN')
    if(
      $ele->{VR} eq "UN"
    ){
      unless(defined $ele_lookup->{$el}){
        print "unknown ele: $el\n";
        return;
      }
      if($ele_lookup->{$el} eq "text"){
        $Overlays{$ov_no}->{$el} =~ s/ $//;
      } elsif ($ele_lookup->{$el}->{type} eq "short"){
        my @foo = unpack("v*", $ele->{value});
        if($#foo == 0){
          $Overlays{$ov_no}->{$el} = $foo[0];
        } else {
          $Overlays{$ov_no}->{$el} = \@foo;
        }
      } else {
        $Overlays{$ov_no}->{$el} = $ele->{value};
      }
    } else {
      # here if Posda has already converted elements
      $Overlays{$ov_no}->{$el} = $ele->{value};
    }
  }
};

# If the file didn't parse, die.  If it did, map $foo over the dataset.
if($ds){
  $ds->MapPvt($foo);
} else {
  die "$file didn't parse";
}
#  The following code was used to debug the scanning of overlay data
#  print "Overlays:\n";
#  for my $key (sort { $a <=> $b } keys %Overlays){
#    print "\t$key:\n";
#    for my $ele (sort keys %{$Overlays{$key}}){
#      if($ele eq "3000"){
#        my $len = length($Overlays{$key}->{$ele});
#        print "\t\t $ele => <binary length $len>\n";
#      } elsif(ref($Overlays{$key}->{$ele}) eq "ARRAY") {
#        print "\t\t $ele => [";
#        for my $i (0 .. $#{$Overlays{$key}->{$ele}}){
#          print "$Overlays{$key}->{$ele}->[$i]";
#          unless($i == $#{$Overlays{$key}->{$ele}}){
#            print ", ";
#          }
#        }
#        print "]\n";
#      } else {
#        print "\t\t $ele => $Overlays{$key}->{$ele}\n";
#      }
#    }
#  };
#exit;
# End of test code

# Now we have parsed all of the overlays and extracted all the data
# Here loop over the overlays and:
#    - Produce a ".pbm" file of the overlay
#    - If the overlay has "bare" points, produce a ".points" file with
#      a list of all such points
#
for my $i (sort { $a <=> $b } keys %Overlays){
  my $decoded;
  for my $key (sort keys %{$Overlays{$i}}){
    unless($key eq "3000"){
      $decoded->{$ele_lookup->{$key}->{name}} = $Overlays{$i}->{$key};
    }
  }
  #  Here's the start of the code which produces the .pbm file
  my $rows = $decoded->{rows};
  my $cols = $decoded->{cols};
  my $file_name = $Overlays{$i}->{"1500"};
  $file_name =~ s/ //g;
  my $file_name_pbm = "$file_name.pbm";
  open FILE, ">$file_name_pbm" or die "can't open $file_name_pbm";
  print FILE "P4\n";
  print FILE "$cols\n";
  print FILE "$rows\n";
  my $new_img = "\0" x (($rows * $cols)/8);
  my $old_img = $Overlays{$i}->{"3000"};
  my $len_old = length($old_img);
  my $len_new = length($new_img);
  my @array;
  for my $i (0 .. ($rows * $cols) - 1){
    my $byte_offset = int($i / 8);
    my $bit_no = $i - ($byte_offset * 8);
    my $from_bit = ($byte_offset * 8) + $bit_no;
    my $to_bit = ($byte_offset * 8) + (7 - $bit_no);
    vec($new_img, $to_bit, 1) = vec($old_img, $from_bit, 1);
    my $bit = vec($old_img, $from_bit, 1);
    $array[($byte_offset * 8) + $bit_no] = $bit;
  }
  print FILE $new_img;
  close FILE;
# This commented out code was used to debug the production of ".pbm" files.
#  print "Wrote file: $file_name\n";
#  print "$i|file=$file_name";
#  for my $key (keys %$decoded){
#    if(ref($decoded->{$key}) eq "ARRAY"){
#      for my $i (0 .. $#{$decoded->{$key}}){
#        print "|${key}[$i]=$decoded->{$key}->[$i]";
#      }
#    } else {
#      print "|$key=$decoded->{$key}";
#    }
#  };
#  print "|\n";
# End of test code
  #  This concludes producing the .pbm file

  # Here's the start of the code that produces the .points file
  my @points;
  for my $row_i (0 .. $rows - 1){
    for my $col_i (0 .. $cols - 1){
      my $index = $col_i + ($cols * $row_i);
      my($point_above, $point_left, $point_right, $point_below);
      my($point_ul, $point_ur, $point_ll, $point_lr);
      if(
        $row_i > 0 && $row_i < $rows &&
        $col_i > 0 && $col_i < $cols
      ){
        my $pa_index_above = $col_i + ($cols * ($row_i - 1));
        my $pa_index_below = $col_i + ($cols * ($row_i + 1));
        my $pa_index_left = ($col_i - 1) + ($cols * $row_i);
        my $pa_index_right = ($col_i + 1) + ($cols * $row_i);
        my $pa_index_ul =  ($col_i - 1) + ($cols * ($row_i - 1));
        my $pa_index_ur =  ($col_i + 1) + ($cols * ($row_i - 1));
        my $pa_index_ll =  ($col_i - 1) + ($cols * ($row_i + 1));
        my $pa_index_lr =  ($col_i + 1) + ($cols * ($row_i + 1));
        $point_above = $array[$pa_index_above];
        $point_below = $array[$pa_index_below];
        $point_left = $array[$pa_index_left];
        $point_right = $array[$pa_index_right];
        $point_ul = $array[$pa_index_ul];
        $point_ur = $array[$pa_index_ur];
        $point_ll = $array[$pa_index_ll];
        $point_lr = $array[$pa_index_lr];
      } elsif($row_i == 0 && $col_i < $cols && $cols > 0){
        my $pa_index_below = $col_i + ($cols * ($row_i + 1));
        my $pa_index_left = ($col_i - 1) + ($cols * $row_i);
        my $pa_index_right = ($col_i + 1) + ($cols * $row_i);
        my $pa_index_ll =  ($col_i - 1) + ($cols * ($row_i + 1));
        my $pa_index_lr =  ($col_i + 1) + ($cols * ($row_i + 1));
        $point_below = $array[$pa_index_below];
        $point_left = $array[$pa_index_left];
        $point_right = $array[$pa_index_right];
        $point_ll = $array[$pa_index_ll];
        $point_lr = $array[$pa_index_lr];
      } elsif($row_i == ($rows - 1) && $col_i < $cols && $cols < 0){
        my $pa_index_above = $col_i + ($cols * ($row_i - 1));
        my $pa_index_left = ($col_i - 1) + ($cols * $row_i);
        my $pa_index_right = ($col_i + 1) + ($cols * $row_i);
        my $pa_index_ul =  ($col_i - 1) + ($cols * ($row_i - 1));
        my $pa_index_ur =  ($col_i + 1) + ($cols * ($row_i - 1));
        $point_above = $array[$pa_index_above];
        $point_left = $array[$pa_index_left];
        $point_right = $array[$pa_index_right];
        $point_ul = $array[$pa_index_ul];
        $point_ur = $array[$pa_index_ur];
      } elsif($row_i > 0 && $row_i < $rows && $col_i == 0){
        my $pa_index_above = $col_i + ($cols * ($row_i - 1));
        my $pa_index_below = $col_i + ($cols * ($row_i + 1));
        my $pa_index_right = ($col_i + 1) + ($cols * $row_i);
        my $pa_index_ur =  ($col_i + 1) + ($cols * ($row_i - 1));
        my $pa_index_lr =  ($col_i + 1) + ($cols * ($row_i + 1));
        $point_above = $array[$pa_index_above];
        $point_below = $array[$pa_index_below];
        $point_right = $array[$pa_index_right];
        $point_ur = $array[$pa_index_ur];
        $point_lr = $array[$pa_index_lr];
      } elsif($row_i > 0 && $row_i < $rows && $col_i == ($cols - 1)){
        my $pa_index_above = $col_i + ($cols * ($row_i - 1));
        my $pa_index_below = $col_i + ($cols * ($row_i + 1));
        my $pa_index_left = ($col_i - 1) + ($cols * $row_i);
        my $pa_index_ul =  ($col_i - 1) + ($cols * ($row_i - 1));
        my $pa_index_ll =  ($col_i - 1) + ($cols * ($row_i + 1));
        $point_above = $array[$pa_index_above];
        $point_below = $array[$pa_index_below];
        $point_left = $array[$pa_index_left];
        $point_ul = $array[$pa_index_ul];
        $point_ll = $array[$pa_index_ll];
      } elsif($row_i == 0 && $col_i == 0){
        my $pa_index_below = $col_i + ($cols * ($row_i + 1));
        my $pa_index_left = ($col_i - 1) + ($cols * $row_i);
        my $pa_index_ll =  ($col_i - 1) + ($cols * ($row_i + 1));
        $point_below = $array[$pa_index_below];
        $point_left = $array[$pa_index_left];
        $point_ll = $array[$pa_index_ll];
      } elsif($row_i == ($rows - 1) && $col_i == ($cols - 1)){
        my $pa_index_above = $col_i + ($cols * ($row_i - 1));
        my $pa_index_left = ($col_i - 1) + ($cols * $row_i);
        my $pa_index_ul =  ($col_i - 1) + ($cols * ($row_i - 1));
        $point_above = $array[$pa_index_above];
        $point_left = $array[$pa_index_left];
        $point_ul = $array[$pa_index_ul];
      } else {
        die "Invalid rows, cols: $rows, $cols ($row_i, $col_i)";
      }
      unless(defined $point_right){ $point_right = 0}
      unless(defined $point_left){ $point_left = 0}
      unless(defined $point_above){ $point_above = 0}
      unless(defined $point_below){ $point_below = 0}
      unless(defined $point_ul){ $point_ul = 0}
      unless(defined $point_ur){ $point_ur = 0}
      unless(defined $point_ll){ $point_ll = 0}
      unless(defined $point_lr){ $point_lr = 0}
      my $point = $array[$index];
      if(
        ($point == 1) &&
        ($point_above == 0) &&
        ($point_below == 0) &&
        ($point_left == 0) &&
        ($point_right == 0) &&
        ($point_ul == 0) &&
        ($point_ur == 0) &&
        ($point_ll == 0) &&
        ($point_lr == 0)
      ){
        push @points, "bare point: ($col_i, $row_i)\n";
      }
    }
  }
  if($#points >= 0){
    open FILE, ">$file_name.points";
    for my $i (@points){ print FILE $i };
    close FILE;
  }
}
#exit; to execute only test code above, uncomment this exit

# This ends phase one - extraction of overlays:
# Here we have extracted all of the overlays into files with names of the
# for:
#   <ov_name>.pbm
# For each overlay with bare points (i.e. points which are don't border any
# other points, we have produced a file with a name of the form:
#   <ov_name>.points
# With a list of the points
#


# The remaining part of the program generates and executes ImageMagick
# commands to composite the overlays and points on top of the image.
#
# First convert the DICOM pixel data to png format using ImageMagick
`convert $file $file.png`;

# Depending on the version of ImageMagick we will do the compositing
# differently - Here we determine the version
#
open VER, "convert -h |head -1|";
my $line = <VER>;
close VER;
my $ver;
if($line =~ /Version: ImageMagick (.)/){
  $ver = $1;
}

# Loop through the ".pbm" files and do the compositing
for my $file_nm (`ls *.pbm`){
  chomp $file_nm;
  unless($file_nm =~ /(.*).(pbm)/){
    next;
  }
  my $fn = $1;
  open HEAD, "head -3 $file_nm|";
  my $one = <HEAD>;
  my $cols = <HEAD>;
  my $rows = <HEAD>;
  close HEAD;
  chomp $cols;
  chomp $rows;
  my $draw = "";
  if(-r "$fn.points"){
    open POINTS, "<$fn.points";
    while(my $line = <POINTS>){
      chomp $line;
      unless($line =~ /bare point: \((.*),\s*(.*)\)/){
        print STDERR "Non-matching line: $line\n";
        next;
      }
      my $col_i = $1;
      my $row_i = $2;
      $col_i =~ s/\s*//g;
      $row_i =~ s/\s*//g;
      my $l_col = $col_i - 5;
      if($l_col < 0) { $l_col = 0 }
      my $r_col = $col_i + 5;
      if($r_col >= $cols) { $r_col = $cols - 1 }
      my $t_row = $row_i - 5;
      if($t_row < 0) { $t_row = 0 }
      my $b_row = $row_i + 5;
      if($b_row >= $rows) { $b_row = $rows - 1 }
      $draw .= "line $l_col,$row_i $r_col,$row_i " .
               "line $col_i,$t_row $col_i,$b_row ";
    }
    if($draw) {
       $draw = "-stroke green -strokewidth 3 -draw \"$draw\" " 
    }
  }
  $draw .= " -stroke white -strokewidth 2 -draw 'text 10,10 \"$fn\"' ";
  close POINTS;
  my $map_extract_temp;
  my $red_construct_temp;
  my $composite_temp;
  $map_extract_temp = "convert <source> -negate <mask>";
  my $add_points_temp = "convert <dest> <draw> <final>";

  # Here we generate different composite commands based upon version of 
  # ImageMagick
  if($ver == 6){
    $red_construct_temp = 
      "composite -compose CopyOpacity <mask> -size <cols>x<rows> xc:red " .
      "<red>";
    $composite_temp = 
      "composite -dissolve 50% <red> <image> <dest>";
  } elsif ($ver == 5){
    $red_construct_temp = 
      "composite -background transparent -size <cols>x<rows> xc:red " .
      "-compose CopyRed <mask> -negate <red>";
    $composite_temp = 
      "composite -dissolve 50% <red> <image> <mask> <dest>";
  } else {
    die "Unknown version of ImageMagick: $line";
  }
  # This are the file names of various working files
  my $source = $file_nm;
  my $mask = "$fn.mask.png";
  my $red = "$fn.red.png";
  my $dest = "$fn.comp.png";
  my $final = "$fn.final.png";
  my $image = "$file.png";

  # Here we substitute file names and data into constructed commands
  my $map_ext_com = $map_extract_temp;
  $map_ext_com =~ s/<source>/$source/g;
  $map_ext_com =~ s/<mask>/$mask/g;
  my $red_const_com = $red_construct_temp;
  $red_const_com =~ s/<source>/$source/g;
  $red_const_com =~ s/<mask>/$mask/g;
  $red_const_com =~ s/<rows>/$rows/g;
  $red_const_com =~ s/<cols>/$cols/g;
  $red_const_com =~ s/<red>/$red/g;
  my $comp_com = $composite_temp;
  $comp_com =~ s/<source>/$source/g;
  $comp_com =~ s/<mask>/$mask/g;
  $comp_com =~ s/<rows>/$rows/g;
  $comp_com =~ s/<cols>/$cols/g;
  $comp_com =~ s/<red>/$red/g;
  $comp_com =~ s/<dest>/$dest/g;
  $comp_com =~ s/<image>/$image/g;
  my $final_com = $add_points_temp;
  $final_com =~ s/<dest>/$dest/;
  $final_com =~ s/<draw>/$draw/;
  $final_com =~ s/<final>/$final/;

  # Here we execute the ImageMagick commands to produce the composited files
  `$map_ext_com`;
  `$red_const_com`;
  `$comp_com`;
  if($draw){
    `$final_com`;
    `rm $dest`;
  } else {  # dead code now that we are always drawing overlay name
    `mv $dest $final`;
  }
  `rm $red`;
  `rm $mask`;
  # This print command prints the ImageMagick command to display the 
  # composited image.  Piping this command to /bin/sh will cause the
  # images to be displayed, one at a time.
  print "display $final\n";
}


#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/contrib/DoseInterpolationGraphGenerator.pl,v $
#$Date: 2013/02/07 15:47:32 $
#$Revision: 1.1 $
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
################
#   Config file format:
#source_file: <source_file>
#scaling: <scaling>
#...  Repeat these pairs
#sum_file: <summation file>
#start_x: <starting x value>
#start_y: <starting y value>
#start_z: <starting z value>
#num_x: <number of steps in x>
#num_y: <number of steps in y>
#num_z: <number of setps in z>
#x_inc: <step size in x>
#y_inc: <step size in y>
#z_inc: <step size in z>
#bin_size: <bin size for stats (not yet implemented)>
#shift_size: <diagonal spatial phase shift increment (optional for multicolumn report)>
#shift_count: <if shifting phase, number of columns>
use strict;
my $config = $ARGV[0];
unless(-f $config) {
  die "can't find config file: $config";
}
open FILE, "<$config"  or die "can't open $config";
my @source_files;
my $sum_file;
my $start_x;
my $start_y;
my $start_z;
my $num_x;
my $num_y;
my $num_z;
my $x_inc;
my $y_inc;
my $z_inc;
my $bin_size;
my $source_file;
my $shift_size;
my $shift_size_x = 0;
my $shift_size_y = 0;
my $shift_size_z = 0;
my $shift_count;
my $gradient_phase_shift_x;
my $gradient_phase_shift_y;
my $gradient_phase_shift_z;
while(my $line = <FILE>){
  chomp $line;
  my($key, $value) = split /:/, $line;
  $key =~ s/^\s*//;
  $key =~ s/\s*$//;
  $value =~ s/^\s*//;
  $value =~ s/\s*$//;
  if($key eq "source_file"){ $source_file = $value;
  } elsif($key eq "scaling"){
    push(@source_files, {file => $source_file, scaling => $value});
  } elsif($key eq "sum_file") { $sum_file = $value
  } elsif($key eq "start_x") { $start_x = $value
  } elsif($key eq "start_y") { $start_y = $value
  } elsif($key eq "start_z") { $start_z = $value
  } elsif($key eq "num_x") { $num_x = $value
  } elsif($key eq "num_y") { $num_y = $value
  } elsif($key eq "num_z") { $num_z = $value
  } elsif($key eq "x_inc") { $x_inc = $value
  } elsif($key eq "y_inc") { $y_inc = $value
  } elsif($key eq "z_inc") { $z_inc = $value
  } elsif($key eq "shift_size") { $shift_size = $value
  } elsif($key eq "shift_size_x") { $shift_size_x = $value
  } elsif($key eq "shift_size_y") { $shift_size_y = $value
  } elsif($key eq "shift_size_z") { $shift_size_z = $value
  } elsif($key eq "shift_count") { $shift_count = $value
  } elsif($key eq "gradient_phase_shift_x") { $gradient_phase_shift_x = $value
  } elsif($key eq "gradient_phase_shift_y") { $gradient_phase_shift_y = $value
  } elsif($key eq "gradient_phase_shift_z") { $gradient_phase_shift_z = $value
  } elsif($key eq "bin_size") { $bin_size = $bin_size
  } else { print STDERR "line: \"$line\" not understood\n" }
}
if(defined($shift_size)){
  $shift_size_x = $shift_size;
  $shift_size_y = $shift_size;
  $shift_size_z = $shift_size;
}
close FILE;
print "line\t";
for my $i (0 .. $#source_files){
  print "$i\t";
}
print "sum\t";
print "summed\terror\n";
my $line = 1;
for my $i (0 .. $num_x - 1){
  for my $j (0 .. $num_y - 1){
    for my $k (0 .. $num_z - 1){
      my $x = $start_x + ($x_inc * $i);
      my $y = $start_y + ($y_inc * $j);
      my $z = $start_z + ($z_inc * $k);
      print "$line\t";
      $line += 1;
      my $sum = 0;
      for my $f(@source_files){
        my $command = "DoseAt.pl \"$f->{file}\" $x $y $z";
        open CMD, "$command|" or die "can't open $command";
        while(my $line = <CMD>){
          if($line =~ /^(.*) GY/){
            my $dose = $1;
            $sum += $dose;
            printf("%0.4f\t", $dose);
          }
        }
      }
      printf("%0.4f\t", $sum);
      my $command = "DoseAt.pl \"$sum_file\" $x $y $z";
      open CMD, "$command|" or die "can't open $command";
      while(my $line = <CMD>){
        if($line =~ /^(.*) GY/){
          my $dose = $1;
          my $error = $dose - $sum;
          printf("%0.4f\t%04f\n", $dose, $error);
          my $pct = ($error/$dose) * 100;
          my $error_txt = sprintf("%0.4f", $pct);
#          print "\t$error_txt";
        }
      }
    }
  }
}

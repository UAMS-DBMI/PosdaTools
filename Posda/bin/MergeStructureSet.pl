#!/usr/bin/perl -w 
#$Source: /home/bbennett/pass/archive/Posda/bin/MergeStructureSet.pl,v $
#$Date: 2014/12/04 15:14:53 $
#$Revision: 1.5 $
#
#Copyright 2012, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Try;
use Posda::UUID;
use Cwd;
if($ARGV[0] eq "-h"){
  print <<EOF;
Help for MergeStructureSet.pl:
If the first argument is "-h" it produces this output, explaining its usage,
otherwise...
The first two arguments are the names of two files which must both be 
DICOM RTSTRUCTS.  
MergeStructureSet.pl is used to copy or copy and rename
ROI's from the first RTSTRUCT into the Dataset of the second RTSTRUCT.  This
dataset is then given an new SOP Instance UID and written to a file in the
directory specified by the third argument.  The name of the file will be
derived from the SOP instance UID of the dataset.

Following the first three arguments are groups of args which describe
the ROIs to be copied.  These have the form:
  Copy <name>
  CopyAndRename <name> <new_name>

If the script is successful, it will produce output, describing the changes
it made.  First will be a line specifying the new SOP instance uid.  This 
will be follwed by a line indicating the file name of the new DICOM file.
This will be followed by a number of lines which describe how to fix up 
references in DVHs

New SOP: <sop_instance_uid>
New File: <file_name>
Mapped Struct UID: <sop_instance_uid of struct with renumbered ROIs>
Copied ROI: <old_roi_num> <new_roi_num>
....
Mapped ROI: <old_roi_num> <new_roi_num>
...

There may be a lot of messages on STDERR.
EOF
  exit;
}
my $here = getcwd;
my $from = shift @ARGV;
unless($from =~ /^\//){$from = "$here/$from" }
my $to = shift @ARGV;
unless($to =~ /^\//){$to = "$here/$to" }
my $dir = shift @ARGV;
unless($dir =~ /^\//){$dir = "$here/$dir" }
unless(-f $from) { die "$from is not a file" }
unless(-f $to) { die "$to is not a file" }
unless(-d $dir) { die "$dir is not a directory" }
my $copy_from = Posda::Try->new($from);
unless(exists $copy_from->{dataset}) { die "$from isn't a DICOM file" }
my $copy_into = Posda::Try->new($to);
unless(exists $copy_into->{dataset}) { die "$to isn't a DICOM file" }
unless($copy_from->{dataset}->Get("(0008,0016)") eq "1.2.840.10008.5.1.4.1.1.481.3"){
  die "$from is not an RTSTRUCT";
}
unless($copy_into->{dataset}->Get("(0008,0016)") eq "1.2.840.10008.5.1.4.1.1.481.3"){
  die "$to is not an RTSTRUCT";
}
my @commands;
while ($#ARGV >= 0){
  my($cmd, $arg1, $arg2);
  $cmd = shift @ARGV;
  $arg1 = shift @ARGV;
  if($cmd eq "CopyAndRename"){ $arg2 = shift @ARGV }
  unless($cmd eq "Copy" || $cmd eq "CopyAndRename") {
    die "Unknown command: $cmd";
  }
  unless(defined $arg1) { die "no arg1 for $cmd" }
  if($cmd eq "CopyAndRename") {
    unless(defined $arg2) { die "no arg2 for $cmd" }
  }
  if($cmd eq "Copy") { push @commands, [$cmd, $arg1] }
  if($cmd eq "CopyAndRename") { push @commands, [$cmd, $arg1, $arg2] }
}
#Get new SOP instance UID and file name
my $new_uid = Posda::UUID::GetUUID;
my $mapped_uid = $copy_into->{dataset}->Get("(0008,0018)");
$copy_into->{dataset}->Insert("(0008,0018)", $new_uid);
my $new_file = "$dir/RTS_$new_uid.dcm";

#find largest roi_num
my $largest_roi_num = 0;
my $m = $copy_into->{dataset}->Search("(3006,0020)[<0>](3006,0022)");
for my $i (@{$m}){
  my $rsi = $i->[0];
  my $roi_num = $copy_into->{dataset}->Get("(3006,0020)[$rsi](3006,0022)");
  if($roi_num > $largest_roi_num) { $largest_roi_num = $roi_num }
}

#now find largest roi_seq_index
my $roi_seq = $copy_into->{dataset}->Get("(3006,0020)");
my $largest_roi_seq_index = $#{$roi_seq};

#now find largest roi_contour_seq_index
my $roi_c_seq = $copy_into->{dataset}->Get("(3006,0039)");
my $largest_roi_c_seq_index = $#{$roi_c_seq};

#now find largest roi_observation_seq_index and largest roi_obs_num
$m = $copy_into->{dataset}->Search("(3006,0080)[<0>](3006,0082)");
my $largest_roi_obs_num = 0;
for my $i (@{$m}){
  my $ri = $i->[0];
  my $ron = $copy_into->{dataset}->Get("(3006,0080)[$ri](3006,0082)");
  if($ron > $largest_roi_obs_num) { $largest_roi_obs_num = $ron }
}
my $roi_o_seq = $copy_into->{dataset}->Get("(3006,0080)");
my $largest_roi_o_seq_index = $#{$roi_o_seq};

#map roi_name to roi_num in from:
my %from_map;
$m = $copy_from->{dataset}->Search("(3006,0020)[<0>](3006,0022)");
for my $i (@{$m}){
  my $ri = $i->[0];
  my $roi_num = $copy_from->{dataset}->Get("(3006,0020)[$ri](3006,0022)");
  my $roi_name = $copy_from->{dataset}->Get("(3006,0020)[$ri](3006,0026)");
  $from_map{$roi_name} = $roi_num;
}
#map roi_name to roi_num in to:
my %to_map;
$m = $copy_into->{dataset}->Search("(3006,0020)[<0>](3006,0022)");
for my $i (@{$m}){
  my $ri = $i->[0];
  my $roi_num = $copy_into->{dataset}->Get("(3006,0020)[$ri](3006,0022)");
  my $roi_name = $copy_into->{dataset}->Get("(3006,0020)[$ri](3006,0026)");
  $to_map{$roi_name} = $roi_num;
}

# Now loop through commands and make a worklist of elements updates 
# and inserts for deferred application
# (if you apply in this loop, you are modifying the dataset you are scanning)
my %copied_roi_names;
my @copy_results;
my @deferred_commands;
command:
for my $i (@commands){
  my $old_roi_num;
  my $new_roi_num = ++$largest_roi_num;
  
  #First construct and insert new item in roi_seq
  #find the roi_index and roi_num of the relevant roi
  my $m = $copy_from->{dataset}->Search("(3006,0020)[<0>](3006,0026)", $i->[1]);
  unless($m && ref($m) eq "ARRAY" && $#{$m} == 0){
    if($m && ref($m) eq "ARRAY"){
      if($#{$m} < 0){
        print STDERR "Roi named $i->[1] not found in roi_seq\n";
      } else {
        print STDERR "Roi named $i->[1] is not unique in roi_seq\n";
      }
    } elsif($m){
      print STDERR "Search returned bad result for Roi named $i->[1]" .
       " in roi_seq\n";
    } else {
      print STDERR "Roi named $i->[1] not found in roi_seq\n";
    }
    next command;
  }
  my $ori = $m->[0]->[0];
  $old_roi_num = $copy_from->{dataset}->Get("(3006,0020)[$ori](3006,0022)");
  my $old_roi_ent = $copy_from->{dataset}->Get("(3006,0020)[$ori]");
  my $nri = ++$largest_roi_seq_index;
  ###
  #  $ori = old roi index
  #  $old_roi_num = old roi number
  #  $new_roi_num = new_roi_number
  #  $nri = new roi index
  #  $old_roi_ent = content of sequence element (dataset to be modified);
  my $command_hand = {
    type => "InsertModifiedDataset",
    ds => $old_roi_ent,
    commands => [],
    element => "",
  };
  if($i->[0] eq "CopyAndRename"){
     push @{$command_hand->{commands}}, ["Insert", "(3006,0026)", $i->[2]];
  }
  push @{$command_hand->{commands}}, ["Insert", "(3006,0022)", $new_roi_num];
  $copied_roi_names{$i->[1]} = 1;

  #insert new roi_seq_entry
  $command_hand->{element} = "(3006,0020)[$nri]";
  push(@deferred_commands, $command_hand);
  
  push(@copy_results, [$old_roi_num, $new_roi_num]);

  #Next copy relevant entry in roi_contour seq
  my $orci;
  my $nrci = ++$largest_roi_c_seq_index;
  $m = $copy_from->{dataset}->Search("(3006,0039)[<0>](3006,0084)",
    $old_roi_num);
  if($m && ref($m) eq "ARRAY" && $#{$m} == 0){
    $orci = $m->[0]->[0];
  } else {
    if($m && ref($m) eq "ARRAY"){
      if($#{$m} < 0){
        print STDERR "Roi number $old_roi_num not found in roi_seq\n";
      } else {
        print STDERR "Roi number $old_roi_num is not unique in roi_seq!!!!\n";
      }
    } elsif($m){
      print STDERR "Search returned bad result for Roi number $old_roi_num" .
       " in roi_seq\n";
    } else {
      print STDERR "Roi number $old_roi_num not found in roi_seq\n";
    }
  }
  if(defined $orci){
    push(@deferred_commands,
      {
        type => "InsertModifiedDataset",
        ds => $copy_from->{dataset}->Get("(3006,0039)[$orci]"),
        element => "(3006,0039)[$nrci]",
        commands => [
          ["Insert", "(3006,0084)", $new_roi_num],
        ],
      });
  }

  #Next find and copy all roi_observations;
  $m = $copy_from->{dataset}->Search("(3006,0080)[<0>](3006,0084)", 
    $old_roi_num);
  if($m && ref($m) eq "ARRAY"){
    for my $o (@{$m}){
      my $oroi = $o->[0];
      my $old_obs = $copy_from->{dataset}->Get("(3006,0080)[$oroi]");
      my $new_obs_num = ++$largest_roi_obs_num;
      my $nroi = ++$largest_roi_o_seq_index;
      push(@deferred_commands, {
        type => "InsertModifiedDataset",
        ds => $old_obs,
        element => "(3006,0080)[$nroi]",
        commands => [
          ["Insert", "(3006,0082)", $new_obs_num],
          ["Insert", "(3006,0084)", $new_roi_num],
        ],
      });
    }
  }
}
#now apply deferred changes
deferred_command:
for my $c (@deferred_commands){
  unless($c->{type} eq "InsertModifiedDataset") {
    for my $i (sort keys %$c){
      print STDERR "\t$i: $c->{$i}\n";
    }
    next deferred_command;
  }
  modification:
  for my $i (@{$c->{commands}}){
    unless($i->[0] eq "Insert") {
      print STDERR "Unknown modification [";
      for my $m (0 .. $#{$i}){
        print STDERR "$i->[$m]";
        if($m != $#{$i}){ print ", " }
      }
      print STDERR "]\n";
      next modification;
    }
    $c->{ds}->Insert($i->[1], $i->[2]);
  }
  $copy_into->{dataset}->Insert($c->{element}, $c->{ds});
}
#now find all mapped roi_numbers
my @mapped_results;
for my $i (keys %from_map){
  unless(exists $copied_roi_names{$i}){
    if(
      exists($to_map{$i}) &&
      $from_map{$i} ne $to_map{$i}
    ){
      push(@mapped_results, [$from_map{$i}, $to_map{$i}]);
    }
  }
}
$copy_into->{dataset}->WritePart10($new_file, $copy_into->{xfr_stx}, "POSDA");
#New SOP: <sop_instance_uid>
#New File: <file_name>
#Copied ROI: <old_roi_num> <new_roi_num>
print "New SOP: $new_uid\n";
print "New File: $new_file\n";
print "Mapped Struct UID: $mapped_uid\n";
for my $i (@copy_results){
  print "Copied ROI: $i->[0] $i->[1]\n";
}
for my $i (@mapped_results){
  print "Mapped ROI: $i->[0] $i->[1]\n";
}

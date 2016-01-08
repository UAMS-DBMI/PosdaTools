#!/usr/bin/perl -w 
#$Source: /home/bbennett/pass/archive/Posda/bin/RelinkDose.pl,v $
#$Date: 2012/11/13 17:42:26 $
#$Revision: 1.2 $
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
Help for RelinkDose.pl:
If the first argument is "-h" it produces this output, explaining its usage,
otherwise...
The first argument is the name of a file which must a DICOM RTDOSE.
The second argument is the directory in which the new, relinked dose file is
to be written.  The new dose will have a new SOP Instance UID.

This script receives input from <STDIN>.  This input consists of lines in the
following format:
Map Plan Ref: <from sop> <to sop>
Map Struct Ref: <from sop> <to sop>
Map Roi Num in Struct: <struct sop> <from num> <to num>

Any of these lines may repeat, to establish multiple mappings.

"Map Roi Num in Struct" lines may only appear if preceded by a "Map Struct Ref"
line which maps the same structure sop. This is not enforced by this script
but may result in bad mappings if it occurs...

If a new structure set is written, this script will produce two output lines.
The first give the UID of the new dose, the second its file name:
New SOP: <sop_instance_uid>
New File: <file_name>

If the dose has ROIs for which the roi_numbers are relinked, then it will
also produce lines of the form:
ROI translation: <from_roi_num> <to_roi_num>

If no mappings are performed, then this script will produce no output.

There may be a lot of messages on STDERR.
EOF
  exit;
}
my $here = getcwd;
my $dose = shift @ARGV;
my $dir = shift @ARGV;
unless(-f $dose) { die "$dose is not a file" }
unless(-d $dir) { die "$dir is not a directory" }
my $try = Posda::Try->new($dose);
unless($try && exists $try->{dataset}){ die "$dose is not a DICOM file" }
my $modality = $try->{dataset}->Get("(0008,0060)");
unless($modality eq "RTDOSE"){ die "$dose is not an RTDOSE ($modality)" }
my $new_uid = Posda::UUID::GetUUID;
my %PlanMappings;
my %StructureMappings;
my %RoiMappings;
while(my $line = <STDIN>){
  chomp $line;
  if($line =~ /^Map Plan Ref:\s+(\S+)\s+(\S+)\s*$/){
    my $old_uid = $1; my $new_uid = $2;
    $PlanMappings{$old_uid} = $new_uid;
  } elsif($line =~ /^Map Struct Ref:\s+(\S+)\s+(\S+)\s*$/){
    my $old_uid = $1; my $new_uid = $2;
    $StructureMappings{$old_uid} = $new_uid;
  } elsif($line =~ /^Map Roi Num in Struct:\s+(\S+)\s+(\S+)\s+(\S+)\s*$/){
    my $uid = $1; my $old_roi_num = $2; my $new_roi_num = $3;
    $RoiMappings{$1}->{$2} = $3;
  } else { print STDERR "Unparsed input line:\n\t\"$line\"\n"; }
}
my $is_mapped = 0;
my $this_plan_ref = $try->{dataset}->Get("(300c,0002)[0](0008,1155)");
my $this_struct_ref = $try->{dataset}->Get("(300c,0060)[0](0008,1155)");
if(exists $PlanMappings{$this_plan_ref}){
  $is_mapped = 1;
  $try->{dataset}->Insert("(300c,0002)[0](0008,1155)",
    $PlanMappings{$this_plan_ref});
} else{
}
if(exists $StructureMappings{$this_struct_ref}){
  $is_mapped = 1;
  $try->{dataset}->Insert("(300c,0060)[0](0008,1155)",
    $StructureMappings{$this_struct_ref});
} else {
}
if(exists $RoiMappings{$this_struct_ref}){
  for my $from (keys %{$RoiMappings{$this_struct_ref}}){
    my $m = $try->{dataset}->Search(
      "(3004,0050)[<0>](3004,0060)[<1>](3006,0084)", $from);
    if($m && ref($m) eq "ARRAY"){
      for my $i (@{$m}){
        $try->{dataset}->Insert(
          "(3004,0050)[$i->[0]](3004,0060)[$i->[1]](3006,0084)",
          $RoiMappings{$this_struct_ref}->{$from});
        print STDERR
          "ROI Translation: $from $RoiMappings{$this_struct_ref}->{$from}\n";
      }
    }
  }
}
unless($is_mapped) { exit }
$try->{dataset}->Insert("(0008,0018)", $new_uid);
my $new_file = "$dir/RTD_$new_uid.dcm";
$try->{dataset}->WritePart10($new_file, $try->{xfr_stx}, "POSDA");
#New SOP: <sop_instance_uid>
#New File: <file_name>
print "New SOP: $new_uid\n";
print "New File: $new_file\n";

#!/usr/bin/perl -w
#  
# Written 2010 09 22 by Erik Strom.
#
#Copyright 2011, Bill Bennett, Erik Strom.
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
#  This program takes a directory of DICOM files.  
#  Checks that there is one plan with mult fractions and the corsponding Dose file.  
#   (if not - exit with error). 
#  Check for : 
#    for each fraction group: you should have a dose file, which points to that plan & fraction group.  
#    and each dose should have a dose summation type of FRACTION
#
#
#  Usage: SplitFractionatedPlanAndDose.pl  <DICOM src dir> 
#
use Cwd;
use strict;
use Posda::Dataset;
use Posda::Find;
use Posda::Try;
use Posda::UUID;
use File::Copy;

Posda::Dataset::InitDD();

unless ( $#ARGV == 0 && $ARGV[0] ne "--help") { 
  print "Usage: SplitFractionatedPlanAndDose.pl <dir with DICOM case >\n";
  print "  This script converts a DICOM case where the Plan file has mult fraction groups\n";
  print "  to a case with mult Plan files, one for each fraction group.\n";
  print "  Dose files are modified correspondingly.\n"; 
  print "  The original plan & dose files are moved to a sub dir called: old_plan_dose_files\n";
  exit -1;
}
my $src_dir = $ARGV[0]; unless($src_dir=~/^\//){$src_dir=getcwd."/$src_dir"}
unless (-d $src_dir) {die "Invalid dir: $src_dir"};
print "DICOM case dir: $src_dir.\n";

sub CheckFile{
  my($plans, $doses) = @_;
  my $foo = sub {
    my($try) = @_;
    unless(exists $try->{dataset}){ return }
    my $ds = $try->{dataset};
    my $df = $try->{meta_header};
    my $ds_digest = $try->{dataset_digest};
    my $modality = $ds->Get("(0008,0060)");
    # 
    # RTIMAGE  = Radiotherapy Image 
    # RTDOSE  = Radiotherapy Dose 
    # RTSTRUCT = Radiotherapy Structure Set 
    # RTPLAN  = Radiotherapy Plan
    # CT = ct image
    if (defined $modality ) {
      print "  File: $try->{filename}, Modality: $modality.\n";
      if ($modality eq "RTDOSE") {
        print "    Found Dose: File: $try->{filename}.\n";

        my $summation_type = $ds->Get("(3004,000a)");
        my $plan_sop_class_uid = $ds->Get("(300c,0002)[0](0008,1150)");
        my $plan_sop_instance_uid = $ds->Get("(300c,0002)[0](0008,1155)");
        my $ref_fg_num =  $ds->Get("(300c,0002)[0](300c,0020)[0](300c,0022)");
        $doses->{$try->{filename}} = {
          filename => $try->{filename}, 
          summation_type => $summation_type,
          plan_sop_class_uid => $plan_sop_class_uid,
          plan_sop_instance_uid => $plan_sop_instance_uid,
          ref_fg_num => $ref_fg_num,
          ds => $try->{dataset},
        };
        #  fraction group = 
        #  what fraction group does it point to,
        #  what plan does it point to.. 

        #  dose summation type 
        #  point to plan & fraction group...
        #  plan: num fractions groups, 

      } elsif  ($modality eq "RTPLAN") {
        print "    Found Plan: File: $try->{filename}.\n";
        my $plan_sop_class_uid = $ds->Get("(0008,0016)");
        my $plan_sop_instance_uid = $ds->Get("(0008,0018)");
        $plans->{$plan_sop_instance_uid}->{filename} = $try->{filename};
        $plans->{$plan_sop_instance_uid}->{sop_class_uid} = $plan_sop_class_uid;
        $plans->{$plan_sop_instance_uid}->{xfr_stx} = $try->{xfr_stx};
        my $m = $ds->Search("(300a,0070)[<0>](300a,0071)"); # search for fraction groups..
        for my $i (@$m){
           my $fraction_num = $ds->Get("(300a,0070)[$i->[0]](300a,0071)");
           $plans->{$plan_sop_instance_uid}->{fraction_group}->{$fraction_num} = $fraction_num; 
           #$plans->{$plan_sop_instance_uid}->{fg_num}->{$fraction_num} = $fraction_num; 
           print "      Plan fraction group: $fraction_num.\n";
        }
      }
    }
  };
  return $foo;
}

my $plans = {};
my $doses = {};
my $foo = CheckFile($plans, $doses);
print "Interrogating Plan & Dose files.\n";
Posda::Find::DicomOnly($src_dir, $foo);

#  
#  Check pre conditions:  
#  Checks that there is one plan  - check
#    with mult fractions  - check
#    and the corsponding Dose file.  
#  Checks that for each dose file:
#    each referenced RT Plan sop class uid and instance uid are in the plan file. - check. 
#  Check for : 
#    The # of fraction groups in the plan file is equal to the # of dose files. - check.
#    and each dose should have a dose summation type of FRACTION - check.
#
print "Checking pre conditions.\n";
my $num_plans = scalar keys %$plans;
# print "Number of plans in directory: $num_plans.\n";
unless ($num_plans == 1) {die "This script only handles 1 plan file."};

my $plan_sop_class_uid;
my $plan_sop_instance_uid;
my $num_fractions;
foreach my $plan (keys %$plans) {
  print "  Orig Plan sop_instance_uid: $plan.\n";
  $plan_sop_class_uid = $plans->{$plan}->{sop_class_uid};
  $plan_sop_instance_uid = $plan;
  $num_fractions = scalar keys %{$plans->{$plan}->{fraction_group}};
  unless ($num_fractions > 1) {die "This script requires that plans have more than one fraction group, found: $num_fractions."};
  foreach my $fraction_num (keys %{$plans->{$plan}->{fraction_group}}) {
    print "    Orig Plan fraction group #: $fraction_num.\n";
  }
}
my $plan_filename =  $plans->{$plan_sop_instance_uid}->{filename};

my $num_dose_files = 0;
foreach my $dose (keys %$doses) {
  $num_dose_files++;
  print "  Checking orig Dose - filename: $dose.\n";
  my $summation_type =  $doses->{$dose}->{summation_type};
  my $dose_plan_sop_class_uid = $doses->{$dose}->{plan_sop_class_uid};
  my $dose_plan_sop_instance_uid = $doses->{$dose}->{plan_sop_instance_uid};
  my $ref_fg_num = $doses->{$dose}->{ref_fg_num};
  unless ($summation_type eq "FRACTION") {die "This script requires all dose to have summation type of FRACTION, found $summation_type." };
  unless ($plan_sop_class_uid eq $dose_plan_sop_class_uid) {die "Plan sop class uid ($plan_sop_class_uid) does not match dose referenced RT Plan: sop class uid ($dose_plan_sop_class_uid)."} ;
  unless ($plan_sop_instance_uid eq $dose_plan_sop_instance_uid) {die "Plan sop instance uid ($plan_sop_instance_uid) does not match dose referenced RT Plan: sop instance uid ($dose_plan_sop_instance_uid)."} ;
  unless (exists $plans->{$plan_sop_instance_uid}->{fraction_group}->{$ref_fg_num}) {die "Plan does not have matching fraction group number: $ref_fg_num."};
}

#
# Now create new Plan & dose files.  
# Make 2 plan files each with only one fraction group.
#   Each new plan file will need a new plan sop instance uid.
#   Del beam that are not part of this fraction group.
# Modify each dose file to have the correct referencing plan sop instance uid.
#   Change summation type to be "PLAN"
#   Del Referenced Fraction Group Sequence
#

print "Creating new Plan & Dose files.\n";
my $plan_postfix = "A";
my $max_length_of_SH = 16;
if (exists $Posda::Dataset::DD->{VRDesc}->{SH}->{len}) {
  $max_length_of_SH = $Posda::Dataset::DD->{VRDesc}->{SH}->{len};
} 
my $max_length_of_LO = 64;
if (exists $Posda::Dataset::DD->{VRDesc}->{LO}->{len}) {
  $max_length_of_LO = $Posda::Dataset::DD->{VRDesc}->{LO}->{len};
} 

foreach my $dose (keys %$doses) {
  my $summation_type =  $doses->{$dose}->{summation_type};
  my $dose_plan_sop_class_uid = $doses->{$dose}->{plan_sop_class_uid};
  my $dose_plan_sop_instance_uid = $doses->{$dose}->{plan_sop_instance_uid};
  my $ref_fg_num = $doses->{$dose}->{ref_fg_num};
  my $dose_ds =  $doses->{$dose}->{dataset};
  print "  Dose - Reference FG: $ref_fg_num, filename: $dose.\n";
  # create new plan file...
  my $new_plan = Posda::Try->new($plan_filename);
  unless (defined $new_plan) {die "Could not read plan file: $plan_filename.";}
  my $plan_ds = $new_plan->{dataset};
  unless (defined $plan_ds) {die "Plan has no dicom data: $plan_filename.";}
  my $new_plan_sop_instance_uid = Posda::UUID::GetUUID();
  $plan_ds->Insert("(0008,0018)",$new_plan_sop_instance_uid);
  print "    Creating new Plan with SOP instance UID: $new_plan_sop_instance_uid.\n";
  # Next item to get is the index number in the fraction group sequence 
  #  for the fraction group referenced by this dose file.
  # print "searching for: (300a,0070)[<0>](300a,0071).\n";
  my $index = $plan_ds->Search("(300a,0070)[<0>](300a,0071)",$ref_fg_num);
  my $plan_ref_fg_num_index;
  $plan_ref_fg_num_index = $index->[0]->[0];

  # Now get all of the fraction group items for this fraction group index
  #  so we can add them later as index [0]
  # print "searching for fraction group items: (300a,0070)[$plan_ref_fg_num_index]\n";
  my $plan_fg_items = $plan_ds->Get("(300a,0070)[$plan_ref_fg_num_index]");

  # Get the referenced beam numbers in in the fraction group 
  #   with index: $plan_ref_fg_num_index
  # print "searching for referenced beam numbers: (300a,0070)[$plan_ref_fg_num_index](300c,0004)[<0>](300c,0006)\n";
  my $ref_beam_numbers = $plan_ds->Search("(300a,0070)[$plan_ref_fg_num_index](300c,0004)[<0>](300c,0006)");
  my $plan_beam_items = {};
  for my $i (@{$ref_beam_numbers}) {
    my $rbn = $plan_ds->Get("(300a,0070)[$plan_ref_fg_num_index](300c,0004)[$i->[0]](300c,0006)");
    # Now get the beam information for these referenced beams from (300a,00b0)
    my $beam_search = $plan_ds->Search("(300a,00b0)[<0>](300a,00c0)", $rbn);
    my $beam_index = $beam_search->[0]->[0];
    print "    Getting data for Ref beam #: $rbn, with index: $beam_index.\n";
    # Now save off this beam info to add back later.
    $plan_beam_items->{$rbn} = $plan_ds->Get("(300a,00b0)[$beam_index]");
  }

  # Del all fraction group info & re-add...
  $plan_ds->Delete("(300a,0070)");
  $plan_ds->Insert("(300a,0070)[0]", $plan_fg_items);
  $plan_ds->Insert("(300a,0070)[0](300a,0071)","1");

  # Del all beam info, re-add...
  $plan_ds->Delete("(300a,00b0)");
  my $beam_index = 0;
  for my $beam (sort keys %{$plan_beam_items}) {
    print "    Adding Beam info for beam #: $beam, with index: $beam_index.\n";
    $plan_ds->Insert("(300a,00b0)[$beam_index]",$plan_beam_items->{$beam});
    $beam_index++;
  }
  # Update Plan label to be unique from original plan, some ITC tools need this.
  my $plan_label = $plan_ds->Get("(300a,0002)");
  $plan_label = substr($plan_label,0,$max_length_of_SH);
  print "    Original plan label: $plan_label.\n";
  if (length($plan_label) < $max_length_of_SH) {
    $plan_label .= $plan_postfix;
  } else {
    substr($plan_label,$max_length_of_SH-1,1,$plan_postfix);
  }
  $plan_ds->Insert("(300a,0002)",$plan_label);
  print "    New plan label: $plan_label.\n";

  # Update Plan name to be unique from original plan, some ITC tools need this.
  my $plan_name = $plan_ds->Get("(300a,0003)");
  $plan_name = substr($plan_name,0,$max_length_of_LO);
  print "    Original plan name: $plan_name.\n";
  if (length($plan_name) < $max_length_of_LO) {
    $plan_name .= $plan_postfix;
  } else {
    substr($plan_name,$max_length_of_LO-1,1,$plan_postfix);
  }
  $plan_ds->Insert("(300a,0003)",$plan_name);
  print "    New plan name: $plan_name.\n";

  $plan_postfix++;
  print "    Writing new Plan file...\n";
  $plan_ds->WritePart10($src_dir . "/" . $plan_ds->CanonicalFileName, $plans->{$plan_sop_instance_uid}->{xfr_stx}, "POSDA",undef, undef);

  # Create new Dose file...
  my $new_dose = Posda::Try->new($dose);
  unless (defined $new_dose) {die "Could not read dose file: $dose.";}
  my $new_dose_sop_instance_uid = Posda::UUID::GetUUID();
  $new_dose->{dataset}->Insert("(0008,0018)",$new_dose_sop_instance_uid);
  $new_dose->{dataset}->Insert("(3004,000a)","PLAN"); # replace FRACTION
  $new_dose->{dataset}->Insert("(300c,0002)[0](0008,1155)",$new_plan_sop_instance_uid);
  print "    Writing new Dose file...\n";
  $new_dose->{dataset}->WritePart10($src_dir . "/" . $new_dose->{dataset}->CanonicalFileName, $new_dose->{xfr_stx} , "POSDA",undef, undef);

  # my $foo = $plan_ds->Search("(300a,00b0)[<0>](300a,00c0)","1");
}

# Now move old plan & dose file sto saved directory...
my $dir = $src_dir . "/old_plan_dose_files";
unless (-d $dir) {mkdir  $dir};
unless (-d $dir) {die "could not make save dir /old_plan_dose_files to save the old plan & dose files."};
foreach my $dose (keys %$doses) {
  if ($dose =~ /^(.+)\/([^\/]*)$/ ) {
    my $path = $1;
    my $base = $2;
    move($dose,"$dir/$base");
  } else {
    print "Was not able to move dose file: $dose.\n";
  }
}
if ($plan_filename =~ /^(.+)\/([^\/]*)$/ ) {
  my $path = $1;
  my $base = $2;
  move($plan_filename,"$dir/$base");
} else {
  print "Was not able to move plan file: $plan_filename.\n";
}

exit 0;

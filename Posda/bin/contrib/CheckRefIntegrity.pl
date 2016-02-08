#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Cwd;
use strict;
use Posda::Find;
my %ImagesByZ;        #  Map a z-value to an Image file_name
my %ImagesByFile;     #  Map a file-name to a UID
my %ImagesByUid;     #  Look up values in Image by UID
my %SS;               #  Structure Set by UID;
my %Plan;             #  Plan or Ion Plan by UID;
my %Dose;             #  Dose by UID
Posda::Dataset::InitDD();

my $usage = "usage: $0 <dir>";
unless($#ARGV==0){die $usage}
my $DIR = $ARGV[0];
unless(
	$DIR =~ /^\//
) {
	$DIR = getcwd."/$DIR";
}
#
# Callback to populate Data structures
#
my $file_count = 0;
my $total_file_count = 0;
my $finder = sub {
  my($file_name, $df, $ds, $size, $xfr_stx, $errors) = @_;
  print ".";
  $file_count += 1;
  $total_file_count += 1;
  if($file_count >= 80){
    print "\n";
    $file_count = 0;
  }
  my $modality = $ds->ExtractElementBySig("(0008,0060)");
  my $sop_class = $ds->ExtractElementBySig("(0008,0016)");
  my $UID = $ds->ExtractElementBySig("(0008,0018)");
  my $Study_UID = $ds->ExtractElementBySig("(0020,000d)");
  my $Series_UID = $ds->ExtractElementBySig("(0020,000e)");
  my $z = $ds->ExtractElementBySig("(0020,0032)[2]");
  my $for_uid = $ds->ExtractElementBySig("(0020,0052)");
  # is it an image which may be referenced in an RT Struct?
  if(defined $z && $modality ne "RTDOSE"){
    if(defined $ImagesByZ{$z}){
      print "\nError: two Images at $z: $ImagesByZ{$z} and $file_name\n";
    }
    $ImagesByZ{$z} = $file_name;
    $ImagesByFile{$file_name} = $UID;
    if(defined $ImagesByUid{$UID}){
      print "\nError: Two Images with same UID ($UID):\n" .
        "\t$file_name\n\t$ImagesByUid{$UID}->{file}\n";
      return;
    }
    $ImagesByUid{$UID} = {
      file => $file_name,
      modality => $modality,
      sop_class => $sop_class,
      z => $z,
      study_uid => $Study_UID,
      series_uid => $Series_UID,
      for_uid => $for_uid,
    };
  # is it an RT Struct?
  } elsif($modality eq "RTSTRUCT"){
    if(exists $SS{$UID}){
      print "\nError: Two SS's with same UID ($UID):\n" .
        "\t$file_name\n\t$SS{$UID}->{file}\n";
      return;
    }
    $SS{$UID} = {
      file => $file_name,
      modality => $modality,
      sop_class => $sop_class,
      study_uid => $Study_UID,
      series_uid => $Series_UID,
    };
    ####
    ##   Go through the "Referenced Frame of Reference" Sequence
    ##   Building a Volume  ($SS{$UID}->{Volume}
    #####
    my $ct_vol_ref = $ds->Substitutions(
       "(3006,0010)[<0>](3006,0012)[<1>](3006,0014)[<2>]" .
       "(3006,0016)[<3>](0008,1155)"
    );
    vol_element:
    for my $i (@{$ct_vol_ref->{list}}){
      my $for_i = $i->[0];
      my $st_i = $i->[1];
      my $sr_i = $i->[2];
      my $img_i = $i->[3];

      my $for_ele = "(3006,0010)[$for_i](0020,0052)";
      my $for = $ds->ExtractElementBySig($for_ele);

      my $study_ele = "(3006,0010)[$for_i](3006,0012)[$st_i]" .
        "(0008,1155)";
      my $ref_study = $ds->ExtractElementBySig($study_ele);

      my $series_ele = "(3006,0010)[$for_i](3006,0012)[$st_i]" .
        "(3006,0014)[$sr_i](0020,000e)";
      my $ref_series = $ds->ExtractElementBySig($series_ele);

      my $sop_cl_ele = "(3006,0010)[$for_i](3006,0012)[$st_i]" .
        "(3006,0014)[$sr_i](3006,0016)[$img_i](0008,1150)";
      my $ref_sop_cl = $ds->ExtractElementBySig($sop_cl_ele);

      my $sop_inst_ele = "(3006,0010)[$for_i](3006,0012)[$st_i]" .
        "(3006,0014)[$sr_i](3006,0016)[$img_i](0008,1155)";
      my $ref_sop_inst = $ds->ExtractElementBySig($sop_inst_ele);

      if(exists($SS{$UID}->{Volume}->{$ref_sop_inst})){
        print "\nError: $UID is referenced more than once in " .
          "ref frame of ref sequence\n";
        next vol_element;
      }
      $SS{$UID}->{Volume}->{$ref_sop_inst} = {
         file => $file_name,
         study => $ref_study,
         series => $ref_series,
         sop_cl => $ref_sop_cl,
         for => $for,
      };
      unless(defined $for) { die "for is undefined" }
      $SS{$UID}->{VolumeByFor}->{$for}->{$ref_sop_inst} = 1;
    }
    ####
    ##   Go through the "Structure Set ROI" Sequence
    ##   Building a hash of ROI to frame of reference
    ##   $SS{$UID}->{RoiToFor};
    #####
    my $roi_ref = $ds->Substitutions("(3006,0020)[<0>](3006,0022)");
    for my $i (@{$roi_ref->{list}}){
      my $roi_i = $i->[0];
      my $roi_num_ele = "(3006,0020)[$roi_i](3006,0022)";
      my $roi_num = $ds->ExtractElementBySig($roi_num_ele);

      my $roi_for_ele = "(3006,0020)[$roi_i](3006,0024)";
      my $roi_for = $ds->ExtractElementBySig($roi_for_ele);
      $SS{$UID}->{RoiToFor}->{$roi_num} = $roi_for;
    }
    ####
    ##   Go through the "ROI Contour" Sequence
    ##   Building a Volume  ($SS{$UID}->{Volume}
    ##   Adding references to ROI list;
    #####
    my $ct_cont_ref = $ds->Substitutions(
      "(3006,0039)[<0>](3006,0040)[<1>](3006,0042)"
    );
    contour:
    for my $i (@{$ct_cont_ref->{list}}){
      my $roi_i = $i->[0];
      my $cont_i = $i->[1];

      my $geo_type_ele = "(3006,0039)[$roi_i](3006,0040)[$cont_i]" .
        "(3006,0042)";
      my $geo_type = $ds->ExtractElementBySig($geo_type_ele);
      unless($geo_type eq "CLOSED_PLANAR"){
        print "\nIgnoring roi $roi_i, contour $cont_i, " .
          "geometric type $geo_type\n";
        next contour;
      }

      my $ref_sop_cl_ele = "(3006,0039)[$roi_i](3006,0040)[$cont_i]" .
        "(3006,0016)[0](0008,1150)";
      my $ref_sop_cl = $ds->ExtractElementBySig($ref_sop_cl_ele);

      my $ref_sop_inst_ele = "(3006,0039)[$roi_i](3006,0040)[$cont_i]" .
        "(3006,0016)[0](0008,1155)";
      my $ref_sop_inst = $ds->ExtractElementBySig($ref_sop_inst_ele);

      my $z_ele = "(3006,0039)[$roi_i](3006,0040)[$cont_i]" .
        "(3006,0050)[2]";
      my $z = $ds->ExtractElementBySig($z_ele);
      my $num_points = $ds->ExtractElementBySig(
        "(3006,0039)[$roi_i](3006,0040)[$cont_i](3006,0046)");
      if(
        $num_points == 0
      ){
        if(defined $ref_sop_inst){
          print "\nROI $roi_i, cont $cont_i has no points (but image " .
            "pointer) in file:\n" .
            "$file_name";
        }
        next contour;
      }
      if($ref_sop_inst && !defined($z)){
        print "\nIgnoring ref_sop_inst and no z " . 
          "for roi $roi_i, cont_i $cont_i " .
          "in file:\n $file_name\n";
        next contour;
      }
      my $ref_roi_num_ele = "(3006,0039)[$roi_i](3006,0084)";
      my $ref_roi_number = $ds->ExtractElementBySig($ref_roi_num_ele);
      unless(defined($ref_roi_number)){
        print "\nIgnoring roi $roi_i, cont_i $cont_i no ref_roi_num\n" .
          "in file:\n $file_name\n";
        next contour;
      }

      $SS{$UID}->{roi}->[$roi_i]->{contours}->[$cont_i] = {
        ref_sop_cl => $ref_sop_cl,
        ref_sop_inst => $ref_sop_inst,
        z => $z,
        ref_roi_number => $ref_roi_number,
      };
    }
  # is it an RT Plan? (or RT Ion Plan)
  } elsif($modality eq "RTPLAN" || $modality eq "RTIONPLAN"){
    if($modality eq "RTIONPLAN"){
      print "Error: $file_name has modality of RTIONPLAN (should be RTPLAN)\n";
    }
    if(exists $Plan{$UID}){
      print "Error: Two Plan's with same UID ($UID):\n" .
        "\t$file_name\n\t$Plan{$UID}->{file}\n";
      return;
    }
    my $ref_ss_class = $ds->ExtractElementBySig(
      "(300c,0060)[0](0008,1150)"
    );
    my $ref_ss_inst = $ds->ExtractElementBySig(
      "(300c,0060)[0](0008,1155)"
    );
    $Plan{$UID} = {
      file => $file_name,
      modality => $modality,
      sop_class => $sop_class,
      study_uid => $Study_UID,
      series_uid => $Series_UID,
      ref_ss_class => $ref_ss_class,
      ref_ss_inst => $ref_ss_inst,
    };
  # is it an RT Dose?
  } elsif($modality eq "RTDOSE"){
    if(exists $Dose{$UID}){
      print "Error: Two Dose's with same UID ($UID):\n" .
        "\t$file_name\n\t$Dose{$UID}->{file}\n";
      return;
    }
    my $ref_plan_class = $ds->ExtractElementBySig(
      "(300c,0002)[0](0008,1150)"
    );
    my $ref_plan_inst = $ds->ExtractElementBySig(
      "(300c,0002)[0](0008,1155)"
    );
    $Dose{$UID} = {
      file => $file_name,
      modality => $modality,
      sop_class => $sop_class,
      study_uid => $Study_UID,
      series_uid => $Series_UID,
      ref_plan_class => $ref_plan_class,
      ref_plan_inst => $ref_plan_inst,
    };
  }
};

#
# Populate Data structures by finding files and Calling Callback
#
print "Processing Files and building data\n";
Posda::Find::SearchDir($DIR, $finder);
if($file_count != 0){
  print "\n";
}
print "Processed $total_file_count files\n";

#
# Look for problems in SS Contours
#
print "Validating SS Contours\n";
for my $ss (sort keys %SS){
  print "SS: $SS{$ss}->{file}\n";
  for my $roi_i (0 .. $#{$SS{$ss}->{roi}}){
    unless(exists($SS{$ss}->{roi}->[$roi_i])){ next };
    my $roi = $SS{$ss}->{roi}->[$roi_i];
    contour:
    for my $contour_i(0 .. $#{$roi->{contours}}){
      unless(defined $roi->{contours}->[$contour_i]){ next contour }
      my $contour = $roi->{contours}->[$contour_i];
      my $ref_sop_cl = $contour->{ref_sop_cl};
      my $ref_sop_inst = $contour->{ref_sop_inst};
      my $z = $contour->{z};
      my $ref_roi_number = $contour->{ref_roi_number};
      my $ref_for = "";
      unless(exists($SS{$ss})){ die "????" }
      if(exists $SS{$ss}->{RoiToFor}->{$ref_roi_number}){
        #print "roi $roi_i contour $contour_i has roi_number which " .
        #  "maps to frame of reference\n";
        $ref_for = $SS{$ss}->{RoiToFor}->{$ref_roi_number};
        if(defined $ref_for) {
           unless(defined $SS{$ss}->{VolumeByFor}->{$ref_for}){
             print "Error: roi $roi_i references a FOR not in the Volume\n";
           }
         } else {
          print "Error: roi $roi_i has no FOR defined\n";
        }
      } else {
        print "Error: roi $roi_i, contour $contour_i references undefined " .
          "roi $ref_roi_number\n";
      }
      unless(defined $ref_sop_inst){
        print "ROI: $roi_i, contour: $contour_i doesn't reference an image\n";
        next contour;
      }
      if(exists($SS{$ss}->{Volume}->{$ref_sop_inst})){
        my $Vol_ref = $SS{$ss}->{Volume}->{$ref_sop_inst};
        if($ref_for eq $Vol_ref->{for}){
          #print "roi $roi_i contour $contour_i for matches volume\n";
        } else {
          print "Error: roi $roi_i contour $contour_i FOR ($ref_for) " .
            "doesn't match " .
            "FOR ($Vol_ref->{for}) in Volume\n";
        }
        if($ref_sop_cl eq $Vol_ref->{sop_cl}){
          #print "roi $roi_i contour $contour_i matches sop_class in volume\n";
        } else {
          print "Error: sop class in volume doesn't match sop class for " .
            "same UID in roi $roi_i contour $contour_i\n";
        }
        if(exists($ImagesByUid{$ref_sop_inst})){
          $ImagesByUid{$ref_sop_inst}->{visited} = 1;
          if($ref_for eq $ImagesByUid{$ref_sop_inst}->{for_uid}){
            #print "roi $roi_i contour $contour_i matches FOR in image " .
            #  "instance\n";
          } else {
            print "Error: roi $roi_i contour $contour_i FOR doesn't " .
              "match that in image\n";
          }
          if(
            $ImagesByUid{$ref_sop_inst}->{sop_class} eq $ref_sop_cl
          ){
            #print "roi $roi_i contour $contour_i matches sop class in file";
          } else {
            print "Error: roi $roi_i contour $contour_i references " .
              "sop_class which doesn't match that in image file\n";
          }
          my $diff = abs($z - $ImagesByUid{$ref_sop_inst}->{z});
          if($diff <= 0.1){
            #print "Z in contour and image seem to match OK\n";
          } else {
            print "Error:  Difference between z ($z) in contour and " .
              "z in referenced image is $diff\n" .
              "\t$ImagesByUid{$ref_sop_inst}->{file}\n";
          }
          if($Vol_ref->{visited}){
            #print "Already visited Volume for previous roi contour\n";
          } else {
            $Vol_ref->{visited} = 1;
            if(
              $Vol_ref->{series} eq $ImagesByUid{$ref_sop_inst}->{series_uid}
            ){
              #print "series in Volume for roi $roi_i contour $contour_i " .
              #  "matches that in image\n";
            } else {
              print "Error: series in Volume for roi " .
                "$roi_i contour $contour_i " .
                "doesn't match that in image\n";
            }
            if(
              $Vol_ref->{study} eq $ImagesByUid{$ref_sop_inst}->{study_uid}
            ){
              #print "study in Volume for roi $roi_i contour $contour_i " .
              #  "matches that in image\n";
            } else {
              print "Error: study in Volume for roi " .
                "$roi_i contour $contour_i " .
                "doesn't match that in image\n";
            }
          }
        } else {
          print "Error: roi $roi_i contour $contour_i references an image " .
            "which can't be located\n";
        }
      } else {
        print "Error: roi $roi_i, contour $contour_i " .
          "references SOP instance which is not in volume\n";
      }
    }
  }
}
print "Finished Validating SS Contours\n";
print "Validating Remaining SS Volume\n";
for my $uid (keys %SS){
  print "SS: $SS{$uid}->{file}\n";
  for my $ref (keys %{$SS{$uid}->{Volume}}){
    if($SS{$uid}->{Volume}->{$ref}->{visited}){
      #print "Reference to $ref already visited\n";
    } else {
      if(exists $ImagesByUid{$ref}){
        $ImagesByUid{$ref}->{visited} = 1;
        #print "Volume references known image " .
        #  "(not referenced in contour)\n";
        if(
          $ImagesByUid{$ref}->{for_uid} eq 
          $SS{$uid}->{Volume}->{$ref}->{for}
        ){
          #print "FOR in volume matches FOR in referenced image\n";
        } else {
          print "Error: Volume with FOR " .
            "($SS{$uid}->{Volume}->{$ref}->{for} " .
            "references image with different FOR " .
            "($ImagesByUid{$ref}->{for_uid})\n" .
            "\tfile: $ImagesByUid{$ref}->{file}\n";
        }
      } else {
        print "Error: Volume references unknown image " .
          "(not referenced in contour)\n";
      }
    }
  }
}
print "Finished Validating Remaining SS Volume\n";
print "Look for unreferenced images\n";
for my $uid (keys %ImagesByUid){
  my $file = $ImagesByUid{$uid}->{file};
  if($ImagesByUid{$uid}->{visited}){
    #print "Image $file is referenced in SS\n";
  } else {
    print "Warning: Image $file is not referenced in SS\n";
  }
}
print "Finished looking for unreferenced images\n";
print "Validating Plan Linkages\n";
for my $uid (keys %Plan){
  my $plan = $Plan{$uid};
  if(
    exists($plan->{ref_ss_class}) &&
    defined($plan->{ref_ss_class}) &&
    $plan->{ref_ss_class} eq "1.2.840.10008.5.1.4.1.1.481.3" 
  ){
    print "plan $uid references a Structure Set\n";
    if(exists $SS{$plan->{ref_ss_inst}}){
      print "plan $uid references an existing Structure Set\n";
    } else {
      print "Error: plan $uid references an unknown Structure Set\n";
    }
  } else {
    print "Error: plan $uid doesn't reference a Structure Set\n";
  }
}
print "Finished Validating Plan Linkages\n";
print "Validating Dose Linkages\n";
for my $uid (keys %Dose){
  my $dose = $Dose{$uid};
  if($dose->{ref_plan_class} eq "1.2.840.10008.5.1.4.1.1.481.5"){
    print "dose $uid references a Plan\n";
  }elsif($dose->{ref_plan_class} eq "1.2.840.10008.5.1.4.1.1.481.8"){
    print "dose $uid references an Ion Plan\n";
  } else {
    print "Error: dose $uid doesn't reference a Plan or Ion Plan\n";
  }
  if(exists $Plan{$dose->{ref_plan_inst}}){
    print "dose $uid references an existing Plan (or Ion Plan)\n";
  } else {
    print "Error: dose $uid references an unknown Plan (or Ion Plan)\n";
  }
}
print "Finished Validating Dose Linkages\n";

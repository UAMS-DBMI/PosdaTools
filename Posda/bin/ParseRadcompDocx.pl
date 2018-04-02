#!/usr/bin/perl -w
use strict;
use JSON;
use Debug;
my $dbg = sub { print @_ };

my $SectionMarkers = {
  '^\* Submission Type' => "submission_type",
  '^\* Subject Identifiers' => "subject_identifiers",
  "^C.   Submitting Institution" => "submitting_institution",
  "^D.   Contact Information" => "contact_information",
  "^E. Submission Folder" => "submission_folder",
  "^F. Submission Detail:" => "submission_detail",
  "^G.   Treatment Planning System" => "treatment_planning_system",
  "^H.   Prescription and First Treatment Date" => "pres_treatment_date",
  "^I.   Dose Delivered Using:" => "dose_delivered_using",
  "^J.   Planning and Delivery Details:" => "planning_delivery_details",
  "^K.   Treatment Machine Used" => "treatment_machine",
  "^L.  Additional Comments" => "additional_comments",
  "^M. Form Submitter" => "form_submitter",
};
my $mode;
my %ResultsFirstPass;
my $collected_lines = [];
line:
while(my $line = <STDIN>){
  chomp $line;
  for my $k (keys %$SectionMarkers){
    if($line =~ /$k/){
      if($mode){
        $ResultsFirstPass{$mode} = $collected_lines;
        $collected_lines = [];
      }
      $mode = $SectionMarkers->{$k};
      next line;
    }
  }
  push @$collected_lines, $line;
}
if($mode){
  $ResultsFirstPass{$mode} = $collected_lines;
  $collected_lines = [];
}
my %SectionParsers = (
  submission_type => \&SubmissionTypeParser,
  subject_identifiers => \&SubjectIdentifierParser,
  submission_detail => \&SubmissionDetailParser,
  treatment_planning_system => \&TreatmentPlanningSystemParser,
  pres_treatment_date => \&PresTreatmentDateParser,
  dose_delivered_using => \&DoseDeliveredUsingParser,
  planning_delivery_details => \&PlanningDeliveryDetailsParser,
  treatment_machine => \&TreatmentMachineParser,
  additional_comments => \&AdditionalCommentsParser,
);
my %CollectedData;
for my $k (keys %SectionParsers){
  &{$SectionParsers{$k}}($k, \%ResultsFirstPass, \%CollectedData);
}
my $crunched = CrunchResults(\%CollectedData);
#print "Crunched Structure: ";
#Debug::GenPrint($dbg, \%$crunched, 1);
#print "\n";
my $json_text = to_json( $crunched, { ascii => 1, pretty => 1 } );
print $json_text;
sub CheckBoxFirst{
  my($line) = @_;
  my $remain = $line;
  my $r;
  while($remain){
    if($remain =~ /^\s*\(([\*\+])\)\s*FORMCHECKBOX\s*([^\(]+)(\([\*\+].*)$/){
      my $check = $1;
      my $v = $2;
      $remain = $3;
      $v =~ s/\s*$//;
      $r->{$v} = $check;
    } elsif($remain =~  /^\s*\(([\*\+])\)\s*FORMCHECKBOX\s*(.+)$/){
      my $check = $1;
      my $v = $2;
      $remain = "";
      $v =~ s/\s*$//;
      $r->{$v} = $check;
    } else {
      #print STDERR "no match\n";
      $remain = "";
    }
  }
  return $r;
}
sub CheckBoxColumns{
  my($line, $columns) = @_;
  my $remain = $line;
  my %r;
  for my $col (@$columns){
    if($remain =~ /^\s*\((.)\)\s*FORMCHECKBOX(.*)/){
      my $check = $1;
      $remain = $2;
      $r{$col} = $check;
    } else {
      $r{$col} = "not_found";
    }
  }
  return \%r;
}
############## Section Parsers #####################
sub SubmissionTypeParser{
  my($section, $first_pass, $results) = @_;
  my @lines = @{$first_pass->{$section}};
  my %r;
  for my $i (0 .. $#lines){
    if($lines[$i] =~ /^Submission Category/){
      $r{"Submission Category"} =
        CheckBoxFirst($lines[$i+1]);
    }
    if($lines[$i] =~ /^Submission Number/){
      $r{"Submission Number"} =
        CheckBoxFirst($lines[$i+1]);
    }
  }
  $results->{$section} = \%r;
}
sub SubmissionDetailParser{
  my($section, $first_pass, $results) = @_;
  my %r;
  for my $i (0 .. $#{$first_pass->{$section}}){
    my $line = $first_pass->{$section}->[$i];
    if(
      $line eq "CT image series" ||
      $line eq "RT Structure Set " ||
      $line eq "RT Plan" ||
      $line eq "RT Dose" ||
      $line eq "Color Isodose *"
    ){
      $r{$line} = CheckBoxColumns($first_pass->{$section}->[$i+1],
        ["Submitted", "Not Submitted"]);
    }
  }
  $results->{$section} = \%r;
}
sub TreatmentMachineParser{
  my($section, $first_pass, $results) = @_;
  my @lines = @{$first_pass->{$section}};
  my %r;
  for my $i (0 .. $#lines){
    if($lines[$i] =~ /FORMCHECKBOX/){
      my $lr = CheckBoxFirst($lines[$i]);
      for my $k (keys %$lr){
        $r{$k} = $lr->{$k};
      }
    }
  }
  $results->{$section} = \%r;
}
sub PresTreatmentDateParser{
  my($section, $first_pass, $results) = @_;
  my @lines = @{$first_pass->{$section}};
  my %r;
  for my $i (0 .. $#lines){
    my $line = $lines[$i];
    if(
      $line eq "CTV_Lump" || $line eq "CTV_Breast" ||
      $line eq "CTV_Chestwall" || $line eq "CTV_SCL" ||
      $line eq "CTV_Ax" || $line eq "CTV_IMN" ||
      $line eq "First Treatment Date (MM/DD/YYYY)"
    ){
      my $v = $lines[$i+1];
      $r{$line} = $v;
    }
    if($line eq "Total Prescription"){
      $r{$line} = $lines[$i+2];
    }
    if($line eq "Number of Treatment Phases"){
      my @foo;
      my $idx = 1;
      while(
        exists($lines[$i+$idx]) && 
        $i+$idx < $#lines &&
        $lines[$i+$idx] ne "First Treatment Date (MM/DD/YYYY)"
      ){
        push @foo, $lines[$i+$idx];
        $idx += 1;
      }
      $r{$line} = \@foo;
    }
  }
  $results->{$section} = \%r;
}
sub DoseDeliveredUsingParser{
  my($section, $first_pass, $results) = @_;
  my %r;
  my @lines = @{$first_pass->{$section}};
  for my $i (0 .. $#lines){
    my $line = $lines[$i];
    if(
      $line eq "3D Conformal RT" ||
      $line eq "IMRT - Step-and-Shoot" ||
      $line eq "IMRT - Sliding Window" ||
      $line eq "IMRT / VMAT" ||
      $line eq "Helical Tomotherapy" ||
      $line eq "Electrons" ||
      $line eq "Protons  -  Passive Scatter" ||
      $line eq "Protons  -  Uniform Scanning" ||
      $line eq "Protons  -  Pencil Beam Scanning" ||
      $line eq "Other (specify in comments)"
    ){
      $r{$line} = CheckBoxColumns($lines[$i+1],
        ["Initial Plan", "Boost Plan (if used)"]);
    }
  }
  $results->{$section} = \%r;
}
sub PlanningDeliveryDetailsParser{
  my($section, $first_pass, $results) = @_;
  my %r;
  my @lines = @{$first_pass->{$section}};
  for my $i (0 .. $#lines){
    my $line = $lines[$i];
    if(
      $line eq "Patient treated in prone position?" ||
      $line eq "Implanted tissue expander used?" ||
      $line eq "Respiratory gating used for treatment delivery?" ||
      $line eq "Boost delivered as separate phase?" ||
      $line eq 
         "Total (composite) dose submitted " .
         "if multiple phases used for treatment?" ||
      $line eq "Simultaneous integrated boost used?" ||
      $line eq "Heterogeneity Corrected Dose submitted?" ||
      $line eq "All phases planned using the same CT series"
    ){
      $r{$line} = CheckBoxColumns($lines[$i+1],
        ["Yes", "No"]);
    }
  }
  $results->{$section} = \%r;
}
sub TreatmentPlanningSystemParser{
  my($section, $first_pass, $results) = @_;
  my %r;
  my @lines = @{$first_pass->{$section}};
  for my $i (0 .. $#lines){
    my $line = $lines[$i];
    if(
      $line eq "TPS Manufacturer" ||
      $line eq "TPS Name" ||
      $line eq "TPS Version" ||
      $line eq "IMRT / VMAT" ||
      $line eq "Dose Calculation Algorithm"
    ){
      $r{$line} = $lines[$i+1];
    }
  }
  $results->{$section} = \%r;
}
sub SubjectIdentifierParser{
  my($section, $first_pass, $results) = @_;
  my @lines = @{$first_pass->{$section}};
  my %r;
  for my $i (0 .. $#lines){
    if($lines[$i] =~ /^Randomization/){
      $r{"Randomization"} =
        CheckBoxFirst($lines[$i+1]);
    }
    if($lines[$i] =~ /^Disease Laterality/){
      $r{"Disease Laterality"} =
        CheckBoxFirst($lines[$i+1]);
    }
    if($lines[$i] eq "Case Number:"){
      $r{case_number} = $lines[$i+1];
    }
  }
  $results->{$section} = \%r;
}
sub AdditionalCommentsParser{
  my($section, $first_pass, $results) = @_;
  my @lines = @{$first_pass->{$section}};
  my @non_blank;
  for my $i (@lines) {
    if($i) { push @non_blank, $i }
  }
  if(@non_blank > 0){
    $results->{$section} = \@non_blank;
  }
}
sub CrunchResults{
  my($results) = @_;
  my $crunched;
  for my $i (keys %$results){
    if($i eq "additional_comments"){
      $crunched->{$i} = $results->{$i};
    } elsif($i eq "dose_delivered_using"){
      my %c;
      for my $type (keys %{$results->{$i}}){
        for my $p_type (keys %{$results->{$i}->{$type}}){
          if($results->{$i}->{$type}->{$p_type} eq "+"){
            unless(exists($crunched->{$i}->{$p_type})){
              $crunched->{$i}->{$p_type} = [];
            }
            push(@{$crunched->{$i}->{$p_type}}, $type);
          }
        }
      }
    } elsif($i eq "planning_delivery_details"){
      for my $question (keys %{$results->{$i}}){
        for my $ans (keys %{$results->{$i}->{$question}}){
          if($results->{$i}->{$question}->{$ans} eq "+"){
            $crunched->{$i}->{$question} = $ans;
          }
        }
      }
    } elsif($i eq "pres_treatment_date"){
      $crunched->{$i} = $results->{$i};
    } elsif($i eq "subject_identifiers"){
      for my $k ("Disease Laterality", "Randomization"){
        for my $choice (keys %{$results->{$i}->{$k}}){
          if($results->{$i}->{$k}->{$choice} eq "+"){
            $crunched->{$i}->{$k} = $choice;
          }
          $crunched->{$i}->{case_number} =
            $results->{$i}->{case_number}
        }
      }
    } elsif($i eq "submission_detail"){
      my @submitted;
      for my $ftype (keys %{$results->{$i}}){
        for my $stat (keys %{$results->{$i}->{$ftype}}){
          if($results->{$i}->{$ftype}->{$stat} eq "+"){
            if($stat eq "Submitted"){
              push(@submitted, $ftype);
            }
          }
        }
      }
      $crunched->{submitted_files} = \@submitted;
    } elsif($i eq "submission_type"){
      my $type = "Submission Category";
      my $trans_type = "Category";
      for my $v (keys %{$results->{$i}->{$type}}){
        if($results->{$i}->{$type}->{$v} eq "+"){
          $crunched->{$i}->{$trans_type} = $v;
        }
      }
      $type = "Submission Number";
      $trans_type = "Number";
      for my $v (keys %{$results->{$i}->{$type}}){
        if($results->{$i}->{$type}->{$v} eq "+"){
          $crunched->{$i}->{$trans_type} = $v;
        }
      }
    } elsif($i eq "treatment_machine"){
      for my $m (keys %{$results->{$i}}){
        if($results->{$i}->{$m} eq "+"){
          $crunched->{$i} = $m;
        }
      }
    } elsif($i eq "treatment_planning_system"){
      $crunched->{$i} = $results->{$i};
    } else {
      print STDERR "Unknown section: $i\n";
    }
  }
  return $crunched;
}

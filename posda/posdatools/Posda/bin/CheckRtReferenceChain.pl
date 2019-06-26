#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;

my $usage = <<EOF;
CheckRtReferenceChain.pl <bkgrnd_id> <collection> <site> <notify>
or
CheckRtReferenceChain.pl -h

The script doesn't expect lines on STDIN:

EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 3){
  die "$usage\n";
}

my ($invoc_id, $collection, $site, $notify) = @ARGV;

my $background = Posda::BackgroundProcess->new($invoc_id, $notify);

print "Going straight to background\n";

$background->ForkAndExit;

my $start_time = `date`;
chomp $start_time;
$background->WriteToEmail(
  "Starting  CheckRtReferenceChain.pl at $start_time\n");
$background->WriteToEmail(
  "##### This is a test version of this script #####\n");
close STDOUT;
close STDIN;
print STDERR "Starting  PopulateFileRoiImageLinkages.pl at $start_time\n";
open PIPE, "PopulatePlanFrameOfRef.pl|";
$background->WriteToEmail("Running PopulateFileRoiImageLinkages.pl:\n");
while(my $line = <PIPE>){
  chomp $line;
  $background->WriteToEmail(">>>>$line\n");
}
my $now = `date`;
chomp $now;
$background->WriteToEmail("$now: finished PopulatePlanFrameOfRef.pl.pl:\n");

my %Doses;
#{
#   <dose_sop> => [<pat_id>, <for_uid>],
#   ...
#}
my %Plans;
#{
#   <plan_sop> => [<pat_id>, <for_uid>],
#   ...
#}
my %Structs;
#{
#   <struct_sop> => {
#     pat_id => <pat_id>, 
#     for_uids => {
#       <for_uid> => 1,
#       ...
#     },
#   ...
#}
my %StructLinkages;
#{
#  <struct_sop> => {
#    from_plan => {
#      <plan_sop> => 1,
#      ...
#    },
#    ...
#  },
#}
my %PlanLinkages;
#{
#  <plan_sop> => {
#    to_struct => <struct_sop>
#    from_dose => {
#      <dose_sop> => 1,
#      ...
#    },
#    ...
#  },
#}
my %DoseLinkages;
#{
#  <dose_sop> => {
#    to_plan => <plan_sop>,
#    ...
#  },
#}
#### define queries to set up loop
my $plan_to_ss = Query("PlanToSsLinkageByCollectionSite");
my $dose_to_plan = Query("DoseLinkageToPlanByCollectionSite");
my $ss_sop_to_for = Query("SsSopToForByCollectionSite");
my $plan_sop_to_for = Query("PlanSopToForByCollectionSite");
my $dose_sop_to_for = Query("DoseSopToForByCollectionSite");
#### populate loop drivers data set
$ss_sop_to_for->RunQuery(sub {
  my($row) = @_;
  my($patient_id, $sop_instance_uid, $for_uid) = @$row;
  $Structs{$sop_instance_uid}->{pat_id} = $patient_id;
  $Structs{$sop_instance_uid}->{for_uids}->{$for_uid} = 1;
}, sub {}, $collection, $site);
$plan_sop_to_for->RunQuery(sub {
  my($row) = @_;
  my($patient_id, $sop_instance_uid, $for_uid) = @$row;
  $Plans{$sop_instance_uid} = [$patient_id, $for_uid];
}, sub {}, $collection, $site);
$dose_sop_to_for->RunQuery(sub {
  my($row) = @_;
  my($patient_id, $sop_instance_uid, $for_uid) = @$row;
  $Doses{$sop_instance_uid} = [$patient_id, $for_uid];
}, sub {}, $collection, $site);
$plan_to_ss->RunQuery(sub {
  my($row) = @_;
  my($referencing_plan, $referenced_ss) = @$row;
  $StructLinkages{$referenced_ss}->{from_plan}->{$referencing_plan} = 1;
  $PlanLinkages{$referencing_plan}->{to_struct} = $referenced_ss;
}, sub{}, $collection, $site);
$dose_to_plan->RunQuery(sub {
  my($row) = @_;
  my($referencing_dose, $referenced_plan) = @$row;
  $PlanLinkages{$referenced_plan}->{from_dose}->{$referencing_dose} = 1;
  $DoseLinkages{$referencing_dose}->{to_plan} = $referenced_plan;
}, sub{}, $collection, $site);
#### 
my @FullLinkageChains;
my @DosePlanChains;
my @PlanStructChains;
my %PoorlyLinkedDoses;
my %PoorlyLinkedPlans;
my %DoublyLinkedPlans;
my %DoublyLinkedStructs;
my %UnlinkedPlans;
my %UnlinkedStructs;
my %IsInChain;
dose:
for my $dose (keys %Doses){
  unless(exists $DoseLinkages{$dose}->{to_plan}){
    $PoorlyLinkedDoses{$dose} = 1;
    next dose;
  }
  my $plan = $DoseLinkages{$dose}->{to_plan};
  unless(exists $Plans{$plan}){
    $PoorlyLinkedDoses{$dose} = 1;
    next dose;
  }
  $IsInChain{$dose} = 1;
  $IsInChain{$plan} = 1;
  my $dose_plan_chain = [$dose, $plan];
  unless(exists $PlanLinkages{$plan}->{to_struct}){
    $PoorlyLinkedPlans{plan} = 1;
    push @DosePlanChains, $dose_plan_chain;
    next dose;
  }
  my $struct = $PlanLinkages{$plan}->{to_struct};
  unless(exists $Structs{$struct}){
    $PoorlyLinkedPlans{plan} = 1;
    push @DosePlanChains, $dose_plan_chain;
    next dose;
  }
  my $full_chain = [$dose, $plan, $struct];
  $IsInChain{$struct} = 1;
  push @FullLinkageChains, $full_chain;
}
plan:
for my $plan (keys %Plans){
  if(exists $IsInChain{$plan}){
    my @dose_links = $PlanLinkages{$plan}->{from_dose};
    if(@dose_links > 1){
      $DoublyLinkedPlans{$plan} = 1;
      next plan;
    }
  } else {
    $UnlinkedPlans{$plan} = 1;
    if(exists $PlanLinkages{$plan}->{to_struct}){
      my $struct = $PlanLinkages{$plan}->{to_struct};
      if(exists $Structs{$struct}){
        my $plan_struct_chain = [$plan, $struct];
        $IsInChain{$plan} = 1;
        $IsInChain{$struct} = 1;
        push @PlanStructChains, $plan_struct_chain;
        next plan;
      }
    }
    $PoorlyLinkedPlans{$plan} = 1;
  }
}
struct:
for my $struct(keys %Structs){
  if(exists $IsInChain{$struct}){
    my @ref = keys %{$StructLinkages{$struct}->{from_plan}};
    if(@ref > 1){
      $DoublyLinkedStructs{$struct} = 1;
      next struct;
    }
  } else {
    $UnlinkedStructs{$struct} = 1;
  }
}
my $num_full_chains = @FullLinkageChains;
my $num_dose_plan_chains = @DosePlanChains;
my $num_plan_struct_chains = @PlanStructChains;
my $num_poorly_linked_doses = keys %PoorlyLinkedDoses;
my $num_poorly_linked_plans = keys %PoorlyLinkedPlans;
my $num_doubly_linked_plans = keys %DoublyLinkedPlans;
my $num_doubly_linked_structs = keys %DoublyLinkedStructs;
my $num_unlinked_plans = keys %UnlinkedPlans;
my $num_unlinked_structs = keys %UnlinkedStructs;
$background->WriteToEmail(
"$num_full_chains FullLinkageChains\n" .
"$num_dose_plan_chains DosePlanChains\n" .
"$num_plan_struct_chains PlanStructChains\n" .
"$num_poorly_linked_doses PoorlyLinkedDoses\n" .
"$num_poorly_linked_plans PoorlyLinkedPlans\n" .
"$num_doubly_linked_plans DoublyLinkedPlans\n" .
"$num_doubly_linked_structs DoublyLinkedStructs\n".
"$num_unlinked_plans UnlinkedPlans\n" .
"$num_unlinked_structs UnlinkedStructs\n");
if($num_full_chains > 0){
  my $rpt = $background->CreateReport("RtLinkageChainReport");
  $rpt->print("patient,struct,plan,dose,comment\n");
  for my $row (@FullLinkageChains){
    my($dose, $plan, $struct) = @$row;
    my $plan_pat = $Plans{$plan}->[0];
    my $plan_for = $Plans{$plan}->[1];
    my $dose_pat = $Doses{$dose}->[0];
    my $dose_for = $Doses{$dose}->[1];
    my $struct_pat = $Structs{$struct}->{pat_id};
    my @comments;
    $rpt->print("\"$struct_pat\",\"$struct\",\"$plan\",\"$dose\",");
    my @struct_fors = keys %{$Structs{$struct}->{for_uids}};
    if(@struct_fors == 0){
      push(@comments, "No ROI frames of reference");
    }
    if(@struct_fors > 1){
      my $comment = "Multiple ROI frame of reference:";
      for my $i (@struct_fors) {
         $comment .= "\n\t$i";
      }
      push(@comments, $comment);
    }
    if($dose_pat eq $plan_pat && $dose_pat eq $struct_pat){
      push @comments, "patients all match";
    } else {
      push @comments, "patients don't match:\n\tdose: $dose_pat\n\tplan: $plan_pat" .
        "\n\tstruct: $struct_pat";
    }
    if(@struct_fors == 1){
      my $struct_for = $struct_fors[0];
      if($struct_for eq $plan_for && $plan_for eq $dose_for){
        push @comments, "frames of reference all match";
      } else {
        my $comment = "frame of reference mismatch" .
          "\n\tstruct: $struct_for" .
          "\n\tplan: $plan_for" .
          "\n\tdose: $dose_for";
        push @comments, $comment;
      }
    } else {
      if($plan_for ne $dose_for){
        push @comments, "plan and dose frame of reference don't match:" .
          "\n\tplan: $plan_for" .
          "\n\tdose: $dose_for";
      } elsif (exists $Structs{$struct}->{for_uids}->{$plan_for}){
        push(@comments, "plan, dose from of reference match one of struct:" .
          "\n\tfor: $plan_for");
      } else {
        push(@comments, "plan, dose from of reference match none of struct:" .
          "\n\tfor: $plan_for");
      }
    }
    my $final_comment = "";
    for my $i (0 .. $#comments) {
      unless($i == 0){ $final_comment .= "\n" }
      $final_comment .= $comments[$i];
    }
    $final_comment =~ s/"/""/g;
    $rpt->print("\"$final_comment\"\r\n");
  }
}
$background->Finish;

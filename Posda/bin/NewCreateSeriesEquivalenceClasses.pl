#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Debug;
use Data::Dumper;
use VectorMath;
my $dbg = sub {print STDERR @_};
my $usage = <<EOF;
CreateSeriesEquivalenceClasses.pl <series_instance_uid> <visual_review_inst_id>
EOF
unless($#ARGV == 1){ die $usage }
if($ARGV[0] eq "-h"){ print STDERR "$usage\n"; exit }
my $q_inst = PosdaDB::Queries->GetQueryInstance(
  "ForConstructingSeriesEquivalenceClasses");
my @col_headers = (
  "series_instance_uid",
  "modality",
  "series_number",
  "laterality",
  "series_date",
  "dicom_file_type",
  "performing_phys",
  "protocol_name",
  "series_description",
  "operators_name",
  "body_part_examined",
  "patient_position",
  "smallest_pixel_value",
  "largest_pixel_value",
  "performed_procedure_step_id",
  "performed_procedure_step_start_date",
  "performed_procedure_step_desc",
  "performed_procedure_step_comments",
  "image_type",
  "iop",
  "pixel_rows",
  "pixel_columns",
  "file_id",
  "ipp"
);


#After Runquery this will be a collection of all the "files" in the series
my $Separator= {};

$q_inst->RunQuery(
  # Do this sub for every row returned by q_inst(ForConstructingSeriesEquivalenceClasses)
  sub {
      my($row) = @_;
      my @cols = @$row;
      my $i;
      my $file = {};
        #loop through all the fields
        for $i (0 .. $#col_headers){
          #if the field is empty, set it to undefined
          unless(defined $cols[$i]) { $cols[$i] = "<undef>" }
          #set each field - value pair for the file
          $file->{$col_headers[$i]} = $cols[$i];
        };
        #Add this file to the file collection
        $Separator->{$file->{file_id}}=$file;
      }, 
  sub {}, 
  $ARGV[0]
);

#check that the non-geometric fields match the template

#First separate any IEC groups that differ on non geometric data
#Each potential IEC group will have a template, and matching files will be members

my $templates={};
foreach my $file_id (keys %$Separator){
  my $match = 0;
  foreach my $tmpl_id (keys %$templates){
     if(HashCompare($Separator->{$tmpl_id},$Separator->{$file_id})){
        #add this file to this templates members
        push @{$templates->{$tmpl_id}}, $file_id; 
        $match = 1; 
        last;
      }  
  }
  unless($match){
    #since no templates matched, create  a new one and add this as its first member
    push @{$templates->{$file_id}}, $file_id;
  }
}

#Within each group compare the geometric data to separate the files into the final IECs

my ($prev_2,$prev_1,$point,$dist);
my $radials = {};
my $lines = {};
my $extras = {};

print " \n begining separation \n";
foreach my $tmpl_id (keys %$templates){
    my @templ = @{$templates->{$tmpl_id}};
    
    foreach my $file_id (@templ){
      my $image_position_patient = $Separator->{$file_id}->{"ipp"};
      my $point;
      @$point = split /\\/, $image_position_patient;
      
      if(!defined($prev_2)){
           #if this is the first file, compare it to the last one
           #print "\n setting prev values for the first file\n";
           unless($#templ < 2){@$prev_1 = split /\\/,$Separator->{$templ[$#templ-2]}->{"ipp"}}else{$prev_2 =$point};
           @$prev_2 = split /\\/,$Separator->{$templ[$#templ-1]}->{"ipp"};
      }
      #print "\n prev 2: ", Dumper($prev_2), " prev 1: ", Dumper($prev_1), " point: ", Dumper($point), "\n" ; 
         
      if (@$point[2] == @$prev_2[2]){
         # print " radial ";
         push @{$radials->{0}},$file_id;
         $prev_1 = $prev_2;
         $prev_2 = $point; 
       }else{
         $dist = VectorMath::DistPointToLine($point,$prev_1,$prev_2);
         if  ($dist > -0.9 and $dist < 0.9){ # distance = 0 or very close
           #print " on a line ";
           push @{$lines->{0}},$file_id;
           $prev_1 = $prev_2;
           $prev_2 = $point; 
         }else{
           #print "\n failed to line - dist : $dist \n";
           push @{$extras->{0}},$file_id; 
         }
       }
    }
}

# my @equiv_classes = $radials + $lines + $extras;
my @equiv_classes; 
foreach my $rad_id (keys %$radials){
 push @equiv_classes, $radials->{$rad_id};
}
foreach my $line_id (keys %$lines){
 push @equiv_classes, $lines->{$line_id};
}
foreach my $extra_id (keys %$extras){
 push @equiv_classes, $extras->{$extra_id};
}
my $num_equiv = @equiv_classes;
print "$num_equiv classes for series $ARGV[0]:\n";
my $ins_equiv = PosdaDB::Queries->GetQueryInstance("CreateEquivalenceClassNew");
my $get_id = PosdaDB::Queries->GetQueryInstance("GetEquivalenceClassId");
my $ins_equiv_file = PosdaDB::Queries->GetQueryInstance(
  "CreateEquivalenceInputClass");
my $upd_proc_stat = PosdaDB::Queries->GetQueryInstance(
  "UpdateEquivalenceClassProcessingStatus");
for my $i (0 .. $#equiv_classes){
  #inserts 'series_instance_uid' and 'equivalence_class_number' into Image_Equivalence_Class table with 'Preparing' status  
  $ins_equiv->RunQuery(sub{}, sub{}, $ARGV[0], $i,$ARGV[1]);
  my $id = $i;
  #gets the newly generated Sequence Id from that table
  $get_id->RunQuery(
    sub {
       my($row) = @_;
       $id = $row->[0]
    },
    sub {}
  );
  print "[$id]-[$i]$ARGV[0]:\n"; 
  #loop through each equivalnce class array
  for my $file_id (@{$equiv_classes[$i]}){
    #print the array id and the file id
    print "\t[$id] file: $file_id\n";
    #insert into the Image_Equivalence_Class_Input_Image table the corresponding IEC table record id and the file id
    $ins_equiv_file->RunQuery(sub {}, sub {}, $id, $file_id);
  }
  #when complete, change status of the IEC table record from 'Preparing' to 'ReadytoProcess'
  $upd_proc_stat->RunQuery(sub{}, sub{}, "ReadyToProcess", $id);
}

#Compare the string values of matching keys (ignoring geometric data)
sub HashCompare{
  my ($hash1,$hash2) = @_;
      foreach my $key (keys(%$hash1)){
          if ($key ne "iop" and $key ne "ipp" and $key ne "file_id"){ 
             if($hash1->{$key} eq $hash2->{$key}){
               #matches, continue the check
             }else{ 
                #not a match to this template, end the check
                return 0;
             }
          }
        }
  return 1;
}
      

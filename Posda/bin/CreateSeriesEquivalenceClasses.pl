#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Debug;
use Data::Dumper;
my $dbg = sub {print STDERR @_};
my $usage = <<EOF;
CreateSeriesEquivalenceClasses.pl <series_instance_uid>
EOF
unless($#ARGV == 0){ die $usage }
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
#creates a large tree made of hashes. These hashes are "walked through" in the later steps
my %files;
$q_inst->RunQuery(
  sub {
    my($row) = @_;
    my @cols = @$row;
    my $i;
    my $debugtabs= 0; #debug tabs added for printing debug output
    #loops through all the fields
    for $i (0 .. $#col_headers){
      #if the field is empty set it to undefined
      unless(defined $cols[$i]) { $cols[$i] = "<undef>" }
      #if there is not a matching key...
      # unless(exists($h_ptr->{$cols[$i]})) {
      #print "\nset to empty\n";
      $files{$col_headers[$i]} = $cols[$i];
      #$debugtabs = 0;
      #print "\n";
      #}

      #DEBUG PRINTING
      # my $k = 0;
      #for $k (0 .. $debugtabs){
      #  print " ";
      #}

      # print "\nrecurse\n";
      #$debugtabs++;
      #$h_ptr = $h_ptr->{$cols[$i]};
      #print "$i: $col_headers[$i] = $cols[$i]\n"; 
    };
    #unless(defined $cols[$#col_headers]){
    #  $cols[$#col_headers] = "<undef>";
    #}
    #$h_ptr->{$cols[$#col_headers]} = 1;
  }, 
  sub {}, 
  $ARGV[0]
);

print Dumper(\%files);

my @equiv_classes;
my $level = 0;
my $num_levels = $#col_headers - 1;
my $files_ptr = \%files;
print "\nBegin Walk Separator\n";
WalkSeparator($files_ptr, $level, $num_levels, \@equiv_classes);
print "\nEnd Walk Separator\n";
my $num_equiv = @equiv_classes;
print "$num_equiv classes for series $ARGV[0]:\n";
my $ins_equiv = PosdaDB::Queries->GetQueryInstance("CreateEquivalenceClass");
my $get_id = PosdaDB::Queries->GetQueryInstance("GetEquivalenceClassId");
my $ins_equiv_file = PosdaDB::Queries->GetQueryInstance(
  "CreateEquivalenceInputClass");
my $upd_proc_stat = PosdaDB::Queries->GetQueryInstance(
  "UpdateEquivalenceClassProcessingStatus");
for my $i (0 .. $#equiv_classes){
  #inserts 'series_instance_uid' and 'equivalence_class_number' into Image_Equivalence_Class table with 'Preparing' status  
  $ins_equiv->RunQuery(sub{}, sub{}, $ARGV[0], $i);
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

sub WalkSeparator{
  my($tree, $cur_level, $max_level, $equiv_classes) = @_;
  if($cur_level == $max_level){
    #at each level create an array of files? and assign it to equivalence class array?
    my @files = keys %$tree;
    print "\nThis level has $#files files.\n";
    push @$equiv_classes, \@files;
  } else {
    for my $k (keys %$tree){
      #get to the bottom of the tree (h_ptr)
      WalkSeparator($tree->{$k}, $cur_level + 1, $max_level, $equiv_classes);
    }
  }
}


#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Debug;
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
);
my %Separator;
$q_inst->RunQuery(
  sub {
    my($row) = @_;
    my @cols = @$row;
    my $h_ptr = \%Separator;
    my $i;
    for $i (0 .. $#col_headers - 1){
      unless(defined $cols[$i]) { $cols[$i] = "<undef>" }
      unless(exists($h_ptr->{$cols[$i]})) {
        $h_ptr->{$cols[$i]} = {};
      }
      $h_ptr = $h_ptr->{$cols[$i]};
    };
    unless(defined $cols[$#col_headers]){
      $cols[$#col_headers] = "<undef>";
    }
    $h_ptr->{$cols[$#col_headers]} = 1;
  }, 
  sub {}, 
  $ARGV[0]
);
my @equiv_classes;
my $level = 0;
my $num_levels = $#col_headers - 1;
my $h_ptr = \%Separator;
WalkSeparator($h_ptr, $level, $num_levels, \@equiv_classes);
my $num_equiv = @equiv_classes;
print "$num_equiv classes for series $ARGV[0]:\n";
my $ins_equiv = PosdaDB::Queries->GetQueryInstance("CreateEquivalenceClass");
my $get_id = PosdaDB::Queries->GetQueryInstance("GetEquivalenceClassId");
my $ins_equiv_file = PosdaDB::Queries->GetQueryInstance(
  "CreateEquivalenceInputClass");
my $upd_proc_stat = PosdaDB::Queries->GetQueryInstance(
  "UpdateEquivalenceClassProcessingStatus");
for my $i (0 .. $#equiv_classes){
  $ins_equiv->RunQuery(sub{}, sub{}, $ARGV[0], $i);
  my $id = $i;
  $get_id->RunQuery(
    sub {
       my($row) = @_;
       $id = $row->[0]
    },
    sub {}
  );
  print "[$id]-[$i]$ARGV[0]:\n"; 
  for my $file_id (@{$equiv_classes[$i]}){
     print "\t[$id] file: $file_id\n";
    $ins_equiv_file->RunQuery(sub {}, sub {}, $id, $file_id);
  }
  $upd_proc_stat->RunQuery(sub{}, sub{}, "ReadyToProcess", $id);
}

sub WalkSeparator{
  my($tree, $cur_level, $max_level, $equiv_classes) = @_;
  if($cur_level == $max_level){
    my @files = keys %$tree;
    push @$equiv_classes, \@files;
  } else {
    for my $k (keys %$tree){
      WalkSeparator($tree->{$k}, $cur_level + 1, $max_level, $equiv_classes);
    }
  }
}


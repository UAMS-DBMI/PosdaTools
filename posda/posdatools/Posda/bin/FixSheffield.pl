#!/usr/bin/perl -w
use strict;
use PosdaCuration::PerformBulkOperations;
use Posda::UUID;
use Posda::Try;
my $sub = sub {
  my($coll, $site, $subj, $f_list) = @_;
  my $edits = {};
  my $bad_file_count = 0;
  file:
  for my $f (@$f_list){
    my $try = Posda::Try->new($f);
    unless(exists $try->{dataset}){
      print STDERR "Couldn't parse $f\n";
      next file;
    }
    my $ds = $try->{dataset};
    my $modality = $ds->Get("(0008,0060)");
    if($modality eq "MR"){
      my $req_proc_desc = $ds->Get("(0032,1060)");
      my $seq_name = $ds->Get("(0018,0024)");
      unless(defined($req_proc_desc) && defined($seq_name)){
        $bad_file_count += 1;
        next file;
      }
      $edits->{$f}->{full_ele_additions}->{"(0008,1030)"} =
        $req_proc_desc;
      $edits->{$f}->{full_ele_additions}->{"(0008,103e)"} =
        $seq_name;
    } elsif ($modality eq "CT"){
      my $image_type = $ds->Get("(0008,0008)");
      my $contrast = $ds->Get("(0018,0010)");
      if($image_type->[2] eq "LOCALIZER"){
        $edits->{$f}->{full_ele_additions}->{"(0008,103e)"} =
          "LOCALIZER";
      } elsif ($contrast) {
        $edits->{$f}->{full_ele_additions}->{"(0008,103e)"} =
          $contrast;
      } else {
        $edits->{$f}->{full_ele_additions}->{"(0008,103e)"} =
          $image_type->[2];
      }
      $edits->{$f}->{full_ele_additions}->{"(0008,1030)"} =
        "Bladder CT";
    }
  }
  if($bad_file_count) {
    print "$bad_file_count files not edited in $coll, $site, $subj\n";
  }
  my $files_edited = keys %$edits;
  unless($files_edited > 0){
    print "No files edited for $coll, $site, $subj\n";
    return undef;
  }
  print "$files_edited to edit for $coll, $site, $subj\n";
  return $edits;
};
my $user = `whoami`;
chomp $user;
my $port = 64612;
my $session = Posda::UUID::GetGuid;
my $Bulk = PosdaCuration::PerformBulkOperations->new(
  "/cache/bbennett/Data/HierarchicalExtractions/data",
  "TCGA-BLCA", "Sheffield", $session, $user, $port);
$Bulk->MapEdits($sub, $0);

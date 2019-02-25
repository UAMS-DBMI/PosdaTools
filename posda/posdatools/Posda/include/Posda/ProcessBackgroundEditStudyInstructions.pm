#!/usr/bin/perl -w
use strict;
package Posda::ProcessBackgroundEditStudyInstructions;
use Posda::DB ('Query');
use Posda::ProcessBackgroundEditInstructions;
use vars qw( @ISA );
@ISA = ( "Posda::ProcessBackgroundEditInstructions" );
#sub new{
#  my($class) = @_;
#  return Posda::ProcessBackgroundEditInstructions::new($class);
#}
##############################
# Override ProcessGetObjectFileList (obj_id file_id)
my $get_list_of_sops_and_files = Query("GetFilesAndSopsByStudy");
sub GetObjectFileList{
  my($this, $study) = @_;
  unless(exists $this->{PatientToNickname}){
    $this->{PatientToNickname} = {};
  }
  unless(exists $this->{StudyToNickname}){
    $this->{StudyToNickname} = {};
  }
  unless(exists $this->{SeriesToNickname}){
    $this->{SeriesToNickname} = {};
  }
  unless(exists $this->{pat_seq}) { $this->{pat_seq} = 0 }
  unless(exists $this->{study_seq}) { $this->{study_seq} = 0 }
  unless(exists $this->{series_seq}) { $this->{series_seq} = 0 }
  my %study_struct;
  $get_list_of_sops_and_files->RunQuery(sub{
    my($row) = @_;
    my($pat_id, $study_id, $series_id, $sop, $file_id, $path) = @$row;
    if(exists $study_struct{$sop}){
      print "Error: duplicate sop ($sop) in study ($study)\n";
      exit;
    }
    unless(exists $this->{PatientToNickname}->{$pat_id}){
      $this->{pat_seq} += 1;
      my $pat_nick = "pat_$this->{pat_seq}";
      $this->{PatientToNickname}->{$pat_id} = "pat_$this->{pat_seq}";
      unless(-d "$this->{dest_dir}/$pat_nick"){
        unless((mkdir "$this->{dest_dir}/$pat_nick") == 1){
          print "Couldn't mkdir $this->{dest_dir}/$pat_nick ($!)\n";
          exit;
        }
      }
    }
    my $pat_path = $this->{PatientToNickname}->{$pat_id};
    unless(exists $this->{StudyToNickname}->{$study_id}){
      $this->{study_seq} += 1;
      my $study_nick = "study_$this->{study_seq}";
      $this->{StudyToNickname}->{$study_id} = "study_$this->{study_seq}";
      unless(-d "$this->{dest_dir}/$pat_path/$study_nick"){
        unless((mkdir "$this->{dest_dir}/$pat_path/$study_nick") == 1){
          print "Couldn't mkdir $this->{dest_dir}/$pat_path/$study_nick ($!)\n";
          exit;
        }
      }
    }
    my $study_path = $this->{StudyToNickname}->{$study_id};
    unless(exists $this->{SeriesToNickname}->{$series_id}){
      $this->{series_seq} += 1;
      my $series_nick = "series_$this->{series_seq}";
      $this->{SeriesToNickname}->{$series_id} = "series_$this->{series_seq}";
      unless(-d "$this->{dest_dir}/$pat_path/$study_path/$series_nick"){
        unless((mkdir "$this->{dest_dir}/$pat_path/$study_path/$series_nick") == 1){
          print "Couldn't mkdir $this->{dest_dir}/$pat_path/$study_path/$series_nick ($!)\n";
          exit;
        }
      }
    }
    my $series_path = $this->{SeriesToNickname}->{$series_id};
    my $dest_file = "$this->{dest_dir}/$pat_path/$study_path/$series_path/" .
      "$file_id.dcm";
    $study_struct{$file_id} = {
      from_file => $path,
      to_file => $dest_file,
    };
  }, sub {}, $study);
  return \%study_struct;
}

#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Dispatch/Anonymizer.pm,v $
#$Date: 2010/05/21 20:18:35 $
#$Revision: 1.6 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
package Dispatch::Anonymizer;
use strict;
use Posda::Anonymizer;
use File::Find;
sub FindFiles{
  my($this, $dir) = @_;
  my @list;
  my $foo = sub {
    if(-f $File::Find::name){
      push @list, $File::Find::name;
    }
  };
  find({wanted => $foo, follow => 1}, $dir);
  return \@list;
}

sub MakeLoopStepSearch{
  my($this) = @_;
  my $foo = sub {
    my $disp = shift;
    unless(
      exists($this->{raw_file_list}) &&
      ref($this->{raw_file_list}) eq "ARRAY" &&
      $#{$this->{raw_file_list}} >= 0
    ){
      delete $this->{raw_file_list};
      delete $this->{Anonymizing};
      return;
    }
    my $file = shift(@{$this->{raw_file_list}});
    my $try = Posda::Try->new($file);
    if(exists $try->{dataset}){
      push(@{$this->{pass_one_file_list}}, $file);
      $this->{DicomAnonymizer}->history_builder($try->{dataset});
    }
    $disp->queue();
  };
  return $foo;
}
sub StartAnonymizationSearch{
  my($this) = @_;
  $this->{raw_file_list} = FindFiles($this, $this->{from});
  $this->{pass_one_file_list} = [];
  $this->{pass_two_file_list} = [];
  $this->{DicomAnonymizer} = Posda::Anonymizer::Raw->new_blank();
  $this->{Anonymizing} = 1;
  my $loop = Dispatch::Select::Background->new(
    MakeLoopStepSearch($this));
  $loop->queue();
}


sub MakeLoopStepAnonymize{
  my($this, $anon) = @_;
  my %FileByDigest;
  my %FileByDatasetDigest;
  my $foo = sub {
    my $disp = shift;
    if(
      exists $this->{pass_one_file_list} && 
      ref($this->{pass_one_file_list}) eq "ARRAY" &&
      $#{$this->{pass_one_file_list}} >= 0
    ){
      my $pass_one_file = shift @{$this->{pass_one_file_list}};
      if($#{$this->{pass_one_file_list}} < 0){
        delete $this->{pass_one_file_list};
      }
      my $try = Posda::Try->new($pass_one_file);
      my $ds = $try->{dataset};
      my $file_digest = $try->{digest};
      my $dataset_digest;
      if(exists($try->{dataset_digest})){
        $dataset_digest = $try->{dataset_digest}
      }
      unless(exists $try->{dataset}){ die "WTF???" }
      if(exists $FileByDigest{$file_digest}){
        push(@{$this->{AnonymizationErrors}},
          "File \"$pass_one_file\" has the same content as file " .
          "\"$FileByDigest{$file_digest}\".  It is therefore being skipped.");
        $disp->queue();
        return;
      }
      if(defined $dataset_digest){
        if(exists $FileByDigest{$dataset_digest}){
          push(@{$this->{AnonymizationErrors}},
            "File \"$pass_one_file\" contains the dataset of file " .
            "\"$FileByDigest{$dataset_digest}\".  " .
            "It is therefore being skipped.");
          $disp->queue();
          return;
        }
        if(exists $FileByDatasetDigest{$dataset_digest}){
          push(@{$this->{AnonymizationErrors}},
            "File \"$pass_one_file\" contains the same dataset as file " .
            "\"$FileByDatasetDigest{$dataset_digest}\"." .
            "  It is therefore being skipped.");
          $disp->queue();
          return;
        }
        $FileByDatasetDigest{$dataset_digest} = $pass_one_file;
      }
      $FileByDigest{$file_digest} = $pass_one_file;
      my $sop_inst = $ds->ExtractElementBySig("(0008,0018)");
      my $modality = $ds->ExtractElementBySig("(0008,0060)");
      unless(defined $sop_inst){
        push(@{$this->{AnonymizationErrors}},
          "File \"$pass_one_file\" has no SOP Instance UID. " .
          "  It is therefore being skipped.");
          $disp->queue();
          return;
      }
      unless(defined $modality){
        push(@{$this->{AnonymizationErrors}},
          "File \"$pass_one_file\" has no Modality. " .
          "  It is therefore being skipped.");
          $disp->queue();
          return;
      }
      push(@{$this->{pass_two_file_list}}, $pass_one_file);
      $anon->pass_one($ds);
      $disp->queue();
      return;
    }
    unless(
      exists($this->{pass_two_file_list}) &&
      ref($this->{pass_two_file_list}) eq "ARRAY" &&
      $#{$this->{pass_two_file_list}} >= 0
    ){
      delete $this->{Anonymizing};
      if($this->can("AnonComplete")){
        $this->AnonComplete();
      }
      return;
    }
    my $file = shift @{$this->{pass_two_file_list}};
    if($#{$this->{pass_two_file_list}} < 0){
      delete $this->{pass_two_file_list};
    }
    my $try = Posda::Try->new($file);
    unless($try->{status} eq "parsed dicom file") {
      die "$file didn't parse for pass two";
    }
    my $ds = $try->{dataset};
    $anon->pass_two($ds);
    $ds->InsertElementBySig("(0012,0062)", "YES");
    $ds->InsertElementBySig("(0012,0063)",
      ["Posda Anonymizer", "Dicom Tools"]);
    my $sop_inst = $ds->ExtractElementBySig("(0008,0018)");
    my $modality = $ds->ExtractElementBySig("(0008,0060)");
    my $dest_file = "$this->{to}/${modality}_$sop_inst.dcm";
    push(@{$this->{AnonymizationResults}}, {
       from => $file,
       to => $dest_file,
    });
    $ds->MapToConvertPvt();
    $ds->WritePart10($dest_file, $try->{xfr_stx}, "POSDA_ANON", undef, undef);
    $disp->queue();
  };
  return $foo;
}
sub StartAnonymization {
  my($this, $anon) = @_;
  $this->{AnonymizationResults} = [];
  $this->{AnonymizationErrors} = [];
  $this->{Anonymizing} = 1;
  my $loop = Dispatch::Select::Background->new(
    MakeLoopStepAnonymize($this, $anon));
  $loop->queue();
}

sub MakePassOneFileLoopStep{
  my($this) = @_;
  my $foo = sub {
    my $disp = shift();
    unless(
      exists($this->{raw_file_list}) &&
      ref($this->{raw_file_list}) eq "ARRAY" &&
      $#{$this->{raw_file_list}} >= 0
    ){
      delete $this->{raw_file_list};
      delete $this->{Anonymizing};
      return;
    }
    my $file = shift(@{$this->{raw_file_list}});
    my $try = Posda::Try->new($file);
    if(exists $try->{dataset}){
      push(@{$this->{pass_one_file_list}}, $file);
    }
    $disp->queue();
  };
  return $foo;
}

sub StartFileSearch{
  my($this) = @_;
  $this->{raw_file_list} = FindFiles($this, $this->{from});
  $this->{pass_one_file_list} = [];
  $this->{pass_two_file_list} = [];
  $this->{Anonymizing} = 1;
  my $loop = Dispatch::Select::Background->new(
    MakePassOneFileLoopStep($this));
  $loop->queue();
}
1;

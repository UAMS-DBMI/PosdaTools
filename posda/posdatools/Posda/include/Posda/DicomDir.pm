#! /usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
package Posda::DicomDir;
use Posda::Parser;
use strict;
use Posda::Dataset;
sub MakeMapFun{
  my($state) = @_;
  return sub {
    my($ds, $curr_loc, $level, $ele_num, $offset, $size) = @_;
    my $in_use = $ds->ExtractElementBySig("(0004,1410)");
    my $rec_type = $ds->ExtractElementBySig("(0004,1430)");
    my $priv_rec_uid = $ds->ExtractElementBySig("(0004,1432)");
    my $ref_file_id = $ds->ExtractElementBySig("(0004,1500)");
    my $ref_sopcl_in_file = $ds->ExtractElementBySig("(0004,1510)");
    my $ref_sopinst_in_file = $ds->ExtractElementBySig("(0004,1511)");
    my $ref_xfrstx_in_file = $ds->ExtractElementBySig("(0004,1512)");
    my $ref_rel_gen_sopcl_in_file = $ds->ExtractElementBySig("(0004,151a)");
    my $rec = {
      in_use => $in_use,
      type => $rec_type,
      priv_rec_uid => $priv_rec_uid,
      ref_file_id => $ref_file_id,
      ref_sopcl_in_file => $ref_sopcl_in_file,
      ref_sopinst_in_file => $ref_sopinst_in_file,
      ref_xfrstx_in_file => $ref_xfrstx_in_file,
      ref_rel_gen_sopcl_in_file => $ref_rel_gen_sopcl_in_file,
      file_offset => $offset,
      length => $size,
    };
    my $hash;
    for my $i (keys %$ds){
      if($i == 4){ next }
      $hash->{$i} = $ds->{$i};
    }
    bless $hash, "Posda::Dataset";
    $rec->{identifier} = $hash;
    if($level == $state->{level}){
      push(@{$state->{children}}, $rec);
    } elsif ($level > $state->{level}){
      unless($level == $state->{level} + 1){
        die "increase in level greater than 1";
      }
      push(@{$state->{stack}}, $state->{children});
      $state->{level} += 1;
      $state->{children} = [ $rec ];
    } else {
      my $parent_list = pop(@{$state->{stack}});
      $parent_list->[$#{$parent_list}]->{children} = $state->{children};
      $state->{children} = $parent_list;
      $state->{level} -= 1;
      while($state->{level} > $level){
        $parent_list = pop(@{$state->{stack}});
        $parent_list->[$#{$parent_list}]->{children} = $state->{children};
        $state->{children} = $parent_list;
        $state->{level} -= 1;
      }
      push(@{$state->{children}}, $rec);
    }
  }
}
sub new_from_file{
  my($class, $file_name) = @_;
  my @errors;
  my($df, $ds, $size, $xfr_stx, $errors) = Posda::Dataset::Try($file_name);
  unless($ds){ die "$file_name didn't parse" }
  unless($df){ die "$file_name not DICOMDIR - no metaheader" }
  unless($df->{metaheader}->{"(0002,0002)"} eq "1.2.840.10008.1.3.10"){
    die "Not a DICOMDIR - SOP CLASS != \"1.2.840.10008.1.3.10\"";
  }
  if($errors && ref($errors) eq "ARRAY" && $#{$errors} >= 0){
    for my $e (@$errors){
      push @errors,  "Parse error: $e";
    }
  }
  return new_from_ds($class, $ds, \@errors);
}
sub new_from_ds{
  my($class, $ds, $errors) = @_;
  unless(defined $errors){
    my @errors;
    $errors = \@errors;
  }
  my $file_set_id = $ds->ExtractElementBySig("(0004,1130)");
  my $file_set_desc_id = $ds->ExtractElementBySig("(0004,1141)");
  my $spec_char_set_of_desc = $ds->ExtractElementBySig("(0004,1142)");
  my $consistent = $ds->ExtractElementBySig("(0004,1212)");
  unless($consistent == 0){
    die "bad value in directory consistency flag";
  }
  my $hash = {
    fs_id => $file_set_id,
    fs_desc_id => $file_set_desc_id,
    spec_char_set_of_desc => $spec_char_set_of_desc,
    parse_errors => $errors,
  };
  my $state = {
    level => 0,
    stack => [],
    children => [],
  };
  $ds->MapDicomDir(MakeMapFun($state));
  while($state->{level} > 0){
    my $parent_list = pop(@{$state->{stack}});
    $parent_list->[$#{$parent_list}]->{children} = $state->{children};
    $state->{children} = $parent_list;
    $state->{level} -= 1;
  }
  $hash->{dir_items} = $state->{children};
  return bless $hash, $class;
};
1;

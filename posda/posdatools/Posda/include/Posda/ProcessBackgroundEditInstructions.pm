#!/usr/bin/perl -w
use strict;
package Posda::ProcessBackgroundEditInstructions;
use Posda::DB 'Query';
use Data::UUID;
our $ug = Data::UUID->new;
sub get_uuid {
  return lc $ug->create_str();
}
use Debug;
my $dbg = sub { print @_ };
sub new {
  my($class) = @_;
  my $this = {};
  bless $this, $class;
  my $dest_dir = $this->DestDir;
  if(exists $this->{Error}) { return $this }
  if(-d $dest_dir) {
    $this->{dest_dir} = $dest_dir;
  } else {
   $this->{Error} = "$dest_dir is not a directory";
  }
  return $this;
}
sub DestDir{
  my($this) = @_;
  my $sub_dir = get_uuid();
  my $CacheDir = $ENV{POSDA_CACHE_ROOT};
  unless(-d $CacheDir){
    print "Error: Cache dir ($CacheDir) isn't a directory\n";
  }
  my $EditDir = "$CacheDir/edits";
  unless(-d $EditDir){
    unless(mkdir($EditDir) == 1){
      $this->{Error} =  "can't mkdir $EditDir ($!)";
      return;;
    }
  }
  my $DestDir = "$EditDir/$sub_dir";
  if(-e $DestDir) {
    $this->{Error} = "Destination dir ($DestDir) already exists\n";
    return;
  }
  unless(mkdir($DestDir) == 1){
    $this->{Error} =  "can't mkdir $DestDir ($!)";
    return;
  }
  return $DestDir;
}
my $input_help = <<EOF;
Expects lines of the form:
<obj_id>&<op>&<tag>&<val1>&<val2>

Lines specify the following things:
 - Series edits:
   An line with a value in obj_id specifies a series, study, or file to be edited.
   Such a line is not allowed to have anything in the <operation>, <tag>,
   <val1> or <val2> fields.  Generally, there will be some lines with values
   in <obj_id> followed by some lines with values in these other
   fields.  The edits specified in lines following these series specifications
   are specified in lines which have values in for <operation> and <tag>, and 
   may also have values in <val1> and <val2> (if the operation has parameters).
   The first line with a value in obj_id following a list of 
   operations resets the list of series (e.g.):
     <obj_id_1>
     <obj_id_2>
               <op1> <tag1> <val1> <val2>
               <op2> <tag2> <val1> <val2>
     <obj_id_3>
     <obj_id_4>
               <op3> <tag3>

      <op1> <tag1> and <op2> <tag2> are applied to <obj_id_1> and <obj_id_2>
      <op3> <tag3> is applied to <obj_id_3> and <obj_id_4>
  
Tags may be specified in any of the following ways (e.g):
  (0010,0010) - specifies the tag (0010,0010) tag_mode "exact"
  PatientName - Also specifies the tag (0010,0010) tag mode "exact",
     using keyword from standard
  Patient's Name - Also specifies the tag (0010,0010) tag mode "exact",
     using name from standard
  (0008,0008)[7] - Specifies the 8th item in the multi-valued tag (0008,0008)
     tag_mode "item".
     Note: you cant use tag names here.
  (0054,0016)[<0>](0018,1079) - Identifies all (0018,1079) tags which occur
     in any element of sequence contained in an (0054,0016) tag.
     tag_mode "pattern".
  (0054,0016)[0](0018,1079) - Identifies the (0018,1079) tag which occurs in
     the zero-ith (aka the first) element of the (0054,0016) sequence
     tag_mode "exact"
  ..(0018,1079) - Identifies all (0018,1079) tags which occur anywhere, 
     either at root, or in any sequence.  tag_mode "exact"
  (0013,"CTP",10) - Identifies the tag (0013,xx10) which occurs in a group
     0013 in which (0013,0010) has the value "CTP ".
     tag_mode "private"
  (0013,1010) - Identifies the tag (0013,1010), which may also be (and usually
     is) the tag identified by (0013,"CTP",10).  It is generally foolish to 
     count on this, but sometimes necessary to delve a little deeper 
     (perhaps you intend to create some erroneously encoded files?)
     tag_mode "exact"
     This is not currently supported in this version and will cause an error.
     It may be suported in future versions, but has a serious conflict with 
     support for "private" tag modes and both modes may not be supported in a
     single edit session.
   Along these lines, tag patterns which specify exact private tags
     eg "(00e1,1039)[<0>](0008,1110)[<1>](0008,1155)"
     are considered abominations and flagged as errors.
     patterns like:
     '(00e1,"ELSCINT1",39)[<0>](0008,1110)[<1>](0008,1155)' are fine, as are 
     patterns like:
     (00e1,"ELSCINT1",39)[<0>](0008,1110)[0](0008,1155), or
     (00e1,"ELSCINT1",39)[0](0008,1110)[<0>](0008,1155)
   Also, repeating tags (e.g. (60xx,0051)) are not supported.  They may 
   actually work if you enter the full tag value, but generally Posda support
   for repeating tags is a little sketchy.

The contents of the fields <tag>, <value1>, and <value2> may by enclosed in 
  "meta-quotes" (i.e. "<(0010,0010)>" for "(0010,0010)".  This is to prevent
  Excel from doing unnatural things to the values contained within.  If you
  want to specify a value which is actually includes meta-quotes, you have
  to double up the metaquotes. e.g."<<placeholder>>".  This script will strip
  only one level of metaquotes. caveat usor.
  Further complicating this, is an additional bit of extradorinary Excel
  madness which causes it to be (sometimes) almost impossible to delete a
  leading single quote in a cell. (I have no idea why or how they implemented
  this, but it must have been hard).
  So sometimes, metaquotes effectively look like "'<(0010,0010)>".
  A lone single quote before the left metaquote will be deleted along with
  the metaquotes.
EOF
sub InputHelp{
  my($class) = @_;
  return $input_help;
}
sub ProcessInput{
  my($this, $inp) = @_;
  if(exists $this->{Error}) { return }
  #Inputs will be parsed into these data structures
  #
  # $this->{objs_to_edit} = {
  #   <obj_id> => {
  #     from_file => <from_file>,
  #     to_file => <to_file>,
  #     edits => [
  #       {
  #         op => <op>,
  #         tag => <tag>,
  #         tag_mode => "exact"|"pattern"|"leaf"|"private"|"item",
  #         value1 => <value1>,
  #         value2 => <value2>
  #       },
  #       ...
  #     ]
  #   },
  #   ...
  # };
  #
  my $last_line_was_obj = 0;
  my $last_line_was_edit = 0;
  my $accumulating_objs = [];
  my $current_obj_list = [];
  my $accumulating_edits = [];
  line:
  while(my $line = <$inp>){
    chomp $line;
    my($obj_id, $op, $tag, $v1, $v2) =
      split(/&/, $line);
    if($obj_id){
      if($op) {
        $this->{Error} = "operation ($op) on same line as object ($obj_id)\n";
        return;
      }
      if($last_line_was_edit){
        $this->ProcessEndOfEdits($current_obj_list, $accumulating_edits);
        $current_obj_list = [];
        $accumulating_edits = [];
      }
      push @$accumulating_objs, $obj_id;
      $last_line_was_obj = 1;
      $last_line_was_edit = 0;
      next line;
    }
    if($op){
      if($last_line_was_obj) {
        $current_obj_list = $accumulating_objs;
        $accumulating_objs = [];
        unless($#{$current_obj_list} >= 0){
          $this->{Error} = "operation($op) applies to no objects\n";
          return;
        }
      }
      push(@{$accumulating_edits}, [$op, $tag, $v1, $v2]);
      $last_line_was_obj = 0;
      $last_line_was_edit = 1;
    } elsif($last_line_was_edit) {
      $this->ProcessEndOfEdits($current_obj_list, $accumulating_edits);
      $accumulating_edits = [];
      $current_obj_list = [];
      $last_line_was_edit = 0;
    }
  }
  if($last_line_was_edit) {
    $this->ProcessEndOfEdits($current_obj_list, $accumulating_edits);
  }
}
sub ProcessEndOfEdits{
  my($this, $obj_list, $accumulating_edits) = @_;
  my @obj_ids_for_these_edits;
  for my $obj(@$obj_list){
    my $obhash = $this->GetObjectFileList($obj);
    for my $id(keys %{$obhash}){
      push(@obj_ids_for_these_edits, $id);
      if(exists $this->{objs_to_edit}->{$id}){
        $this->{Error} =  "the id ($id)\n  occurring in obj($obj)\n  " .
          "seems to have occurred also in an earlier obj\n";
        return;
      }
      $this->{objs_to_edit}->{$id}->{from_file} = $obhash->{$id}->{from_file};
      $this->{objs_to_edit}->{$id}->{to_file} = $obhash->{$id}->{to_file};
    }
  }
  for my $edit (@$accumulating_edits){
    my $processed_edit = $this->ProcessIndividualEdit($edit);
    for my $id(@obj_ids_for_these_edits){
      unless(exists $this->{objs_to_edit}->{$id}->{edits}){
        $this->{objs_to_edit}->{$id}->{edits} = [];
      }
      push(@{$this->{objs_to_edit}->{$id}->{edits}}, $processed_edit);
    }
  }
}
sub GetObjectFileList{
  my($this, $obj_id) = @_;
  $this->{Error} = "GetObjectFileList must be overriden";
  return {};
}


#############################
### Process an Individual Edit
my $look_up_tag = Query("LookUpTag");
sub ProcessIndividualEdit{
  my($this, $edit) = @_;
  my $supported_edit_ops = {
    shift_date => 1,
    copy_date_from_tag_to_dt => 1,
    delete_tag => 1,
    set_tag => 1,
    substitute => 1,
    string_replace => 1,
    empty_tag => 1,
    short_hash => 1,
    hash_unhashed_uid => 1,
  };
  my($op, $tag, $v1, $v2) = @$edit;
  unless(exists $supported_edit_ops->{$op}){
    $this->{Error} = "Operation ($op) not supported";
    return;
  }
  $tag = $this->unmetaquote($tag);
  $v1 = $this->unmetaquote($v1);
  $v2 = $this->unmetaquote($v2);
  if($tag =~ /^[A-Za-z]*$/){
    my $tags;
    $look_up_tag->RunQuery(sub {
      my($row) = @_;
      my($tags1, $name, $keyword, $vr, $vm, $is_retired, $comments) = @$row;
      $tags = $tags1;
    }, sub {}, $tag, $tag);
    unless(defined $tags){
      $this->{Error} = "Error: Can't identify $tag";
      return;
    }
    $tag = $tags;
  }
  my $tag_mode = "exact";
  my $check_item_at_end = 0;
  if($tag =~ /\[\d+\]$/){
    $tag_mode = "item";
    $check_item_at_end = 1;
  }
  if($tag =~ /^\.\.(\(....,....\))$/) {
    $tag = $1;
    $tag_mode = "leaf";
  }
  if($tag =~ /</){
    $tag_mode = "pattern";
  }
  if($tag =~ /^\.\.(\(....,\"[^\"]*\",..\))$/) {
    $tag = $1;
    $tag_mode = "leaf";
  }
  if($this->look_for_private($tag)){
    $this->{Error} = "Private reference ($tag) not supported";
    return;
  }
  if($tag =~ /x/){
    $this->{Error} =  "repeating element <$tag> not supported";
    return;
  }
  if($check_item_at_end && $tag_mode ne "item"){
    $this->{Error} =  "Error: Bad item specification: $tag";
    return;
  }
  return {op => $op, tag =>$tag, tag_mode => $tag_mode, arg1 => $v1,
    arg2 =>  $v2};
}
sub unmetaquote{
  my($this, $v) = @_;
  if($v =~ /^<(.*)>$/) { $v = $1 }
  elsif($v =~ /^'<(.*)>$/) { $v = $1 }
  return $v;
}
sub look_for_private{
  my($this, $tag) = @_;
  my $remain = $tag;
  my $found_private;
  loop:
  while($remain ne ""){
    if($remain =~ /^(\(....,....\))(.*)$/){
      my $first_tag = $1; $remain = $2;
      $first_tag =~ /\(...(.),....\)$/;
      my $lsd = $1;
      if($lsd =~ /[13579bdf]/){
        $found_private = 1;
      }
    } elsif ($remain =~ /^(\(....,\"[^\"]*\",..\))(.*)$/){
      my $first_tag = $1; $remain = $2;
    } else {
      $this->{Error} =  "Error: didn't match a tag pattern in $tag";
      return;
    }
    if($remain =~ /^\[[^\]]*\](.*)/){
      $remain = $1;
    }
  }
  return $found_private;
}
sub FilesToEdit{
  my($this) = @_;
  return $this->{objs_to_edit};
}
sub EditDir{
  my($this) = @_;
  return $this->{dest_dir};
}
sub Debug{
  my($this, $out) = @_;
  &$out("Object to Edit ");
  Debug::GenPrint($out, $this->{objs_to_edit}, 1);
  &$out("\n");
}
1; 

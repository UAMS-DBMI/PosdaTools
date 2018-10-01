#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::BackgroundEditor;
use Posda::UUID;
use Posda::DownloadableFile; use Dispatch::Select;
use Dispatch::EventHandler;
use Dispatch::LineReader;
use Digest::MD5;
use FileHandle;
use Storable qw( store retrieve fd_retrieve store_fd );use Data::UUID;
our $ug = Data::UUID->new;
sub get_uuid {
  return lc $ug->create_str();
}

use Debug;
my $dbg = sub { print @_ };
$| = 1; # this should probably be at the top of the script, maybe in the lib?

my $usage = <<EOF;
Usage:
BackgroundEditStudy.pl <?bkgrnd_id?> "<description>" <notify>
or
BackgroundEditStudy.pl -h
Expects lines of the form:
<study_instance_uid>&<op>&<tag>&<val1>&<val2>

Lines specify the following things:
 - Study edits:
   An line with a value in study_instance_uid specifies a study to be edited.
   Such a line is not allowed to have anything in the <operation>, <tag>,
   <val1> or <val2> fields.  Generally, there will be some lines with values
   in <study_instance_uid> followed by some lines with values in these other
   fields.  The edits specified in lines following these study specifications
   are specified in lines which have values in for <operation> and <tag>, and 
   may also have values in <val1> and <val2> (if the operation has parameters).
   The first line with a value in study_instance_uid following a list of 
   operations resets the list of study (e.g.):
     <study1>
     <study2>
               <op1> <tag1>
               <op2> <tag2>
     <study3>
     <study4>
               <op3> <tag3>

      <op1> <tag1> and <op2> <tag2> are applied to <study1> and <study2>
      <op3> <tag3> is applied to <study3> and <study4>
  
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

Edited files will be stored underneath the specified <dest_root> in the 
following hierarchy:
  <dest_dir>/pat_<n>/study_<n1>/series_<n2>/<file_id>.dcm

where "pat_<n>" (for some n) corresponds to a unique "from" patient (in posda),
"study_<n1>" (for some n1) corresponds to a unique "from" study (in posda), 
"series_<n2>" (for some n2) corresponds to a unique "from" series (in posda),
and "<file_id>" is the "from" file_id (in posda).  Since any of these may be
changed in editing (they are usually, but not necessarily, changed consistently
in the edits). Again caveat usor.

As in all things, if you don't know what you are doing, you should:
  1) Ask yourself why you are doing it, or
  2) Ask someone to help, so you have some idea what you're doing, and
  3) Be very careful doing it.
I'm not sure about the whether the above is ((1 or 2) and 3) or 
  (1 or (2 and 3)) or whether it matters.

On the other hand, this script can't do a lot of damage, all it does is create
new files in the <dest_root> directory.  As long as you don't specify a really
bad place to create these files, recovery from a bad run simply means deleting
the bogus files you created.
Edit operations currently supported:
  shift_date(<tag>, <shift_count>)
  copy_date_from_tag_to_dt(<tag>, <from_tag>)
  delete_tag(<tag>)
  set_tag(<tag>, <value>)
  substitute(<tag>, <existing_value>, <new_value>)
  string_replace(<tag>, <old_text>, <new_text>)
  empty_tag(<tag>)
  short_hash(<tag>)
  hash_unhashed_uid(<tag>, <uid_root>)

This script uses the "NewSubprocessEditor.pl" as a subprocess to apply the
edits in parallel to individual files.

Maintainers:
Be careful that the version of this file is compatable with the version of
"NewSubprocessEditor.pl".  Why would it not be?  If you have changed one but
not the other...
EOF
#Inputs will be parsed into these data structures
my %SopsToEdit;
# $SopsToEdit = {
#   <sop> => {
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
my %PatientToNickname;
my $pat_seq = 0;
my %StudyToNickname;
my $study_seq = 0;
my %SeriesToNickname;
my $series_seq = 0;
#############################
## This routine checks for Duplicate SOPs
## This is a serious no-no, and causes
## the edits to all be aborted before they
## start.
sub CheckFiles{
  my($from_file, $to_file, $sop) = @_;
  unless(exists $SopsToEdit{$sop}){
    $SopsToEdit{$sop} = {
      from_file => $from_file,
      to_file => $to_file,
    };
  }
  my $sop_p = $SopsToEdit{$sop};
  unless(
    $sop_p->{from_file} eq $from_file &&
    $sop_p->{to_file} eq $to_file
  ){
    print "SOP vs file collision:\n" .
      "\tSOP: $sop\n" .
      "\tFrom:\n" .
      "\t\t$sop_p->{from_file}\n" .
      "\tvs\n" .
      "\t\t$from_file\n" .
      "\tTo:\n" .
      "\t\t$sop_p->{to_file}\n" .
      "\tvs\n" .
      "\t\t$to_file\n" .
      "Editing transaction aborted\n";
     die "abort";
  }
  return $sop_p;
}

#############################
## This code process parameters
##
#
#

if($#ARGV == 0) { die "$usage\n\n" }
if($#ARGV != 2){ print "Wrong args: $usage\n"; die "$usage\n\n" }
my($invoc_id, $description, $notify) = @ARGV;
#print "Undergoing maintenance\n";
#exit;

#############################
# Compute the Destination Dir (and die if it already exists)
my $sub_dir = get_uuid();
my $CacheDir = $ENV{POSDA_CACHE_ROOT};
unless(-d $CacheDir){
  print "Error: Cache dir ($CacheDir) isn't a directory\n";
}
my $EditDir = "$CacheDir/edits";
unless(-d $EditDir){
  unless(mkdir($EditDir) == 1){
    print "Error: can't mkdir $EditDir ($!)";
    exit;
  }
}
my $DestDir = "$EditDir/$sub_dir";
if(-e $DestDir) {
  print "Error: Destination dir ($DestDir) already exists\n";
  exit;
}
unless(mkdir($DestDir) == 1){
  print "Error: can't mkdir $DestDir ($!)";
  exit;
}

#############################
## This code parses the input and populates the hashes
## %SopsToEdit and %UidMapping
#

my $get_list_of_sops_and_files = Query("GetFilesAndSopsByStudy");
my $look_up_tag = Query("LookUpTag");
my $last_line_was_study = 0;
my $last_line_was_edit = 0;
my $accumulating_study = [];
my $current_study = [];
my $accumulating_edits = [];
line:
while(my $line = <STDIN>){
  chomp $line;
  my($study_uid, $op, $tag, $v1, $v2) =
    split(/&/, $line);
  if($study_uid){
    if($op) {
      print "Error: operation ($op) on same line as study ($study_uid)\n";
      exit;
    }
    if($last_line_was_edit){
      ProcessEndOfEdits();
    }
    push @$accumulating_study, $study_uid;
    $last_line_was_study = 1;
    next line;
  }
  if($op){
    if($last_line_was_study) {
      $current_study = $accumulating_study;
      $accumulating_study = [];
      unless($#{$current_study} >= 0){
        print "Error: operation($op) applies to no study\n";
        exit;
      }
    }
    push(@{$accumulating_edits}, [$op, $tag, $v1, $v2]);
    $last_line_was_study = 0;
    $last_line_was_edit = 1;
  } elsif ($last_line_was_edit){
    ProcessEndOfEdits();
    $last_line_was_edit = 0;
  }
}
if($last_line_was_edit) { ProcessEndOfEdits(); }

#############################
## Process a list of Edits with study list
#

sub ProcessEndOfEdits{
  my @sops_for_these_edits;
  for my $study(@$current_study){
    my $ss = GetStudyFileList($study);
    for my $sop(keys %$ss){
      if(exists $SopsToEdit{$sop}){
        print "Error: the sop ($sop)\n  occurring in study($study)\n  " .
          "seems to have occurred also in an earlier study\n";
        exit;
      }
      push @sops_for_these_edits, $sop;
      $SopsToEdit{$sop}->{from_file} = $ss->{$sop}->{from_file};
      $SopsToEdit{$sop}->{to_file} = $ss->{$sop}->{to_file};
    }
  }
  $current_study = [];
  for my $edit (@$accumulating_edits){
    my $processed_edit = ProcessIndividualEdit($edit);
    for my $sop(@sops_for_these_edits){
      unless(exists $SopsToEdit{$sop}->{edits}){
        $SopsToEdit{$sop}->{edits} = [];
      }
      push(@{$SopsToEdit{$sop}->{edits}}, $processed_edit);
    }
  }
  $accumulating_edits = [];
}

#############################
## Get all the info for a list of study
#

sub GetStudyFileList{
  my($study) = @_;
  my %study_struct;
  $get_list_of_sops_and_files->RunQuery(sub{
    my($row) = @_;
    my($pat_id, $study_id, $series_id, $sop, $file_id, $path) = @$row;
    if(exists $study_struct{$sop}){
      print "Error: duplicate sop ($sop) in study ($study)\n";
      exit;
    }
    unless(exists $PatientToNickname{$pat_id}){
      $pat_seq += 1;
      my $pat_nick = "pat_$pat_seq";
      $PatientToNickname{$pat_id} = "pat_$pat_seq";
      unless(-d "$DestDir/$pat_nick"){
        unless((mkdir "$DestDir/$pat_nick") == 1){
          print "Couldn't mkdir $DestDir/$pat_nick ($!)\n";
          exit;
        }
      }
    }
    my $pat_path = $PatientToNickname{$pat_id};
    unless(exists $StudyToNickname{$study_id}){
      $study_seq += 1;
      my $study_nick = "study_$study_seq";
      $StudyToNickname{$study_id} = "study_$study_seq";
      unless(-d "$DestDir/$pat_path/$study_nick"){
        unless((mkdir "$DestDir/$pat_path/$study_nick") == 1){
          print "Couldn't mkdir $DestDir/$pat_path/$study_nick ($!)\n";
          exit;
        }
      }
    }
    my $study_path = $StudyToNickname{$study_id};
    unless(exists $SeriesToNickname{$series_id}){
      $series_seq += 1;
      my $series_nick = "series_$series_seq";
      $SeriesToNickname{$series_id} = "series_$series_seq";
      unless(-d "$DestDir/$pat_path/$study_path/$series_nick"){
        unless((mkdir "$DestDir/$pat_path/$study_path/$series_nick") == 1){
          print "Couldn't mkdir $DestDir/$pat_path/$study_path/$series_nick ($!)\n";
          exit;
        }
      }
    }
    my $series_path = $SeriesToNickname{$series_id};
    my $dest_file = "$DestDir/$pat_path/$study_path/$series_path/" .
      "$file_id.dcm";
    $study_struct{$sop} = {
      from_file => $path,
      to_file => $dest_file,
    };
  }, sub {}, $study);
  return \%study_struct;
}

#############################
## Process an Individual Edit

sub ProcessIndividualEdit{
  my($edit) = @_;
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
    print "Operation ($op) not supported\n";
    exit;
  }
  $tag = unmetaquote($tag);
  $v1 = unmetaquote($v1);
  $v2 = unmetaquote($v2);
  if($tag =~ /^[A-Za-z]*$/){
    my $tags;
    $look_up_tag->RunQuery(sub {
      my($row) = @_;
      my($tags1, $name, $keyword, $vr, $vm, $is_retired, $comments) = @$row;
      $tags = $tags1;
    }, sub {}, $tag, $tag);
    unless(defined $tags){
      print "Error: Can't identify $tag\n";
      exit;
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
  if(look_for_private($tag)){
    print "Error: Private reference ($tag) not supported\n";
    exit;
  }
  if($tag =~ /x/){
    print "Error: repeating element <$tag> not supported\n";
    exit;
  }
  if($check_item_at_end && $tag_mode ne "item"){
    print "Error: Bad item specification: $tag\n";
    exit;
  }
  return {op => $op, tag =>$tag, tag_mode => $tag_mode, arg1 => $v1,
    arg2 =>  $v2};
}

sub unmetaquote{
  my($v) = @_;
  if($v =~ /^<(.*)>$/) { $v = $1 }
  elsif($v =~ /^'<(.*)>$/) { $v = $1 }
  return $v;
}

sub look_for_private{
  my($tag) = @_;
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
      print "Error: didn't match a tag pattern in $tag\n";
      exit;
    }
    if($remain =~ /^\[[^\]]*\](.*)/){
      $remain = $1;
#print "remain: $remain\n";
    }
#    } elsif($remain){
#      print "Error: found leftover ($remain) examining tag\n";
#      exit;
#    }
  }
  return $found_private;
}
#############################
## Uncomment these lines when testing just the processing of
## input
## Only do this for small test cases - it generates a lot of 
## rows in subprocess_lines and chews up a lot of time, etc.
#print "SopsToEdit: ";
#Debug::GenPrint($dbg, \%SopsToEdit, 1);
#print "\nUidMapping:  ";
#Debug::GenPrint($dbg, \%UidMapping, 1);
#print "\nPatientToNickname:  ";
#Debug::GenPrint($dbg, \%PatientToNickname, 1);
#print "\nStudyToNickname:  ";
#Debug::GenPrint($dbg, \%StudyToNickname, 1);
#print "\nSeriesToNickname:  ";
#Debug::GenPrint($dbg, \%SeriesToNickname, 1);
#print "\n";
#exit;
#
#

my $num_sops = keys %SopsToEdit;
print "Found list of $num_sops to edit\n";
print "Directory: $DestDir\n";
print "Subprocess_invocation_id: $invoc_id\n";
print "Forking background process\n";
#############################
# This is code which sets up the Background Process and Starts it
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
$background->Daemonize;
my $BackgroundPid = $$;
# now in the background...
$background->WriteToEmail("Starting edits on $num_sops sop_instance_uids\n" .
  "Description: $description\n" .
  "Results dir: $DestDir\n" .
  "Subprocess_invocation_id: $invoc_id\n");
$background->WriteToEmail("About to enter Dispatch Environment\n");

# Create row in dicom_edit_compare_disposition
my $ins = Query("CreateDicomEditCompareDisposition");
$ins->RunQuery(sub {}, sub{}, $invoc_id, $BackgroundPid, $DestDir);


# 
# The code which follows is used to create an instance of this object
# and turn it over to the Dispatcher
#

sub MakeEditor{
  my($sop_list, $sop_hash, $invoc_id) = @_;
  my $sub = sub {
    my($disp) = @_;
    Posda::BackgroundEditor->new(
      $sop_list, $sop_hash, $invoc_id, $notify, $background);
  };
  return $sub;
}
{
  my @sops = sort keys %SopsToEdit;
  Dispatch::Select::Background->new(
    MakeEditor(\@sops, \%SopsToEdit, $invoc_id))->queue;
}
Dispatch::Select::Dispatch();

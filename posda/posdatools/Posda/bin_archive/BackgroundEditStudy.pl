#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::BackgroundEditor;
use Posda::ProcessBackgroundEditStudyInstructions;
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

if($#ARGV == 0) { die "$usage\n\n" }
if($#ARGV != 2){ print "Wrong args: $usage\n"; die "$usage\n\n" }
my($invoc_id, $description, $notify) = @ARGV;

my $InputProc = Posda::ProcessBackgroundEditStudyInstructions->new();
$InputProc->ProcessInput(\*STDIN);
my $FilesToEdit = $InputProc->FilesToEdit;
my $DestDir = $InputProc->EditDir;


my $num_files = keys %{$FilesToEdit};
print "Found list of $num_files to edit\n";
print "Directory: $DestDir\n";
print "Subprocess_invocation_id: $invoc_id\n";
#print "Forking background process\n";
#print "test only - not forking\n";
#exit;
#############################
# This is code which sets up the Background Process and Starts it
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
$background->Daemonize;
my $BackgroundPid = $$;
# now in the background...
$background->WriteToEmail("Starting edits on $num_files files\n" .
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
  my @files = sort keys %{$FilesToEdit};
  Dispatch::Select::Background->new(
    MakeEditor(\@files, $FilesToEdit, $invoc_id))->queue;
}
Dispatch::Select::Dispatch();

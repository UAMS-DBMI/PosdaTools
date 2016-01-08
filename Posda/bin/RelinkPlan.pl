#!/usr/bin/perl -w 
#$Source: /home/bbennett/pass/archive/Posda/bin/RelinkPlan.pl,v $
#$Date: 2012/11/12 21:59:50 $
#$Revision: 1.1 $
#
#Copyright 2012, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Try;
use Posda::UUID;
use Cwd;
if($ARGV[0] eq "-h"){
  print <<EOF;
Help for RelinkPlan.pl:
If the first argument is "-h" it produces this output, explaining its usage,
otherwise...
The first argument is the name of a files which must a DICOM RTPLAN.
The second argument is the SOP Instance UID of an RTSTRUCT to which the plan
should be relinked.
The third argument is the directory in which the new, relinked plan file is
to be written.  The new plan will have a new SOP Instance UID.

This script will produce two output lines.  The first give the UID of the
new plan, the second its file name.

Old SOP: <sop_instance_uid>
New SOP: <sop_instance_uid>
New File: <file_name>

There may be a lot of messages on STDERR.
EOF
  exit;
}
my $here = getcwd;
my $plan = shift @ARGV;
my $mapped_uid = shift @ARGV;
my $dir = shift @ARGV;
unless(-f $plan) { die "$plan is not a file" }
unless(-d $dir) { die "$dir is not a directory" }
my $try = Posda::Try->new($plan);
unless($try && exists $try->{dataset}){ die "$plan is not a DICOM file" }
my $modality = $try->{dataset}->Get("(0008,0060)");
unless($modality eq "RTPLAN"){ die "$plan is not an RTPLAN ($modality)" }
my $new_uid = Posda::UUID::GetUUID;
my $old_uid = $try->{dataset}->Get("(0008,0018)");
$try->{dataset}->Insert("(0008,0018)", $new_uid);
my $new_file = "$dir/RTP_$new_uid.dcm";
$try->{dataset}->Insert("(300c,0060)[0](0008,1150)",
 "1.2.840.10008.5.1.4.1.1.481.3");
$try->{dataset}->Insert("(300c,0060)[0](0008,1155)", $mapped_uid);
$try->{dataset}->WritePart10($new_file, $try->{xfr_stx}, "POSDA");
print "Old SOP: $old_uid\n";
print "New SOP: $new_uid\n";
print "New File: $new_file\n";

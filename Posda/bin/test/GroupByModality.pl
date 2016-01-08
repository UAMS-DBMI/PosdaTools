#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/test/GroupByModality.pl,v $
#$Date: 2012/04/26 14:40:00 $
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
use Posda::Find;
use Posda::UUID;
use Cwd;
my %mod_to_series_uid;
my %mod_sop_index;
my $uid_index = 1;
my $sop_inst_index = 1;
my $study_uid = Posda::UUID::GetUUID;
unless($#ARGV == 1){
  die "Usage: $0 <from_dir> <to_dir>";
}
my $cur = getcwd;
my $from_dir = $ARGV[0];
my $to_dir = $ARGV[1];
unless($from_dir =~ /^\//){ $from_dir = "$cur/$from_dir" }
unless($to_dir =~ /^\//){ $to_dir = "$cur/$to_dir" }
unless(-d $from_dir) { die "$from_dir is not a directory" }
unless(-d $to_dir) { die "$to_dir is not a directory" }
sub ProcessFile{
  my($try) = @_;
  my $modality = $try->{dataset}->Get("(0008,0060)");
  unless(defined $modality) { return }
  unless(exists $mod_to_series_uid{$modality}){
    $mod_to_series_uid{$modality} = "$study_uid.$uid_index";
    $mod_sop_index{$modality} = 1;
    $uid_index += 1;
  }
  my $series_inst_uid = $mod_to_series_uid{$modality};
  my $sop_inst_uid = "$series_inst_uid.$mod_sop_index{$modality}";
  $mod_sop_index{$modality} += 1;
  $try->{dataset}->Insert("(0008,0018)", $sop_inst_uid);
  $try->{dataset}->Insert("(0020,000d)", $study_uid);
  $try->{dataset}->Insert("(0020,000e)", $series_inst_uid);
  my $file_name = "$ARGV[1]/${modality}_$sop_inst_uid.dcm";
  $try->{dataset}->WritePart10($file_name, $try->{xfr_stx}, "POSDA");
};
Posda::Find::DicomOnly($from_dir, \&ProcessFile);

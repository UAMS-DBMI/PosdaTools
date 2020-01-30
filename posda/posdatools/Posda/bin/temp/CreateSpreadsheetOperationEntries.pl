#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query', 'GetHandle';
use Debug;
my $dbg = sub { print @_ };
my $usage = <<EOF;
usage:
CreateSpreadsheetOperationEntries.pl [-i] [-r] [-h]

Will verify contents of the spreadsheet operation table (in the current Posda environment) against those
listed in this file.

if [-i] is specified, will insert any rows not in the database.
if [-r] is specified, will replace any non-matching rows in the database.
if [-h] is specified, will print this help file (and do nothing else).
EOF
my $DoInsert = 0;
my $DoReplace = 0;
my $Help = 0;
for my $p (@ARGV){
  unless ($p =~ /^-([irh]*)$/){
    die "Unrecognized parameter: $p\n" . $usage;
  }
  my $remain = $1;
  if($remain =~ /i/){
    $DoInsert = 1;
  }
  if($remain =~ /r/){
    $DoReplace = 1;
  }
  if($remain =~ /h/){
    $Help = 1;
  }
}
if($Help){
  print $usage;
  exit;
}
my $rows = {
    CreateActivityTimepointFromImportName => {
      command_line => 'CreateActivityTimepointFromImportName.pl <?bkgrnd_id?> <activity_id> "<import_name>" "<comment>" <notify>',
      operation_type => 'background_process',
      input_line_format => undef,
      tags => [
        "activity_timepoints"
      ],
      can_chain => undef
    },
    CreateActivityTimepointFromCollectionSite => {
      command_line => 'CreateActivityTimepointFromCollectionSite.pl <?bkgrnd_id?> <collection> <site> <activity_id> "<comment>" <notify>',
      operation_type => 'background_process',
      input_line_format => undef,
      tags => [
        "timepoint_buttons"
      ],
      can_chain => undef
    },
    VisualReviewFromTimepoint => {
      command_line => 'ScheduleVisualReviewFromActivityTimepoint.pl <?bkgrnd_id?> <activity_id> <notify>',
      operation_type => 'background_process',
      input_line_format => undef,
      tags => [
        "visual_review"
      ],
      can_chain => undef
    },
    PhiReviewFromTimepoint => {
      command_line => 'SchedulePhiReviewFromActivityTimepoint.pl <?bkgrnd_id?> <activity_id> <notify>',
      operation_type => 'background_process',
      input_line_format => undef,
      tags => [
        "visual_review"
      ],
      can_chain => undef
    },
    ConsistencyFromTimePoint => {
      command_line => 'AnalyzeStudySeriesConsistencyByActivity.pl <?bkgrnd_id?> <activity_id> <notify>',
      operation_type => 'background_process',
      input_line_format => undef,
      tags => [
        "timepoint_buttons"
      ],
      can_chain => undef
    },
    LinkRtFromTimepoint => {
      command_line => 'LinkRtByActivityTimepoint.pl <?bkgrnd_id?> <activity_id> <notify>',
      operation_type => 'background_process',
      input_line_format => undef,
      tags => [
        "timepoint_buttons"
      ],
      can_chain => undef
    },
    CheckStructLinkagesTp => {
      command_line => 'CheckStructLinkagesTpId.pl <?bkgrnd_id?> <activity_id> <notify>',
      operation_type => 'background_process',
      input_line_format => undef,
      tags => [
        "timepoint_buttons"
      ],
      can_chain => undef
    },
    PhiPublicScanTp => {
      command_line => 'PhiPublicScanTp.pl <?bkgrnd_id?> <activity_id> <max_rows> <notify>',
      operation_type => 'background_process',
      input_line_format => undef,
      tags => [
        "simple_phi"
      ],
      can_chain => undef
    },
    SummarizeStructLinkage => {
      command_line => 'SummarizeStructLinkagesByFileId.pl <?bkgrnd_id?> <file_id> <notify>',
      operation_type => 'background_process',
      input_line_format => undef,
      tags => [
        "activity_timepoint_support"
      ],
      can_chain => undef
    },
    BackgroundDciodvfyTp => {
      command_line => 'BackgroundDciodvfyTp.pl <?bkgrnd_id?> <activity_id> <type> <notify>',
      operation_type => 'background_process',
      input_line_format => undef,
      tags => [
        "activity_timepoint"
      ],
      can_chain => undef
    },
    CondensedActivityTimepointReport => {
      command_line => 'CondensedActivityTimepointReport.pl <?bkgrnd_id?> <activity_id> <notify>',
      operation_type => 'background_process',
      input_line_format => undef,
      tags => [
        "timepoint_buttons"
      ],
      can_chain => undef
    },
    AnalyzeSeriesDuplicates => {
      command_line => 'AnalyzeSeriesDuplicates.pl <?bkgrnd_id?> "<collection>" <site> <notify>',
      operation_type => 'background_process',
      input_line_format => undef,
      tags => [
        "ACRIN-FMISO-Brain Duplicate Elimination",
        "dup_sops",
        "activity_timepoint_support"
      ],
      can_chain => undef
    },
    FilesInTpNotInPublic => {
      command_line => 'FilesInLatestActivityNotInPublic.pl <?bkgrnd_id?> <activity_id> <notify>',
      operation_type => 'background_process',
      input_line_format => undef,
      tags => [
        "activity_timepoints_support"
      ],
      can_chain => undef
    },
    CompareSopsInTpToPublic => {
      command_line => 'CompareSopsInTpToPublic.pl <?bkgrnd_id?> <activity_id> <notify>',
      operation_type => 'background_process',
      input_line_format => undef,
      tags => [
        "activity_timepoints_support"
      ],
      can_chain => undef
    },
    AnalyzeSeriesDuplicatesForTimepoint => {
      command_line => 'AnalyzeTpSeriesDuplicates.pl <?bkgrnd_id?> <activity_id> <notify>',
      operation_type => 'background_process',
      input_line_format => undef,
      tags => [
        "activity_timepoint_support"
      ],
      can_chain => undef
    },
    CompareSopsTpPosdaPublic => {
      command_line => 'CompareSopsTpPosdaPublic.pl <?bkgrnd_id?> "<collection>" <activity_id> <notify>',
      operation_type => 'background_process',
      input_line_format => undef,
      tags => [
        "activity_timepoint_support"
      ],
      can_chain => undef
    },
    BackgroundPrivateDispositionsTp => {
      command_line => 'BackgroundPrivateDispositionsTp.pl <?bkgrnd_id?> <activity_id> <uid_root> <offset> <notify>',
      operation_type => 'background_process',
      input_line_format => undef,
      tags => [
        "activity_timepoints"
      ],
      can_chain => undef
    },
    BackgroundPrivateDispositionsTpBaseline => {
      command_line => 'BackgroundPrivateDispositionsTpBaseline.pl <?bkgrnd_id?> <activity_id> <notify>',
      operation_type => 'background_process',
      input_line_format => undef,
      tags => [
        "activity_timepoints"
      ],
      can_chain => undef
    },
    CompareSopsTpPosdaPublicLike => {
      command_line => 'CompareSopsTpPosdaPublicLike.pl <?bkgrnd_id?> "<collection_like>" <activity_id> <notify>',
      operation_type => 'background_process',
      input_line_format => undef,
      tags => [
        "activity_timepoint_support"
      ],
      can_chain => undef
    },
    UpdateActivityTimepoint => {
      command_line => 'UpdateActivityTimepointForChange.pl <?bkgrnd_id?> <activity_id> "<comment>" <notify>',
      operation_type => 'background_process',
      input_line_format => undef,
      tags => [
        "timepoint_buttons"
      ],
      can_chain => undef
    },
};
my $gssop = Query("GetSpreadsheetOperationByName");
#my $inssop = Query("InsertSpreadsheetOperation");
#my $updssop = Query("UpdateSpreadsheetOperation");
my $cur_rows = {};
for my $op_name(keys %$rows){
  $gssop->RunQuery(sub{
    my($row) = @_;
    my $operation_name = $row->[0];
    my $command_line = $row->[1];
    my $operation_type = $row->[2];
    my $input_line_format = $row->[3];
    my $tags = $row->[4];
    my $can_chain = $row->[5];
    $cur_rows->{$operation_name} = {
      command_line => $command_line,
      operation_type => $operation_type,
      input_line_format => $input_line_format,
      tags => $tags,
      can_chain => $can_chain
    };
  }, sub {}, $op_name);
}
my $inserts;
my $updates;
op:
for my $op_name (keys %$rows){
  unless(exists $cur_rows->{$op_name}){
    print "$op_name is not in current\n";
    $inserts->{$op_name} = $rows->{$op_name};
    next op;
  }
  my $row = $rows->{$op_name};
  my $cur_row = $cur_rows->{$op_name};
  my $matches = 1;
  key:
  for my $k ("command_line", "operation_type", "input_line_format", "can_chain"){
    my $row_v = $row->{$k};
    my $cur_row_v = $cur_row->{$k};
    unless(defined $row_v) { $row_v = "<undef>" }
    unless(defined $cur_row_v) { $cur_row_v = "<undef>" }
    unless($row_v eq $cur_row_v){
      print "$op_name doesn't match (key $k: $row_v vs $cur_row_v)\n";
      $matches = 0;
      last key;
    }
  }
  if(
    $matches &&
    (
      ( !defined ref($row->{tags}) && !defined ref($cur_row->{tags}))
      ||
      (
        ref($row->{tags}) eq "ARRAY" &&
        ref($cur_row->{tags}) eq "ARRAY" &&
        $#{$row->{tags}} == $#{$cur_row->{tags}}
      )
    )
  ){
    tag:
    for my $t (0 .. $#{$row->{tags}}){
      unless($row->{tags}->[$t] eq $cur_row->{tags}->[$t]){
        print "$op_name tag[$t] mismatch ($row->{tags}->[$t] vs " .
          "$cur_row->{tags}->[$t])\n";
        $matches = 0;
        last tag;
      }
    }
  } else {
    my($tag1_desc, $tag2_desc);
    unless(defined $row->{tags}) { $tag1_desc = "<undef>" }
    unless(defined $cur_row->{tags}) { $tag2_desc = "<undef>" }
    if(ref($row->{tags}) eq "ARRAY"){
      my $v = "'{";
      for my $i (0 .. $#{$row->{tags}}){
        my $v .= $row->{tags}->[$i];
	unless($i == $#{$rows->{tags}}){ $v .= ","; }
      }
      $tag1_desc = "$v}'";
    }
    if(ref($cur_row->{tags}) eq "ARRAY"){
      my $v = "'{";
      for my $i (0 .. $#{$cur_row->{tags}}){
        my $v .= $cur_row->{tags}->[$i];
	unless($i == $#{$cur_rows->{tags}}){ $v .= ","; }
      }
      $tag2_desc = "$v}'";
    }
    unless($tag1_desc eq $tag2_desc){
      print "$op_name doesn't match in particulars ($tag1_desc vs $tag2_desc)\n";
    }
  }
  unless($matches){
    $updates->{$op_name} = $row;
    next op;
  }
  print "spreadsheet operation ($op_name) is up to date\n";
}
if($DoInsert) {
  print "Insert goes here\n";
}
if($DoReplace) {
  print "Replace goes here\n";
  Debug::GenPrint($dbg, $updates, 1);
  print "\n";
}

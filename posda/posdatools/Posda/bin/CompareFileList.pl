#!/usr/bin/perl -w
use strict;
use File::Temp qw/ tempfile /;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::Try;
use Posda::DiffDicom;
use Digest::MD5;
use FileHandle;
use Storable qw( store retrieve fd_retrieve store_fd );


#use Debug;
#my $dbg = sub { print STDERR @_ };
#my $dbg = sub { print @_ };

my $usage = <<EOF;
Usage:
CompareFileList.pl <?bkgrnd_id?> <activity_id> <notify>
or
CompareFileList.pl -h
Expects lines of the form:
<from_file_id>&<to_file_path>

This program compares a set of files in Posda to corresponding files (which
may or may not be in Posda, but are in directories accessible to Posda).
For example the files may be in nbia, or may be in a directory simulating nbia
(As in the case of BackgroundApplyDispositionTp.pl to directory...)

It's primary use case is to see what changes arise from ApplyingDispositions.
This script will produce the following reports:
  EditDifferences: A difference report similar to that produced by Background 
                   Editors.
  UnchangedFiles:  A list of file_id's which were not changed.
  CompareErrors:   A list of file_id's for which the compare errored, with
                   an error message.

It will also populate the dicom_edit_compare table in the posda_files 
database. This table can be used to drill down into the differences 
in the differences.
EOF

if($#ARGV == 0 && $ARGV[0] eq "-h") { print "$usage\n\n"; exit }
if($#ARGV != 2){ print "Wrong args: $usage\n"; die "$usage\n\n" }
my($invoc_id, $activity_id, $notify) = @ARGV;

print "All processing in background\n";
my @Params;
my $back = 
  Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$back->Daemonize;

$back->WriteToEmail("Starting reading file pairs\n");
my $num_lines = 0;
my $q = Query("PathAndDigestByFileId");
while(my $line = <STDIN>){
  $num_lines += 1;
  $back->SetActivityStatus("Reading line $num_lines");
  chomp $line;
  my($from_file_id, $to_file_path) = split(/&/, $line);
  my($from_file_path, $from_file_digest);
  $q->RunQuery(sub{
    my($row) = @_;
    $from_file_path = $row->[0];
    $from_file_digest = $row->[1];
  }, sub {}, $from_file_id);
  push @Params, [$from_file_id, $to_file_path,
                 $from_file_path, $from_file_digest];
#  $back->WriteToEmail("$from_file_id, $to_file_path, $from_file_path, $from_file_digest\n");
}
$back->WriteToEmail("Read $num_lines lines\n");

$back->WriteToEmail("Starting comparision $num_lines file pairs\n" .
  "Subprocess_invocation_id: $invoc_id\n");

my $rpt_unchanged = $back->CreateReport("UnchangedFiles");
$rpt_unchanged->print("\"file_id\"\r\n");
my $rpt_error = $back->CreateReport("CompareErrors");
$rpt_error->print("\"file_id\",\"error_message\"\r\n");

my $ins = PosdaDB::Queries->GetQueryInstance(
  "InsertIntoDicomEditCompareFixed");
my %FileIdByDig;
my $cur_cmp = 0;
my $num_pairs = @Params;
pair:
for my $pair(@Params){
  $cur_cmp += 1;
  my $num_diff = keys %FileIdByDig;
  $back->SetActivityStatus("Processing pair $cur_cmp of $num_pairs " .
    "($num_diff diff files)");
  my($from_file_id, $to_file_path, $from_file_path, $from_file_digest) =
    @$pair;
  my $ctx = Digest::MD5->new;
  my $fh;
  unless(open $fh, "<$from_file_path") {
    my $msg = "Couldn't open from file: $from_file_path ($!)";
    $msg =~ s/"/""/g;
    $rpt_error->print("$from_file_id,\"$msg\"\r\n");
    next pair;
  }
  $ctx->addfile($fh);
  close $fh;
  my $dig = $ctx->hexdigest;
  unless($from_file_digest eq $dig){
    my $msg = "From file digest different from DB: $dig vs $from_file_digest";
    $rpt_error->print("$from_file_id,\"$msg\"\r\n");
    next pair;
  }
  $ctx = Digest::MD5->new;
  unless(open $fh, "<$to_file_path"){
    my $msg = "Couldn't open to file ($to_file_path): $!";
    $msg =~ s/"/""/g;
    $rpt_error->print("$from_file_id,\"$msg\"\r\n");
    next pair;
  }
  $ctx->addfile($fh);
  close $fh;
  my $to_file_digest = $ctx->hexdigest;

  my $f_try = Posda::Try->new($from_file_path);
  unless(exists $f_try->{dataset}){
    my $msg = "from_file ($from_file_path) is not a dicom_file";
    $rpt_error->print("$from_file_id,\"$msg\"\r\n");
    next pair;
  }
  my $t_try = Posda::Try->new($to_file_path);
  unless(exists $t_try->{dataset}){
    my $msg = "to file ($to_file_path) is not a dicom_file";
    $rpt_error->print("$from_file_id,\"$msg\"\r\n");
    next pair;
  }
  my $fds = $f_try->{dataset};
  my $tds = $t_try->{dataset};
  my $f_dig = $f_try->{digest};
  my $t_dig = $t_try->{digest};
  my $diff = Posda::DiffDicom->new($fds, $tds);
  $diff->Analyze;
  my($only_in_from, $only_in_to, $different) =
    $diff->SemiDiffReport;
  my($s_rept, $l_rept) =
    $diff->ReportFromSemi($only_in_from, $only_in_to, $different);
  if(length($s_rept) <= 0){
    my $msg = "no lines in short rept";
    $rpt_error->print("$from_file_id,\"$msg\"\r\n");
    next line;
  }
  if(length($l_rept) <= 0){
    my $msg = "no lines in long rept";
    $rpt_error->print("$from_file_id,\"$msg\"\r\n");
    next line;
  }
  $ctx = Digest::MD5->new;
  $ctx->add($s_rept);
  my $s_rept_dig = $ctx->hexdigest;
  my $ctx1 = Digest::MD5->new;
  $ctx1->add($l_rept);
  my $l_rept_dig = $ctx1->hexdigest;
  my($s_rept_file_id, $l_rept_file_id);
  if(exists $FileIdByDig{$s_rept_dig}){
    $s_rept_file_id = $FileIdByDig{$s_rept_dig};
  } else {
    my($fhs, $short_rept) = tempfile();
    $fhs->print($s_rept);
    my $cmd =
      "ImportSingleFileIntoPosdaAndReturnId.pl \"$short_rept\" " .
      "\"Difference report\"";
    my $result = `$cmd`;
    unlink $short_rept;
    if($result =~ /File id: (.*)/){
      $s_rept_file_id = $1;
      $FileIdByDig{$s_rept_dig} = $s_rept_file_id;
    } else {
      my $msg = "Couldn't import short_rept into posda";
      $rpt_error->print("$from_file_id,\"$msg\"\r\n");
      next line;
    }
  }
  if(exists $FileIdByDig{$l_rept_dig}){
    $l_rept_file_id = $FileIdByDig{$l_rept_dig};
  } else {
    my($fhl, $long_rept) = tempfile();
    $fhl->print($l_rept);
    my $cmd =
      "ImportSingleFileIntoPosdaAndReturnId.pl \"$long_rept\" " .
      "\"Difference report\"";
    my $result = `$cmd`;
    unlink $long_rept;
    if($result =~ /File id: (.*)/){
      $l_rept_file_id = $1;
      $FileIdByDig{$l_rept_dig} = $l_rept_file_id;
    } else {
      my $msg = "Couldn't import short_rept into posda";
      $rpt_error->print("$from_file_id,\"$msg\"\r\n");
      next line;
    }
  }
  $ins->RunQuery(sub{}, sub{},
    $invoc_id, $f_dig, $t_dig, $s_rept_file_id, $l_rept_file_id, $to_file_path);
}
$back->SetActivityStatus("Generating diff report");
my $rpt_compare = $back->CreateReport("EditDifferences");
$rpt_compare->print("\"Short Report\"," .
  "\"Long Report\",\"short_file_id\",\"long_file_id\",\"num_files\"\r\n");
my $get_list = Query("DifferenceReportByEditId");
my $num_rows = 0;
my %data;
$get_list->RunQuery(sub {
  my($row) = @_;
  my($short_report_file_id, $long_report_file_id, $num_files) = @$row;
  $num_rows += 1;
  $data{$short_report_file_id}->{$long_report_file_id} = $num_files;
}, sub {}, $invoc_id);
my $num_short = keys %data;
my $get_path = Query("GetFilePath");
for my $short_id (keys %data){
  my $short_seen = 0;
  for my $long_id (keys %{$data{$short_id}}){
    my $num_files = $data{$short_id}->{$long_id};
    my $short_rept = "-";
    my $long_rept = "";
    unless($short_seen){
      $short_seen = 1;
      $get_path->RunQuery(sub{
        my($row) = @_;
        my $file = $row->[0];
        $short_rept = `cat $file`;
        chomp $short_rept;
      }, sub {}, $short_id);
    }
    $get_path->RunQuery(sub{
      my($row) = @_;
      my $file = $row->[0];
      $long_rept = `cat $file`;
      chomp $long_rept;
    }, sub {}, $long_id);
    $short_rept =~ s/"/""/g;
    $long_rept =~ s/"/""/g;
    $rpt_compare->print("\"$short_rept\"," .
      "\"$long_rept\",$short_id,$long_id,$num_files\r\n");
  }
}
$back->Finish("Done");

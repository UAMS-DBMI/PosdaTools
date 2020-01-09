#!/usr/bin/perl -w
use strict;
use File::Temp qw/ tempfile /;
use Posda::DB 'Query';
use Digest::MD5;
use Posda::BackgroundProcess;
use Posda::UUID;
use FileHandle;
our $ug = Data::UUID->new;
sub get_uuid {
  return lc $ug->create_str();
}

my $usage = <<EOF;
RepairBadVrs.pl <?bkgrnd_id?> <activity_id> <notify>
  <activity_id>> - activity
  <notify> - user to notify

Expects the following list on <STDIN>
  <file_id>

Does the following:
0) Create EditDir
1) Create dicom_edit_compare_disposition row
   Queries: CreateDicomEditCompareDisposition
     UpdateDicomEditCompareDisposition
     Finalize DicomEditCompareDisposition
     InsertIntoDicomEditCompareFixed
2) For each file_id:
    a) Read the file (as DICOM) Query: GetFilePath
    b) Write the file (as DICOM)
    c) Verify that it changed (via MD5-digest) , if so:
       create dicom_edit_compare row (like edits)
3) Hide all of the from files
4) Import all of the to files (script: ImportMultipleFilesIntoPosda.pl)
5) At the end create a new timepoint with
    a) visible files from the old timepoint
    b) all the to files
    Queries: CreateActivityTimepoint, GetActivityTimepointId
      InsertActivityTimepointFile
      VisibleFilesInTimepoint     
      FindVisibleToFiles

EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 2){
  my $n_args = @ARGV;
  my $mess = "Wrong number of args ($n_args vs 3). Usage:\n$usage\n";
  print $mess;
  die "######################## subprocess failed to start:\n" .
      "$mess\n" .
      "#####################################################\n";
}
my($invoc_id, $activity_id, $notify) = @ARGV;
my @files;
while(my $line = <STDIN>){
  chomp $line;
  $line =~ s/^\s*//;
  $line =~ s/\s*$//;
  push @files, $line;
}
my $num_files = @files;
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
print "Going to background to process $num_files files\n";
print "Directory: $DestDir\n";
print "Subprocess_invocation_id: $invoc_id\n";

my $back = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$back->Daemonize;
my $BackgroundPid = $$;

Query("CreateDicomEditCompareDisposition")->RunQuery(sub {}, sub{}, $invoc_id, $BackgroundPid, $DestDir);
my $upd = Query("UpdateDicomEditCompareDisposition");
my $fin = Query("FinalizeDicomEditCompareDisposition");


my $ins_cmp = Query("InsertIntoDicomEditCompareFixed");
my $q = Query("GetFilePath");
my $files_tried = 0;
my $files_changed = 0;
my $files_bad = 0;
file_id:
for my $f_id (@files){
  my $file;
  $q->RunQuery(sub{
    my($row) = @_;
    $file = $row ->[0];
  }, sub {}, $f_id);
  unless(defined $file) { next file_id }
  $files_tried += 1;
  my $new_file = "$DestDir/$f_id.temp";
  my $cmd = "ConvertToPart10.pl \"$file\" \"$new_file\"";
  open SUB, "$cmd|";
  while(my $line = <SUB>){};
  close SUB;
  unless(-f $new_file){
    $back->WriteToEmail("file: $f_id didn't parse on repair attempt\n");
    $files_bad += 1;
    $upd->RunQuery(sub {}, sub {},
        $files_tried, $files_changed,
        $files_bad, $invoc_id);
    $back->SetActivityStatus("fixed: $files_changed failed: $files_bad of $num_files");
    next file_id;
  }
  my $old_dig = GetDigest($file);
  my $new_dig = GetDigest($new_file);
  if($old_dig eq $new_dig) {
    $back->WriteToEmail("file: $f_id didn't change on repair attempt\n");
    $files_bad += 1;
    $upd->RunQuery(sub {}, sub {},
        $files_tried, $files_changed,
        $files_bad, $invoc_id);
    $back->SetActivityStatus("fixed: $files_changed failed: $files_bad of $num_files");
    next file_id;
  }
  $files_changed += 1;
  GenerateFileComparisons($file, $old_dig, $new_file, $new_dig, $invoc_id);
  $upd->RunQuery(sub {}, sub {},
        $files_tried, $files_changed,
        $files_bad, $invoc_id);
  $back->SetActivityStatus("fixed: $files_changed failed: $files_bad of $num_files");
}

my %ShortRepts;
my %LongRepts;
my %FileDigToFileId;

$fin->RunQuery(sub{}, sub{}, $invoc_id);
my $rpt_pipe = $back->CreateReport("EditDifferences");
$rpt_pipe->print("\"Short Report\"," .
  "\"Long Report\",\"short_file_id\",\"long_file_id\",\"num_files\"\r\n");
my %ShortPrinted;
for my $i (sort keys %ShortRepts){
  for my $j (sort keys %{$ShortRepts{$i}->{long_repts}}){
    if(exists $ShortPrinted{$i}){
      $rpt_pipe->print("-,");
    } else {
      my $text = $ShortRepts{$i}->{text};
      $text =~ s/"/""/g;
      $rpt_pipe->print("\"$text\",");
      $ShortPrinted{$i} = 1;
    }
    my $text = $LongRepts{$j}->{text};
    my $count = $LongRepts{$j}->{count};
    $text =~ s/"/""/g;
    $rpt_pipe->print("\"$text\",$i,$j,$count\r\n");
  }
}
my $op = "ScriptButton";
my $caption = "Reject Edits and Delete Temporary Files";
my $param_hash = {
  op => "OpenTableFreePopup",
  class_ => "Posda::ProcessPopup",
  cap_ => "RejectEditsTp",
  subprocess_invoc_id => $invoc_id,
  activity_id => $activity_id,
  notify => $notify
};
$back->InsertEmailButton($caption, $op, $param_hash);
$op = "ScriptButton";
$caption = "Accept Edits, Import and Delete Temporary Files";
$param_hash = {
  op => "OpenTableFreePopup",
  class_ => "Posda::ProcessPopup",
  cap_ => "ImportEditsTp",
  subprocess_invoc_id => $invoc_id,
  activity_id => $activity_id,
  notify => $notify
};
$back->InsertEmailButton($caption, $op, $param_hash);

$back->Finish("Done - Processed $num_files files");;



sub GetDigest{
  my($file) = @_;
  my $ctx = Digest::MD5->new;
  unless (open FILE, "$file"){
    $back->WriteToEmail(
      "Can't open $file to take digest\n");
    next item;
  }
  $ctx->addfile(\*FILE);
  my $dig = $ctx->hexdigest;
  close FILE;
  return $dig;
}
sub GenerateFileComparisons{
  my($from, $from_dig, $to, $to_dig, $invoc_id) = @_;
  my $cmd = "ShortLongCompare.pl \"$from\" \"$to\"";
  unless(open CMD, "$cmd|"){
    $back->WriteToEmail("Can't open cmd: $cmd\n");
    return 0;
  }
  my $short = "";
  my $long = "";
  my $mode;
  line:
  while(my $line = <CMD>){
    chomp $line;
    unless(defined $mode){
      if($line eq "short_rept:"){
        $mode = "short";
      } elsif($line eq "long_rept:"){
        $mode = "long";
      } else {
        $back->WriteToEmail("bad line: \"$line\"");
      }
      next line;
    }
    if($line =~ /^-+$/) {
      $mode = undef;
      next line;
    }
    if($mode eq "short"){
      $short .= "$line\n";
    } else {
      $long .= "$line\n";
    }
  }
  close CMD;
  if($short eq "") { $short = "no changes\n" };
  if($long eq "") { $long = "no changes\n" };
  my $ctx1 = Digest::MD5->new;
  $ctx1->add($short);
  my $s_dig = $ctx1->hexdigest;
  my $s_file_id;
  if(exists $FileDigToFileId{$s_dig}){
    $s_file_id = $FileDigToFileId{$s_dig};
  } else {
    my($fhs, $short_rept) = tempfile();
    $fhs->print($short);
    $fhs->close;
    my $cmd = "ImportSingleFileIntoPosdaAndReturnId.pl \"$short_rept\" " .
      "\"Difference report\"";
    my $result = `$cmd`;
    unlink $short_rept;
    if($result =~ /File id: (.*)/){
      $s_file_id = $1;
      $FileDigToFileId{$s_dig} = $s_file_id;
    } else {
      $back->WriteToEmail(
        "Unable to import short differences into Posda\n");
      next item;
    }
  }
  my $ctx2 = Digest::MD5->new;
  $ctx2->add($long);
  my $l_dig = $ctx2->hexdigest;
  my $l_file_id;
  if(exists $FileDigToFileId{$l_dig}){
    $l_file_id = $FileDigToFileId{$l_dig};
  } else {
    my($fhl, $long_rept) = tempfile();
    $fhl->print($long);
    $fhl->close;
    my $cmd = "ImportSingleFileIntoPosdaAndReturnId.pl \"$long_rept\" " .
      "\"Difference report\"";
    my $result = `$cmd`;
    unlink $long_rept;
    if($result =~ /File id: (.*)/){
      $l_file_id = $1;
      $FileDigToFileId{$l_dig} = $l_file_id;
    } else {
      $back->WriteToEmail(
        "Unable to import short differences into Posda\n");
      next item;
    }
  }
  $ins_cmp->RunQuery(sub{},sub{},
     $invoc_id, $from_dig, $to_dig, $s_file_id, $l_file_id, $to);
  $ShortRepts{$s_file_id}->{text} = $short;
  $ShortRepts{$s_file_id}->{long_repts}->{$l_file_id} = 1;
  $LongRepts{$l_file_id}->{text} = $long;
  unless(exists $LongRepts{$l_file_id}->{count}){
    $LongRepts{$l_file_id}->{count} = 0;
  }
  $LongRepts{$l_file_id}->{count} += 1;
}

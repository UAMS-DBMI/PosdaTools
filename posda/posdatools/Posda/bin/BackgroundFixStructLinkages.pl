#!/usr/bin/perl -w
use strict;
use File::Temp qw/ tempfile /;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::UUID;
use Digest::MD5;
use FileHandle;
our $ug = Data::UUID->new;
sub get_uuid {
  return lc $ug->create_str();
}

use Debug;
my $dbg = sub { print STDERR @_ };
$| = 1; # this should probably be at the top of the script, maybe in the lib?

my $usage = <<EOF;
Usage:
BackgroundFixStructLinkages.pl <?bkgrnd_id?> "<comment>" <notify>
or
BackgroundFixStructLinkages.pl -h
Expects lines of the form:
<series_instance_uid>&<struct_file_id>
EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}
unless($#ARGV == 2){
  die "Wrong number of args ($#ARGV):\n$usage";
}
my($invoc_id, $comment, $notify) = @ARGV;
my @Worklist;
while (my $line = <STDIN>){
  chomp $line;
  my($img_series, $struct_id) = split(/&/, $line);
  push @Worklist, [$img_series, $struct_id];
}

my $num_edits = @Worklist;;
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

print "Found list of $num_edits to edit\n";
print "Directory: $DestDir\n";
print "Subprocess_invocation_id: $invoc_id\n";
print "Forking background process\n";
#############################
# This is code which sets up the Background Process and Starts it
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
$background->Daemonize;
my $BackgroundPid = $$;
# now in the background...
$background->WriteToEmail("Starting relinka on $num_edits RTSTRUCTs\n" .
  "Comment: $comment\n" .
  "Results dir: $DestDir\n" .
  "Subprocess_invocation_id: $invoc_id\n");

my $rpt_pipe1 = $background->CreateReport("LinkageReport");
$rpt_pipe1->print("\"Image series_instance_uid\"," .
  "\"Structure Set file_id\",\"status\",\"errors\",\"linkage_report\"\r\n");

# Create row in dicom_edit_compare_disposition
my $ins = Query("CreateDicomEditCompareDisposition");
my $upd = Query("UpdateDicomEditCompareDisposition");
my $fin = Query("FinalizeDicomEditCompareDisposition");
$ins->RunQuery(sub {}, sub{}, $invoc_id, $BackgroundPid, $DestDir);

my $get_sop = Query("GetSopModalityPathDigest");
my $ins_cmp = Query("InsertIntoDicomEditCompareFixed");
my %FileDigToFileId;
my %ShortRepts;
my %LongRepts;
my $num_ok = 0;
my $num_bad = 0;
item:
for my $item (@Worklist){
  my($img_series, $ss_file_id) = @$item;
  my($sop, $modality, $path, $f_dig);
  $get_sop->RunQuery(sub{
    my($row) = @_;
    ($sop, $modality, $path, $f_dig) = @$row;
  },sub {}, $ss_file_id);
  my $dest_file = "$DestDir/${modality}_$sop.dcm";
  my $cmd = "TestStructFixer.pl $img_series $ss_file_id $dest_file";
  $background->WriteToEmail("cmd: $cmd\n");
  unless(open CMD, "$cmd|"){
    $background->WriteToEmail("Can't open cmd: $cmd\n");
    next item;
  }
  my $errors = "";
  my $report = "";
  my $status;
  while (my $line = <CMD>){
    chomp $line;
    if($line =~ /^Linked:\s*(.*)$/){
      $status = "OK";
      $dest_file = $1;
    } elsif ($line =~ /^Not linked/){
      $status = "Failed";
    } elsif ($line =~ /^Error:\s*(.*)$/){
      $errors .= "$1\n";
    } else {
      $report .= "$line\n";
    }
  }
  close CMD;
  $rpt_pipe1->print("$img_series,$ss_file_id,$status," .
    "\"$errors\",\"$report\"\r\n");
  if($status eq "OK"){ $num_ok += 1; } else { $num_bad += 1 }
  $upd->RunQuery(sub {}, sub {},
        $num_edits, $num_ok,
        $num_bad, $invoc_id);
  unless($status eq "OK") { next item }
  my $ctx = Digest::MD5->new;
  unless (open FILE, "$dest_file"){
    $background->WriteToEmail(
      "Can't open $dest_file to take digest\n");
    next item;
  }
  $ctx->addfile(\*FILE);
  my $t_dig = $ctx->hexdigest;
  $cmd = "ShortLongDicomCompare.pl $path $dest_file";
  $errors =~ s/"/""/g;
  $report =~ s/"/""/g;
  unless(open CMD, "$cmd|"){
    $background->WriteToEmail("Can't open cmd: $cmd\n");
    next item;
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
        $background->WriteToEmail("bad line: \"$line\"");
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
  if($short eq "" || $long eq ""){
    $background->WriteToEmail("$ss_file_id: no changes\n");
    next item;
  }
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
      $background->WriteToEmail(
        "$ss_file_id: Unable to import short differences into Posda\n");
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
      $background->WriteToEmail(
        "$ss_file_id: Unable to import short differences into Posda\n");
      next item;
    }
  }
  $ins_cmp->RunQuery(sub{},sub{},
     $invoc_id, $f_dig, $t_dig, $s_file_id, $l_file_id, $dest_file);
  $ShortRepts{$s_file_id}->{text} = $short;
  $ShortRepts{$s_file_id}->{long_repts}->{$l_file_id} = 1;
  $LongRepts{$l_file_id}->{text} = $long;
  unless(exists $LongRepts{$l_file_id}->{count}){
    $LongRepts{$l_file_id}->{count} = 0;
  }
  $LongRepts{$l_file_id}->{count} += 1;
}
$fin->RunQuery(sub{}, sub{}, $invoc_id);
my $rpt_pipe = $background->CreateReport("EditDifferences");
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
  class_ => "Posda::NewerProcessPopup",
  cap_ => "RejectEdits",
  subprocess_invoc_id => $invoc_id,
  notify => $notify
};
$background->InsertEmailButton($caption, $op, $param_hash);
$op = "ScriptButton";
$caption = "Accept Edits, Import and Delete Temporary Files";
$param_hash = {
  op => "OpenTableFreePopup",
  class_ => "Posda::NewerProcessPopup",
  cap_ => "ImportEdits",
  subprocess_invoc_id => $invoc_id,
  notify => $notify
};
$background->InsertEmailButton($caption, $op, $param_hash);
$background->Finish;

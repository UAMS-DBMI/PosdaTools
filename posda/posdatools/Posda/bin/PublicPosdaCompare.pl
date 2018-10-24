#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Digest::MD5;
use Posda::BackgroundProcess;
use Posda::DB::PosdaFilesQueries;
use Socket;

my $usage = <<EOF;
PublicPosdaCompare.pl <bkgrnd_id> <collection>  <notify>
or
PublicPosdaCompare.pl -h

The script doesn't expect lines on STDIN:
It generates lists of SOP Uids for a collection on both public and posda
and does a compare of the lists.

In test: reports on differences
EOF
print "This is obsolete - don't use\n";
exit;
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}
unless($#ARGV == 2){ die "$usage\n"; }

my ($invoc_id, $collections, $notify) = @ARGV;
my $get_posda_counts = PosdaDB::Queries->GetQueryInstance(
  "GetPosdaSopsForCompare");
my $get_public_counts = PosdaDB::Queries->GetQueryInstance(
  "GetPublicSopsForCompare");
my %PosdaHierarchy;
my %PosdaSops;
my %PosdaDup1Sops;
my %PosdaDup2Sops;
my %PosdaMultiDupSops;
my %PublicHierarchy;
my %PublicSops;
$get_posda_counts->RunQuery(sub {
    my($row) = @_;
    my $patient_id = $row->[0];
    my $study_uid = $row->[1];
    my $series_uid = $row->[2];
    my $sop_inst = $row->[3];
    my $sop_class = $row->[4];
    my $modality = $row->[5];
    my $dicom_file_type = $row->[6];
    my $file_path = $row->[7];
    my $file_id = $row->[8];
    my $h = {
       pat_id => $patient_id,
       study_uid => $study_uid,
       series_uid => $series_uid,
       sop_inst => $sop_inst,
       sop_class => $sop_class,
       modality => $modality,
       dicom_file_type => $dicom_file_type,
       file_path => $file_path,
       file_id => $file_id,
    };
    if(exists $PosdaSops{$sop_inst}){
      if(exists $PosdaDup1Sops{$sop_inst}){
        $PosdaDup2Sops{$sop_inst} = $h;
      } else {
        $PosdaDup1Sops{$sop_inst} = $h;
      }
    } else {
      $PosdaSops{$sop_inst} = $h;
      $PosdaHierarchy{$patient_id}->{$study_uid}->{$series_uid}
         ->{$sop_inst} = $PosdaSops{$sop_inst};
    }
  }, sub {},
  $ARGV[1]
);
$get_public_counts->RunQuery(sub {
    my($row) = @_;
    my $patient_id = $row->[0];
    my $study_uid = $row->[1];
    my $series_uid = $row->[2];
    my $sop_inst = $row->[3];
    my $sop_class = $row->[4];
    my $modality = $row->[5];
    my $dicom_file_uri = $row->[6];
    $dicom_file_uri =~ s/^.*\/storage/\/nas\/public\/storage/;
    $PublicSops{$sop_inst} = {
       pat_id => $patient_id,
       study_uid => $study_uid,
       series_uid => $series_uid,
       sop_inst => $sop_inst,
       sop_class => $sop_class,
       modality => $modality,
       file_path => $dicom_file_uri,
    };
    $PublicHierarchy{$patient_id}->{$study_uid}->{$series_uid}
       ->{$sop_inst} = $PublicSops{$sop_inst};
  }, sub {},
  $ARGV[1]
);
my %OnlyInPosda;
my %OnlyInPublic;
my %InBoth;
for my $sop (keys %PosdaSops){
  unless(exists $PublicSops{$sop}) { $OnlyInPosda{$sop} = 1 }
  else { $InBoth{$sop} = 1 }
}
for my $sop (keys %PublicSops){
  unless(exists $PosdaSops{$sop}) { $OnlyInPublic{$sop} = 1 }
}
my $total_in_posda = keys %PosdaSops;
my $total_in_public = keys %PublicSops;
my $only_in_posda = keys %OnlyInPosda;
my $only_in_public = keys %OnlyInPublic;
my $dup_sops_in_posda = keys %PosdaDup1Sops;
print "Total in Posda:     $total_in_posda\n" .
      "Total in Public:    $total_in_public\n" .
      "Only in Posda:      $only_in_posda\n" .
      "Only in Public:     $only_in_public\n" .
      "Dup Sops in Posda:  $dup_sops_in_posda\n";
my %BySop;
for my $i (keys %OnlyInPosda){
  my $h = $PosdaSops{$i};
  my $sop_desc = $h->{dicom_file_type};
  unless(exists $BySop{$sop_desc}) { $BySop{$sop_desc} = 0 }
  $BySop{$sop_desc} += 1;
}
print "Number of Sops in Posda but not in Public:\n";
for my $sop (keys %BySop){
  print "$BySop{$sop}:   $sop\n";
}

my $background = Posda::BackgroundProcess->new($invoc_id, $notify);

print "Entering Background\n";

$background->Daemonize;
my $bk_id = $background->GetBackgroundID;
my $start_time = `date`;
chomp $start_time;
$background->WriteToEmail("Starting Public/Posda Comparison at $start_time\n");
$background->WriteToEmail("BackgroundProcess Id: $bk_id\n");
close STDOUT;
close STDIN;
#####################
# Comparison Report
my($child, $child_pid) = ReadWriteChild(
  "StreamingPublicPosdaCompare.pl $bk_id");
my $commands_to_child = 0;
compare:
for my $sop (keys %InBoth){
  my $from = $PosdaSops{$sop}->{file_path};
  my $to = $PublicSops{$sop}->{file_path};
  my $id = $PosdaSops{$sop}->{file_id};
  my $line = "$sop|$from|$to|$id\n";
  $commands_to_child += 1;
  print $child $line;
  if(exists $PosdaDup1Sops{$sop}){
    $from = $PosdaDup1Sops{$sop}->{file_path};
    $id = $PosdaDup1Sops{$sop}->{file_id};
    $line = "$sop|$from|$to|$id\n";
    print $child $line;
    $commands_to_child += 1;
  print $child $line;
  }
  if(exists $PosdaDup2Sops{$sop}){
    $from = $PosdaDup2Sops{$sop}->{file_path};
    $id = $PosdaDup2Sops{$sop}->{file_id};
    $line = "$sop|$from|$to|$id\n";
    print $child $line;
    $commands_to_child += 1;
  }
}
print $child ("Prepare Report\n");
#shutdown $child, 1;
my $tt = `date`;
chomp $tt;
$background->WriteToEmail(
  "$tt - Sent ($commands_to_child) commands to child\n");
my %ProcessingErrors;
#not a dicom file:sop=$sop;from_file=$from_file;from_file_id=$posda_file_id
#not a dicom file:sop=$sop;to_file=$to_file
#Couldn't import short_rept into posda:sop=$sop
#Couldn't import long_rept into posda:sop=$sop\n";
read_line:
while(my $line = <$child>){
  chomp $line;
  if($line eq "End of Report") { last read_line }
  if($line =~ /^Error: (.*):\s*(.*)$/){
    my $err = $1;
    my $details = $2;
#    my @fields = split /;/, $2;
#    my $h;
#    for my $i (@fields) {
#      my($k, $v) = split /=/, $i;
#    }
    $ProcessingErrors{$err} = $details;
    next read_line;
  }
  $background->WriteToEmail("$line\n");
}
$tt = `date`;
chomp $tt;
$background->WriteToEmail("$tt - " .
  "(Great grand) Child processing complete\n");
$background->WriteToEmail("Starting Difference Report\n");
#### Here to generate report
my $diff_report = $background->CreateReport("DifferenceReport");
$diff_report->print("\"Short Report\"," .
  "\"Long Report\",\"short_file_id\"," .
  "\"long_file_id\",\"num_sops\",\"num_files\"\r\n");
my %data;
my $num_rows = 0;
my $get_list = PosdaDB::Queries->GetQueryInstance(
  "PublicDifferenceReportBySubprocessId");
$get_list->RunQuery(sub {
    my($row) = @_;
    my($short_report_file_id, $long_report_file_id, $num_sops, $num_files) = 
      @$row;
    $num_rows += 1;
    $data{$short_report_file_id}->{$long_report_file_id} = 
      [$num_sops, $num_files];
  }, sub {}, $bk_id);
my $num_short = keys %data;
my $get_path = PosdaDB::Queries->GetQueryInstance("GetFilePath");
for my $short_id (keys %data){
  my $short_seen = 0;
  for my $long_id (keys %{$data{$short_id}}){
    my $num_sops = $data{$short_id}->{$long_id}->[0];
    my $num_files = $data{$short_id}->{$long_id}->[1];
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
    $diff_report->print("\"$short_rept\"," .
      "\"$long_rept\",$short_id,$long_id,$num_sops,$num_files\r\n");
  }
}
my $at_text = `date`;
chomp $at_text;
$background->WriteToEmail("Difference Report finished at: $at_text\n");
#####################
# if posda has dup (unhidden) sops, produce report
if($dup_sops_in_posda > 0){
  my $dup_report = $background->CreateReport("DupReport");
  $dup_report->print("\"patient_id\",\"study_uid\",\"series_uid\"," .
    "\"sop_instance_uid\",\"file_id\"\r\n");
  for my $sop (keys %PosdaDup1Sops){
    my $file_id_1 = $PosdaSops{$sop}->{file_id};
    my $file_id_2 = $PosdaDup1Sops{$sop}->{file_id};
    my $patient_id_1 = $PosdaSops{$sop}->{pat_id};
    my $patient_id_2 = $PosdaDup1Sops{$sop}->{pat_id};
    my $study_uid_1 = $PosdaSops{$sop}->{study_uid};
    my $study_uid_2 = $PosdaDup1Sops{$sop}->{study_uid};
    my $series_uid_1 = $PosdaSops{$sop}->{series_uid};
    my $series_uid_2 = $PosdaDup1Sops{$sop}->{series_uid};
    if($patient_id_1 eq $patient_id_2){
      $dup_report->print ("\"$patient_id_1\",")
    } else {
      $dup_report->print ("\"$patient_id_1\n$patient_id_2\",")
    }
    if($study_uid_1 eq $study_uid_2){
      $dup_report->print ("\"$study_uid_1\",")
    } else {
      $dup_report->print ("\"$study_uid_1\n$study_uid_2\",")
    }
    if($series_uid_1 eq $series_uid_2){
      $dup_report->print ("\"$series_uid_1\",")
    } else {
      $dup_report->print ("\"$series_uid_1\n$series_uid_2\",")
    }
    $dup_report->print ("\"$sop\",");
    if($file_id_1 eq $file_id_2){
      $dup_report->print ("\"$file_id_1\",")
    } else {
      $dup_report->print ("\"$file_id_1\n$file_id_2\",")
    }
    $dup_report->print("\r\n");
  }
}
# end of dup sop report
#####################
# if posda has sops not in public, produce report
if($only_in_posda > 0){
  my $posda_only_report = $background->CreateReport("PosdaOnlyReport");
  $posda_only_report->print("\"patient_id\",\"study_uid\",\"series_uid\"," .
    "\"sop_instance_uid\",\"modality\",\"dicom obj type\"," .
    "\"file_id\"\r\n");
  for my $sop (keys %OnlyInPosda){
    my $pat_id = $PosdaSops{$sop}->{pat_id};
    my $study_uid = $PosdaSops{$sop}->{study_uid};
    my $series_uid = $PosdaSops{$sop}->{series_uid};
    my $modality = $PosdaSops{$sop}->{modality};
    my $obj_type = $PosdaSops{$sop}->{dicom_file_type};
    my $file_id = $PosdaSops{$sop}->{file_id};
    $posda_only_report->print("\"$pat_id\",\"$study_uid\",\"$series_uid\"," .
      "\"$sop\",\"$modality\",\"$obj_type\",\"$file_id\"\r\n");
  }
  $posda_only_report->print("\r\n");
}
# end of only in posda sop report
#####################
# if public has sops not in posda, produce report
if($only_in_public > 0){
  my $public_only_report = $background->CreateReport("PublicOnlyReport");
  $public_only_report->print("\"patient_id\",\"study_uid\",\"series_uid\"," .
    "\"sop_instance_uid\",\"modality\",\"sop class\"," .
    "\"file_path\"\r\n");
  for my $sop (keys %OnlyInPublic){
    my $pat_id = $PublicSops{$sop}->{pat_id};
    my $study_uid = $PublicSops{$sop}->{study_uid};
    my $series_uid = $PublicSops{$sop}->{series_uid};
    my $modality = $PublicSops{$sop}->{modality};
    my $obj_type = $PublicSops{$sop}->{sop_class};
    my $file_path = $PublicSops{$sop}->{file_path};
    $public_only_report->print("\"$pat_id\",\"$study_uid\",\"$series_uid\"," .
      "\"$sop\",\"$modality\",\"$obj_type\",\"$file_path\"\r\n");
  }
  $public_only_report->print("\r\n");
}
# end of only in public sop report
#####################
# if errors in compare, produce report
my $num_errors = keys %ProcessingErrors;
if($num_errors > 0){
  my $process_report = $background->CreateReport("CompareErrors");
  $process_report->print("\"error\",\"details\"\r\n");
  for my $err (keys %ProcessingErrors){
    $process_report->print("\"$err\",\"$ProcessingErrors{$err}\"\r\n");
  }
  $process_report->print("\r\n");
}
# end of errors in compare report
#####################

$background->Finish;
exit;
######  End of program
sub ReadWriteChild{
  my($cmd) = @_;
  my($child, $parent, $oldfh);
  socketpair($parent, $child, AF_UNIX, SOCK_STREAM, PF_UNSPEC) or
    die("socketpair: $!");
  $oldfh = select($parent); $| = 1; select($oldfh);
  $oldfh = select($child); $| = 1; select($oldfh);
  my $child_pid = fork;
  unless(defined $child_pid) {
    die("couldn't fork: $!");
  }
  if($child_pid == 0){
    close $child;
    close STDIN;
    close STDOUT;
    unless(open STDIN, "<&", $parent){die "Redirect of STDIN failed: $!"}
    unless(open STDOUT, ">&", $parent){die "Redirect of STDOUT failed: $!"}
    exec $cmd;
    die "exec failed: $!";
  } else {
    close $parent;
  }
  return $child, $child_pid;
}

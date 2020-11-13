#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::Dataset;
use Posda::BackgroundProcess;
use Data::Dumper;
use File::Temp qw/ tempfile /;
my $usage = <<EOF;
TomosynthesisConverterTP.pl <?bkgrnd_id?> <activity_id> <activity_timepoint_id> <notify>
  <activity_id>> - activity
  <activity_timepoint_id>> - activity_timepoint_id
  <notify> - user to notify

Expects nothing on <STDIN>

---
In progress converter to make invalid DICOM Tomosynthesis files valid.
Created for the Duke collection.

Based on FixReallyBadDicomFilesInTimepoint

--
Uses named queries:
   GetPathsForActivityTP
   FileIdsByActivityTimepointId
   CreateActivityTimepoint
   InsertActivityTimepointFile


EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 3){
  my $n_args = @ARGV;
  my $mess = "Wrong number of args ($n_args vs 4). Usage:\n$usage\n";
  print $mess;
  die "######################## subprocess failed to start:\n" .
      "$mess\n" .
      "#####################################################\n";
}
my($invoc_id, $activity_id, $activity_timepoint_id, $notify) = @ARGV;

print "Going to background\n";
my $back = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$back->Daemonize;

my $oq = Query("GetPathsForActivityTP");
my $i = 0;
my $start = time;
my %Files;
my %Conversions;

$oq->RunQuery(sub{
  my($row) = @_;
  my($file_id, $path) = @$row;
  $Files{$file_id} = $path;
}, sub {}, $activity_timepoint_id);
my $num_files = keys %Files;
my $num_done = 0;
my $num_failed = 0;
my $num_converted = 0;

print STDERR "\n Do I have any files? I see $num_files \n";
print STDERR Dumper(\%Files);
file:
for my $file (keys %Files){
  $num_done += 1;
  my $path = $Files{$file};
  my($sop_class, $sop_inst);
  my $cmd = "GetSopInfoFromMeta.pl $path";

  #Find values in header
  open FILE, "$cmd|";
  while (my $line = <FILE>){
    chomp $line;
    if($line =~ /^SOP Instance:\s*(.*)\s*$/){
      $sop_inst = $1;
    }
  }
  close FILE;

  #Find values at top level that should be moved to lower levels
  my($df, $ds, $size, $xfr_stx, $errors)  = Posda::Dataset::Try($path);
  unless($ds) { die "$path didn't parse into a dataset"; }
  my $numframes  = $ds->GetEle("(0028,0008)")->{value};
  my $bodypartthickness = $ds->GetEle("(0018,11a0)")->{value};
  my $ppa  = $ds->GetEle("(0018,9507)[0](0018,9538)[0](0018,1510)")->{value};
  my $sinTheta = sin($ppa);
  my $negativeCosTheta = cos($ppa) * -1;
  my $ippIncrement = ($bodypartthickness / $numframes);
  my $incrementedST = $sinTheta * $ippIncrement;
  my $incrementedNCT = $negativeCosTheta * $ippIncrement;
  my $IPP1 = 0;
  my $IPP3 = 0;

  my $laterality  = $ds->GetEle("(5200,9229)[0](0020,9071)[0](0020,9072)")->{value};
  my $dest_file = File::Temp::tempnam("/tmp", "New_$num_done");

  #Per frame functional groups
  for my $i (0..($numframes-1)){

    $ds->Insert("(5200,9230)[$i](0020,9113)[0](0020,0032)[0]", $IPP1 );                                   #Plane Position Sequence - Image Position Patient
    $ds->Insert("(5200,9230)[$i](0020,9113)[0](0020,0032)[1]", "0");                                      #Plane Position Sequence - Image Position Patient
    $ds->Insert("(5200,9230)[$i](0020,9113)[0](0020,0032)[2]", $IPP3);                                    #Plane Position Sequence - Image Position Patient
    $ds->Insert("(5200,9230)[$i](0020,9116)[0](0020,0037)[0]", "0");                                      #Plane Orientation Sequence - Image Orientation Patient
    if ($laterality eq 'L'){
      $ds->Insert("(5200,9230)[$i](0020,9116)[0](0020,0037)[1]", "1");                                    #Plane Orientation Sequence - Image Orientation Patient
    }else{
      $ds->Insert("(5200,9230)[$i](0020,9116)[0](0020,0037)[1]", "-1");                                   #Plane Orientation Sequence - Image Orientation Patient
      }
    $ds->Insert("(5200,9230)[$i](0020,9116)[0](0020,0037)[2]", "0");                                      #Plane Orientation Sequence - Image Orientation Patient
    $ds->Insert("(5200,9230)[$i](0020,9116)[0](0020,0037)[3]", $sinTheta);                                #Plane Orientation Sequence - Image Orientation Patient
    $ds->Insert("(5200,9230)[$i](0020,9116)[0](0020,0037)[4]", "0");                                      #Plane Orientation Sequence - Image Orientation Patient
    $ds->Insert("(5200,9230)[$i](0020,9116)[0](0020,0037)[5]", $negativeCosTheta);                        #Plane Orientation Sequence - Image Orientation Patient
    $IPP1 += $incrementedNCT;
    $IPP3 += $incrementedST;

  }


  if($df){
    $ds->WritePart10($dest_file, $xfr_stx, "POSDA", undef, undef);
  } else {
    $ds->WriteRawDicom($dest_file, $xfr_stx);
  }


  $cmd = "ImportSingleFileIntoPosdaAndReturnId.pl $dest_file \"Changing tags to make valid Tomosynthesis\"";
  my $result = `$cmd`;
  print STDERR "\n Result: $result ";
  my $new_file_id;
  $back->WriteToEmail("\n$result");
  if($result =~ /File id: (.*)/){
    $new_file_id = $1;
  }
  unlink $dest_file;
  unless(defined($new_file_id)){
    print STDERR "\n Unable to import file $dest_file\n($result) \n";
  }
  if($new_file_id != $file){
    $Conversions{$file} = $new_file_id;
    $num_converted += 1;
  } else {
    print STDERR "Meet the new file, same as the old file ($new_file_id)\n";
  }
}
print STDERR "Processed $num_done files\n Failed to get meta for $num_failed\n Converted $num_converted\n";
$back->WriteToEmail("\nProcessed $num_done files\nFailed to get meta for $num_failed\nConverted $num_converted\n");
if($num_converted > 0){
  my %FilesInNewTp;
  my $comment = "New Timepoint for ImportedEdits $invoc_id";
  Query("CreateActivityTimepoint")->RunQuery(sub {}, sub {},
    $activity_id, $0, $comment, $notify);
  my $new_tp;
  Query("GetActivityTimepointId")->RunQuery(sub {
    my($row) = @_;
    $new_tp = $row->[0];
  }, sub{});
  unless(defined $new_tp){
    exit;
  }
  $back->WriteToEmail("\nNew Timepoint created: $new_tp");

  my $num_copied = 0;
  my $num_replaced = 0;
  my $ins = Query('InsertActivityTimepointFile');
  for my $old_file (keys %Files){
    my $new_file;
    if(exists $Conversions{$old_file}){
      $new_file = $Conversions{$old_file};
      $num_replaced += 1;
    } else {
      $num_copied += 1;
      $new_file = $old_file;
    }
    $ins->RunQuery(sub{}, sub{}, $new_tp, $new_file);
    $FilesInNewTp{$new_file} = 1;
  }
} else {
  $back->WriteToEmail("No conversions, so no new timepoint\n");
}
my $elapsed = time - $start;
$back->WriteToEmail("\nProcessed $num_done files in $elapsed seconds\n");
$back->Finish("\nProcessed $num_done files in $elapsed seconds\n");

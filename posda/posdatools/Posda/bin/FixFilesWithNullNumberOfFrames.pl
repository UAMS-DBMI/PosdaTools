#!/usr/bin/perl -w
use strict;
use File::Temp qw/ tempfile /;
use Posda::BackgroundProcess;
use Posda::Try;
use Posda::DB 'Query';
my $usage = <<EOF;
FixFilesWithNullNumberOfFrames.pl <?bkgrnd_id?> "<comment>" <notify>

Ad hoc script to find and fix files with a null "Number of frames" tag
EOF
unless($#ARGV == 2) { die $usage }
my($invoc_id, $comment, $notify) = @ARGV;

my %Files;
my $find_em = Query('FindingFilesWithImageProblem');
$find_em->RunQuery(sub{
  my($row) = @_;
  my $file_id = $row->[0];
  my $path = $row->[1];
  $Files{$file_id} = $path;
},sub {});
my @file_ids = keys %Files;
my $num_files = @file_ids;
print "Found $num_files with potential problem\n";
print "Going to background for further analysis\n";
my $back = Posda::BackgroundProcess->new($invoc_id, $notify);
$back->Daemonize;
my %FilesFixed;
my %FilesNotFixed;
$back->WriteToEmail("Starting Fixup of Files with " .
  "blank Number of Frames");
file:
for my $i (0 .. $#file_ids){
  my $file_id = $file_ids[$i];
  my $path = $Files{$file_id};
  my $try = Posda::Try->new($path);
  unless(exists $try->{dataset}) { die "$path didn't parse" }
  my $foo = $try->{dataset}->Get("(0028,0008)");
  unless(defined $foo) {
    $back->WriteToWmil("$path has no (0028,0008)\n");
    $FilesNotFixed{$file_id} = 1;
    next file;
  }
  unless($foo eq ""){
    $back->WriteToEmail("$path has (0028,0008) = $foo\n");
    $FilesNotFixed{$file_id} = 1;
    next file;
  }
  print "$path has blank (0028,0008)\n";
  $try->{dataset}->Delete("(0028,0008)");
  my($fh, $new_dicom_file) = tempfile();
  $try->{dataset}->WritePart10($new_dicom_file, $try->{xfr_stx}, 
    "DICOM_TEST", undef, undef);
  my $cmd =
      "ImportSingleFileIntoPosdaAndReturnId.pl \"$new_dicom_file\" " .
      "\"Fixing files with null number of frames\"";
  my $result = `$cmd`;
  my $new_file_id;
  if($result =~ /File id: (.*)/){
    $new_file_id = $1;
    unlink $new_dicom_file;
  } else {
    $back->WriteToEmail("Failed: $file_id|Couldn't import fixed file into posda\n");
    unlink $new_dicom_file;
    $FilesNotFixed{$file_id} = 1;
    next file;
  }
  $FilesFixed{$file_id} = $new_file_id;
}
my $num_fixed = keys %FilesFixed;
my $num_not_fixed = keys %FilesNotFixed;
$back->WriteToEmail("$num_fixed files fixed\n");
$back->WriteToEmail("$num_not_fixed files not fixed\n");
if($num_fixed > 0){
  open HIDE, "|HideFilesWithStatus.pl $notify \"Deleted null number of frames\"";
  my $rpt1 = $back->CreateReport("Files Fixed");
  $rpt1->print ("from_file_id,to_file_id\r\n");
  for my $i (sort {$a <=> $b} keys %FilesFixed){
    $rpt1->print("$i,$FilesFixed{$i}\r\n");
    print HIDE "$i&<undef>\n";
  }
  close HIDE;
}
if($num_not_fixed > 0){
  my $rpt2 = $back->CreateReport("Files Not Fixed");
  $rpt2->print("file_id\r\n");
  for my $i (keys %FilesNotFixed){
    print "$i\r\n";
  }
}
$back->Finish;

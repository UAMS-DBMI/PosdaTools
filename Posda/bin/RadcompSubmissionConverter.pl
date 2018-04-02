#!/usr/bin/perl -w
use strict;
use File::Temp qw/ tempfile /;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Storable qw( store retrieve fd_retrieve store_fd );

use Debug;
my $dbg = sub { print @_ };
$| = 1; # this should probably be at the top of the script, maybe in the lib?

my $usage = <<EOF;
Usage:
RadcompSubmissionConverter.pl <bkgrnd_id> <notify>
or
RadcompSubmissionConverter.pl -h
Expects lines of the form:
<file_id>

EOF
if($#ARGV == 0 && $ARGV[0]) { print "$usage"; exit }
unless($#ARGV == 1){
  print "Wrong number of args ($#ARGV vs 1)\n$usage\n";
  exit;
}
my($invoc_id, $notify) = @ARGV;
my $get_file_info = Query("GetNonDicomConversionInfoById");
my %Files;
while(my $line = <STDIN>){
  chomp $line;
  my $file_id = $line;
  $get_file_info->RunQuery(sub {
    my($row) = @_;
    $Files{$file_id} = {
      path => $row->[0],
      file_type => $row->[1],
      file_sub_type => $row->[2],
      collection => $row->[3],
      site => $row->[4],
      subject => $row->[5],
      visibility => $row->[6],
      size => $row->[7],
      date_last_categorized => $row->[8]
    };
  }, sub {}, $file_id);
}
file_id:
for my $file_id (keys %Files){
  if(defined $Files{$file_id}->{visibility}){
    print "$file_id is hidden ($Files{visibility})\n";
    delete $Files{$file_id};
    next file_id;
  }
  unless(
   $Files{$file_id}->{file_type} eq "docx"  && 
   $Files{$file_id}->{file_sub_type} eq "radcomp data submittal form"
  ){
    print "$file_id has wrong type or subtype (" .
      "$Files{$file_id}->{file_type}, " .
      "$Files{$file_id}->{file_sub_type})\n";
    delete $Files{$file_id};
    next file_id;
  }
  unless(-f $Files{$file_id}->{path}){
    print "$file_id has nonexistent path: " .
      "$Files{$file_id}->{path}\n";
    delete $Files{$file_id};
    next file_id;
  }
}
my $num_files = keys %Files;
print "$num_files found to convert\n";
print "invoc_id: $invoc_id, notify: $notify\n";
unless(defined $invoc_id) { die "foo!" }
my $create_conversion = Query("CreateConversionEvent");
my $get_conversion_id = Query("GetConversionId");
$create_conversion->RunQuery(sub{}, sub{}, $notify,
  "RadcompSubmissionConverter.pl $invoc_id $notify");
my $conversion_id;
$get_conversion_id->RunQuery(sub{
  my($row) = @_;
  $conversion_id = $row->[0];
}, sub {});
unless(defined $conversion_id){
  print "Couldn't create conversion event\n";
  exit;
}
print "Conversion id: $conversion_id\n";
print "invoc_id: $invoc_id, notify: $notify\n";
print "Entering Background\n";
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
$background->Daemonize;

my $get_to_file_info = Query("GetFileSizeAndPathById");
my $create_ndf_change = Query("CreateNonDicomFileChangeRow");
my $update_ndf = Query("UpdateNonDicomFileById");
my $create_ndf = Query("CreateNonDicomFileById");
my $record_conversion = Query("RecordFileConversion");

$background->WriteToEmail(
  "Background of RadcompSubmissionConverter.pl($invoc_id, $notify)\n");
my $rpt = $background->CreateReport("ConversionSummary");
$rpt->print("\"collection\",\"site\",\"subject\",".
  "\"from_file_id\",\"from_file_path\"," .
  "\"from_file_size\",\"to_file_id\",\"to_file_path\"," .
  "\"to_file_size\",\"comment\"\n");
file_id:
for my $file_id (keys %Files){
  my $from_file = $Files{$file_id}->{path};
  my $from_file_type = $Files{$file_id}->{file_type};
  my $file_sub_type = $Files{$file_id}->{file_sub_type};
  my $collection = $Files{$file_id}->{collection};
  my $site = $Files{$file_id}->{site};
  my $subject = $Files{$file_id}->{subject};
  my $old_visibility = $Files{$file_id}->{visibility};
  if($old_visibility eq ""){ $old_visibility = "<undef>" }
  my $from_file_size = $Files{$file_id}->{size};
  my $date_last_categorized = $Files{$file_id}->{date_last_categorized};
  my ($t_fh, $to_temp) = tempfile();
  print STDERR "tempfile: $to_temp\n";
  my $cmd = "docx2txt.pl \"$from_file\" - |ParseRadcompDocx.pl";
  print STDERR "Command: $cmd\n";
  open CMD, "-|", "$cmd" or die "Can't open CMD ($!)";
  while(my $line = <CMD>){
    $t_fh->print($line);
  }
  close CMD;
  $t_fh->close;
  my $i_cmd = "ImportSingleFileIntoPosdaAndReturnId.pl \"$to_temp\" " .
    "\"Difference report\"";
  my $to_file_id;
  my $result = `$i_cmd`;
  if($result =~ /File id: (.*)/){
    $to_file_id = $1;
  } else {
    $rpt->print("\"$collection\",\"$site\",\"$subject\"," .
      "\"$file_id\",\"$from_file\"," .
      "\"$from_file_size\",\"N/A\",\"N/A\",\"N/A\",".
      "\"Conversion failed to import\"\n");
    next file_id;
  }
  my($to_file_path, $to_file_size) = @_;
  $get_to_file_info->RunQuery(sub {
    my($row) = @_;
    ($to_file_path, $to_file_size) = @$row;
  }, sub {}, $to_file_id);
  $rpt->print("\"$collection\",\"$site\",\"$subject\"," .
    "\"$file_id\",\"$from_file\"," .
    "\"$from_file_size\",\"$to_file_id\",\"$to_file_path\"," .
    "\"$to_file_size\",\"Import OK\"\n");
  
  $create_ndf_change->RunQuery(sub {}, sub {},
    $file_id, $from_file_type, $file_sub_type,
    $collection, $site, $subject, 
    "$old_visibility",
    $date_last_categorized, $notify,
    "RadcompSubmissionConverter($invoc_id, $notify)"
  );
  $update_ndf->RunQuery(sub {}, sub {},
    $from_file_type, $file_sub_type, $collection, $site,
    $subject, "converted_to_new_format (json)",
    $file_id
  );
  $create_ndf->RunQuery(sub {}, sub {},
    $to_file_id, "json", $file_sub_type, $collection,
    $site, $subject);
  $record_conversion->RunQuery(sub{}, sub {},
    $file_id, $to_file_id, $conversion_id);
}
$background->Finish;

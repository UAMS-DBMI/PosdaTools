#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::Try;

my $usage = <<EOF;
FixCtpFileRow.pl <bkgrnd_id> <notify>
or
FixCtpFileRow.pl -h

Expects lines on <STDIN>:
<file_id>&<file_path>

Checks that file doesn't have ctp_file row.
If it doesn't, parses file, and if it has group 13 elements,
creates a ctp_file row.

EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 1){
  die "$usage\n";
}

my ($invoc_id, $notify) = @ARGV;

my $background = Posda::BackgroundProcess->new($invoc_id, $notify);

my %FileIds;
my $lines = 0;
while(my $line = <STDIN>){
  chomp $line;
  my($file_id, $file_path) = split /&/, $line;
  $FileIds{$file_id} = $file_path;
  $lines += 1;
}
my $num_files = keys %FileIds;

print "Found $num_files files in $lines lines to fix\n";
print "Entering Background\n";
$background->ForkAndExit;

my $start_time = `date`;
chomp $start_time;
$background->WriteToEmail(
  "Starting FixCtpFileRow.pl at $start_time\n");
my $get_ctp_row = Query("GetCtpFileRow");
my $create_ctp_row = Query("CreateCtpFileRow");
my $num_fixed = 0;
my $num_couldnt_fix = 0;
my $num_not_broken = 0;
file:
for my $file_id(sort keys %FileIds){
  my $has_ctp = 0;
  $get_ctp_row->RunQuery(sub {
    $has_ctp = 1;
  }, sub {}, $file_id);
  if($has_ctp){
    $num_not_broken += 1;
    $background->WriteToEmail("File with id $file_id already " .
      "has ctp_file row\n");
    next file;
  }
  my $try = Posda::Try->new($FileIds{$file_id});
  unless(exists $try->{dataset}){
    $background->WriteToEmail("FileIds{$file_id} ($FileIds{$file_id}) " .
      "didn't parse as DICOM file\n");
    next file;
  }
  my $ds = $try->{dataset};
  my $project_name = $ds->Get('(0013,"CTP",10)');
  my $site_name = $ds->Get('(0013,"CTP",12)');
  my $site_id = $ds->Get('(0013,"CTP",13)');
  my $visibility = $ds->Get('(0013,"CTP",14)');
  my $batch = $ds->Get('(0013,"CTP",15)');
  my $year_of_study = $ds->Get('(0013,"CTP",50)');
  $create_ctp_row->RunQuery(sub {}, sub{},
    $file_id, $project_name, $site_name, $site_id, $visibility, $batch, $year_of_study);
  $background->WriteToEmail("Created ctp_file row for $file_id\n");
}
$background->Finish;

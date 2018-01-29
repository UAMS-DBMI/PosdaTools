#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::DownloadableFile;
use Posda::BackgroundProcess;
use Debug;
my $usage = <<EOF;
BackgroundDciodvfyReport.pl <id> <scan_id> <notify>
  id - id of row in subprocess_invocation table created for the
    invocation of the script
  scan_id - id of scan
  notify - email address for completion notification

Expects nothing on STDIN

Uses the following script to do most of the work:
  ProcessDciodvfyScan.pl <type> <uid> <scan_id>

EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 2) {
  print "Wrong number of args\n";
  die $usage
}
my($invoc_id, $scan_id, $notify) = @ARGV;
my $get_series = Query('GetSeriesListByDciodvyScanInstance');
my @Series;
$get_series->RunQuery(sub {
  my($row) = @_;
  push(@Series, $row->[0]);
}, sub {}, $scan_id, $scan_id);
my $num_series = @Series;
print "Found $num_series to process\n";
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
print "Entering background\n";
$background->ForkAndExit;
my $start_time = `date`;
chomp $start_time;
#### here (get description of scan, etc. and add to print
my $get_scan_desc = Query("GetDciodvfyScanDesc");
$get_scan_desc->RunQuery(sub {
  my($row) = @_;
  my($type_of_unit,
    $description_of_scan,
    $number_units,
    $scanned_so_far,
    $start_time,
    $end_time) = @$row;
  $background->WriteToEmail("$start_time: Starting Dciodvfy Report:\n" .
    "        ScanId: $scan_id\n" .
    "     Unit type: $type_of_unit\n" .
    "   Description: $description_of_scan\n" .
    "Number to scan: $number_units\n" .
    " Number scaned: $scanned_so_far\n" .
    "    Start time: $start_time\n" .
    "      End time: $end_time\n"
  );
}, sub {}, $scan_id);
#######################################################################
### Body of script
my %SeriesErrorClasses;
my $get_error_ids = PosdaDB::Queries->GetQueryInstance(
  "DciodvfyErrorIdsBySeriesAndScanInstance"
);
my $get_error_string= PosdaDB::Queries->GetQueryInstance(
  "DciodvfyErrorsStringByErrorId"
);
for my $series(@Series){
  my $sig = "";
  $get_error_ids->RunQuery(sub {
    my($row) = @_;
    my $id = $row->[0];
    if($sig) { $sig .= "-$id";
    } else { $sig = $id }
  }, sub {}, $scan_id, $series);
  $SeriesErrorClasses{$sig}->{$series} = 1;
}
$background->WriteToEmail("This is a test version of this script\n");
my $rpt = $background->CreateReport("DciodvfySeriesReport");
print $rpt "Series,Errors\n";
my $report_rows = 0;
for my $error_str (sort keys %SeriesErrorClasses){
  my @ids = split(/-/, $error_str);
  my @series = sort keys %{$SeriesErrorClasses{$error_str}};
  print $rpt '"';
  for my $i (0 .. $#series){
    print $rpt "$series[$i]";
    unless($i == $#series) {print $rpt "\n"}
  }
  print $rpt '","';
  if($#ids >= 0){
    for my $i (0 .. $#ids){
      my $string;
      $get_error_string->RunQuery(sub {
        my($row) = @_;
        $string = $row->[0];
      }, sub {}, $ids[$i]);
      my $converted_string = ConvertString($string);
      print $rpt "$converted_string";
      unless($i == $#ids) { print $rpt "\n" }
    }
  } else {
    print $rpt 'none';
  }
  print $rpt '"' . "\r\n";
  $report_rows += 1;
}
$background->Finish;
### Body of script
###################################################################
exit;
sub ConvertString{
  my($string) = @_;
  my($dciodvfy_error_id, $error_type,
    $error_tag, $error_value,
    $error_subtype, $error_module,
    $error_reason, $error_index,
    $error_text) = split(/\|/, $string);
  if($error_type eq 'Uncategorized'){
    $error_text =~ s/"/""/g;
    return $error_text;
  } elsif($error_type eq 'MayNotBePresent'){
    return "Tag: $error_tag : May not be present because $error_reason";
  } elsif($error_type eq 'UnrecognizedEnumeratedValue'){
    return "Tag: $error_tag : has an unrecognized enumerated value ($error_value) in index $error_index";
  } elsif($error_type eq 'AttributeSpecificError'){
    return "Tag: $error_tag : $error_subtype";
  } elsif($error_type eq 'AttributeSpecificErrorWithIndex'){
    return "Tag: $error_tag : $error_subtype for index $error_index";
  } elsif($error_type eq 'MissingAttributes'){
    return "Tag: $error_tag : Missing Tag : $error_subtype : $error_module";
  } elsif($error_type eq 'BadValueMultiplicity'){
    return "Tag: $error_tag : has bad value multiplicity : $error_value vs $error_index : per $error_module";
  } elsif($error_type eq 'CantBeNegative'){
    return "Tag: $error_tag : has illegal negative value: $error_value\n";
  } elsif($error_type eq 'AttributesPresentWhenConditionNotSatisfied'){ 
    return "Tag: $error_tag : is conditional and is present when condition not satisfied : per $error_module module";
  } elsif($error_type eq 'InvalidElementLength'){
    return "Tag: $error_tag : has value ($error_value) with invalid length ($error_index vs $error_reason)";                     
  } elsif($error_type eq 'UnrecognizedPublicTag'){
    return "Unrecognized public tag: $error_tag";
  } elsif($error_type eq 'InvalidValueForVr'){
    return "Tag: $error_tag : Invalid Value for VR : $error_value : $error_reason : $error_subtype";
  } else {
    return $string;
  }
  return $string;
}


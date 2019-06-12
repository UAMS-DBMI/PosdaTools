use strict;
package Posda::Background::PhiScan;
use Posda::DB 'Query';
my $doc = <<EOF;
Instances of Posda::Background::PhiScan  essentially represent rows in the 
phi_scan_instance table in the posda_phi_simple database, which in turn 
represent PHI scans of DICOM files.

Such an instance of this class can be created in one of two different ways:
 - initiate a scan.  This creates a row in phi_scan_instance, and populates
   all of the associated rows.   to do this you need to supply three things
     1) A list of series to scan,
     2) The database against which you wish to scan: "Posda" or "Public"
     3) A description of the Scan to be performed
   Creating an object this way will take a long time. During which the
   script creating the object will be waiting for the scan to complete.
 - specify an id of an already exiting scan. This returns immediately.
   However, if no such scan exists, or if the scan is still in progress,
   it will return null.
Attributes:
 - phi_scan_instance_id -- the id of the phi_scan_instance
 - description -- a description of the scan (supplied when scan created)
 - num_series -- the number of series submitted to be scanned
 - num_series_scanned -- the number of series scanned so far
 - start_time -- the time the scan started
 - end_time -- the time the scan completed
 - file_query -- "PublicFilsesInSeries" if scan of Public database or
   "FilesInSeries" if scan of Posda database.
Constructors:
 - NewFromScan(series_list, database, description) -- creates new scan and
   returns (after a potentially long time) an object representing the new scan.
 - NewFromId(id) -- creates a new scan from an existing scan_id.  This will
   only succeed if the scan completed successfully. (i.e. num_series == 
   num_series_scanned and end_time is not null).
Report Methods:
 - TableFromQuery(query_name) -- returns a table produced by making the
   named query (which must be a query with a single parameter,
   phi_scan_instance_id).

EOF
my $create_scan = Query("CreateSimplePhiScanRow");
my $get_scan_id = Query("GetSimplePhiScanId");
my $create_series_scan = Query("CreateSimpleSeriesScanInstance");
my $get_series_scan_id = Query("GetSimpleSeriesScanId");
my $get_ele = Query("GetSimpleElementSeen");
my $create_ele = Query("CreateSimpleElementSeen");
my $get_ele_id = Query("GetSimpleElementSeenIndex");
my $get_value = Query("GetSimpleValueSeen");
my $create_value = Query("CreateSimpleValueSeen");
my $get_value_id = Query("GetSimpleValueSeenId");
my $create_occurance = Query("CreateSimpleElementValueOccurance");
my $finalize_series = Query("FinalizeSimpleSeriesScan");
my $increment_series_done = Query("IncrementSimpleSeriesScanned");
my $finalize_scan = Query("FinalizeSimpleScanInstance");
my $get_scan_by_id = Query("GetScanInstanceById");
my $update_act = Query('UpdateActivityTaskStatus');
sub NewFromScan{
  my($class, $SeriesList, $description, $database, $invoc_id, $act_id, $back) = @_;
  my $num_series = @$SeriesList;
  my $q_name = "FilesInSeries";
  if($database eq "Public") {
    $q_name = "PublicFilesInSeries";
  } elsif($database ne "Posda"){
    die "Database must be either Posda or Public";
  }
  my $get_series_count = Query($q_name);
  $create_scan->RunQuery(sub {}, sub{}, $description, $num_series, $q_name);
  my $scan_id;
  $get_scan_id->RunQuery(sub {
    my($row) = @_;
    $scan_id = $row->[0];
  }, sub {});
  my $num_series_being_scanned = 0;
  for my $series (@$SeriesList){
    $num_series_being_scanned += 1;
    if(
      defined($act_id) && defined($invoc_id) &&
      defined $back && $back->can("SetActivityStatus")
    ){
      $back->SetActivityStatus(
        "Scanning $num_series_being_scanned series of $num_series");
    }
    my $series_start_time = time;
    my $num_files_in_series = 0;
    $get_series_count->RunQuery(sub {
      my($row) = @_;
      $num_files_in_series += 1;
    }, sub {}, $series);
    $create_series_scan->RunQuery(sub {}, sub {}, $scan_id,
      $series);
    my $series_scan_id;
    $get_series_scan_id->RunQuery(sub {
      my($row) = @_;
      $series_scan_id = $row->[0];
    }, sub {});
    open SUBP, "PhiSimpleSeriesScan.pl $series $q_name|";
    while(my $line = <SUBP>){
      chomp $line;
      my($tagp, $vr, $value) = split(/\|/, $line);
      my $tag_id;
      $get_ele->RunQuery(sub {
        my($row) = @_;
        $tag_id = $row->[0];
      }, sub {}, $tagp, $vr);
      unless(defined $tag_id){
        $create_ele->RunQuery(sub {}, sub {},
          $tagp, $vr);
        $get_ele_id->RunQuery(sub {
          my($row) = @_;
          $tag_id = $row->[0];
        }, sub {} );
      }
      my $value_id;
      $get_value->RunQuery(sub {
        my($row) = @_;
        $value_id = $row->[0];
      }, sub {}, $value);
      unless(defined $value_id){
        $create_value->RunQuery(sub {}, sub {},
          $value);
        $get_value_id->RunQuery(sub {
          my($row) = @_;
          $value_id = $row->[0];
        }, sub {} );
      }
      $create_occurance->RunQuery(sub {}, sub {},
        $tag_id, $value_id, $series_scan_id, $scan_id)
    }
    close SUBP;
    if(
      defined($act_id) && defined($invoc_id) &&
      defined $back && $back->can("SetActivityStatus")
    ){
      $back->SetActivityStatus("Finished PHI scan");
    }
    my $series_duration = time - $series_start_time;
    $finalize_series->RunQuery(sub {}, sub {},
      $num_files_in_series, $series_scan_id);
    $increment_series_done->RunQuery(sub {}, sub {}, $scan_id);
  }
  $finalize_scan->RunQuery(sub {}, sub {}, $scan_id);
  return $class->NewFromId($scan_id);
}
sub NewFromId{
  my($class, $id) = @_;
  my $this = {};
  $get_scan_by_id->RunQuery(sub {
    my($row) = @_;
    my($phi_scan_instance_id, $start_time, $end_time,
      $description, $num_series, $num_series_scanned, $file_query) = @$row;
    $this->{phi_scan_instance_id} = $phi_scan_instance_id;
    $this->{start_time} = $start_time;
    $this->{end_time} = $end_time;
    $this->{description} = $description;
    $this->{num_series} = $num_series;
    $this->{num_series_scanned} = $num_series_scanned;
    $this->{file_query} = $file_query;
  }, sub {}, $id);
  return bless $this, $class;
}
sub PrintTableFromQuery{
  my($this, $table_name, $fh) = @_;
  my $q = Query($table_name);
  for my $i (0 .. $#{$q->{columns}}){
    my $f = $q->{columns}->[$i];
    unless($i == 0) { $fh->print(",") }
    $f =~ s/"/""/g;
    $fh->print("\"$f\"");
  }
  $fh->print("\n");
  $q->RunQuery(sub {
    my($row) = @_;
    for my $i (0 .. $#{$row}){
      my $f = $row->[$i];
      unless($i == 0) { $fh->print(",") }
      $f =~ s/"/""/g;
      $fh->print("\"$f\"");
    }
    $fh->print("\n");
  }, sub {}, $this->{phi_scan_instance_id});
}
sub PrepareBackgroundReportBasedOnQuery{
  my($this, $query, $report_name, $background, $max_rows) = @_;
print STDERR "In PrepareBackgroundReportBasedOnQuery\n";
  my @rows;
  my $q = Query($query);
  my $header = $q->{columns};
  my $num_rows = 0;
  $q->RunQuery(sub {
    my($row) = @_;
    $num_rows += 1;
    my @fields = @$row;
    unless($#fields == $#$header){
      my $num_fields = @fields;
      my $num_header = @$header;
      $background->WriteToEmail(
        "Error in PrepareBackgroundReportBasedOnQuery\n" .
        "Error:      row had $num_fields columns " .
        "vs header ($num_header) columns\n" .
        "Query:      $query\n" .
        "Row number: $num_rows\n");
      return;
    }
    push @rows, \@fields;
  }, sub {}, $this->{phi_scan_instance_id});
  $background->WriteToEmail(
    "Report $report_name has $num_rows generated rows\n");
  my @report_spec;
  if($num_rows > $max_rows){
    my $remaining = $num_rows;
    my $current_row = 1;
    while($remaining > 0){
      my $first_row = $current_row;
      my $last_row;
      if($remaining <= $max_rows){
        $last_row = $first_row + $remaining - 1;
        $remaining = 0;
        $current_row = $last_row + 1;
      } else {
        $last_row = $first_row + $max_rows - 1;
        $remaining = $remaining - $max_rows;
        $current_row = $last_row + 1;
      }
      my $d = {
        first_row => $first_row,
        last_row => $last_row,
        num_rows => $last_row - $first_row + 1,
      };
      push @report_spec, $d;
    }
  } else {
    push(@report_spec, {
      num_rows => $num_rows,
      first_row => 1,
      last_row => $num_rows,
    });
  }
  my $num_reports = @report_spec;
  if($num_reports > 1){
    $background->WriteToEmail("Splitting report $report_name into " .
      "$num_reports parts based on max rows: $max_rows\n");
    my $rept_num = 0;
    for my $i (@report_spec){
      $rept_num += 1;
      my $rept_num_text = sprintf("%03d", $rept_num);
      my $name = "$report_name [$rept_num_text] " .
        "($i->{first_row} -> $i->{last_row})";
      my @rpt_rows;
      for my $i (1 .. $i->{num_rows}){
        my $row = shift @rows;
        push @rpt_rows, $row;
      }
      MakeBackgroundReport($header, \@rpt_rows, $name, $background);
    }
  } else {
    MakeBackgroundReport($header, \@rows, $report_name, $background);
  }
}
sub MakeBackgroundReport{
  my($header, $rows, $name, $background) = @_;
  print STDERR "In MakeBackgroundReport\n";
  my $rpt = $background->CreateReport($name);
  for my $i (0 .. $#{$header}){
    my $f = $header->[$i];
    unless($i == 0) { $rpt->print(",") }
    $f =~ s/"/""/g;
    $rpt->print("\"$f\"");
  }
  $rpt->print("\n");
  for my $r (@$rows){
    for my $i (0 .. $#{$r}){
      my $f = $r->[$i];
      unless($i == 0) { $rpt->print(",") }
      $f =~ s/"/""/g;
      $rpt->print("\"$f\"");
    }
    $rpt->print("\n");
  }
  $rpt->close;
}
1;

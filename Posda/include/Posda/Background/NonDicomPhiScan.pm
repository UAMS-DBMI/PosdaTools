use strict;
package Posda::Background::NonDicomPhiScan;
use Posda::DB 'Query';
my $doc = <<EOF;
Instances of Posda::Background::NonDicomPhiScan  essentially represent rows in the 
phi_non_dicom_scan_instance table in the posda_phi_simple database, which in turn 
represent non_dicom PHI scans.

Such an instance of this class can be created in one of two different ways:
 - initiate a scan.  This creates a row in phi_non_dicom_scan_instance, and populates
   all of the associated rows.   to do this you need to supply two things
     1) A list of information about files to scan.  Each file needs either
        a) A posda file_id, or
        b) information about a file inside a (currently unwrapped) DICOM
           wrapped tgz (assumed to be in public):
           1) the SOP Instance UID of the DICOM file
           2) the relative path of the file within this tgz
           3) the full path the file where it is currently sitting
           4) the md5 digest of the wrapped tgz
        Note: please don't mix file specification types in a single scan
              it might work, but probably won't and there is no obvious
              use case.
        Note: At this time, only the first (i.e. a) above) is supported.
     3) A description of the Scan to be performed
   Creating an object this way may take a long time. During which the
   script creating the object will be waiting for the scan to complete.
 - specify an id of an already exiting scan. This returns immediately.
   (well, not immediately, but a lot faster).
   However, if no such scan exists it will return null.  If the scan is
   not complete (i.e. num_series == num_series_scanned and end_time is not null),
   then the "TableFromQuery" method will probably not return anything meaningful.
Attributes:
 - instance_id -- the id of the phi_non_dicom_scan_instane
 - description -- a description of the scan (supplied when scan created)
 - num_files -- the number of files submitted to be scanned
 - num_files_scanned -- the number of files scanned so far
 - start_time -- the time the scan started
 - end_time -- the time the scan completed
Constructors:
 - NewFromScan(file_list, description) -- creates new scan and
   returns (after a potentially long time) an object representing the new scan.
 - NewFromId(id) -- creates a new scan from an existing scan_id.  This will
   only succeed if the scan exists.
Report Methods: (Not implemented now, possibly never).
 - TableFromQuery(query_name) -- returns a table produced by making the
   named query (which must be a query with a single parameter,
   phi_non_dicom_scan_instance_id).  This will fail unless the scan
   completed (i.e. num_series == num_series_scanned and end_time is not null).

EOF

############
#Queries go here
my $create_scan = Query("CreatePhiNonDicomScanInstance"); #done
my $get_scan_id = Query("GetPhiNonDicomScanId"); #done
my $create_file_scan = Query("CreateNonDicomFileScanInstance"); #done
my $get_file_scan_id = Query("GetNonDicomFileScanId"); #done
my $get_path = Query("GetNonDicomPathSeen"); #done
my $create_path = Query("CreateNonDicomPathSeen"); #done
my $get_path_id = Query("GetNonDicomPathSeenId"); #done
my $get_value = Query("GetSimpleValueSeen"); #done
my $create_value = Query("CreateSimpleValueSeen"); #done
my $get_value_id = Query("GetSimpleValueSeenId"); #done
#non_dicom_path_value_occurrance
my $create_occurance = Query("CreateNonDicomPathValueOccurance"); #done
my $increment_files_done = Query("IncrementPhiNonDicomFilesScanned"); #done
my $finalize_scan = Query("FinalizePhiNonDicomInstance"); #done
my $get_scan_by_id = Query("GetPhiNonDicomScanInstanceById"); #done

sub NewFromScan{
  my($class, $FileList, $description) = @_;
  my $num_files = @$FileList;
  $create_scan->RunQuery(sub {}, sub{}, $description, $num_files);
  my $scan_id;
  $get_scan_id->RunQuery(sub {
    my($row) = @_;
    $scan_id = $row->[0];
  }, sub {});
  file:
  for my $i (@$FileList){
    my $file_id = $i->[0];
    my $file_type = $i->[1];
    my $file_sub_type = $i->[2];
    my $file_path = $i->[3];
    $create_file_scan->RunQuery(sub {}, sub {}, $scan_id,
      $file_type, $file_id);
    my $file_scan_id;
    $get_file_scan_id->RunQuery(sub {
      my($row) = @_;
      $file_scan_id = $row->[0];
    }, sub {});
    my $cmd;
    if($file_type eq "csv"){
      if(
      $file_sub_type eq "radcomp plan dvh" ||
      $file_sub_type eq "radcomp heart dvh"
      ){
        $cmd = "PhiScanCsv.pl \"$file_path\" 1";
      } else {
        $cmd = "PhiScanCsv.pl \"$file_path\"";
      }
    } elsif($file_type eq "json"){
      $cmd = "PhiScanJson.pl \"$file_path\"";
    } else {
      next file;
    }
    open SUBP, "$cmd|";
    while(my $line = <SUBP>){
      chomp $line;
      my($path, $value) = split(/\|/, $line);
      my $path_id;
      $get_path->RunQuery(sub {
        my($row) = @_;
        $path_id = $row->[0];
      }, sub {}, $file_type, $path);
      unless(defined $path_id){
        $create_path->RunQuery(sub {}, sub {},
          $file_type, $path);
        $get_path_id->RunQuery(sub {
          my($row) = @_;
          $path_id = $row->[0];
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
        $path_id, $value_id, $file_scan_id)
    }
    close SUBP;
    $increment_files_done->RunQuery(sub {}, sub {}, $scan_id);
  }
  $finalize_scan->RunQuery(sub {}, sub {}, $scan_id);
  return $class->NewFromId($scan_id);
}
sub NewFromId{
  my($class, $id) = @_;
  my $this = {};
  $get_scan_by_id->RunQuery(sub {
    my($row) = @_;
    my($phi_scan_instance_id, $description, $start_time, $num_files,
      $num_files_scanned, $end_time) = @$row;
    $this->{phi_scan_instance_id} = $phi_scan_instance_id;
    $this->{start_time} = $start_time;
    $this->{end_time} = $end_time;
    $this->{description} = $description;
    $this->{num_files} = $num_files;
    $this->{num_files_scanned} = $num_files_scanned;
  }, sub {}, $id);
  return bless $this, $class;
}
sub PrintTableFromQuery{
  my($this, $table_name, $fh) = @_;
print STDERR "in PrintTableFromQuery($this->{phi_scan_instance_uid}, $table_name)\n";
  my $q = Query($table_name);
  for my $i (0 .. $#{$q->{columns}}){
    my $f = $q->{columns}->[$i];
    unless($i == 0) { $fh->print(",") }
    $f =~ s/"/""/g;
    $fh->print("\"$f\"");
  }
  $fh->print("\n");
print STDERR "Running Query\n";
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
1;

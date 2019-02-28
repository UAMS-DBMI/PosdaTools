#!/usr/bin/perl -w
#
# FastFileProcessWorker
#
# This program reads from the simple Redis based queue and imports files.
# If the key 'quit' is defined, it will exit.
#
# See FastFileProcessDaemon.pl for the queue details
#
#

# These settings may need to be adjusted
use constant DBNAME => 'posda_files';
use constant REDIS_HOST => 'redis:6379';

###############################################################################

use Modern::Perl;

use DBD::Pg;

use Posda::Config 'Database';

use Posda::Try;
use Posda::DB::DicomDir;
use Posda::DB::DicomIod;

use JSON;
use Redis;


$| = 1; # Set non-buffered output mode

say "FFPW: FastFileProcessWorker Starting up...";

# Setup phase
#
my $db = DBI->connect(Database(DBNAME));
unless($db) { die "couldn't connect to DB: DBNAME" }

my $redis = Redis->new(server => REDIS_HOST); #hostname from Docker-compose

while (1) {
  my ($key, $next_thing) = $redis->brpop('files', 5);
  # say $next_thing;

  if (defined $key) {
    my ($file_id, $file_path) = @{decode_json($next_thing)};
    say "FFPW: Processing $file_id, $file_path";
    InsertOneFile($file_id, $file_path, $db);
    $redis->rpush('pixel_location', $next_thing);
  }

  my $should_we_quit_now = $redis->get('quit');
  if (defined $should_we_quit_now) {
    say "FFPW: Worker stopping.";
    $db->disconnect;
    $redis->quit;
    exit;
  }

}

sub InsertOneFile {
  my($file_id, $file_path, $db) = @_;

  my $h = { path => $file_path,
            file_id => $file_id };

  my @errors;
  unless(-f $h->{path}) { 
    print STDERR "File ($h->{path}) not found\n";
    return;
  }
  # File is present
  #
  my $qp = $db->prepare(qq{
      update file_location  
      set file_is_present = true
      where file_id = ?
  });
  $qp->execute($h->{file_id});


  my $try = Posda::Try->new($h->{path});
  if(exists $try->{dataset}){
    my $has_meta = 0;
    my $df;
    my $ds = $try->{dataset};
    my $xfr_stx = $try->{xfr_stx};
    if(exists $try->{has_meta_header}){
      $df = $try->{meta_header};
      if(defined $df->{metaheader}->{"(0002,0001)"}){
        InsertMeta($db, $h->{file_id}, $df);
        $has_meta = 1;
      } else {
        push(@errors, "Meta header with no (0002,0001) (entry not created)");
      }
    }
    my $dataset_digest = $try->{dataset_digest};
    my $is_dicom_dir = 0;
    my $has_sop_common = 0;
    my $dicom_file_type = "";
    if(
      $has_meta &&
       defined($df->{metaheader}->{"(0002,0002)"}) &&
      $df->{metaheader}->{"(0002,0002)"} eq "1.2.840.10008.1.3.10"
    ){
     $is_dicom_dir = 1;
      $dicom_file_type = "DICOMDIR";
    }
    my $sop_class = $ds->ExtractElementBySig("(0008,0016)");
    if(defined $sop_class){
      $has_sop_common = 1;
      if(exists $Posda::Dataset::DD->{SopCl}->{$sop_class}){
        $dicom_file_type =
          $Posda::Dataset::DD->{SopCl}->{$sop_class}->{sopcl_desc};
      } else {
        $dicom_file_type = $sop_class;
      }
    }    my $q = $db->prepare(
      "update file set\n" .
      "  is_dicom_file = ?,\n" .
      "  file_type = 'parsed dicom file'\n" .
      "where file_id = ?"
    );
    my $q1 = $db->prepare(
      "insert into dicom_file (\n" .
      "  file_id,\n" .
      "  xfr_stx,\n" .
      "  has_meta,\n" .
      "  is_dicom_dir,\n" .
      "  has_sop_common,\n" .
      "  dicom_file_type,\n" .
      "  dataset_digest\n" .
      ")\n" .
      "values(?, ?, ?, ?, ?, ?, ?)"
    );
    $q->execute(1, $h->{file_id});
    $q1->execute($h->{file_id}, $xfr_stx, $has_meta,
      $is_dicom_dir, $has_sop_common, $dicom_file_type, $dataset_digest);
    my $i_err = $db->prepare(
      "insert into dicom_file_errors(file_id, error_msg) values (?, ?)"
    );
    # TODO should @errors be emptied here?
    for my $i (@errors){
      $i_err->execute($h->{file_id}, $i);
    }
    if($is_dicom_dir){
      print "import: DicomDir ($h->{file_id})\n";
      Posda::DB::DicomDir::Import($db, $ds, $h->{file_id});
    } elsif ($has_sop_common){
      print "import: DicomIod ($h->{file_id})\n";
      Posda::DB::DicomIod::Import($db, $ds, $h->{file_id}, $sop_class,
        $dicom_file_type);
    } else {
      ## todo - what if its neither a DICOMDIR nor a known UID?
    }
  } else {
    my $file_type = `file $h->{path}`;
    chomp $file_type;
    print "import: Non DICOM ($file_type) ($h->{file_id})\n";
    if($file_type =~ /^[^:]*:\s*(.*)$/){
      $file_type = $1;
    }
    my $q = $db->prepare(
      "update file set\n" .
      "  is_dicom_file = false,\n" .
      "  file_type = ?\n" .
      "where file_id = ?"
    );
    $q->execute($file_type, $h->{file_id});
  }
}

sub InsertMeta{
  my($db, $file_id, $df) = @_;
  my $ins_part10 = $db->prepare(
    "insert into file_meta\n" .
    "  (file_id, file_meta, data_set_size, data_set_start,\n" .
    "   media_storage_sop_class,\n" .
    "   media_storage_sop_instance, xfer_syntax, imp_class_uid,\n" .
    "   imp_version_name, source_ae_title, private_info_uid,\n" .
    "   private_info)\n" .
    "values\n" .
    "  (?, ?, ?, ?,\n" .
    "   ?,\n" .
    "   ?, ?, ?,\n" .
    "   ?, ?, ?,\n" .
    "   ?)"
  );
  my $mh = $df->{metaheader};
  my($file_meta);
  if(exists $mh->{"(0002,0001)"}){
    $file_meta = unpack("v", $mh->{"(0002,0001)"});
  } else {
    $file_meta = 0x0101;
  }
  $ins_part10->execute(
     $file_id, $file_meta, $df->{DataSetSize}, $df->{DataSetStart},
     $mh->{'(0002,0002)'},
     $mh->{'(0002,0003)'}, $mh->{'(0002,0010)'}, $mh->{'(0002,0012)'},
     $mh->{'(0002,0013)'}, $mh->{'(0002,0016)'}, $mh->{'(0002,0100)'},
     $mh->{'(0002,0102)'}
  );
}

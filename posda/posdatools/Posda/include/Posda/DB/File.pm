#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
package Posda::DB::File;
use File::Find;
use Digest::MD5;
use Posda::Dataset;
use Posda::DB::DicomIod;
use Posda::DB::DicomDir;
use Posda::Find;
use Posda::Try;
use File::Copy;

Posda::Dataset::InitDD();

sub Insert{
  my($path, $db) = @_;
  my $digest = GetDigest($path);
  my $size = GetSize($path);
  my $file_id = GetFileId($digest, $db);
  my @errors;
  if(defined $file_id){
    push(@errors, "Re-import of file_id $file_id");
    return $file_id, 1, \@errors;
  }
  my $ins_file = $db->prepare(
    "insert into file (size, digest, file_type)\n" .
    "values (?, ?, ?)"
  );
  my $result = $ins_file->execute($size, $digest, undef);
  my $get_id = $db->prepare (
    "select currval('public.file_file_id_seq'::text) as file_id "
  );
  $get_id->execute();
  my $r = $get_id->fetchrow_hashref();
  $get_id->finish();
  unless($r && ref($r) eq "HASH"){
    die "Unable to fetch new file_id";
  }
  $file_id = $r->{file_id};
  my($root_id, $root) = GetFileStorageRoot($db);
  my $pad = sprintf("%07d", $file_id);
  unless($pad =~ /^(\d\d\d\d)(\d\d\d)$/){
    die "sprintf didn't produce a 7 digit integer: $pad";
  }
  my $rel_dir = "$1";
  my $fname = "$2";
  my $rel_path = "$rel_dir/$fname";
  my $dir = "$root/$rel_dir";
  my $file = "$dir/$fname";
  unless(-d $dir){
    mkdir $dir;
  }
  unless(-d $dir){
    die "couldn't mkdir $dir";
  }
  if(-f $file) {
     push @errors, "$file already exists - deleting";
    `rm $file`
  };
#  my @args = ("cp", $path, $file);
#  $r = system(@args);
#  unless($r == 0) { die "cp $path $file returned $r" }
  unless(copy $path, $file){
    die "couldn't copy $path to $file: $!";
  }
  my $ins_file_loc = $db->prepare(
    "insert into file_location\n" .
    "  (file_id, rel_path, file_storage_root_id, is_home)\n" .
    "values\n" .
    "  (?, ?, ?, ?)"
  );
  my $c = $ins_file_loc->execute(
    $file_id,
    $rel_path,
    $root_id,
    'true'
  );
  unless($c == 1){
    die "failed to create file_location"
  }
  return $file_id, 0, \@errors;
}
sub GetDigest{
  my($path) = @_;
  my $ctx = Digest::MD5->new();
  open FILE, "<$path" or die "Can't open file $path for reading";
  binmode FILE;
  $ctx->addfile(*FILE);
  return $ctx->hexdigest;
  close FILE;
}
sub GetSize{
  my($path) = @_;
  open FILE, "<$path" or die "Can't open file $path for reading";
  binmode FILE;
  seek FILE, 0, 2;
  my $size = tell(FILE);
  close FILE;
  return $size;
}
sub GetFileId{
  my($digest, $db) = @_;
  my $get_file_rec = $db->prepare("select * from file where digest = ?");
  $get_file_rec->execute($digest);
  my $r = $get_file_rec->fetchrow_hashref();
  $get_file_rec->finish();
  if($r && ref($r) eq "HASH"){
    return $r->{file_id};
  }
  return undef;
}
sub GetFileStorageRoot{
  my($db) = @_;
  my $gr = $db->prepare("select * from file_storage_root where current");
  $gr->execute();
  my $h = $gr->fetchrow_hashref();
  $gr->finish();
  unless($h && ref($h) eq "HASH"){
    die "Unable to fetch storage root";
  }
  my $root = $h->{root_path};
  my $file_storage_root_id = $h->{file_storage_root_id};
  unless($root && -d $root){ die "$root is not a directory" }
  return ($file_storage_root_id, $root);
}
sub MakeWantedMedia{
  my($db, $root) = @_;
  my $insert_file_q = $db->prepare(
    "insert into file_import(\n" .
    "  import_event_id, file_id, rel_path\n" .
    ")values(\n" .
    "  currval('import_event_import_event_id_seq'), ?, ?\n" .
    ")"
  );
  my $foo = sub {
    my $f_name = $File::Find::name;
    unless($f_name =~/^$root\/(.*)$/){
      unless($f_name eq $root){
        die "Found $f_name not in path of $root";
      }
      return;
    }
    my $rel_path = $1;
    if(-d $f_name) { return }
    unless( -r $f_name) { return }
    my($id, $copy, $errors) = Insert($f_name, $db);
    $insert_file_q->execute($id, $rel_path);
  };
  return $foo;
}
sub InsertNoCopy{
  my($db, $digest, $df, $ds, $size, $xfr_stx, $errors, $fn) = @_;
  my $file_id = GetFileId($digest, $db);
  if(defined $file_id){
    my $i_err = $db->prepare(
      "insert into dicom_file_errors(file_id, error_msg) values (?, ?)"
    );
    my $message = "File imported more than once";
    $i_err->execute($file_id, $message);
    # insert a process error
    return $file_id;
  }
  my $ins_file = $db->prepare(
    "insert into file (size, digest, file_type)\n" .
    "values (?, ?, ?)"
  );
  my $result = $ins_file->execute($size, $digest, "parsed dicom file");
  my $get_id = $db->prepare (
    "select currval('public.file_file_id_seq'::text) as file_id "
  );
  $get_id->execute();
  my $r = $get_id->fetchrow_hashref();
  $get_id->finish();
  unless($r && ref($r) eq "HASH"){
    die "Unable to fetch new file_id";
  }
  $file_id = $r->{file_id};
  ProcessSingleFile($db, $file_id, $df, $ds, $size, $xfr_stx, $errors, $fn);
  return $file_id;
}
sub InsertNoCopy1{
  my($db, $digest, $ds_digest, $df, $ds, $size, $xfr_stx, $errors, $fn, $ieid) = @_;
  my $file_id = GetFileId($digest, $db);
  if(defined $file_id){
    my $i_err = $db->prepare(
      "insert into dicom_file_errors(file_id, error_msg) values (?, ?)"
    );
    my $message = "File imported more than once";
    $i_err->execute($file_id, $message);
    # insert a process error
    return $file_id;
  }
  my $ins_file = $db->prepare(
    "insert into file (size, digest, file_type)\n" .
    "values (?, ?, ?)"
  );
  my $result = $ins_file->execute($size, $digest, "parsed dicom file");
  my $get_id = $db->prepare (
    "select currval('public.file_file_id_seq'::text) as file_id "
  );
  $get_id->execute();
  my $r = $get_id->fetchrow_hashref();
  $get_id->finish();
  unless($r && ref($r) eq "HASH"){
    die "Unable to fetch new file_id";
  }
  $file_id = $r->{file_id};
  ProcessSingleFile1($db, $ds_digest, $file_id, 
    $df, $ds, $size, $xfr_stx, $errors, $fn, $ieid);
  return $file_id;
}
sub MakeWantedTarOnly{
  my($db, $import_id, $root ) = @_;
  my $insert_file_q = $db->prepare(
    "insert into file_import(\n" .
    "  import_event_id, file_id, rel_path\n" .
    ")values(\n" .
    "  ?, ?, ?\n" .
    ")"
  );
  my $get_file_id = $db->prepare(
    "select currval('file_file_id_seq') as id"
  );
  my $foo = sub {
    my($try) = @_;
    unless($try->{filename} =~ /^$root\/(.*)$/){
      die "funny path: $try->{filename}";
    }
    my $rel_path = $1;
    print "Message: Importing file $rel_path ($import_id);\n";
    my $digest = $try->{digest};
    my $dataset_digest = $try->{digest};
    if(exists $try->{dataset_digest}){
      $dataset_digest = $try->{dataset_digest};
    }
    my $df = $try->{meta_header};
    my $ds = $try->{dataset};
    my $size = $try->{file_size};
    my $xfr_stx = $try->{xfr_stx};
    my $errors = $try->{parser_warnings};
    my($id) = InsertNoCopy1(
      $db, $digest, $dataset_digest, $df, $ds, $size, $xfr_stx, $errors,
      $try->{filename}, $import_id);
    $insert_file_q->execute($import_id, $id, $rel_path);
  };
}
sub ImportFromTarOnly{
  my($db, $id, $path) = @_;
  my $wanted = MakeWantedTarOnly($db, $id, $path);
  Posda::Find::DicomOnly($path, $wanted);
}
sub ProcessSingleFile{
  my($db, $id, $df, $ds, $size, $xfr_stx, $errors, $fn) = @_;
  my $has_meta = 0;
  if($df){
    InsertMeta($db, $id, $df);
    $has_meta = 1;
  }
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
  }
  my $q = $db->prepare(
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
    "  dicom_file_type\n" .
    ")\n" .
    "values(?, ?, ?, ?, ?, ?)"
  );
  $q->execute(1, $id);
  $q1->execute($id, $xfr_stx, $has_meta,
    $is_dicom_dir, $has_sop_common, $dicom_file_type);
  my $i_err = $db->prepare(
    "insert into dicom_file_errors(file_id, error_msg) values (?, ?)"
  );
  for my $i (@$errors){
    $i_err->execute($id, $i);
  }
  if($is_dicom_dir){
    Posda::DB::DicomDir::Import($db, $ds, $id);
  } elsif ($has_sop_common){
    Posda::DB::DicomIod::Import($db, $ds, $id, $sop_class, 
      $dicom_file_type);
  } else {
    if($has_sop_common){
      print STDERR "Encountered unimplemented UID: $sop_class\n";
    } else {
      $i_err->execute($id, "This file is neither a DICOMDIR nor has a UID");
      print STDERR "This file ($fn)  is neither a DICOMDIR nor has a UID\n";
    }
    ## todo - what if its neither a DICOMDIR nor a known UID?
  }
}
sub ProcessSingleFile1{
  my($db, $ds_digest, $id, $df, $ds, $size, $xfr_stx, $errors, $fn, $ieid) = @_;
  my $has_meta = 0;
  if($df){
    InsertMeta($db, $id, $df);
    $has_meta = 1;
  }
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
  }
  my $q = $db->prepare(
    "update file set\n" .
    "  is_dicom_file = ?,\n" .
    "  file_type = 'parsed dicom file'\n" .
    "where file_id = ?"
  );
  my $q1 = $db->prepare(
    "insert into dicom_file (\n" .
    "  file_id,\n" .
    "  dataset_digest,\n" .
    "  xfr_stx,\n" .
    "  has_meta,\n" .
    "  is_dicom_dir,\n" .
    "  has_sop_common,\n" .
    "  dicom_file_type\n" .
    ")\n" .
    "values(?, ?, ?, ?, ?, ?, ?)"
  );
  $q->execute(1, $id);
  $q1->execute($id, $ds_digest, $xfr_stx, $has_meta,
    $is_dicom_dir, $has_sop_common, $dicom_file_type);
  my $i_err = $db->prepare(
    "insert into dicom_file_errors(file_id, error_msg) values (?, ?)"
  );
  for my $i (@$errors){
    $i_err->execute($id, $i);
  }
  if($is_dicom_dir){
    Posda::DB::DicomDir::Import($db, $ds, $id);
  } elsif ($has_sop_common){
    Posda::DB::DicomIod::Import($db, $ds, $id, $sop_class, 
      $dicom_file_type, $ieid);
  } else {
    if($has_sop_common){
      print STDERR "Encountered unimplemented UID: $sop_class\n";
    } else {
      $i_err->execute($id, "This file is neither a DICOMDIR nor has a UID");
      print STDERR "This file is ($fn) neither a DICOMDIR nor has a UID\n";
    }
    ## todo - what if its neither a DICOMDIR nor a known UID?
  }
}
sub ScanDirectory{
  my($path, $db, $comment) = @_;
  my $ie_insert = $db->prepare(
    "insert into import_event(\n" .
    "  import_type, importing_user, import_comment,\n" .
    "  import_time, volume_name\n" .
    ")values(\n" .
    "  'scan_dir', ?, ?,\n" .
    "  now(), ?\n" .
    ")"
  );
  $ie_insert->execute(`whoami`, $comment, $path);
  my $wanted = MakeWantedMedia($db, $path);
  find({wanted => $wanted, follow => 1},  $path);
}
sub ImportFromTar{
  my($path, $db, $comment, $orig_file) = @_;
  my $ie_insert = $db->prepare(
    "insert into import_event(\n" .
    "  import_type, importing_user, import_comment,\n" .
    "  import_time, volume_name, remote_file\n" .
    ")values(\n" .
    "  'tar_file', ?, ?,\n" .
    "  now(), ?, ?\n" .
    ")"
  );
  $ie_insert->execute(`whoami`, $comment, $path, $orig_file);
  my $wanted = MakeWantedMedia($db, $path);
  find({wanted => $wanted, follow => 1},  $path);
}

sub ProcessFilesWithLimit{
  my($db, $limit) = @_;
  my $q = $db->prepare(
    "select\n" .
    "  file_id, root_path || '/' || rel_path as path\n" .
    "from\n" .
    "   file NATURAL JOIN file_location NATURAL JOIN file_storage_root\n" .
    "where is_dicom_file is null\n" .
    "limit $limit"
  );
  $q->execute();
  while(my $h = $q->fetchrow_hashref()){
    my($df, $ds, $size, $xfr_stx, $errors) = 
      Posda::Dataset::Try($h->{path});
    if($ds){
      my $has_meta = 0;
      if($df){
        if(defined $df->{"(0002,0001)"}){
          InsertMeta($db, $h->{file_id}, $df);
          $has_meta = 1;
        } else {
          push(@$errors, "Meta header with no (0002,0001) (entry not created)");
        }
      }
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
      }
      my $q = $db->prepare(
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
        "  dicom_file_type\n" .
        ")\n" .
        "values(?, ?, ?, ?, ?, ?)"
      );
      $q->execute(1, $h->{file_id});
      $q1->execute($h->{file_id}, $xfr_stx, $has_meta,
        $is_dicom_dir, $has_sop_common, $dicom_file_type);
      my $i_err = $db->prepare(
        "insert into dicom_file_errors(file_id, error_msg) values (?, ?)"
      );
      for my $i (@$errors){
        $i_err->execute($h->{file_id}, $i);
      }
      if($is_dicom_dir){
        Posda::DB::DicomDir::Import($db, $ds, $h->{file_id});
      } elsif ($has_sop_common){
        Posda::DB::DicomIod::Import($db, $ds, $h->{file_id}, $sop_class, 
          $dicom_file_type);
      } else {
        ## todo - what if its neither a DICOMDIR nor a known UID?
      }
    } else {
      my $file_type = `file \"$h->{path}\"`;
      chomp $file_type;
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
}


sub ProcessFiles{
  my($db) = @_;
  my $q = $db->prepare(
    "select\n" .
    "  file_id, root_path || '/' || rel_path as path\n" .
    "from\n" .
    "   file NATURAL JOIN file_location NATURAL JOIN file_storage_root\n" .
    "where is_dicom_file is null"
  );
  $q->execute();
  while(my $h = $q->fetchrow_hashref()){
    my($df, $ds, $size, $xfr_stx, $errors) = 
      Posda::Dataset::Try($h->{path});
    if($ds){
      my $has_meta = 0;
      if($df){
        if(defined $df->{"(0002,0001)"}){
          InsertMeta($db, $h->{file_id}, $df);
          $has_meta = 1;
        } else {
          push(@$errors, "Meta header with no (0002,0001) (entry not created)");
        }
      }
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
      }
      my $q = $db->prepare(
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
        "  dicom_file_type\n" .
        ")\n" .
        "values(?, ?, ?, ?, ?, ?)"
      );
      $q->execute(1, $h->{file_id});
      $q1->execute($h->{file_id}, $xfr_stx, $has_meta,
        $is_dicom_dir, $has_sop_common, $dicom_file_type);
      my $i_err = $db->prepare(
        "insert into dicom_file_errors(file_id, error_msg) values (?, ?)"
      );
      for my $i (@$errors){
        $i_err->execute($h->{file_id}, $i);
      }
      if($is_dicom_dir){
        Posda::DB::DicomDir::Import($db, $ds, $h->{file_id});
      } elsif ($has_sop_common){
        Posda::DB::DicomIod::Import($db, $ds, $h->{file_id}, $sop_class, 
          $dicom_file_type);
      } else {
        ## todo - what if its neither a DICOMDIR nor a known UID?
      }
    } else {
      my $file_type = `file $h->{path}`;
      chomp $file_type;
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
1;

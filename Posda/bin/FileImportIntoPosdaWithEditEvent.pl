#!/usr/bin/perl -w 
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Cwd;
use Posda::DB::PosdaFilesQueries;
use Digest::MD5;
use File::Copy;
use File::Path qw(remove_tree make_path);
use File::Compare;
my $start_t = PosdaDB::Queries->GetQueryInstance("StartTransactionPosda");
my $locker = PosdaDB::Queries->GetQueryInstance("LockFilePosda");
my $unlocker = PosdaDB::Queries->GetQueryInstance("EndTransactionPosda");
my $gfile = PosdaDB::Queries->GetQueryInstance("GetPosdaFileIdByDigest");
my $insf = PosdaDB::Queries->GetQueryInstance("InsertFilePosda");
my $gfileloc = PosdaDB::Queries->GetQueryInstance("FilePathComponentsByFileId");
my $ifl = PosdaDB::Queries->GetQueryInstance("InsertFileLocation");
my $mpfltp = PosdaDB::Queries->GetQueryInstance("MakePosdaFileReadyToProcess");
my $g_file_id = PosdaDB::Queries->GetQueryInstance("GetCurrentPosdaFileId");
my $get_root = PosdaDB::Queries->GetQueryInstance("GetPosdaFileCreationRoot");
my $insert_import_event = PosdaDB::Queries->GetQueryInstance("InsertEditImportEvent");
my $insert_file_import = PosdaDB::Queries->GetQueryInstance("InsertFileImportLong");
my $giei = PosdaDB::Queries->GetQueryInstance("GetImportEventId");

sub InsertFile{
  my($digest, $size, $edit_event_id, $event_description) = @_;
  $start_t->RunQuery(sub {}, sub {});
  $locker->RunQuery(sub {}, sub {});
  my $file_id;
  $gfile->RunQuery(sub {
      my($row) = @_;
      if(defined $file_id) {
        $unlocker->RunQuery(sub{}, sub {});
        die "Duplicate file entries for $digest";
      }
      $file_id = $row->[0];
    }, sub {},
    $digest
  );
  if(defined $file_id){
    CreateAdverseFileEventForFileEdit($file_id, 
      $edit_event_id,
      "File id is already defined for import resulting from edit");
  } else {
    $insf->RunQuery(sub {}, sub {}, $digest, $size);
    $g_file_id->RunQuery(sub {
        my($row) = @_;
        $file_id = $row->[0];
      }, sub {},
    );
  }
  $unlocker->RunQuery(sub{}, sub{});
  return $file_id;
}
sub CopyOrLinkFile{
  my($file_id, $digest, $root_id, $root, $fname, $errors) = @_;
  my @locs;
  $gfileloc->RunQuery(sub{
      my($row) = @_;
      push @locs, $row;
    }, sub {},
    $file_id
  );
  my($rel_path, $root_path);
  if(@locs <= 0){
    $root_path = $root;
    # Construct a path to the file and link or copy the file there
    unless($digest =~ /^(..)(..)(..)/){
      push(@$errors,  "digest error: doesn't have 6 leading hex digits");
      return (undef, undef);
    }
    my $d1 = $1;
    my $d2 = $2;
    my $d3 = $3;
    $rel_path = "$d1";
    unless(-d "$root/$d1"){
      unless(mkdir("$root/$d1")== 1){
        push(@$errors, "mkdir error: ($!) level 1");
        return (undef, undef);
      }
    }
    $rel_path .= "/$d2";
    unless(-d "$root/$d1/$d2"){
      unless(mkdir("$root/$d1/$d2") == 1){
        push(@$errors, "mkdir error: ($!) level 2");
        return (undef, undef);
      }
    }
    $rel_path .= "/$d3";
    unless(-d "$root/$d1/$d2/$d3"){
      unless(mkdir("$root/$d1/$d2/$d3") == 1){
        my $message = "mkdir error: ($!) level 3";
        push(@$errors, $message);
        return (undef, undef);
      }
    }
    $rel_path .= "/$digest";
    my $full_path = "$root/$rel_path";
    if(-e "$full_path"){
      unless(compare($full_path, $fname) == 0){
        my $message = 
           "########################\n" .
           "# Call the National Enquirer!!!!\n" .
           "# Two files with the same digest ($digest)\n" .
           "# are different:\n" .
           "#   $full_path\n" .
           "#   $fname\n" .
           "########################\n";
        push(@$errors, $message);
        return (undef, undef);
      }
    } else {
      unless(link $fname, $full_path){
        unless(copy($fname, $full_path)){
          my $message = 
            "########################\n" .
            "# Link and Copy both failed ($!)\n" .
            "# to:   $full_path\n" .
            "# from: $fname\n" .
            "########################\n";
          push(@$errors, $message);
          return (undef, undef);
        }
      }
    }
    # insert file location into db

    $ifl->RunQuery(sub{}, sub{}, $file_id, $root_id, $rel_path);
  } else {
    $rel_path = $locs[0]->[1];
    $root_path = $locs[0]->[0];
  }
  return ($rel_path, $root_path);
}
sub FileIsReady{
  my($file_id) = @_;
  $mpfltp->RunQuery(sub {}, sub {}, $file_id);
}
#################################################################
#  Create Adverse File Event for File Edit
my $create_adverse_file_event = 
 PosdaDB::Queries->GetQueryInstance("InsertAdverseFileEvent");
my $get_adverse_file_event_id = 
 PosdaDB::Queries->GetQueryInstance("GetCurrentAdverseFileEvent");
my $link_afe_to_edit_event = 
 PosdaDB::Queries->GetQueryInstance("LinkAFEtoEditEvent");
sub CreateAdverseFileEventForFileEdit{
  my($file_id, $edit_event_id, $event_description) = @_;
  $create_adverse_file_event->RunQuery(sub {}, sub {},
    $file_id, $event_description);
  my $id;
  $get_adverse_file_event_id->RunQuery(sub {
    my($row) = @_;
    $id = $row->[0];
  }, sub {});
  $link_afe_to_edit_event->RunQuery(sub{}, sub {}, $edit_event_id, $id);
}
#################################################################
#  Initialization  First phase of processing
my $usage = <<EOF;
Usage: FileImportIntoPosdaWithEditEvent.pl  <id> <import_type> <comment>";
or: /FileImportIntoPosdaWithEditEvent.pl -h

Expects list of file_paths on STDIN

Identical to FileImportIntoPosda.pl except for the following:

If it finds that the file is already present in Posda, it considers this
an "adverse file event" and creates rows in the following tables:

adverse_file_event (file_id, "edited file already present",
  "ImportIntoPosdaWithEditEvent.pl", now());
dicom_edit_event_adverse_file_event(<id>, <adverse_file_event_id>);
EOF
unless ($#ARGV == 2) {die $usage;}
my $edit_event_id = $ARGV[0];
my $import_type = $ARGV[1];
my $comment = $ARGV[2];
####GetPosdaFileCreationRoot
my($root, $root_id);
$get_root->RunQuery(sub{
    my($row) = @_;
    $root_id = $row->[0];
    $root = $row->[1];
  }, sub {});;
unless(-d $root) {
  die "No root path for storage found";
}
############################################################
# Create import_event 
$insert_import_event->RunQuery(sub{}, sub{}, $import_type, $comment);
####GetImportEventId
my $ie_id;
$giei->RunQuery(sub{
  my($row) = @_;
    $ie_id = $row->[0];
  }, sub {});
my @FileErrors;
############################################################
# Process files on STDIN
file:
while (my $fname = <STDIN>){
  chomp $fname;
  unless(-f $fname){
print STDERR "$fname is not a file\n";
    push(@FileErrors, "$fname is not a file");
    next file;
  }
  my $fd;
  unless(open $fd, "<$fname"){
    push(@FileErrors, "can't open $fname ($!)");
    next file;
  }
  my $ctx = Digest::MD5->new;
  $ctx->addfile($fd);
  close($fd);
  my $digest = $ctx->hexdigest;
  my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
      $atime,$mtime,$ctime,$blksize,$blocks) = stat($fname);
  my $file_id = InsertFile($digest, $size, $edit_event_id, $comment);
  my($rel_path, $root_path) = 
    CopyOrLinkFile($file_id, $digest, $root_id, $root, $fname, \@FileErrors);
  if(defined $rel_path){
    $insert_file_import->RunQuery(sub{}, sub{}, $ie_id, $file_id, $rel_path, $root_path, $fname);
  }
  FileIsReady($file_id);
}

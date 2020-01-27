#!/usr/bin/perl -w 
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Modern::Perl;
use Try::Tiny;

use Posda::DB::PosdaFilesQueries;
use Posda::DB 'Query';
use Posda::DebugLog;

use Digest::MD5;
use File::Copy;
use File::Path qw(remove_tree make_path);
use File::Compare;

use Data::Dumper;

# Queries {{{
# NOTE: See preload_queries function below for the actual query names!
our $start_t;
our $locker;
our $unlocker;
our $gfile;
our $insf;
our $gfileloc;
our $ifl;
our $mpfltp;
our $g_file_id;
our $insert_import_event;
our $insert_file_import;
our $giei;

our $FileStorageRoots;
#}}}
# Functions {{{
sub preload_queries {
  DEBUG "Loading queries";
  $start_t = Query("StartTransactionPosda");
  $locker = Query("LockFilePosda");
  $unlocker = Query("EndTransactionPosda");
  $gfile = Query("GetPosdaFileIdByDigest");
  $insf = Query("InsertFilePosda");
  $gfileloc = Query("FilePathComponentsByFileId");
  $ifl = Query("InsertFileLocation");
  $mpfltp = Query("MakePosdaFileReadyToProcess");
  $g_file_id = Query("GetCurrentPosdaFileId");
  $insert_import_event = Query("InsertEditImportEvent");
  $insert_file_import = Query("InsertFileImportLong");
  $giei = Query("GetImportEventId");
}

sub insert_file_or_get_id {
  # Insert the given file and return the new file_id,
  # OR if the file already exists, just return it's file_id
  my($digest, $size) = @_;
  $start_t->RunQuery(sub {}, sub {});
  $locker->RunQuery(sub {}, sub {});
  my $file_id;

  # Get the file_id given a digest{{{
  $gfile->RunQuery(sub {
      my($row) = @_;
      if(defined $file_id) {
        $unlocker->RunQuery(sub{}, sub {});
        die "Duplicate file entries for $digest";
      }
      $file_id = $row->[0];
    }, sub {},
    $digest
  );#}}}

  # if digest didn't already exist, insert it and get the new file_id {{{
  unless(defined $file_id){
    # insert file (without setting storage_location)
    $insf->RunQuery(sub {}, sub {}, $digest, $size);
    # get the new file_id TODO: this should be adjusted to a single command
    $g_file_id->RunQuery(sub {
        my($row) = @_;
        $file_id = $row->[0];
      }, sub {},
    );
  }#}}}

  # finish transaction
  $unlocker->RunQuery(sub{}, sub{});
  return $file_id;
}
sub set_file_ready_to_process {
  # Mark the file as ready to process
  my($file_id) = @_;
  $mpfltp->RunQuery(sub {}, sub {}, $file_id);
}

sub get_file_storage_roots {
  my $q_file_storage_roots = Query("GetPosdaFileStorageRoots");
  my $FileStorageRoots;
  map {
    my ($id, $root, $current, $class) = @$_;
    $FileStorageRoots->{$root} = {
      id => $id, current => $current, class => $class
    };
  } @{$q_file_storage_roots->FetchResults()};

  return $FileStorageRoots;
}

sub find_matching_root {
  my ($roots, $path) = @_;
  # find the correct root
  DEBUG "Searching for root for path: $path";
  my ($root_id, $root_path, $rel_path);
  fsr:
  for my $i (keys %{$roots}) {
    if ($path =~ /^$i\/(.*)/) {
      $root_id = $roots->{$i}->{id};
      $root_path = $i;
      $rel_path = $1;
      DEBUG "Found matching root: $root_id|$root_path|$rel_path";
      last fsr
    } else {
      DEBUG "Root did not match: $i";
    }
  }
  if (not defined $root_id) {
    die "Error: No root path for storage found";
  }

  return [$root_id, $root_path, $rel_path];
}

sub set_file_location {
  my ($file_id, $root_id, $rel_path) = @_;
  # First determine if this file already has a location set
  my $existing_location = $gfileloc->FetchOneHash($file_id);
  if (not defined $existing_location) { 
    $ifl->RunQuery(undef, undef, $file_id, $root_id, $rel_path);
    DEBUG "Created new file_location record";
  } else {
    DEBUG "File already has a location, skipping!";
  }
}

sub create_import_event {
  my ($message, $comment) = @_;
  # Create import_event  TODO: make this one query
  $insert_import_event->RunQuery(sub{}, sub{}, $message, $comment);
  ####GetImportEventId
  my $ie_id;
  $giei->RunQuery(sub{
    my($row) = @_;
      $ie_id = $row->[0];
    }, sub {});
  return $ie_id;
}

sub process_one_file {
  my ($path, $import_event_id) = @_;
  my($root_id, $root_path, $rel_path) = 
    @{find_matching_root($FileStorageRoots, $path)};

  ############################################################
  unless(-f $path){
    die "Error: $path is not a file\n";
  }
  my $fd;
  unless(open $fd, "<$path"){
    die "Error: can't open $path ($!)\n";
  }

  my $ctx = Digest::MD5->new;
  $ctx->addfile($fd);
  close($fd);

  my $digest = $ctx->hexdigest;

  my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
      $atime,$mtime,$ctime,$blksize,$blocks) = stat($path);

  my $file_id = insert_file_or_get_id($digest, $size);

  set_file_location($file_id, $root_id, $rel_path);

  # Record the import event
  if(defined $rel_path){
    $insert_file_import->RunQuery(sub{}, sub{}, 
      $import_event_id, $file_id, $rel_path, $root_path, $path);
  }

  set_file_ready_to_process($file_id);
  return "File id: $file_id";
}

#}}}
# Main body {{{

#  Initialization  First phase of processing
my $usage = <<EOF;
Usage: ImportFilesInPlace.pl "<path>" "<comment>";
or: ImportFilesInPlace.pl -h

Imports <path> and prints to STDOUT:
File id: <file_id>
or
Error: <description of error>

If <path> is -, read multiple files from STDIN,
and print a report (as above) to STDOUT for each file.
EOF

unless ($#ARGV == 1) {
  DEBUG "Argument count looks wrong, exiting with usage.";
  die $usage;
}
my $path = $ARGV[0];
my $comment = $ARGV[1];

preload_queries(); # load only after arguments are checked
$FileStorageRoots = get_file_storage_roots();

if ($path eq '-') {
  DEBUG "Reading filenames from STDIN";
  my $import_id = create_import_event("multi file import", $comment);
  print "Import id: $import_id\n";
  while (<STDIN>) {
    chomp;
    $path = $_;
    try { # continue processing new lines even when one fails
      say process_one_file($path, $import_id);
    } catch {
      print;
    }
  }
} else {
  my $import_id = create_import_event("single file import", $comment);
  say process_one_file($path, $import_id);
}

# vim: foldmethod=marker

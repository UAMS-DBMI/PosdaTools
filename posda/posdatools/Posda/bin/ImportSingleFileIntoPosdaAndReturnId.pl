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
use Data::Dumper;

my $start_t = PosdaDB::Queries->GetQueryInstance("StartTransactionPosda");
my $gfile = PosdaDB::Queries->GetQueryInstance("GetPosdaFileIdByDigest");
my $insf = PosdaDB::Queries->GetQueryInstance("InsertFilePosdaReturnID");
my $gfileloc = PosdaDB::Queries->GetQueryInstance("FilePathComponentsByFileId");
my $ifl = PosdaDB::Queries->GetQueryInstance("InsertFileLocation");
my $mpfltp = PosdaDB::Queries->GetQueryInstance("MakePosdaFileReadyToProcess");
my $g_file_id = PosdaDB::Queries->GetQueryInstance("GetCurrentPosdaFileId");
my $get_root = PosdaDB::Queries->GetQueryInstance("GetPosdaFileCreationRoot");
my $insert_import_event = PosdaDB::Queries->GetQueryInstance("InsertEditImportEvent");
my $insert_file_import = PosdaDB::Queries->GetQueryInstance("InsertFileImportLong");
my $giei = PosdaDB::Queries->GetQueryInstance("GetImportEventId");
my $endtransaction = PosdaDB::Queries->GetQueryInstance("EndTransactionPosda");

sub InsertFile{
  my($digest, $size) = @_;
  $start_t->RunQuery(sub {}, sub {});
    
  my $results = $insf->FetchOneHash($digest,$size);
  my $file_id;
  unless(defined $results){
    $gfile->RunQuery(sub {
	   my($row) = @_;
           $file_id = $row->[0];
         }, sub {}, $digest);
  }else{
    $file_id = $results->{file_id};
  }
  $endtransaction->RunQuery(sub{}, sub{});
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
#  Initialization  First phase of processing
my $usage = <<EOF;
Usage: ImportSingleFileIntoPosdaAndReturnId.pl <path> <comment>";
or: ImportSingleFileIntoPosdaAndReturnId.pl -h

Imports <path> and prints to STDOUT:
File id: <file_id>
or
Error: <description of error>
EOF
unless ($#ARGV == 1) {die $usage;}
my $path = $ARGV[0];
my $comment = $ARGV[1];
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
$insert_import_event->RunQuery(sub{}, sub{}, "single file import", $comment);
####GetImportEventId
my $ie_id;
$giei->RunQuery(sub{
  my($row) = @_;
    $ie_id = $row->[0];
  }, sub {});
my @FileErrors;
############################################################
# Process files on STDIN
  unless(-f $path){
    print "Error: $path is not a file\n";
    exit;
  }
  my $fd;
  unless(open $fd, "<$path"){
    print "Error: can't open $path ($!)\n";
    exit;
  }
  my $ctx = Digest::MD5->new;
  $ctx->addfile($fd);
  close($fd);
  my $digest = $ctx->hexdigest;
  my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
      $atime,$mtime,$ctime,$blksize,$blocks) = stat($path);
  my $file_id = InsertFile($digest, $size);
  my($rel_path, $root_path) = 
    CopyOrLinkFile($file_id, $digest, $root_id, $root, $path, \@FileErrors);
  if(defined $rel_path){
    $insert_file_import->RunQuery(sub{}, sub{}, $ie_id, $file_id, $rel_path, $root_path, $path);
  }
  FileIsReady($file_id);
  print "File id: $file_id\n";

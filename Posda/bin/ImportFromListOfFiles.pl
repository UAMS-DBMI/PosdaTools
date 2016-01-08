#!/usr/bin/perl -w 
#$Source: /home/bbennett/pass/archive/Posda/bin/ImportFromListOfFiles.pl,v $
#$Date: 2015/12/15 14:06:41 $
#$Revision: 1.1 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Cwd;
use DBD::Pg;
use Digest::MD5;
use File::Copy;
use File::Path qw(remove_tree make_path);
use File::Compare;

sub InsertFile{
  my($db, $digest, $size) = @_;
  my $start_t = $db->prepare("begin");
  my $locker = $db->prepare("LOCK file in ACCESS EXCLUSIVE mode");
  my $unlocker = $db->prepare("commit");
  $start_t->execute;
  $locker->execute;
  my $gfile = $db->prepare("select * from file where digest = ?");
  $gfile->execute($digest);
  my @files;
  while(my $h = $gfile->fetchrow_hashref){
    push(@files, $h);
  }
  if(@files > 1){
    $unlocker->execute;
    die "Duplicate file entries for $digest";
  }
  my $file_id;
  if(@files == 0){
    my $insf = $db->prepare(
      "insert into file(\n" .
      "  digest, size, processing_priority, ready_to_process\n" .
      ") values ( ?, ?, 1, 'false')");
    $insf->execute($digest, $size);
    my $g_file_id = $db->prepare("select currval('file_file_id_seq') as id");
    $g_file_id->execute;
    my $h = $g_file_id->fetchrow_hashref;
    $g_file_id->finish;
    $file_id = $h->{id};
  } else {
    $file_id = $files[0]->{file_id};
  }
  $unlocker->execute;
  return $file_id;
}
sub CopyOrLinkFile{
  my($db, $file_id, $digest, $root_id, $root, $fname, $errors) = @_;
  my $gfileloc = $db->prepare(
    "select root_path || '/' || rel_path as path, rel_path, root_path\n" .
    "from file_location natural join file_storage_root\n" .
    "where file_id = ?");
  $gfileloc->execute($file_id);
  my @locs;
  while (my $h = $gfileloc->fetchrow_hashref){
    push @locs, $h;
  }
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
    my $ifl = $db->prepare("insert into file_location(\n" .
      "  file_id, file_storage_root_id, rel_path\n" .
      ") values ( ?, ?, ?)");
    $ifl->execute($file_id, $root_id, $rel_path);
  } else {
    $rel_path = $locs[0]->{rel_path};
    $root_path = $locs[0]->{root_path};
  }
  return ($rel_path, $root_path);
}
sub FileIsReady{
  my($db, $file_id) = @_;
  my $q = $db->prepare(
    "update file set ready_to_process = 'true' where file_id = ?"
  );
  $q->execute($file_id);
}
my $usage = "Usage: $0 <db_name> <comment>";
unless ($#ARGV == 1) {die $usage;}
my $db_name = $ARGV[0];
my $comment = $ARGV[1];
my $db = DBI->connect("dbi:Pg:dbname=$db_name");
unless($db) { die "Can't connect to $db_name" }
my $get_root = $db->prepare("select * from file_storage_root where current");
$get_root->execute;
my $h = $get_root->fetchrow_hashref;
$get_root->finish;
my $root = $h->{root_path};
my $root_id = $h->{file_storage_root_id};
unless(-d $root) {
  die "No root path for storage found";
}
############################################################
# Create import_event 
my $iie = $db->prepare(
  "insert into import_event(\n" .
  "  import_type, import_comment, import_time\n" .
  ") values (\n" .
  "  ?, ?, now()\n" .
  ")"
);
$iie->execute("Import From File List", $comment);
my $giei = $db->prepare("select currval('import_event_import_event_id_seq') as id");
$giei->execute;
$h = $giei->fetchrow_hashref;
$giei->finish;
my $ie_id = $h->{id};
my @FileErrors;
############################################################
# Process files on STDIN
file:
while (my $fname = <STDIN>){
  chomp $fname;
  unless(-f $fname){
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
  my $file_id = InsertFile($db, $digest, $size);
  my($rel_path, $root_path) = 
    CopyOrLinkFile($db, $file_id, $digest, $root_id, $root, $fname, \@FileErrors);
  if(defined $rel_path){
    my $ifi = $db->prepare(
      "insert into file_import(\n" .
      "  import_event_id, file_id, rel_path, rel_dir, file_name\n" .
      ") values ( ?, ?, ?, ?, ?)"
    );
    $ifi->execute($ie_id, $file_id, $rel_path, $root_path, $fname);
  }
  FileIsReady($db, $file_id);
}

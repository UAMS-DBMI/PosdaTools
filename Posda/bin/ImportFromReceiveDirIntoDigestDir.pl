#!/usr/bin/perl -w 
#$Source: /home/bbennett/pass/archive/Posda/bin/ImportFromReceiveDirIntoDigestDir.pl,v $
#$Date: 2015/12/15 14:06:04 $
#$Revision: 1.4 $
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

sub EnterErrors{
  my($db, $id, $desc, $errors) =@_;
  my $num = @$errors;
  print STDERR "$num Errors ($desc):\n";
  for my $e (@$errors) {
    print "\t$e\n";
  }
}
sub UpdateAssocStatus{
  my($db, $id, $status) = @_;
  my $upd = $db->prepare("update association set processing = ?\n" .
    "where association_id = ?");
  $upd->execute($status, $id);
}
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
my $usage = "Usage: $0 <assoc_dir> <db_name> <comment>";
unless ($#ARGV == 2) {die $usage;}
my $assoc_dir = $ARGV[0];
my $db_name = $ARGV[1];
my $comment = $ARGV[2];
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
my $assoc_info_file = "$assoc_dir/Session.info";
unless(-f $assoc_info_file) { die "Association Dir has no info file" }
############################################################
# Parse Association Info
open INFO, "<$assoc_info_file" or
  die "open failed: ($!) $assoc_info_file";
my %AssocInfo;
$AssocInfo{parse_errors} = [];
$AssocInfo{errors} = [];
my @FileList;
while(my $line = <INFO>){
  chomp $line;
  my @fields = split(/\|/, $line);
  if($fields[0] eq "SCU"){
    $AssocInfo{SCU} = $fields[1];
  } elsif($fields[0] eq "host"){
    $AssocInfo{host} = $fields[1];
  } elsif($fields[0] eq "status"){
    $AssocInfo{status} = $fields[1];
  } elsif($fields[0] eq "calling"){
    $AssocInfo{calling} = $fields[1];
  } elsif($fields[0] eq "called"){
    $AssocInfo{called} = $fields[1];
  } elsif($fields[0] eq "start time"){
    $AssocInfo{start} = $fields[1];
  } elsif($fields[0] eq "elapsed time"){
    $AssocInfo{elapsed} = $fields[1];
  } elsif($fields[0] eq "proposed_pc"){
    for my $i (3 .. $#fields){
      $AssocInfo{proposed}->{$fields[1]}->{$fields[2]}->{$fields[$i]} = 1;
    }
  } elsif($fields[0] eq "accepted_pc"){
    $AssocInfo{accepted}->{$fields[1]} = $fields[2];
  } elsif($fields[0] eq "rejected_pc"){
    $AssocInfo{rejected}->{$fields[1]} = $fields[2];
  } elsif($fields[0] eq "file"){
    push @FileList, {
      sop_class => $fields[1],
      sop_inst => $fields[2],
      xfer_stx => $fields[3],
      path => $fields[4],
    };
  } else {
    push @{$AssocInfo{parse_errors}}, {
      type => "Unparsable line",
      line => $line
    };
  }
}
close INFO;
############################################################
# If association already processed, error
my $check_assoc = <<EOF;
select * from association where session_info_file = ?
EOF
my $create_assoc = <<EOF;
insert into association(
  called_ae_title, calling_ae_title, start_time, duration, originating_ip_addr,
  processing, session_info_file
)values(
  ?, ?, to_timestamp(?), ?, ?, 'processing Session.info', ?
)
EOF
my $cq = $db->prepare($check_assoc);
my @assocs;
$cq->execute($assoc_info_file);
while(my $h = $cq->fetchrow_hashref){
  push @assocs, $h;
}
if($#assocs > 0){
  die "Error: $assoc_info_file has been imported more than once before\n";
} elsif ($#assocs == 0){
  die "Error: $assoc_info_file has been imported once before\n";
}
############################################################
# Create association row
my $crq = $db->prepare($create_assoc);
$crq->execute($AssocInfo{called}, $AssocInfo{calling}, $AssocInfo{start},
  $AssocInfo{elapsed}, $AssocInfo{host}, $assoc_info_file);
my $get_id = $db->prepare("select currval('association_association_id_seq') as id");
$get_id->execute;
$h = $get_id->fetchrow_hashref;
$get_id->finish;
my $id = $h->{id};
############################################################
# Create presention context rows
UpdateAssocStatus($db, $id, "processing presentation contexts for association");
for my $pc (keys %{$AssocInfo{$id}->{proposed}}){
  my $astx = [ keys %{$AssocInfo{$pc}->{proposed}->{$pc}} ]->[0];
  if(exists $AssocInfo{$pc}->{accepted}){
    my $ipc = $db->prepare(
      "insert into association_pc(\n" .
      "  association_id,\n" .
      "  abstract_syntax_uid\n" .
      "  accepted,\n" .
      "  accepted_ts\n" .
      ") values (\n" .
      "  ?, ?, 'true', ?\n" .
      ")"
    );
    $ipc->execute($id, $astx, $AssocInfo{$pc}->{accepted});
    my $gpcid = $db->prepare("select currval('association_pc_association_pc_id_seq') as pcid");
    $gpcid->execute;
    my $h1 = $gpcid->fetchrow_hashref;
    $gpcid->finish;
    my $pcid = $h1->{pcid};
    my $insptsx = $db->prepare(
      "insert into association_pc_proposed_ts(\n" .
        "association_pc_id, proposed_ts_uid\n" .
      ")values( ?, ?)"
    );
    for my $tsx (keys %{$AssocInfo{$pc}->{proposed}->{$pc}}){
      $insptsx->execute($pcid, $tsx);
    }
  } elsif(exists $AssocInfo{$pc}->{rejected}){
    my $ipc = $db->prepare(
      "insert into association_pc(\n" .
      "  association_id,\n" .
      "  abstract_syntax_uid\n" .
      "  accepted,\n" .
      "  not_accepted_reason\n" .
      ") values (\n" .
      "  ?, ?, 'false', ?\n" .
      ")"
    );
    $ipc->execute($id, $astx, $AssocInfo{$pc}->{rejected});
  } else {
    push(@{$AssocInfo{errors}}, { type => "negot_error",
      "Pcid: $pc ($astx) is neither accepted nor rejected" });
  }
}
############################################################
# Log parse errors
if( @{$AssocInfo{parse_errors}} > 0){
  EnterErrors($db, $id, "parse Session.info", $AssocInfo{parse_errors});
}
if( @{$AssocInfo{errors}} > 0){
  EnterErrors($db, $id, "processing Session.info", $AssocInfo{errors});
}
############################################################
# Create import_event linked to association
my $iie = $db->prepare(
  "insert into import_event(\n" .
  "  import_type, import_comment, import_time, remote_file\n" .
  ") values (\n" .
  "  ?, ?, now(), ?\n" .
  ")"
);
$iie->execute("Association", $comment, $assoc_info_file);
my $giei = $db->prepare("select currval('import_event_import_event_id_seq') as id");
$giei->execute;
$h = $giei->fetchrow_hashref;
$giei->finish;
my $ie_id = $h->{id};
my $iai = $db->prepare("insert into association_import(\n" .
  "  association_id, import_event_id\n" .
  ") values ( ?, ? )");
$iai->execute($id, $ie_id);
############################################################
# Insert Session.info as file here
my $ctx = Digest::MD5->new;
open INFO, "<$assoc_info_file" or
  die "open failed: ($!) $assoc_info_file";
$ctx->addfile(\*INFO);
my $digest = $ctx->hexdigest;
close INFO;
my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
      $atime,$mtime,$ctime,$blksize,$blocks) = stat($assoc_info_file);
my $file_id = InsertFile($db, $digest, $size);
my $errors = [];
my($rel_path, $root_path) = 
  CopyOrLinkFile($db, $file_id, $digest, $root_id, $root, $assoc_info_file,
    $errors);
if(defined $rel_path){
  my $ifi = $db->prepare(
    "insert into file_import(\n" .
    "  import_event_id, file_id, rel_path, rel_dir, file_name\n" .
    ") values ( ?, ?, ?, ?, ?)"
  );
  $ifi->execute($ie_id, $file_id, $rel_path, $root_path, $assoc_info_file);
}
if($#{$errors} >= 0){
    EnterErrors($db, $id, "inserting Session.info", $errors);
}
FileIsReady($db, $file_id);
my $file_count = @FileList;
if($file_count <= 0){
  UpdateAssocStatus($db, $id, "association processing complete");
  exit;
}
############################################################
# Process files in association
my $NumberOfFiles = $file_count;
UpdateAssocStatus($db, $id, 
  "processing ($file_count) file list for association");
my @FileErrors;
file:
for my $fdesc (@FileList){
  my $fname = $fdesc->{path};
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
if($#FileErrors >= 0){
  EnterErrors($db, $id, "process file list", \@FileErrors);
}
UpdateAssocStatus($db, $id, "association processing complete");
if(
  $#{$AssocInfo{parse_errors}} < 0 &&
  $#{$AssocInfo{errors}} < 0 &&
  $#FileErrors < 0
){
  remove_tree($assoc_dir);
}

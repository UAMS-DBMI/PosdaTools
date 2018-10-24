#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Digest::MD5;
use File::Path;
use File::Copy;
my $usage = <<EOF;
CopyFilesFromRootToRoot.pl <from_root_type> <to_root_type> <count>
  or
CopyFilesFromRootToRoot.pl -h
EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 2){
  die "$usage\n";
}
my $get_id = PosdaDB::Queries->GetQueryInstance("StorageRootIdByClass");
my $get_root = PosdaDB::Queries->GetQueryInstance("StorageRootIdById");
my $get_locations = PosdaDB::Queries->GetQueryInstance(
  "GetNLocationsByFileStorageRootId");
my $change_location = PosdaDB::Queries->GetQueryInstance(
  "ChangeFileStorageRootIdByFileIdAndOldStorageRootId");
my $from_desc = $ARGV[0];
my $to_desc = $ARGV[1];
my $count = $ARGV[2];
my $from_id;
$get_id->RunQuery(sub{
  my($row) = @_;
  if(defined $from_id) {
    die "Database config error: multiple file_storage_roots for class $from_desc";
  }
  $from_id = $row->[0];
} , sub {}, $from_desc);
my $to_id;
$get_id->RunQuery(sub{
  my($row) = @_;
  if(defined $to_id) {
    die "Database config error: multiple file_storage_roots for class $to_desc";
  }
  $to_id = $row->[0];
} , sub {}, $to_desc);
my $FromRoot;
$get_root->RunQuery(sub {
  my($row) = @_;
  $FromRoot = $row->[0];
}, sub {}, $from_id);
my $ToRoot;
$get_root->RunQuery(sub {
  my($row) = @_;
  $ToRoot = $row->[0];
}, sub {}, $to_id);
my %ByFileId;
$get_locations->RunQueries(sub {
  my($row) = @_;
  my($file_id, $digest, $file_path) = @_;
  $ByFileId{$file_id} = [ $digest, $file_path ];
}, sub {}, $from_Id, $count);
file:
for my $file_id (keys %ByFileId){
  my $digest = $ByFileId{$file_id}->[0];
  my $rel_path = $ByFileId{$file_id}->[1];
  my $from_path = "$FromRoot/$rel_path";
  unless(-f $from_path) {
    print STDERR "File not Found for Copy: $from_path\n";
    next file;
  }
  unless($rel_path =~ /^(.*)\/([^\/]+)$/){
    print STDERR "Can't extract file from rel_path: $rel_path\n";
    next file;
  }
  my $rel_dir = $1;
  my $file_part = $2;
  my $dest_dir = "$ToRoot/$rel_dir";
  unless(-d $dest_dir){
    if(-e $dest_dir){
      print STDERR "file: $dest_dir should be dir\n";
      next file;
    }
    mkpath($dest_dir)
    unless(-d $dest_dir){
      print STDERR "failed to mkdir $dest_dir\n";
      next file;
    }
  }
  unless(open DIG "<$from_path"){
    print STDERR "Can't open ($!) from_file $from_path\n";
    close DIG;
    next file;
  }
  my $ctx = Digest::MD5->new;
  $ctx->addfile(\*DIG);
  close DIG;
  my $file_dig = $ctx->hexdigest;
  unless($digest eq $file_dig){
    print STDERR "Digest ($digest) doesn't match ($file_dig)\n" .
      "\tfor file $file_id\n\t($from_path)\n";
    next file;
  }
  my $dest_file = "$dest_dir/$file_part"
  if(-f $dest_file){
    print STDERR "Warning: $dest_file already exists (going to overwrite)\n";
  }
  print "Need to copy:\n";
  print "From: $from_file\n";
  print "To: $to_file\n";
}

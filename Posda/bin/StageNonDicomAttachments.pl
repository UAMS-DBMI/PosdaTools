#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;

my $usage = <<EOF;
StageNonDicomAttachments.pl <bkgrnd_id> <collection> <dir>
or
StageNonDicomAttachments.pl -h

Link all non_dicom_attachments into directory

Doesn't bother to enter background
EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 2){
  die "$usage\n";
}

my ($invoc_id, $collection, $dir) = @ARGV;
print "Invoc_id: $invoc_id\nCollection: $collection\nDir: $dir\n";

unless(-d $dir) {
  print "Error: ($dir is not a directory)\n";
  exit;
}
my $file_list = Query("GetAttachmentFiles");
my @FileList;
$file_list->RunQuery(sub {
  my($row) = @_;
#  my($file_id, $path, $ext) = @$row
  push @FileList, $row;
}, sub {}, $collection);

my $num_files = @FileList;
print "About to link $num_files files\n";
for my $i (@FileList){
  my($file_id, $path, $ext) = @$i;
  my $from = "$dir/$file_id.$ext";
  my $to = $path;
  if(symlink $path, $from){
    print "Linked $from to $path\n";
  } else {
    print "Failed ($!) to link $from to $path\n";
  }
}

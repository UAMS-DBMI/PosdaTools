#!/usr/bin/perl -w
#
#Copyright 2011, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Socket;
use Posda::Try;
use Posda::UUIDServer;
use Cwd;
my $usage = "usage: $0 <from> <prog>\n" .
  "usage: $0 -h\n";
if($ARGV[0] eq "-h"){
  print
    "\n\n\n" .
    "ModifyDoseArray.pl - Modify a Dose Matrix using an external C program\n" .
    "This program is invoked as follows:\n" .
    "  ModifyDoseArray.pl <from> <prog>\n" .
    "where:\n" .
    "  <from> is the name (or path to) a DICOM RTDOSE file\n" .
    "  <prog> is an external program (normally a C program)\n\n" .
    "This external program will be invoked to manipulate the pixel data\n" .
    "of the dose.  It is invoked with the following parameters:\n" .
    "  <prog> <rows> <cols> <planes> <bytes_per_pixel> <grid_scaling>\n\n" . 
    "The program is expected to read the original dose on STDIN, and\n" .
    "write the modified dose / dose description to STDOUT (see below for format).\n\n" .
    "The new RTDOSE file will have a new SOP Instance UID, and will be\n" .
    "written to a file in the current directory with a name of the form:\n" .
    "RD_<sop_inst_uid>.dcm\n" .
    "The old dose array will be replaced by the new dose array, and the file\n" .
    "will have a new meta-header.  Otherwise it will be the same as the old\n" .
    "RTDOSE file.\n\n" .
    "The pixels in both the new and old dose arrays are in the \"raw format\" in\n" .
    "the DICOM files (which is little endian).\n\n" .
    "The format for the output of from the sub-program is as follows:\n" .
    "There is a header which consists of a number of lines of the form\n" .
    "<name>:<value>\n\n" .
    "where name is one of the descriptors (rows, cols, bytes_per_pixel, or\n" .
    "grid_scaling), and value is the value to assign to the descriptor.\n" .
    "At this time, the only descriptor which is allowed to be changed is\n" .
    "\"grid_scaling\".  An attempt to change any other will result in a\n" .
    "crash.  The last line in the header contains the line:\n" .
    "dose:\n\n" .
    "It is terminated (like all of the lines in the file) with a single newline\n" .
    "(i.e. it follows UNIX/C conventions for lines), and is followed\n" .
    "immediately by the (binary) dose.  The length of the binary dose\n" .
    "should match the descriptors.\n\n";
  exit;
}
unless($#ARGV == 1){ die $usage}
my $dir = getcwd;
my $from_file = $ARGV[0];
my $prog = $ARGV[1];
unless($from_file =~ /^\//) {
  $from_file = "$dir/$from_file";
}
my $try = Posda::Try->new($from_file);
unless(exists $try->{dataset}) {
  die "$from_file is not a DICOM file";
}
my $ds = $try->{dataset};
my $modality = $ds->Get("(0008,0060)");
unless($modality eq "RTDOSE"){
  die "$from_file is not a DICOM DOSE file";
}
my $rows = $ds->Get("(0028,0010)");
my $cols = $ds->Get("(0028,0011)");
my $frames = $ds->Get("(0028,0008)");
my $bits_alloc = $ds->Get("(0028,0100)");
my $scaling = $ds->Get("(3004,000e)");
my $bytes;
if($bits_alloc == 8) { $bytes = 1 }
elsif($bits_alloc == 16) { $bytes = 2 }
elsif($bits_alloc == 32) { $bytes = 4 }
else { die "don't support bits_alloc of $bits_alloc" } 
my $pixels = $ds->Get("(7fe0,0010)");
my $len = length($pixels);
unless($len == $rows * $cols * $frames * $bytes){
  my $pix_len = length($pixels);
  my $len = $rows * $cols *$frames * $bytes;
  die "pixel length ($pix_len) doesn't match computed ($len)";
}
my $new_root = UUIDServer::new_root();
$ds->Insert("(0008,0018)", $new_root);
socketpair(PARENT, CHILD, AF_UNIX, SOCK_STREAM, PF_UNSPEC) or die
  "socketpair: $!";
my $child_pid = fork;
unless(defined $child_pid) { die "couldn't fork $!" }
if($child_pid == 0){
  # here we are in the child;
  close CHILD;
  open(STDIN, "<&PARENT");
  open(STDOUT, ">&PARENT");
  exec "$prog $rows $cols $frames $bytes $scaling";
  die "exec failed: $!";
} else {
  # here we are in the parent
  close PARENT;
  my $written = 0;
  while($written < $len){
    my $next_write = syswrite(CHILD, $pixels, ($len - $written), $written);
    unless(defined($next_write)){
      die "Error writing to child: $!";
    }
    $written += $next_write;
  }
  shutdown(CHILD, 1);
  my($new_rows, $new_cols, $new_planes, $new_bytes, $new_scaling);
  while(my $line = <CHILD>){
    chomp $line;
    if($line eq "dose:"){ last }
    if($line =~ /^\s*rows\s*:\s*(.*)\s*/){
      $new_rows = $1;
      unless($new_rows == $rows) { die "Not allowing you to change rows now" }
    }elsif($line =~ /^\s*cols\s*:\s*(.*)\s*/){
      $new_cols = $1;
      unless($new_rows == $cols) { die "Not allowing you to change cols now" }
    }elsif($line =~ /^\s*frames\s*:\s*(.*)\s*/){
      $new_planes = $1;
      unless($new_planes == $frames) {
        die "Not allowing you to change frames now" 
      }
    }elsif($line =~ /^\s*bytes_per_pixel\s*:\s*(.*)\s*/){
      $new_bytes = $1;
      unless($new_bytes == $bytes) {
        die "Not allowing you to change bytes_per_pixel now" 
      }
    }elsif($line =~ /^\s*grid_scaling\s*:\s*(.*)\s*/){
      $new_scaling = $1;
      $ds->Insert("(3004,000e)", $new_scaling);
    }
  }
  my $buff = "\0" x $len;
  my $len_read = 0;
  while($len_read < $len) {
    my $this_read = read(CHILD, $buff, ($len - $len_read), $len_read);
    unless(defined $this_read){
      die "Error reading from child: $!";
    }
    $len_read += $this_read;
  }
  $ds->Insert("(7fe0,0010)", $buff);
  my $file_name = "RD_$new_root.dcm";
  $ds->WritePart10($file_name, $try->{xfr_stx}, "POSDA", undef, undef);
}

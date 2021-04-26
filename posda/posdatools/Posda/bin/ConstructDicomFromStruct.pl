#!/usr/bin/perl -w
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Dataset;
use Debug;
my $dbg = sub { print STDERR @_ };
my $help = <<EOF;
ConstructDicomFromStruct.pl <file>
 Reads spec on STDIN
 Writes DICOM file to <file>
Spec linw format:
"#..." - comment
<ele_sig>: <value>

Value is text except as follows:
 0xhhhhhhhh - represents a DICOM tag reference
 <?external file_path=<path> offset=<offset> size=><size>?> where to get large data

EOF
if($#ARGV == 0 && ($ARGV[0] eq "-h")){
  print $help;
  exit;
}
my $file = $ARGV[0];
my $xfer_syntax = "1.2.840.10008.1.2.1";
my $ds = Posda::Dataset->new_blank;
for my $line (<STDIN>){
  chomp $line;
  if($line =~ /^#/) { next }
  my($tag, $val);
  if($line =~ /^([^:]+): (.*)$/){
    $tag = $1;
    $val = $2;
  } else {
    print "Line not recognized: $line\n";
    next;
  }
  if($val =~ /^<\?(.*)\?>$/){
    my $macro = $1;
    ParseAndInsertMacro($ds, $tag, $macro);
  } else {
    if($val =~ /^0x(........)$/){
      $val = hex($1);
    }
    if($val =~ /\\/){
      $val = [ split(/\\/, $val) ];
    }
    $ds->Insert($tag, $val);
  }
}
$ds->WritePart10($file, $xfer_syntax, "POSDA");
sub ParseAndInsertMacro{
  my($ds, $tag, $macro) = @_;
  if($macro =~ /^(\S*)\s*(.*)$/){
    my $name = $1;
    unless($name eq "external_file") { die "unknown macro $name" }
    my $remain = $2;
    my @pairs = split(/\s+/, $remain);
    my %nv;
    for my $p (@pairs){
      my($n, $v);
      ($n, $v) = split("=", $p);
      $nv{$n} = $v;
    }
    unless (exists($nv{path}) && exists($nv{offset}) && exists($nv{size})){
      die "macro $name must have path, offset and size ($macro)";
    }
    unless($tag eq "(7fe0,0010)"){
      die "only (7fe0,0010) is currently allowed to have external data";
    }
    my $grp = 0x7fe0;
    my $ele = 0x10;
    $ds->{$grp}->{$ele} = {
      VM => 1,
      VR => 'OB',
      file_pos => $nv{offset},
      ele_len_in_file => $nv{size},
      left_in_file => $nv{path},
      type => 'raw'
    };
  }
}

#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::Try;
use Debug;
my $usage = <<EOF;
AnonymizerToEditor.pl
  Finds all plans in Posda DB which have no corresponding file_for row.
  Parses each file and populates the file_for row.

Expects nothing on on <STDIN>

Uses the following queries:
  PlansWithNoFrameOfRef
  InsertFileFrameOfRef
EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == -1){
  print "Invalid number of args\n$usage";
  exit;
}
my $get_file = Query("PlansWithNoFrameOfRef");
my $ins_file_for = Query("InsertFileFrameOfRef");
$get_file->RunQuery(sub {
  my($row) = @_;
  my($file_id, $path) = @$row;
  my $try = Posda::Try->new($path);
  if(exists $try->{dataset}){
    my $ds = $try->{dataset};
    my $for = $ds->Get("(0020,0052)");
    my $pos_ref_ind = $ds->Get("(0020,1040)");
    if($for){
      $ins_file_for->RunQuery(sub {}, sub {}, $file_id, $for, $pos_ref_ind);
    } else {
      print STDERR "no for for file_id: $file_id\n";
    }
  } else {
    print STDERR "file: $path didn't parse\n";
  }
}, sub {});

#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/DicomProxy/bin/ExtractAssocNegot.pl,v $
#$Date: 2014/01/16 15:57:06 $
#$Revision: 1.1 $
#
use strict;
use Storable qw( store_fd fd_retrieve );
use Dispatch::Dicom::Assoc;
use Debug;
use IO::Handle;
use HexDump;
my $dbg = sub { print @_ };
my $usage = <<EOF;
ExtractAssocNegot.pl <dir>
 or
ExtractAssocNegot.pl -h

Expects to find the following files in the directory:
  pdu_analysis
  trace_from_data
  trace_to_data

Association data:
\$assoc_data = {
  a_assoc_rq => <assoc_rq>, # if request found in <trace_from>
  a_assoc_ac => <assoc_ac>, # if accept found in <trace_to>
  a_assoc_rj => <assoc_rj>, # if reject found in <trace_to>
  error => <errors>         # if can't find rq and one of either ac or rj
};

Association data stored in file
  assoc_data
in <dir>
EOF
if($ARGV[0] eq "-h"){
  print $usage;
  exit;
}
my $dir = $ARGV[0];
my $result = {};
my $pdu_analysis;
sub Done{
  my $fh;
  unless(open $fh, ">$dir/assoc_data"){
    print "Error: Unable to open $dir/assoc_data\n";
    exit;
  }
  store_fd $result, $fh;
  close $fh;
  print "OK\n";
  exit;
}
unless(-f "$dir/trace_from_data") {
  print "Error: $dir/trace_from_data\n";
  exit;
}
unless(-f "$dir/trace_to_data") {
  print "Error: $dir/trace_from_data\n";
  exit;
}
unless(open PDU, "<$dir/pdu_analysis") {
  print "Error: Unable to open $dir/pdu_analysis\n";
  exit;
}
eval { $pdu_analysis = fd_retrieve(\*PDU) };
if($@){
  print "Error: Unable to retrieve $dir/pdu_analysis: $@\n";
}
my $assoc_rq_pdu_desc = $pdu_analysis->{from_pdu}->[0];
unless($assoc_rq_pdu_desc->{pdu_type} eq "A-ASSOCIATE-RQ"){
  $result->{error} = "First PDU in from_trace is not A-ASSOCIATE-RQ";
  Done();
}
my $assoc_rp_pdu_desc = $pdu_analysis->{to_pdu}->[0];
unless(
  $assoc_rp_pdu_desc->{pdu_type} eq "A-ASSOCIATE-AC" ||
  $assoc_rp_pdu_desc->{pdu_type} eq "A-ASSOCIATE-RJ"
){
  $result->{error} = "First PDU in to_trace is not A-ASSOCIATE-[AC | RJ]";
  Done();
}
open FROM, "<$dir/trace_from_data" or die "Can't open $dir/trace_from_data";
open TO, "<$dir/trace_to_data" or die "Can't open $dir/trace_to_data";
seek FROM, $assoc_rq_pdu_desc->{pdu_offset}, 0;
seek TO, $assoc_rp_pdu_desc->{pdu_offset}, 0;
my $assoc_rq_pdu;
my $count = read(FROM, $assoc_rq_pdu, $assoc_rq_pdu_desc->{pdu_length});
unless($count == $assoc_rq_pdu_desc->{pdu_length}){
  $result->{error} = "read $count vs $assoc_rq_pdu_desc->{pdu_length} ".
    "reading A-ASSOCIATE_RQ";
  Done();
}
my $assoc_rp_pdu;
$count = read(TO, $assoc_rp_pdu, $assoc_rp_pdu_desc->{pdu_length});
unless($count == $assoc_rp_pdu_desc->{pdu_length}){
  $result->{error} = "read $count vs $assoc_rp_pdu_desc->{pdu_length} ".
    "reading A-ASSOCIATE_[RJ | AC]";
}
$result->{a_assoc_rq} = Dispatch::Dicom::AssocRq->new_from_pdu($assoc_rq_pdu);
if($assoc_rp_pdu_desc->{pdu_type} eq "A-ASSOCIATE-AC"){
  $result->{a_assoc_ac} = Dispatch::Dicom::AssocAc->new_from_pdu($assoc_rp_pdu);
} else {
  $result->{a_assoc_rj} = Dispatch::Dicom::AssocRj->new_from_pdu($assoc_rp_pdu);
}
Done();

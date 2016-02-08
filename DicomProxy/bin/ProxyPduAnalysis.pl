#!/usr/bin/perl -w
#
use strict;
use Storable qw( store_fd );
my $usage = <<EOF;
ProxyPduAnalysis.pl <dir>
 or
ProxyPduAnalysis.pl -h

This expects to find the following files in the <dir>:
  trace_from_data - this is a binary image of the data sent on the connection
  trace_to_data   - this is a binary image of the data receive on the connection
  trace_index     - this is a text file showing the times of transmissions of
                    blocks of data on the connection

It then analyzes the DICOM PDU and PDV content of the trace_data, producing
a data structure of the following format for each:
\$struct = {
  from_pdu => [
    {
      pdu_type => A-ASSOCIATE-RQ | A-ASSOCIATE-AC | A-ASSOCIATE-RJ |
                  A-RELEASE_RQ | A-RELEASE-RP | A-ABORT | P-DATA-TF ,
      pdu_length => <length>,
      pdu_offset => <offset of pdu data in file>,
      # for pdu_type of P-DATA-TF only:
      pdv_list => [
        {
          pdv_length => <length of pdv>,
          pc_id => <pres_context_id>,
          is_command => 0 | 1,
          is_final => 0 | 1,
          pdv_data_offset => <offset of actual data>,
          pdv_data_length => <length of actual data>, #(pdv_length - 2)
        }
      ],
    },
    ...
  ],
  to_pdu => [
    ...
  ],
  error_list [
    <error_message>,  # any errors encountered 
    ...
  ],
};
This data structures is serialized (using the Storable module) into the
following file in the <dir>:
  pdu_analysis

When analysis is complete, a single line consisting of the string "OK" will be
written to STDOUT, unless the file <to_dir>/pdu_analysis can't be written, in
which case the string "unable to open <to_dir>/pdu_analysis" will the written.
EOF
if($ARGV[0] eq "-h"){
  print $usage;
  exit;
}
my $dir = $ARGV[0];
my $result = {};
sub Done{
  my $fh;
  unless(open $fh, ">$dir/pdu_analysis"){
    print "Unable to open $dir/pdu_analysis\n";
    exit;
  }
  store_fd $result, $fh;
  close $fh;
  print "OK\n";
  exit;
}
sub AnalyzePdvInFile{
  my($fh, $offset, $length, $ft) = @_;
  my $cur_pos = $offset;
  my $remain = $length;
  my @pdv_list;
  while($remain > 6){
    unless(seek($fh, $cur_pos, 0)){
      push(@{$result->{$ft}}, "(pdv) seek failed ($!) to $cur_pos");
      return \@pdv_list;
    }
    my $buff;
    my $count = read($fh, $buff, 6);
    unless($count == 6) { die "read $count vs 6" }
    my($pdv_len, $pc_id, $flags) = unpack("NCC", $buff);
    $cur_pos += 6;
    my $is_command = ($flags & 1) ? 1 : 0;
    my $is_last = ($flags & 2) ? 1 : 0;
    my $pdv = {
      pdv_data_offset => tell($fh),
      pdv_length => $pdv_len,
      pdv_data_length => $pdv_len - 2,
      pc_id => $pc_id,
      is_command => ($flags & 1) ? 1 : 0,
      is_final => ($flags & 2) ? 1 : 0,
    };
    push(@pdv_list, $pdv);
    if($pdv_len <= 2){
      push(@{$result->{$ft}}, "bad pdv length ($pdv_len) at $cur_pos");
      return \@pdv_list;
    }
    $cur_pos += $pdv_len - 2;
    $remain -= $cur_pos;
  }
  return \@pdv_list;
}
sub AnalyzePduInFile{
  my($fh, $ft) = @_;
  my @pdu_list;
  my $pdu_types = {
    1 => "A-ASSOCIATE-RQ",
    2 => "A-ASSOCIATE-AC",
    3 => "A-ASSOCIATE-RJ",
    4 => "P-DATA-TF",
    5 => "A-RELEASE-RQ",
    6 => "A-RELEASE-RP",
    7 => "A-ABORT",
  };
  seek($fh, 0, 2);
  my $length = tell($fh);
  my $cur_pos = 0;
  my $remain = $length - $cur_pos;
  pdu:
  while($remain >= 6){
    unless(seek($fh, $cur_pos, 0)){
      push(@{$result->{$ft}}, "(pdu) seek failed ($!) to $cur_pos");
      return \@pdu_list;
    }
    my $buff;
    my $count = read($fh, $buff, 6);
    unless($count == 6) { die "read $count vs 6" }
    my($pdu_type, $foo, $pdu_len) = unpack("CCN", $buff);
    unless(exists $pdu_types->{$pdu_type}){
      push(@{$result->{$ft}}, "unknown pdu_type $pdu_type at $cur_pos");
    }
    $cur_pos += 6;
    my $pdu = {
      pdu_type => $pdu_types->{$pdu_type},
      pdu_length => $pdu_len,
      pdu_offset => tell($fh),
    };
    if($pdu_type == 4){
      $pdu->{pdv_list} = AnalyzePdvInFile($fh, $cur_pos, $pdu_len, $ft);
    }
    push(@pdu_list, $pdu);
    $cur_pos += $pdu_len;
    $remain -= 6 + $pdu_len;
    }
  if($remain > 0){
    push(@{$result->{$ft}}, "$remain bytes left at end");
  }
  return \@pdu_list;
}
unless(-d $dir) {
  push(@{$result->{error_list}}, "from_dir ($dir) doesn't exist");
  Done();
}
if(-f "$dir/trace_from_data"){
  my $fh;
  unless(open $fh, "<$dir/trace_from_data") {
    push(@{$result->{error_list}}, 
      "can't open ($!) $dir/trace_from_data");
    Done();
  }
  $result->{from_pdu} = AnalyzePduInFile($fh, "from_errors");
} else {
  push(@{$result->{error_list}}, "$dir/trace_from_data doesn't exist");
}
if(-f "$dir/trace_to_data"){
  my $fh;
  unless(open $fh, "<$dir/trace_to_data") {
    push(@{$result->{error_list}}, 
      "can't open ($!) $dir/trace_to_data");
    Done();
  }
  $result->{to_pdu} = AnalyzePduInFile($fh, "to_errors");
} else {
  push(@{$result->{error_list}}, "$dir/trace_to_data doesn't exist");
}
Done();

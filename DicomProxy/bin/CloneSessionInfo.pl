#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/DicomProxy/bin/CloneSessionInfo.pl,v $
#$Date: 2014/01/22 20:16:56 $
#$Revision: 1.2 $
#
use strict;
my $usage = <<EOF;
CloneSessionInfo.pl <from_dir> <to_dir>
 or
CloneSessionInfo.pl -h

This program creates hard links in the <to_dir> to the files in the
<from_dir> for the following files:
  trace_index
  trace_from_data
  trace_to_data
  ProxySession.info
EOF
if($ARGV[0] eq "-h"){
  print $usage;
  exit;
}
my $from_dir = $ARGV[0];
my $to_dir = $ARGV[1];
unless(-d $from_dir) {
  print "Error: from_dir ($from_dir) doesn't exist\n";
}
unless(-d $to_dir){
  print "Error: to_dir ($to_dir) doesn't exist\n";
}
if(-f "$from_dir/trace_index"){
  unless(link "$from_dir/trace_index", "$to_dir/trace_index"){
    print "unable to link trace_index\n" ;
  }
} else {
  print "Error: $from_dir/trace_index doesn't exist\n";
}
if(-f "$from_dir/trace_from_data"){
  unless(link "$from_dir/trace_from_data", "$to_dir/trace_from_data"){
    print "Error: unable to link trace_from_data\n";
  }
} else {
  print "Error: $from_dir/trace_from_data doesn't exist\n";
}
if(-f "$from_dir/trace_to_data"){
  unless(link "$from_dir/trace_to_data", "$to_dir/trace_to_data"){
    print "Error: unable to link trace_to_data\n";
  }
} else {
  print "Error: $from_dir/trace_from_data doesn't exist\n";
}
if(-f "$from_dir/ProxySession.info"){
  unless(link "$from_dir/ProxySession.info", "$to_dir/ProxySession.info"){
    print "Error: unable to link ProxySession.info\n";
  }
} else {
  print "Error: $from_dir/ProxySession.info doesn't exist\n";
}
print "OK\n";

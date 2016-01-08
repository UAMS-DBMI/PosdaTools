#!/usr/bin/perl -w
#$Date: 2013/07/22 20:00:15 $
#$Revision: 1.2 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Cwd;
use strict;
use Posda::Receiver;
use Dispatch::Dicom;
use IO::Socket::INET;
use FileHandle;
use Dispatch::Select;

use vars qw( %Objects );

unless($#ARGV == 2){ 
  die "usage: " .
    "$0 <dcm_port> <config_file> <rcv_dir>"
}

my $dcm_port = $ARGV[0];
my $config_file = $ARGV[1]; unless($config_file=~/^\//){$config_file=getcwd."/$config_file"}
my $rcv_dir = $ARGV[2]; unless($rcv_dir=~/^\//){$rcv_dir=getcwd."/$rcv_dir"}
unless(-r $config_file) { die "<config_file> is not a file" }
unless(-d $rcv_dir) { die "<rcv_dir> is not a directory" }

unless($config_file =~ /(.*)\/([^\/]+)$/){
  die "funny config file path: $config_file";
}
my $config_dir = $1;
my $config_file_name = $2;
my $ae = Dispatch::Dicom::Acceptor->parse_descrip($config_file);
my $aes = {
  UNKNOWN => $ae,
};
my $receiver = Posda::Receiver->new($dcm_port, $aes, $rcv_dir);
Dispatch::Select::Dispatch();
if($ENV{POSDA_DEBUG}){
  print "Returned from Dispatch\n";
}

#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/DB/ChildIf.pl,v $
#$Date: 2012/03/05 15:36:01 $
#$Revision: 1.3 $
#
#Copyright 2012, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use DBI;
use FileHandle;
use Socket;
use Fcntl;
use Term::ReadKey;
use Dispatch::DB::ChildIf;

unless($#ARGV == 2){
  die "usage: $0 <db> <host> <user>"
}
print STDERR "In ChildIf.pl $ARGV[0] $ARGV[1] $ARGV[2]\n";
$Dispatch::DB::ChildIf::db = $ARGV[0];
$Dispatch::DB::ChildIf::host = $ARGV[1];
$Dispatch::DB::ChildIf::user = $ARGV[2];

$| = 1;
select STDERR;
$| = 1;
select STDOUT;
Dispatch::DB::ChildIf::Loop();
print STDERR "Dispatch::Db::ChildIf::Loop returned\n";

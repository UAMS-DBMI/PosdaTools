#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/ProcessPosdaFiles.pl,v $
#$Date: 2015/07/16 17:03:57 $
#$Revision: 1.6 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Posda::DB::File;
use DBI;
#use Term::ReadKey;
#print "User: ";
#my $user = ReadLine 0;
#chomp $user;
#print "Password: ";
#ReadMode 'noecho';
#my $password = ReadLine 0;
#chomp $password;
#ReadMode 'normal';
unless($#ARGV == 0 || $#ARGV == 1){
  die "usage: ProcessPosdaFiles.pl <db_name> [<limit>]";
}

#my $db = DBI->connect("dbi:Pg:dbname=$ARGV[0]", $user, $password);
my $db = DBI->connect("dbi:Pg:dbname=$ARGV[0]");
unless($db) { die "couldn't connect to DB: $ARGV[0]" }
if(exists $ARGV[1] && $ARGV[1] > 0){
  Posda::DB::File::ProcessFilesWithLimit($db,$ARGV[1]);
} else {
  Posda::DB::File::ProcessFiles($db);
}

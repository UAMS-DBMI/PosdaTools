#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/ImportPosdaFile.pl,v $
#$Date: 2015/07/16 17:03:57 $
#$Revision: 1.6 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

use Cwd;
use Posda::DB::File;
use DBI;
#use Term::ReadKey;
my $usage = "usage: $0 <path> <database name> <comment>";
unless($#ARGV == 2) {die $usage}
my $path = $ARGV[0];
unless($path =~ /^\//) {$path = getcwd."/$path"}
#print "User: ";
#my $user = ReadLine 0;
#chomp $user;
#print "Password: ";
#ReadMode 'noecho';
#my $password = ReadLine 0;
#chomp $password;
#ReadMode 'normal';

#my $db = DBI->connect("dbi:Pg:dbname=$ARGV[1]", $user, $password);
my $db = DBI->connect("dbi:Pg:dbname=$ARGV[1]");
my $comment = $ARGV[2];
unless($db) { die "couldn't connect to DB: $ARGV[1]" }
unless(-d $path) { die "$path is not a directory" }
Posda::DB::File::ScanDirectory($path, $db, $comment);

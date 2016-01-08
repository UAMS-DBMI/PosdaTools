#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/CreatePseudoPhantom.pl,v $
#$Date: 2008/06/23 18:59:33 $
#$Revision: 1.5 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

use strict;
use Posda::PseudoPhantom;
use Posda::Dataset;
use Posda::CCgen;
#use Posda::UID;

Posda::Dataset::InitDD();

unless($#ARGV == 1){ die "usage: $0 <config> <dest_dir>" }
my $user = `whoami`;
my $host = `hostname`;
chomp $host;
chomp $user;
#my $uid_root = Posda::UID::GetPosdaRoot({
#  app => $0,
#  user => $user,
#  host => $host,
#  purpose => "Initialize Generator",
#});
#unless(defined $uid_root) { die "unable to get uid_root" }

my $config = $ARGV[0];
my $dest_dir = $ARGV[1];
opendir DIR, $dest_dir;
dir:
while(my $file = readdir(DIR)){
  if($file eq ".") { next dir }
  if($file eq "..") { next dir }
  die "$dest_dir is not empty (and I'm afraid to 'rm -rf $dest_dir/*'";
}
closedir DIR;
my $PPC = Posda::PseudoPhantom->new($config, $dest_dir);
#$PPC->DumpGuts();
$PPC->GenerateStudies();

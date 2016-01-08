#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/CreatePassWordFile.pl,v $
#$Date: 2014/03/19 20:52:11 $
#$Revision: 1.1 $
#
#Copyright 2014, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

use Cwd;
use Term::ReadKey;
my $usage = "usage: $0 <File Name>";
unless($#ARGV == 0) {die $usage}
my $path = $ARGV[0];
unless($path =~ /^\//) {$path = getcwd."/$path"}
open FILE, ">>$path" or die "can't open $path for append";
my $password1;
my $user;
my $user_name;
user:
while(1) {
  print "           User: ";
  $user = ReadLine 0;
  chomp $user;
  unless($user) { last user }
  print "      User Name: ";
  $user_name = ReadLine 0;
  chomp $user_name;
  my $no_password = 1;
  while ($no_password) {
    print "       Password: ";
    ReadMode 'noecho';
    $password1 = ReadLine 0;
    chomp $password1;
    print "\nRepeat Password: ";
    ReadMode 'noecho';
    my $password2 = ReadLine 0;
    chomp $password2;
    ReadMode 'normal';
    print "\n";
    if($password1 eq $password2) { $no_password = 0 }
  }
  my $crypted = crypt($password1,
    join '', ('.', '/', 0..9, 'A'..'Z', 'a'..'z')[rand 64, rand 64] );
  print FILE "$user|$crypted|1|$user_name\n";
}
close FILE;

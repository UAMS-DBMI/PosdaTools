#!/usr/bin/perl -w 
#$Source: /home/bbennett/pass/archive/Posda/bin/contrib/GetUid.pl,v $
#$Date: 2010/01/18 21:00:15 $
#$Revision: 1.1 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Posda::UID;
my $comment = join(" ", @ARGV);
my $user = `whoami`;
chomp $user;
my $host = `hostname`;
chomp $host;
my $uid = Posda::UID::GetPosdaRoot({
  program => "Posda/bin/GetUid.pl",
  reason => $comment,
  user => $user,
  host => $host,
});
print "$uid\n";

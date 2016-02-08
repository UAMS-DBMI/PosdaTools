#!/usr/bin/perl -w
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use DBI;
use Socket;
use Debug;
my $dbg = sub { print @_ };
use Storable qw( store_fd fd_retrieve );
my($child, $parent, $oldfh);
socketpair($parent, $child, AF_UNIX, SOCK_STREAM, PF_UNSPEC) or
  die "socketpair $!";
$oldfh = select($parent); $| = 1; select($oldfh);
$oldfh = select($child); $| = 1; select($oldfh);
my $child_pid = fork;
unless(defined $child_pid) { die "Couldn't fork: $!" }
if($child_pid == 0){
  close $child;
  unless(open STDIN, "<&", $parent) {
    die "Redirect of STDIN in child failed $!"
  }
  unless(open STDOUT, "<&", $parent) {
    die "Redirect of STDOUT in child failed $!"
  }
  exec "GetBookList.pl";
} else {
  close $parent;
}

my $args = {
  database_name => "dicomxml",
  book_only => $ARGV[0],
};

store_fd($args, $child);
my $results;
eval { $results = fd_retrieve($child) };
if($@){
  die $@;
}
print "Results: ";
Debug::GenPrint($dbg, $results, 1);
print "\n";

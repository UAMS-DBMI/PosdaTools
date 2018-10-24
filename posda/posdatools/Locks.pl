################################################################################
# A new script to quickly remove locks!
################################################################################

use lib 'Posda/include/';

use Modern::Perl '2010';
use Method::Signatures::Simple;

use Data::Dumper;
use Posda::DebugLog 'on';
use IO::Socket::INET;

my $root = '/cache/posda/Data/HierarchicalExtractions/data';
my $results;

sub get_locks {
  # get the list of locks
  my $sock = IO::Socket::INET->new(
    PeerAddr => "localhost",
    PeerPort => 64612,
    Proto => 'tcp',
    Timeout => 1,
    Blocking => 1,
  );
  unless($sock){ die "Couldn't connect " }

  print $sock "ListLocks\n\n";

  while(my $line = <$sock>){
    chomp $line;
    push @$results, $line;
  }

  close($sock);
}

get_locks;

# Use some map magic to turn the single lines ListLocks
# returns into something more usable
my @locks = map {
  my @main = split(/: /);
  my @parts = split(/\|/, $main[1]);

  my %single_lock = map {
    split(/=/);
  } @parts;

  \%single_lock;

} @$results;

# Figure out where their lock.txt is, and get the PID from it
for my $lock (@locks) {
  my $lockfile = "$root/$lock->{Collection}/$lock->{Site}/$lock->{Subj}/lock.txt";
  my $pidline = `tail -n 1 $lockfile`;

  $pidline =~ /running under pid: (\d+)/;
  $lock->{Pid} = $1;

  $lock->{Lockfile} = $lockfile;

}

print Dumper(\@locks);

die;
# Now attempt to kill them

for my $lock (@locks) {
  my $sock = IO::Socket::INET->new(
    PeerAddr => "localhost",
    PeerPort => 64612,
    Proto => 'tcp',
    Timeout => 1,
    Blocking => 1,
  );
  unless($sock){ die "Couldn't connect " }

  say "Unlocking ID: $lock->{Id}";
  print $sock "ReleaseLockWithNoEdit\n";
  print $sock "Id: $lock->{Id}\n";
  print $sock "Session: $lock->{Session}\n";
  print $sock "User: $lock->{User}\n";
  print $sock "Pid: $lock->{Pid}\n\n";
  print "Response: ";
  
  while(my $line = <$sock>){
    print $line;
  }

  close($sock);
}

for my $lock (@locks) {
  say "Deleting lock file: $lock->{Lockfile}";
  unlink($lock->{Lockfile});
}

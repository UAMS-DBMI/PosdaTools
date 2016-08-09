#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use DBI;
use IO::Socket;
unless($#ARGV == 2){
  die "usage: $0 <db> <port> <source_root>"
}
my $dbh = DBI->connect("dbi:Pg:dbname=$ARGV[0]", "", "");
my $sub_q = $dbh->prepare(
  "select submitter_id from submitter where collection = ? and " .
  "site = ? and subj = ?"
);
my $ins_sub = $dbh->prepare(
  "insert into submitter(collection, site, subj) values (?, ?, ?)"
);
my $get_id = $dbh->prepare(
  "select currval('submitter_submitter_id_seq')"
);
my $ins_req = $dbh->prepare(
  "insert into request(\n" .
  "  submitter_id, received_file_path, copied_file_path,\n" .
  "  file_copied, copy_error, copy_path, file_digest,\n" .
  "  file_in_posda, import_error, time_received,\n" .
  "  time_copied, time_entered\n" .
  ") values (\n" .
  "  ?, ?, null,\n" .
  "  false, false, null, ?,\n" .
  "  false, false, ?,\n" .
  "  null, null\n" .
  ")"
);

my $port = $ARGV[1];

my $root = $ARGV[2];

#fork and exit;
my $server = IO::Socket::INET->new(
  Listen => 1024,
  LocalPort => $port,
  Proto => 'tcp',
  Blocking => 1,
  ReuseAddr => 1,
);
unless ($server){
  print STDERR "Unable to Bind Socket $!\n";
  exit;
}
while(1){
  my $client = $server->accept;
  if(!$client){
    print STDERR "$$" . "Error $! to accept\n";
    next;
  }
  my $now = time;
  my @lines;
  line:
  while(my $l = <$client>){
    chomp $l;
    $l =~ s/\r//g;
    if($l eq ""){ last line }
    push @lines, $l;
  }
  my $num_lines = @lines;
  my %hash;
  for my $line (@lines){
    if($line =~ /^([^:]+):\s*(\S.*\S)\s*$/){
      my $k = $1; my $v = $2;
      $hash{$k} = $v;
    } else {
      print STDERR "bad format line: $line\n";
    }
  }
  my $err_message = "";
  for my $i (
    "command", "relativepath", "digest",
    "collection", "site", "subject", "receive_date"
  ){
    unless(exists $hash{$i}){
      $err_message .= "no key ($i) found in request; "
    }
  }
#print STDERR "command: $hash{command}\n" .
#  "relativepath: $hash{relativepath}\n" .
#  "digest: $hash{digest}\n" .
#  "collection: $hash{collection}\n" .
#  "site: $hash{site}\n" .
#  "subject: $hash{subject}\n" .
#  "receive_time: $hash{receive_date}\n";
  if($err_message ne ""){
    print $client "status: Error\nmessage: $err_message\n\n";
    close $client;
    next;
  }
  my($submitter_id, $mess) = GetSubmitterId($hash{collection},
    $hash{site}, $hash{subject});
  unless(defined $submitter_id){
    print $client "status: Error\nmessage: $err_message\n\n";
    close $client;
    next;
  }
  my $queued_file = "$root/$hash{relativepath}";
  unless(-f $queued_file){
    my $err_message = "Queued file not found $queued_file";
    print $client "status: Error\nmessage: $err_message\n\n";
    close $client;
    next;
  }
  if(
    InsertRequest($submitter_id, $queued_file, $hash{digest},
      $hash{receive_date})
  ){
    print $client ("status: OK\n\n");
    close $client;
  } else {
    $err_message = "Insert into request table failed";
    print $client "status: Error\nmessage: $err_message\n\n";
    close $client;
    next;
  }
}
sub GetSubmitterId{
  my($collection, $site, $subj) = @_;
  $sub_q->execute($collection, $site, $subj);
  my $h = $sub_q->fetchrow_hashref;
  $sub_q->finish;
  if(defined($h) && exists($h->{submitter_id})){
    return $h->{submitter_id};
  }
  $ins_sub->execute($collection, $site, $subj);
  $get_id->execute;
  my $hid = $get_id->fetchrow_hashref;
  $get_id->finish;
  unless(defined($hid) && exists($hid->{currval})){
    return undef, "Unable to create a new submitter row for ($collection, " .
       "$site, $subj)";
  }
  return $hid->{currval}, undef;
}
sub InsertRequest{
  my($submitter, $file, $digest, $data) = @_;
  return $ins_req->execute($submitter, $file, $digest, $data);
};

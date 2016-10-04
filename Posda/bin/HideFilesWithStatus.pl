#!/usr/bin/perl -w
use strict;
use DBI;
use Posda::Config 'Config';
my $usage = "usage: HideFilesWithStatus.pl <user> <reason>\n" .
  "   receives list of file_ids on STDIN\n";
unless($#ARGV == 1) { die $usage }
my @FileList;
while(my $line = <STDIN>){
  chomp $line;
  push @FileList, $line;
}
my $dbh = DBI->connect("DBI:Pg:database=${\Config('files_db_name')}");
my $get_file = <<EOF;
select
  file_id, visibility
from
   ctp_file natural join file_series
where
   file_id = ?
EOF
my $gf = $dbh->prepare($get_file);
my $hide_Q = <<EOF;
update
  ctp_file
set
  visibility = 'hidden'
where 
  file_id = ?
EOF
my $hide = $dbh->prepare($hide_Q);
my $insert_q = <<EOF;
insert into file_visibility_change(
  file_id, user_name, time_of_change,
  prior_visibility, new_visibility, reason_for
)values(
  ?, ?, now(),
  ?, ?, ?
)
EOF
my $insert = $dbh->prepare($insert_q);
for my $file_id (@FileList){
  $gf->execute($file_id);
  my $h = $gf->fetchrow_hashref;
  $gf->finish;
  unless(defined($h) && ref($h) eq "HASH" && exists $h->{visibility}){
    print STDERR "file $file_id not found\n";
    next;
  }
  my $old_visibility = $h->{visibility};
  unless(defined $old_visibility){ $old_visibility = "<undef>" }
  print "$h->{file_id} $old_visibility => 'hidden' for $ARGV[1]\n";
  $insert->execute($h->{file_id}, 
    $ARGV[0], $h->{visibility}, 'hidden', $ARGV[1]);
  $hide->execute($h->{file_id});
}

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
use Posda::DB::PosdaFilesQueries;
use Socket;
use Storable qw( store retrieve retrieve fd_retrieve store_fd );
use Debug;
my $dbg = sub { print STDERR @_ };
my $help = <<EOF;
Usage: 
  SendSeriesFromDbAndRecord.pl <host> <port> <called> <calling> <series> <who> <why>
or
  SendSeriesFromDbAndRecord.pl -h
EOF

if($#ARGV < 6 || ($ARGV[0] eq "-h")){
  print $help;
  exit;
}
my $q_inst = PosdaDB::Queries->GetQueryInstance("FilesInSeriesForSend");
my $db_name = $q_inst->GetSchema;
my $dbh = DBI->connect("dbi:Pg:dbname=$db_name");
unless($dbh) { die "Can't connect to $db_name" }
my $ins_send_event = $dbh->prepare(
  "insert into dicom_send_event(\n" .
  "  destination_host, destination_port,\n" .
  "  called_ae, calling_ae,\n" .
  "  send_started, invoking_user,\n" .
  "  reason_for_send, number_of_files\n" .
  ")values(\n" .
  "  ?, ?,\n" .
  "  ?, ?,\n" .
  "  now(), ?,\n" .
  "  ?, ?\n" .
  ")"
);
my $gseid = $dbh->prepare(
  "select currval('dicom_send_event_dicom_send_event_id_seq') as id"
);
my $upd_seid = $dbh->prepare("update dicom_send_event\n" .
  "set send_ended = now()\n" .
  "where dicom_send_event_id = ?"
);
my $cr_dicom_file_send = $dbh->prepare(
  "insert into dicom_file_send(\n" .
  "  dicom_send_event_id, file_path, status\n" .
  ") values (\n" .
  "  ?, ?, ?\n" .
  ")"
);
my %Hash;
$Hash{host} = shift @ARGV;
$Hash{port} = shift @ARGV;
$Hash{called} = shift @ARGV;
$Hash{calling} = shift @ARGV;
my $series_instance_uid = shift @ARGV;
$Hash{who} = shift @ARGV;
$Hash{why} = shift @ARGV;
$Hash{FilesToSend} = [];
$Hash{FilesFromDigest} = {};
$Hash{FilesToDigest} = {};
my $add_file = sub {
  my($row) = @_;
  $Hash{FilesToDigest}->{$row->{path}} = $row->{digest};
  push @{$Hash{FilesToSend}}, $row->{path};
  my $file_desc = {
    dataset_start_offset => $row->{data_set_start},
    dataset_size => $row->{data_set_size},
    xfr_stx => $row->{xfer_syntax},
    file => $row->{path},
    sop_class_uid => $row->{sop_class_uid},
    sop_inst_uid => $row->{sop_instance_uid},
    digest => $row->{digest}
  };
  $Hash{FilesFromDigest}->{$row->{digest}} = $file_desc;
};
$q_inst->Prepare($dbh);
$q_inst->Execute($series_instance_uid);
$q_inst->Rows($add_file);
#print STDERR "Specification: ";
#Debug::GenPrint($dbg, \%Hash, 1);
#print STDERR "\n";
#exit;
my $number_of_files = @{$Hash{FilesToSend}};
print STDERR "insert($Hash{host}, $Hash{port}, $Hash{called}, $Hash{calling}, $Hash{who}, $Hash{why}, $number_of_files)\n";
$ins_send_event->execute(
  $Hash{host}, $Hash{port},
  $Hash{called}, $Hash{calling},
  $Hash{who},
  $Hash{why}, $number_of_files
);
my $send_event_id;
$gseid->execute;
while(my $h = $gseid->fetchrow_hashref){
  $send_event_id = $h->{id}
}
unless(defined $send_event_id){
  die "Couldn't get dicom_send_event_id";
}
for my $file (@{$Hash{FilesToSend}}){
  my $dig = $Hash{FilesToDigest}->{$file};
  my $f_desc = $Hash{FilesFromDigest}->{$dig};
  my $cmd = "SendOneFile.pl \"$Hash{host}\" " .
    "$Hash{port} $Hash{called} $Hash{calling} " .
    "\"$file\"";
print STDERR "Command: $cmd\n";
  open FILE, "$cmd|" or die "Can't open pipe to $cmd";
  my $results = "";
  while(my $line = <FILE>){
    chomp $line;
    $results .= "$line;";
  }
  $cr_dicom_file_send->execute($send_event_id, $file, $results);
}
$upd_seid->execute($send_event_id);

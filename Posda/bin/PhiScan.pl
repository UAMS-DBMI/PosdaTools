#!/usr/bin/perl -w
use strict;
use DBI;
my $DbSpec =  {
  "posda_files" => {
    "db_name" => "posda_files",
    "db_type" => "postgres"
  },
  "posda_nicknames" => {
    "db_name" => "posda_nicknames",
    "db_type" => "postgres"
  },
  "posda_counts" => {
    "db_name" => "posda_counts",
    "db_type" => "postgres"
  },
  "posda_phi" => {
    "db_name" => "posda_phi",
    "db_type" => "postgres"
  },
  "public" => {
    "db_name" => "ncia",
    "db_type" => "mysql",
    "db_host" => "144.30.1.74",
    "db_user" => "nciauser",
    "db_pass" => "nciA#112"
  },
  "intake" => {
    "db_name" => "ncia",
    "db_type" => "mysql",
    "db_host" => "144.30.1.71",
    "db_user" => "nciauser",
    "db_pass" => "nciA#112"
  },
};
my $usage = <<EOF;
PhiScan.pl <f_db> <phi_db> <description>
  f_db        - file database
  phi_db      - phi database
  description - description of scan
Expects a list of <series>, <signature> on STDIN
EOF
unless($#ARGV == 2){
  die "$usage\n";
}
my($fdb, $pdb, $desc) = @ARGV;
my $fdbh;
if($DbSpec->{$fdb}->{db_type} eq "postgres"){
  $fdbh = DBI->connect("dbi:Pg:dbname=$DbSpec->{$fdb}->{db_name}");
} elsif($DbSpec->{$fdb}->{db_type} eq "mysql") {
  my $query_spec = $DbSpec->{$fdb};
  my $db_spec = "dbi:mysql:dbname=$query_spec->{db_name};" .
    "host=$query_spec->{db_host}";
  print STDERR "DBI->connect($db_spec,\n" .
    "    $query_spec->{db_user}, $query_spec->{db_pass});\n";
  $fdbh = DBI->connect($db_spec,
    $query_spec->{db_user}, $query_spec->{db_pass});
  unless(defined $fdbh){
    die("Connect error ($!): $query_spec->{db_name}::$query_spec->{db_host}" .
      "::$query_spec->{db_user}");
  }
} else {
  die "Bad fdb: $fdb";
}
my $pdbh = DBI->connect("dbi:Pg:dbname=$pdb");
my %Series;
while(my $line = <STDIN>){
  chomp $line;
  if($line =~ /^([\d\.]+)\s*,\s*(.*)\s*$/){
    my $s = $1; my $sig = $2;
    $Series{$s} = $sig;
  } else {
    print STDERR "Can't process line: $line\n";
  }
}
my $num_series = keys %Series;
my $create_scan = $pdbh->prepare(
  "insert into scan_event(\n" .
  "  scan_started, scan_status, scan_description,\n" .
  "  num_series_to_scan, num_series_scanned\n" .
  ") values (\n" . 
  "  now(), 'In Process', ?,\n" .
  "  ?, 0)"
);
my $get_scan_id = $pdbh->prepare(
  "select currval('scan_event_scan_event_id_seq') as id");
my $update_series_scanned = $pdbh->prepare(
  "update scan_event set num_series_scanned = ? where scan_event_id = ?"
);
my $gfile;
if($DbSpec->{$fdb}->{db_type} eq "postgres"){
  $gfile = $fdbh->prepare(
    "select\n" .
    "  root_path || '/' || rel_path as path\n" .
    "from\n" .
    "  file_series natural join file_location natural join\n" .
    "  file_storage_root\n" .
    "where\n" .
    "  series_instance_uid = ?\n" .
    "limit 1"
  );
} elsif($DbSpec->{$fdb}->{db_type} eq "mysql") {
  $gfile = $fdbh->prepare(
    "select\n" .
    "  dicom_file_uri as path\n" .
    "from\n" .
    "  general_image\n" .
    "where\n" .
    "  series_instance_uid = ?\n" .
    "limit 1"
  );
} else {
  die "DbSpec->{$fdb}->{db_type} = $DbSpec->{$fdb}->{db_type}"
}
my $finish_scan = $pdbh->prepare(
  "update scan_event set scan_status = 'finished',\n" .
  "  scan_ended = now() where scan_event_id = ?"
);
$create_scan->execute($desc, $num_series);
my $scan_id;
$get_scan_id->execute;
while(my $h = $get_scan_id->fetchrow_hashref){
  $scan_id = $h->{id};
}
unless(defined $scan_id) { die "Can't get scan_id" }
my $num_scanned = 0;
series:
for my $series (keys %Series){
  my $sig = $Series{$series};
  my $file;
  $gfile->execute($series);
  while(my $h = $gfile->fetchrow_hashref){
    $file = $h->{path};
  }
  unless(defined $file) {
    print STDERR "can't find file for series $series\n";
    next series;
  }
  if($DbSpec->{$fdb}->{db_type} eq "mysql") {
    $file =~ s/sdd1/intake1-data/;
  }
  my $command = "PhiSeriesScan.pl $pdb $series '$sig' $scan_id " .
    "'$file'";
  open COMMAND, "$command|" or die "can't open command";
  my $resp;
  while (my $line = <COMMAND>){
    $resp .= $line;
  }
  $num_scanned += 1;
  $update_series_scanned->execute($num_scanned, $scan_id);
}
$finish_scan->execute($scan_id);
$fdbh->disconnect;
$pdbh->disconnect;

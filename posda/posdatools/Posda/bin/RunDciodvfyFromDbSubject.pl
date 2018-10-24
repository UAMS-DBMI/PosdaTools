#!/usr/bin/perl -w
use strict;
use DBI;
use Posda::DB::PosdaFilesQueries;
use Debug;
my $dbg = sub {print @_ };
my $usage = <<EOF;
RunDciodvfyFromDbSubject.pl <intake>|<public>|<posda_files> <subj> <collection> <site>
EOF
my $dciodvfy = "/opt/dicom3tools/bin/dciodvfy";
unless($#ARGV == 3) { die $usage }
my $db_type = $ARGV[0];
my $collection = $ARGV[2];
my $site = $ARGV[3];
my $subj =$ARGV[1];
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

unless($db_type eq "posda_files" || $db_type eq "intake"){
  die "unsupported db_type: $db_type";
}
my $fdb;
if($DbSpec->{$db_type}->{db_type} eq "postgres"){
  my $connect_string = "dbi:Pg:dbname=$DbSpec->{$db_type}->{db_name}";
  $fdb = DBI->connect($connect_string);
} elsif($DbSpec->{$db_type}->{db_type} eq "mysql"){
  my $query_spec = $DbSpec->{$fdb};
  my $db_spec = "dbi:mysql:dbname=$query_spec->{db_name};" .
    "host=$query_spec->{db_host}";
  $fdb = DBI->connect($db_spec,
    $query_spec->{db_user}, $query_spec->{db_pass});
  unless(defined $fdb){
    die("Connect error ($!): $query_spec->{db_name}::$query_spec->{db_host}" .
      "::$query_spec->{db_user}");
  }
}
my $get_s;
my $get_ff;
if($db_type eq "intake"){
  $get_s = PosdaDB::Queries->GetQueryInstance("DistinctSeriesBySubjectIntake");
  $get_ff = PosdaDB::Queries->GetQueryInstance("FirstFileInSeriesIntake");
} elsif($db_type eq "posda_files"){
  $get_s = PosdaDB::Queries->GetQueryInstance("DistinctSeriesBySubject");
  $get_ff = PosdaDB::Queries->GetQueryInstance("FirstFileInSeriesPosda");
}
$get_s->Prepare($fdb);
$get_ff->Prepare($fdb);
$get_s->Execute($subj, $collection, $site);
sub MakeFileRow{
  my($FileList, $series_instance_uid) = @_;
  my $sub = sub {
    my($row) = @_;
    push @$FileList, [$series_instance_uid, $row->{path}];
  };
  return $sub;
}
sub MakeSeriesRow{
  my($FileList) = @_;
  my $sub = sub {
    my($row) = @_;
    $get_ff->Execute($row->{series_instance_uid});
    $get_ff->Rows(MakeFileRow($FileList, $row->{series_instance_uid}));
  };
  return $sub;
}
my @FileList;
$get_s->Rows(MakeSeriesRow(\@FileList));

my %ErrorsToSeries;
for my $i (@FileList){
  my $series_uid = $i->[0];
  my $first_file = $i->[1];
  my $cmd = "$dciodvfy \"$first_file\"";
  open FILE, "$cmd 2>&1|grep Error|grep -v \"(0x0018,0x9445)\"|sort -u |";
  my @lines;
  while (my $line = <FILE>){
    chomp $line;
    push @lines, $line;
  }
  close FILE;
  if($#lines >= 0){
    my $ErrorMsg = join "\n", @lines;
    $ErrorsToSeries{$ErrorMsg}->{$series_uid} = 1;
  }
}
print "\"Errors\",\"SeriesInstanceUids\"\r\n";
for my $e (keys %ErrorsToSeries){
  my $en = $e;
  $en =~ s/\n/\r\n/g;
  $en =~ s/"/""/g;
  print "\"$en\",\"";
  for my $s (keys %{$ErrorsToSeries{$e}}){
     print "$s\r\n";
  }
  print "\"\r\n";
}

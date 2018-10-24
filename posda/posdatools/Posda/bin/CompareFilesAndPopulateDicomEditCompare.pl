#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Posda::Try;
use Posda::DiffDicom;
use Posda::Dataset;
use File::Temp qw/ tempfile /;
my $usage = <<EOF;
CompareFilesAndPopulateDicomEditCompare.pl <edit_id> <from_file> <to_file>

  Uses Posda::DiffDicom to generate a "long" and "short" difference report
  for the two files, imports the files into Posda, and creates a row in
  the "dicom_edit_compare" table for the two files.
EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}
unless($#ARGV == 2){
  print "Error: Wrong number of params\n";
  die $usage;
}
my($edit_id, $from_file, $to_file) = @ARGV;
my $f_try = Posda::Try->new($from_file);
unless(exists $f_try->{dataset}){
  print "Error: $from_file is not a dicom file\n";
  die "$from_file is not a dicom file";
}
my $t_try = Posda::Try->new($to_file);
unless(exists $t_try->{dataset}){
  print "Error: $to_file is not a dicom file\n";
  die "$to_file is not a dicom file";
}
my $fds = $f_try->{dataset};
my $tds = $t_try->{dataset};
my $f_dig = $f_try->{digest};
my $t_dig = $t_try->{digest};
my $diff = Posda::DiffDicom->new($fds, $tds);
my($s_rept, $l_rept) = $diff->DiffReport;
my($fhs, $short_rept) = tempfile();
my($fhl, $long_rept) = tempfile();
$fhs->print($s_rept);
$fhl->print($l_rept);
$fhs->close;
$fhl->close;
my $short_id;
my $long_id;
my $result_s = `ImportSingleFileIntoPosdaAndReturnId.pl "$short_rept" "Difference report"`;
unlink $short_rept;
if($result_s =~ /File id: (.*)/){
  $short_id = $1;
}
my $result_l = `ImportSingleFileIntoPosdaAndReturnId.pl "$long_rept" "Difference report"`;
unlink $long_rept;
if($result_l =~ /File id: (.*)/){
  $long_id = $1;
}
print "edit_id: $edit_id\n" .
  "from_digest: $f_dig\n" .
  "to_digest:   $t_dig\n" .
  "short_id:    $short_id\n" .
  "long_id:     $long_id\n" .
  "###################\n$s_rept" .
  "###################\n$l_rept" .
  "###################\n";
my $ins = PosdaDB::Queries->GetQueryInstance(
  "InsertIntoDicomEditCompare");
$ins->RunQuery(sub{}, sub{},
  $edit_id, $f_dig, $t_dig, $short_id, $long_id);
print "Ok: inserted row into dicom_edit_compare\n";

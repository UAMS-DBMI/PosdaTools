#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Posda::Try;
use Posda::DiffDicom;
use Posda::Dataset;
use File::Temp qw/ tempfile /;
use Storable qw( store_fd fd_retrieve);
my $usage = <<EOF;
SerializedSubprocessCompareEdits.pl
or
SerializedSubprocessCompareEdits.pl -h

  Except "-h" (which just prints this message):
  Receives parameters via fd_retrieve on STDIN:
  \$in = {
    sub_process_invocation_id => <id>,
    from_file_path => <from_file_path>,
    to_file_path => <to_file_path>,
  };
  Writes results to STDOUT via store_fd:
  \$out = {
    Status => OK | Error,
    message => <message> if error,
    additional_info => <optional additional info>,
  };

  Uses Posda::DiffDicom to generate a "long" and "short" difference report
  for the two files, imports the files into Posda, and creates a row in
  the "dicom_edit_compare" table for the two files.
EOF
sub Error{
  my($message, $addl) = @_;
print STDERR "#################\n" .
  "Error: $message\n" .
  "#################\n";
  my $results = {};
  $results->{Status} = "Error";
  $results->{message} = $message;
  if($addl){ $results->{additional_info} = $addl }
  store_fd($results, \*STDOUT);
  exit;
}

if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}
unless($#ARGV < 0){
  my $num_parm = @ARGV;
  Error("wrong number of params", { expected => -1, actual => $num_parm });
  print STDERR "Error: Wrong number of params\n";
}
my $edits = fd_retrieve(\*STDIN);
my $subprocess_invocation_id = $edits->{subprocess_invocation_id};
my $from_file = $edits->{from_file_path};
my $to_file = $edits->{to_file_path};
my $f_try = Posda::Try->new($from_file);
unless(exists $f_try->{dataset}){
  Error("from file is not a dataset", { file => $from_file });
  die "$from_file is not a dicom file";
}
my $t_try = Posda::Try->new($to_file);
unless(exists $t_try->{dataset}){
  Error("to file is not a dataset", { file => $to_file });
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
if($result_s =~ /File id: (.*)/){
  $short_id = $1;
}
my $result_l = `ImportSingleFileIntoPosdaAndReturnId.pl "$long_rept" "Difference report"`;
if($result_l =~ /File id: (.*)/){
  $long_id = $1;
}
#print "edit_id: $edit_id\n" .
#  "from_digest: $f_dig\n" .
#  "to_digest:   $t_dig\n" .
#  "short_id:    $short_id\n" .
#  "long_id:     $long_id\n" .
#  "###################\n$s_rept" .
#  "###################\n$l_rept" .
#  "###################\n";
my $ins = PosdaDB::Queries->GetQueryInstance(
  "InsertIntoDicomEditCompareFixed");
$ins->RunQuery(sub{}, sub{},
  $subprocess_invocation_id, $f_dig, $t_dig, $short_id, $long_id, $from_file);
my $results = {
  Status => 'OK',
};
store_fd($results, \*STDOUT);
